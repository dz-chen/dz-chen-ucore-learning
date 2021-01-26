#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* This file contains the definitions for memory management in our OS. */

/* global segment number */
#define SEG_KTEXT   1
#define SEG_KDATA   2
#define SEG_UTEXT   3
#define SEG_UDATA   4
#define SEG_TSS     5

/* global descrptor numbers */
#define GD_KTEXT    ((SEG_KTEXT) << 3)      // kernel text
#define GD_KDATA    ((SEG_KDATA) << 3)      // kernel data
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
 *                            |   Cur. Page Table (Kern, RW)    | RW/-- PTSIZE => 这部分存放页表,共4MB
 *     VPT -----------------> +---------------------------------+ 0xFAC00000
 * 
 *                            |        Invalid Memory (*)       | --/--
 *     KERNTOP -------------> +---------------------------------+ 0xF8000000
 *                            |                                 |
 *                            |    Remapped Physical Memory     | RW/-- KMEMSIZE
 *                            |                                 |
 *     3G KERNBASE ---------> +---------------------------------+ 0xC0000000
 *                            |                                 |
 *                            |                                 |
 *                            |                                 |
 *                            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * (*) Note: The kernel ensures that "Invalid Memory" is *never* mapped.
 *     "Empty Memory" is normally unmapped, but user programs may map pages
 *     there if desired.
 *
 * */

/* All physical memory mapped at this address */
#define KERNBASE            0xC0000000                  // 3GB处,即虚拟地址的3G往上映射给内核(当然,不是3-4G全部,详见上面示意图)
#define KMEMSIZE            0x38000000                  // 896MB,内核最多能占用的虚拟/物理内存大小; the maximum amount of physical memory
#define KERNTOP             (KERNBASE + KMEMSIZE)       // 内核的虚拟地址上界; KMEMSIZE的大小只是一个设定,可以改变
/**
 * 注:虽然KERNBASE被设置为0xC0000000,但内核真正的起始虚拟地址是0xC0100000 (见kernel.ld)
 *    0xC0000000~0xC0100000恰好1MB,恰好对应物理地址0~1MB中的BIOS、bootloader等内容...
 *    0xC0100000往上才是内核代码(即物理地址1MB往上的代码)
 *    by cdz 11.17 
 * */


/* *
 * Virtual page table. Entry PDX[VPT] in the PD (Page Directory) contains
 * a pointer to the page directory itself, thereby turning the PD into a page
 * table, which maps all the PTEs (Page Table Entry) containing the page mappings
 * for the entire virtual address space into that 4 Meg region starting at VPT.
 * */
#define VPT                 0xFAC00000

#define KSTACKPAGE          2                           // 内核栈的大小为8kb,即两个page
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack =8kb

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t;
typedef uintptr_t pde_t;

// some constants for bios interrupt 15h AX = 0xE820
#define E820MAX             20      // number of entries in E820MAP
#define E820_ARM            1       // address range memory
#define E820_ARR            2       // address range reserved

// 地址范围描述符(加了nr_map字段)
struct e820map {
    int nr_map; // 当前是第几个map,从0开始编号
    struct {   // 地址范围描述符
        uint64_t addr;          //基址,8byte
        uint64_t size;          //大小,8byte
        uint32_t type;          //类型,4byte
        /************************ 关于上面type的取值解释如下
         *  01h    memory, available to OS
         *  02h    reserved, not available (e.g. system ROM, memory-mapped device)
         *  03h    ACPI Reclaim Memory (usable by OS after reading ACPI tables)
         *  04h    ACPI NVS Memory (OS is required to save this memory between NVS sessions)
         *  other  not defined yet -- treat as Reserved
         * 
         * *************************************************************/
    } __attribute__((packed)) map[E820MAX];
};

/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as phyical address.
 * */
// 描述物理页(帧)的结构体
struct Page {
    // 若某个页表项设置了某个虚拟页到这个物理页帧的映射,ref会+1
    int ref;                        // page frame's reference counter
    //  flags有32bit,目前只用到两个bit
    // bit 0表示此页是否被保留 => bit 0 为1表示此页保留给操作系统使用;不能放到空闲页链表中
    // bit 1表示此页是否是free的 => bit 1为1表示此页free,可以被分配;否则表示已经分配了
    uint32_t flags;                 // array of flags that describe the status of the page frame => 见PG_property、 PG_reserved
    // 用于记录某连续物理内存空闲块的大小(个数),空闲块的第一个page才会使用这个字段 => 非第一个page需要设置为0!!
    unsigned int property;          // the num of free block, used in first fit pm manager
    // 双向链表,连接连续的物理内存空闲块,空闲块的第一个page才会使用这个字段!! 连接的是空闲块而不是页帧!
    list_entry_t page_link;         // free list link
};

/* Flags describing the status of a page frame */
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))

// convert list entry to page
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)



/* 双向空闲链表,以空闲块为链接单位(而不是空闲页) */
/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header => 链表头
    unsigned int nr_free;           // # of free pages in this free list => 空闲链表中的总页数
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */

