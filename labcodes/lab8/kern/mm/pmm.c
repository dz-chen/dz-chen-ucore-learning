#include <defs.h>
#include <x86.h>
#include <stdio.h>
#include <string.h>
#include <mmu.h>
#include <memlayout.h>
#include <pmm.h>
#include <default_pmm.h>
#include <sync.h>
#include <error.h>
#include <swap.h>
#include <vmm.h>
#include <kmalloc.h>

/*****************************************************************************************
 *                                      关于本文件涉及的TSS
 * 1.TSS(task state segment),是任务(进程/线程)切换时的任务现场信息.
 * 2.如何找到TSS? 
 *   => 类似于代码段、数据段.可通过寄存器TR(task register)在GDT中找到TSS的基址、限长等信息
 *      然后根据GDT中的信息在内存中找到TSS
 * 3.在ucore中主要是在陷入内核时使用(从用户态进入内核态,这个过程有栈的切换)?
 * 4.
 * **************************************************************************************/


/* *
 * Task State Segment:
 *
 * The TSS may reside anywhere in memory. A special segment register called
 * the Task Register (TR) holds a segment selector that points a valid TSS
 * segment descriptor which resides in the GDT. Therefore, to use a TSS
 * the following must be done in function gdt_init:
 *   - create a TSS descriptor entry in GDT
 *   - add enough information to the TSS in memory as needed
 *   - load the TR register with a segment selector for that segment
 *
 * There are several fileds in TSS for specifying the new stack pointer when a
 * privilege level change happens. But only the fields SS0 and ESP0 are useful
 * in our os kernel.
 *
 * The field SS0 contains the stack segment selector for CPL = 0, and the ESP0
 * contains the new ESP value for CPL = 0. When an interrupt happens in protected
 * mode, the x86 CPU will look in the TSS for SS0 and ESP0 and load their value
 * into SS and ESP respectively.
 * */
// 任务状态段 => 见mmu.h
// 这里ts用于描述当前任务的部分信息
static struct taskstate ts = {0};

// virtual address of physicall page array
// 管理物理内存的Page[]结构体数组的起始地址(不过这个指针是va)
struct Page *pages;

// amount of physical memory (in pages)
// 内核代码占用的物理页个数
size_t npage = 0;

// virtual address of boot-time page directory
extern pde_t __boot_pgdir;                    // 定义在entry.S,它是页目录表

// 页目录表的虚拟地址
pde_t *boot_pgdir = &__boot_pgdir;            // 页目录表的虚拟地址

// physical address of boot-time page directory
// 它对应cr3寄存器的内容:一级页表的位置(物理地址,而不是虚拟地址!!!)
uintptr_t boot_cr3;

// physical memory management
// 物理内存管理器
const struct pmm_manager *pmm_manager;

/* *
 * The page directory entry corresponding to the virtual address range
 * [VPT, VPT + PTSIZE) points to the page directory itself. Thus, the page
 * directory is treated as a page table as well as a page directory.
 *
 * One result of treating the page directory as a page table is that all PTEs
 * can be accessed though a "virtual page table" at virtual address VPT. And the
 * PTE for number n is stored in vpt[n].
 *
 * A second consequence is that the contents of the current page directory will
 * always available at virtual address PGADDR(PDX(VPT), PDX(VPT), 0), to which
 * vpd is set bellow.
 * */

// vpt就是第一个页表(二级页表)的起始虚地址(va)
pte_t * const vpt = (pte_t *)VPT;

// vpd是页目录表(一级页表)的起始虚地址(va) => 为什么是固定值0xFAFEB000,不应该是boot_pgdir吗?
pde_t * const vpd = (pde_t *)PGADDR(PDX(VPT), PDX(VPT), 0);  // 0xFAFEB000

/* *
 * Global Descriptor Table:
 * 在bootloader中设置的GDT只包含代码段、数据段;
 * 没有区分内核、用户,且没有TSS;
 * 进入ucore后需要重新设置GDT;不过各段的基址仍然都是0
 *
 * The kernel and user segments are identical (except for the DPL). To load
 * the %ss register, the CPL must equal the DPL. Thus, we must duplicate the
 * segments for the user and the kernel. Defined as follows:
 *   - 0x0 :  unused (always faults -- for trapping NULL far pointers)
 *   - 0x8 :  kernel code segment
 *   - 0x10:  kernel data segment
 *   - 0x18:  user code segment
 *   - 0x20:  user data segment
 *   - 0x28:  defined for tss, initialized in gdt_init
 * */
static struct segdesc gdt[] = {
    SEG_NULL,
    [SEG_KTEXT] = SEG(STA_X | STA_R, 0x0, 0xFFFFFFFF, DPL_KERNEL),
    [SEG_KDATA] = SEG(STA_W, 0x0, 0xFFFFFFFF, DPL_KERNEL),
    [SEG_UTEXT] = SEG(STA_X | STA_R, 0x0, 0xFFFFFFFF, DPL_USER),
    [SEG_UDATA] = SEG(STA_W, 0x0, 0xFFFFFFFF, DPL_USER),
    [SEG_TSS]   = SEG_NULL,
};

// GDT的长度、基址
static struct pseudodesc gdt_pd = {
    sizeof(gdt) - 1, (uintptr_t)gdt
};

static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
    asm volatile ("lgdt (%0)" :: "r" (pd));
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
}

/* *
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * 设置taskstate的esp0
 * */
void load_esp0(uintptr_t esp0) {
    ts.ts_esp0 = esp0;     
}

/***
 * gdt_init - initialize the default GDT and TSS 
 * 重新设置GDT(加入TSS; 区分内核、用户)
 * */
static void gdt_init(void) {
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);     // 保存任务栈顶
    ts.ts_ss0 = KERNEL_DS;                  // 设置堆栈段选择子

    // initialize the TSS filed of the gdt
    // 在GDT中设置任务状态段的描述符
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);

    // reload all segment registers
    // 重新加载GDTR,从而更换GDT; 同时还会重新设置各段寄存器(选择子)
    lgdt(&gdt_pd);

    // load the TSS,设置TR段寄存器(段选择子)
    ltr(GD_TSS);
}

//init_pmm_manager - initialize a pmm_manager instance
// 直接初始化为default_pmm.c中的first-fit物理内存分配法
static void init_pmm_manager(void) {
    pmm_manager = &default_pmm_manager;                       // default_pmm_manager来自default_pmm.c
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();            // 初始化空闲链表
}

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
// 此函数调用物理内存管理器的init_memmap()函数;
// 将base(va)开始的n个空闲page初始化并加入空闲链表;
// base是管理Page结构的va,而不是页面的va!!!
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
// 分配n个连续的物理页,返回第一个页的Page指针
struct Page *alloc_pages(size_t n) {
    struct Page *page=NULL;
    bool intr_flag;                // 用于存储eflags中的中断屏蔽位
    
    while (1)
    {
         local_intr_save(intr_flag);            // 关中断
         {
            page = pmm_manager->alloc_pages(n);
         }
         local_intr_restore(intr_flag);         // 开中断

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);      // 为什么?
         cprintf("------ alloc_pages failed!!! swap_out check_mm_struct... ");  // by cdz
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
// 释放Page指针base开始的n个物理页 
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);             // 关中断
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

/***
 * pmm_init - initialize the physical memory management
 * 1.从e820map中读取物理内存信息(见bootasm.S)
 * 2.初始化内核代码对应的物理页的Page[]数组
 * 3.修改内核代码占用的物理内存页的标志位(修改Page)
 * 4.将 (内核代码+Page结构体数组)往上 ~  KMEMSIZE 这段范围的物理内存加入空闲链表
 * */
static void page_init(void) {
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);  // 存放在物理地址0x8000开始的地方
    uint64_t maxpa = 0;           // 最大物理内存地址

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
        // %llx:有符号64位16进制整数
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
        maxpa = KMEMSIZE;
    }

    extern char end[];              // 定义在lernel.ld

    npage = maxpa / PGSIZE;         // 内核占用的物理内存页个数

    // end 是内核代码占用的空间的末尾(va)
    // 再往上存放的是管理物理内存的Page[]数组
    // 指针pages 就是Page结构体数组起始地址(va)! 
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {              // 设置所有内核占用的物理页的标志位(reserved,见struct Page)
        SetPageReserved(pages + i);
    }

    // 内核代码+Page结构体数组  往上的物理地址(pa)
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    // 将属于内核,但是尚未使用的物理内存空间初始化并加入空闲链表
    // 这段区域的物理范围: (内核代码+Page结构体数组)往上 ~  KMEMSIZE
    for (i = 0; i < memmap->nr_map; i ++) {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
        if (memmap->map[i].type == E820_ARM) {              // memory, available to OS
            if (begin < freemem) {
                begin = freemem;                           
            }
            if (end > KMEMSIZE) {
                end = KMEMSIZE;
            }
            if (begin < end) {
                begin = ROUNDUP(begin, PGSIZE);     // pa
                end = ROUNDDOWN(end, PGSIZE);       // pa
                if (begin < end) {
                    /**
                     * 将空闲物理页对应的Page结构中的flags和引用计数ref清0,
                     * 并加到free_area.free_list指向的双向列表中,为将来的空闲页管理做好初始化准备工作
                     * */
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}

//boot_map_segment - setup&enable the paging mechanism
// parameters
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
// 将虚拟地址la开始的size个字节,映射到从物理地址pa开始...
// 由于权限控制以page为单位,所以size不是整页大小时,需要取整到PGSIZE
// 这个过程需要修页目录表、页表
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
        pte_t *ptep = get_pte(pgdir, la, 1);    // 获取二级页表项的指针
        assert(ptep != NULL);
         // 填写逻辑地址对应页表项中的物理地址信息(20位的物理页号+标志位)
        *ptep = pa | PTE_P | perm;   // 修改页表项内容:物理页号,以及标志位(perm给这个物理页写权限)
    }
}

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
    struct Page *p = alloc_page();
    if (p == NULL) {
        panic("boot_alloc_page failed.\n");
    }
    return page2kva(p);
}

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
// 被init.c中kern_init()函数调用
// 执行pmm_init开始,进入地址映射的第三个阶段(一二阶段见entry.S)
// 主要作用:初始化物理内存管理器、完善段表、页目录表、页表
void pmm_init(void) {
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);   // 将页目录表的物理地址写入boot_cr3

    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();             // 初始化物理内存管理器 => 此为first-fit(default_pmm.c)

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();   // 计算物理内存相关信息(帧数、最大物理内存地址); 修改Page数组;初始化空闲链表

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();  // 调用default_check()检查default_pmm.c中所有函数是否正确

    check_pgdir();       // 检查boot_pgdir、以及页表是否正确

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    // ---------- =>   设置页表(所有页表,共4MB)对应的页目录表项!!!
    // 对PTE_W的解释:只有当一级、二级页表上都设置了用户写权限后,用户才能对对应的物理地址进行读写;
    //              所以可以在一级页表先给用户写权限,再在二级页表上根据需要限制用户的访问,从而对物理页进行保护
    // 这句的理解:所有页表共4MB,对应1024个page,也即对应页目录表中的一个表项; 下面即设置这4MB对应的一级页表
    // 更多理解,详见实验笔记"自映射机制"
    // 还是未懂 ???
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;   

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    // 根据传入的参数,意思是:将物理地址0~KMEMSIZE 映射到 虚拟地址KERNBASE~KERNBASE + KMEMSIZE
    // 从而将内核虚拟地址映射到固定的物理内存区域
    // => 这一步就是给内核代码空间(虚拟空间)分配物理内存!
    // 为什么这里只映射KMEMSIZE大小,这样不是就没有映射0xFAC00000(va)处4MB的页表了吗??
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    // 重新设置GDT(不再使用bootloader中设置的GDT)
    gdt_init();

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();                 // 一些检查工作

    print_pgdir();                      // 打印页目录表 和 页表内容
    
    // 很重要,暂未看!
    kmalloc_init();

}

