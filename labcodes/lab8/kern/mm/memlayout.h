#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* This file contains the definitions for memory management in our OS. */

/* global segment number
 * 对比bootasm.S中gdt的初始化
 */
#define SEG_KTEXT   1                       // 段选择子(编号);每个编号的段描述符在GDT中占8字节
#define SEG_KDATA   2
#define SEG_UTEXT   3
#define SEG_UDATA   4
#define SEG_TSS     5

/* global descrptor numbers */
#define GD_KTEXT    ((SEG_KTEXT) << 3)      // kernel text => 内核代码段的选择子(准确说是相对于GDT的偏移);
#define GD_KDATA    ((SEG_KDATA) << 3)      // kernel data    <<8就是为了由编号计算偏移
#define GD_UTEXT    ((SEG_UTEXT) << 3)      // user text
#define GD_UDATA    ((SEG_UDATA) << 3)      // user data
#define GD_TSS      ((SEG_TSS) << 3)        // task segment selector

#define DPL_KERNEL  (0)
#define DPL_USER    (3)

#define KERNEL_CS   ((GD_KTEXT) | DPL_KERNEL)
#define KERNEL_DS   ((GD_KDATA) | DPL_KERNEL)
#define USER_CS     ((GD_UTEXT) | DPL_USER)
#define USER_DS     ((GD_UDATA) | DPL_USER)

/* *
 * Virtual memory map:                                          Permissions
 *                                                              kernel/user
 *
 *     4G ------------------> +---------------------------------+
 *                            |                                 |
 *                            |         Empty Memory (*)        |
 *                            |                                 |
 *                            +---------------------------------+ 0xFB000000
 *                            |   Cur. Page Table (Kern, RW)    | RW/-- PTSIZE:4096*1024,页表
 *     VPT -----------------> +---------------------------------+ 0xFAC00000
 *                            |        Invalid Memory (*)       | --/--
 *     KERNTOP -------------> +---------------------------------+ 0xF8000000
 *                            |                                 |
 *                            |    Remapped Physical Memory     | RW/-- KMEMSIZE:0x38000000 前1MB是bootloader、BIOS等;
 *                            |                                 | 然后是ucore; 然后是Page[]数组
 *     KERNBASE ------------> +---------------------------------+ 0xC0000000
 *                            |        Invalid Memory (*)       | --/--
 *     USERTOP -------------> +---------------------------------+ 0xB0000000
 *                            |           User stack            |
 *                            +---------------------------------+
 *                            |                                 |
 *                            :                                 :
 *                            |         ~~~~~~~~~~~~~~~~        |
 *                            :                                 :
 *                            |                                 |
 *                            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *                            |       User Program & Heap       |
 *     UTEXT ---------------> +---------------------------------+ 0x00800000
 *                            |        Invalid Memory (*)       | --/--
 *                            |  - - - - - - - - - - - - - - -  |
 *                            |    User STAB Data (optional)    |
 *     USERBASE, USTAB------> +---------------------------------+ 0x00200000
 *                            |        Invalid Memory (*)       | --/--
 *     0 -------------------> +---------------------------------+ 0x00000000
 * (*) Note: The kernel ensures that "Invalid Memory" is *never* mapped.
 *     "Empty Memory" is normally unmapped, but user programs may map pages
 *     there if desired.
 *
 * */

/* All physical memory mapped at this address */
#define KERNBASE            0xC0000000                  // 内核的虚拟起始地址
#define KMEMSIZE            0x38000000                  // 内核占用的物理内存字节数(不含用户空间)
#define KERNTOP             (KERNBASE + KMEMSIZE)

/* *
 * Virtual page table. Entry PDX[VPT] in the PD (Page Directory) contains
 * a pointer to the page directory itself, thereby turning the PD into a page
 * table, which maps all the PTEs (Page Table Entry) containing the page mappings
 * for the entire virtual address space into that 4 Meg region starting at VPT.
 * VPT:页表的起始地址(va)
 * */
#define VPT                 0xFAC00000

#define KSTACKPAGE          2                           // # of pages in kernel stack
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack

#define USERTOP             0xB0000000
#define USTACKTOP           USERTOP
#define USTACKPAGE          256                         // # of pages in user stack
#define USTACKSIZE          (USTACKPAGE * PGSIZE)       // sizeof user stack