//get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
//  pgdir:  the kernel virtual base address of PDT => 页目录表(一级页表)的虚拟地址
//  la:     the linear address need to map         =>  要查找的线性地址/虚拟地址
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
// 作用:输入要查找的虚拟/线性地址,返回映射这个虚拟地址的二级页表表项的指针
//      如果没有对应的二级页表,则根据需要创建 => 需要修改页目录表
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    /* LAB2 EXERCISE 2: YOUR CODE
     *
     * If you need to visit a physical address, please use KADDR()
     * please read pmm.h for useful macros
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
     *   KADDR(pa) : takes a physical address and returns the corresponding kernel virtual address.
     *   set_page_ref(page,1) : means the page be referenced by one time
     *   page2pa(page): get the physical address of memory which this (struct Page *) page  manages
     *   struct Page * alloc_page() : allocation a page
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
    #if 0                      // #if 0 ....#endif 起注释的作用
        pde_t *pdep = NULL;   // (1) find page directory entry
        if (0) {              // (2) check if entry is not present
                            // (3) check if creating is needed, then alloc page for page table
                            // CAUTION: this page is used for page table, not for common data page
                            // (4) set page reference
            uintptr_t pa = 0; // (5) get linear address of page
                            // (6) clear page content using memset
                            // (7) set page directory entry's permission
        }
        return NULL;          // (8) return page table entry
    #endif
    pde_t* pdep=&pgdir[PDX(la)];                // (1) 获取一级页表项
    if((*pdep & PTE_P==0)){                     // (2) 判断该一级页表项是否存在(或者说是判断对应的二级页表是否存在)
        if(create){                             
            struct Page* page=alloc_pages(1);   // (3) 创建页表(该一级页表项对应二级页表)
            if(page==NULL) return NULL;
            set_page_ref(page,1);               // (4) 设置对页表的引用(页目录项中会引用它)  
            uintptr_t la=KADDR(page2pa(page));  // (5) 获取新分配页的线性地址(va/la)   
            memset((void*)la,0,PGSIZE);         // (6) 清空新分配的页表中的内容 => 所有二级页表项置0
            *pdep=page2pa(page)|PTE_W|PTE_P|PTE_U; //(7)设置页目录表权限
        }
        else return NULL;
    }
    /**
     * 注:ucore中,一级页表的页表项存储二级页表的物理页号,二级页表的页表项存储数据的物理页号
     *    PDE_ADDR(*pdep)是计算当前要查找的二级页表的物理地址
     *    KADDR(PDE_ADDR(*pdep))是计算要查找的二级页表的内核虚拟地址
     *    ((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]是获取la对应的二级页表项
     *    最后取地址& 是获取la对应二级页表项的指针!
     **/
    return &(((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]); // (8) 返回虚拟地址la对应的页表项指针
}

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep_store != NULL) {
        *ptep_store = ptep;
    }
    if (ptep != NULL && *ptep & PTE_P) {
        return pte2page(*ptep);
    }
    return NULL;
}

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
// 删除(la,ptep)对应的地址映射
// => 1.在二级页表中清空虚拟地址(la/va)对应的页表项ptep
//    2.在Page[]结构体数组中删除虚拟地址(la/va)对应的信息
//    3.刷新快表(TLB)
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    /* LAB2 EXERCISE 3: YOUR CODE
     *
     * Please check if ptep is valid, and tlb must be manually updated if mapping is updated
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   struct Page *page pte2page(*ptep): get the according page from the value of a ptep
     *   free_page : free a page
     *   page_ref_dec(page) : decrease page->ref. NOTICE: ff page->ref == 0 , then this page should be free.
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
    #if 0
        if (0) {                      //(1) check if this page table entry is present
            struct Page *page = NULL; //(2) find corresponding page to pte
                                    //(3) decrease page reference
                                    //(4) and free this page when page reference reachs 0
                                    //(5) clear second page table entry
                                    //(6) flush tlb
        }
    #endif
    if(*ptep && PTE_P){                     // (1).检查该页表项是否存在
        struct Page* page=pte2page(*ptep);  // (2).找到对应物理页Page结构
        int ref=page_ref_dec(page);         // (3).对该物理页的引用数-1
        if(ref<=0)                          // (4).如果该页没有任何引用,释放page
            free_page(page);
        *ptep=0;                            // (5).清空二级页表项
        tlb_invalidate(pgdir,la);           // (6).刷新TLB
    }
}

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue ;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
}

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    start = ROUNDDOWN(start, PTSIZE);
    do {
        int pde_idx = PDX(start);
        if (pgdir[pde_idx] & PTE_P) {
            free_page(pde2page(pgdir[pde_idx]));
            pgdir[pde_idx] = 0;
        }
        start += PTSIZE;
    } while (start != 0 && start < end);
}
/* copy_range - copy content of memory (start, end) of one process A to another process B
 * @to:    the addr of process B's Page Directory
 * @from:  the addr of process A's Page Directory
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue ;
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
        uint32_t perm = (*ptep & PTE_USER);
        //get page from ptep
        struct Page *page = pte2page(*ptep);
        // alloc a page for process B
        struct Page *npage=alloc_page();
        assert(page!=NULL);
        assert(npage!=NULL);
        int ret=0;
        /* LAB5:EXERCISE2 YOUR CODE
         * replicate content of page to npage, build the map of phy addr of nage with the linear addr start
         *
         * Some Useful MACROs and DEFINEs, you can use them in below implementation.
         * MACROs or Functions:
         *    page2kva(struct Page *page): return the kernel vritual addr of memory which page managed (SEE pmm.h)
         *    page_insert: build the map of phy addr of an Page with the linear addr la
         *    memcpy: typical memory copy function
         *
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
        assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}

//page_remove - free an Page which is related linear address la and has an validated pte
// 删除虚拟地址(la)所在页对应的地址映射
void page_remove(pde_t *pgdir, uintptr_t la) {
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep != NULL) {
        page_remove_pte(pgdir, la, ptep);
    }
}

//page_insert - build the map of phy addr of an Page with the linear addr la
// paramemters:
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
// 完成page指针对应的物理页与la对应的虚拟页的映射 => 需要修改二级页表
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);        // 返回la对应的二级页表项
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_P) {                       // 如果la对应的物理页存在
        struct Page *p = pte2page(*ptep);
        if (p == page) {          // 1.la与page原本就存在映射关系 => 不需要增加引用次数
            page_ref_dec(page);
        }   
        else {                    // 2.la与page原来不存在映射关系,删除(la,ptep)对应的地址映射,在下面重新设置地址映射
            page_remove_pte(pgdir, la, ptep);  
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;       // 修改二级页表项
    tlb_invalidate(pgdir, la);
    return 0;
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
// 取消虚拟地址la在TLB中对应的表项
// 注:TLB由硬件实现,存储虚拟地址 => 物理地址的直接映射 !!!
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    if (rcr3() == PADDR(pgdir)) {               // 确认输入的页目录表是否为当前使用的页目录表
        invlpg((void *)la);
    }
}

/**
 * pgdir_alloc_page 
 * - call alloc_page & page_insert functions to allocate a page size memory 
 * - & setup an addr map pa<->la with linear address la and the PDT pgdir
 * 1.给虚拟地址la分配对应的物理页面
 * 2.完成la与物理页面的映射(通过page_insert)
 * */
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
    struct Page *page = alloc_page();           // 分配物理页
    if (page != NULL) {
        if (page_insert(pgdir, page, la, perm) != 0) {
            free_page(page);
            return NULL;
        }
        if (swap_init_ok){
            if(check_mm_struct!=NULL) {
                swap_map_swappable(check_mm_struct, la, page, 0);
                page->pra_vaddr=la;
                assert(page_ref(page) == 1);
                //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
            } 
            else  {  //now current is existed, should fix it in the future
                //swap_map_swappable(current->mm, la, page, 0);
                //page->pra_vaddr=la;
                //assert(page_ref(page) == 1);
                //panic("pgdir_alloc_page: no pages. now current is existed, should fix it in the future\n");
            }
        }

    }

    return page;
}


// 调用default_check()检查default_pmm.c中所有函数是否正确
static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}

// 检查boot_pgdir、以及页表是否正确
static void check_pgdir(void) {
    assert(npage <= KMEMSIZE / PGSIZE);
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert(page_ref(p1) == 1);

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);

    p2 = alloc_page();
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(*ptep & PTE_U);
    assert(*ptep & PTE_W);
    assert(boot_pgdir[0] & PTE_U);
    assert(page_ref(p2) == 1);

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
    assert(page_ref(p1) == 2);
    assert(page_ref(p2) == 0);
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);

    page_remove(boot_pgdir, 0x0);
    assert(page_ref(p1) == 1);
    assert(page_ref(p2) == 0);

    page_remove(boot_pgdir, PGSIZE);
    assert(page_ref(p1) == 0);
    assert(page_ref(p2) == 0);

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
    free_page(pde2page(boot_pgdir[0]));
    boot_pgdir[0] = 0;

    cprintf("check_pgdir() succeeded!\n");
}

// 检查页目录表
static void check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));

    assert(boot_pgdir[0] == 0);

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
    assert(page_ref(p) == 2);

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);

    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);

    free_page(p);
    free_page(pde2page(boot_pgdir[0]));
    boot_pgdir[0] = 0;

    cprintf("check_boot_pgdir() succeeded!\n");
}

//perm2str - use string 'u,r,w,-' to present the permission
static const char *perm2str(int perm) {
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
    str[1] = 'r';
    str[2] = (perm & PTE_W) ? 'w' : '-';
    str[3] = '\0';
    return str;
}

//get_pgtable_items - In [left, right] range of PDT or PT, find a continuous linear addr space
//                  - (left_store*X_SIZE~right_store*X_SIZE) for PDT or PT
//                  - X_SIZE=PTSIZE=4M, if PDT; X_SIZE=PGSIZE=4K, if PT
// 不重要,只是用于测试...
// paramemters:
//  left:        no use ???
//  right:       the high side of table's range
//  start:       the low side of table's range
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
    }
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
            start ++;
        }
        if (right_store != NULL) {
            *right_store = start;
        }
        return perm;
    }
    return 0;
}

//print_pgdir - print the PDT&PT
// 打印页目录表和页表内容 => 对打印内容的介绍参考lab2实验笔记"ucore自映射的实现"
void print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
}