#define USERBASE            0x00200000
#define UTEXT               0x00800000                  // where user programs generally begin
#define USTAB               USERBASE                    // the location of the user STABS data structure

#define USER_ACCESS(start, end)                     \
(USERBASE <= (start) && (start) < (end) && (end) <= USERTOP)

#define KERN_ACCESS(start, end)                     \
(KERNBASE <= (start) && (start) < (end) && (end) <= KERNTOP)

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t;
typedef uintptr_t pde_t;
typedef pte_t swap_entry_t; //the pte can also be a swap entry

// some constants for bios interrupt 15h AX = 0xE820
#define E820MAX             20      // number of entries in E820MAP
#define E820_ARM            1       // address range memory
#define E820_ARR            2       // address range reserved

/**
 * 结构体e820map描述符了物理内存的信息
 * 在bootloader中通过BIOS探测物理内存,并将其按照emap820格式存放到固定位置(0x8000处),之后由os使用
 * 探测过程见bootasm.S
 * **/
struct e820map {
    int nr_map;          // 总的有多少个物理内存区域 => map[0]、map[1]....map[nr_map-1],最多E820MAX个
    struct {             // 地址范围描述符(数组) => 一个数组,每个项描述了一段物理内存
        uint64_t addr;   // 物理内存基址,8byte
        uint64_t size;   // 物理内存大小,8byte
        uint32_t type;   // 类型,4byte       => 见page_init()函数,会打印物理内存区域的类型
        /************************ 关于上面type的取值解释如下
         *  01h    memory, available to OS
         *  02h    reserved, not available (e.g. system ROM, memory-mapped device)
         *  03h    ACPI Reclaim Memory (usable by OS after reading ACPI tables)
         *  04h    ACPI NVS Memory (OS is required to save this memory between NVS sessions)
         *  other  not defined yet -- treat as Reserved
         * *************************************************************/
    } __attribute__((packed)) map[E820MAX];
};

/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as phyical address.
 * 描述物理页的数据结构
 * 一个空闲块由多个物理页组成
 * 通过空闲链表链接空闲块(而不是页!!!)
 * */
struct Page {
    int ref;                        // 若某页表项设置了虚拟页到这个物理页的映射,ref会+1
    uint32_t flags;                 // => 见PG_property、 PG_reserved
    // flags有32bit,目前只用到两个bit
    // bit 0(PG_reserved)表示此页是否被保留 =>PG_reserved为1:表示此页保留给操作系统使用,不能被分配、释放
    //                                      PG_reserved为0:表示此页可正常分配、使用、释放
    // bit 1(PG_property)表示此页是否为空闲区域的第一个page
    //                                     =>PG_property为1:此页是一个空闲区域的第一个page,且可以被分配;
    //                                       PG_property为0:如果此页是一个区域的第一个页,则此区域已经分配
    //                                                      如果不是一个区域的第一个页,这个标志位没有意义               

    unsigned int property;          // the num of free block, used in first fit pm manager
    // property用于记录某连续物理内存空闲块的大小(page个数),空闲块的第一个page才会使用这个字段 
    // => 非第一个page需要设置为0!!  
    // ===> 这种做法与redbase的记录管理非常相似....
    
    list_entry_t page_link;         // free list link
    // 双向链表page_link,连接连续的物理内存空闲块,空闲块的第一个page才会使用这个字段!! 连接的是空闲块而不是页帧!

    list_entry_t pra_page_link;     // used for pra (page replace algorithm)
    uintptr_t pra_vaddr;            // used for pra (page replace algorithm)
};

/* Flags describing the status of a page frame */
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

/*** 
 * 下面操作:设置指定page的flag标志中某些位
 *  这些位操作是原子的! => 见libs/atomic.h
**/
#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))

// convert list entry to page
// 输入结点le,它对应page结构体的pae_link成员(member),据此得到整个结构体的指针
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)

/**
 * free_area_t - maintains a doubly linked list to record free (unused) pages 
 * 描述空闲链表的数据结构
 * - free_list:第一个空闲区域(链表项)
 * - nr_free:链表中总共的空闲页数
 * */
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;


#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */

