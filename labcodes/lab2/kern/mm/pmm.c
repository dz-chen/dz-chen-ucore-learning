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

/* *
 * Task State Segment: TSS
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
 * 
 * The field SS0 contains the stack segment selector for CPL = 0, and the ESP0
 * contains the new ESP value for CPL = 0. When an interrupt happens in protected
 * mode, the x86 CPU will look in the TSS for SS0 and ESP0 and load their value
 * into SS and ESP respectively.
 * */

// 任务状态描述符 => 定义见mmu.h
static struct taskstate ts = {0};

// virtual address of physicall page array
struct Page *pages;

// amount of physical memory (in pages)
size_t npage = 0;

// virtual address of boot-time page directory
extern pde_t __boot_pgdir;           // 整数,页目表的虚拟地址; 定义见entry.S
// boot_pgdir是页目录表的指针
pde_t *boot_pgdir = &__boot_pgdir;   // 指向页目录表的指针 => *boot_pgdir就是__boot_pgdir,boot_pgdir[0]就是第一个表项

// physical address of boot-time page directory
uintptr_t boot_cr3;   

// physical memory management 
// 物理内存管理器,结构体中包含若干函数指针,定义见pmm.h
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
pte_t * const vpt = (pte_t *)VPT;           // 32位整数,VPT的起始虚拟地址
pde_t * const vpd = (pde_t *)(PGADDR(PDX(VPT), PDX(VPT), 0));  // 页目录表的虚拟地址位置

/* *
 * Global Descriptor Table:
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
 * */
void
load_esp0(uintptr_t esp0) {
    ts.ts_esp0 = esp0;
}

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
    ts.ts_ss0 = KERNEL_DS;

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);

    // reload all segment registers
    lgdt(&gdt_pd);

    // load the TSS
    ltr(GD_TSS);
}

//init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &default_pmm_manager;          //定义见default_pmm.c
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page * alloc_pages(size_t n) {
    struct Page *page=NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
    }
    local_intr_restore(intr_flag);
    return page;
}

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

/* page_init - initialize the physical memory management */
static void page_init(void) {
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;         // 最大物理内存地址

    // 根据bios给出的物理内存布局信息,计算最大物理内存地址maxpa
    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
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

    extern char end[];

    // 计算需要管理的物理页的个数
    npage = maxpa / PGSIZE;             

    // 计算要管理的物理页的起始地址(Page结构体的起始地址)
    /* 由于bootlader加载ucore的结束地址(用全局指针变量end记录)以上的空间没有使用
     * => 对end按页向上取整后,作为页级别物理内存空间所需的Page结构的内存空间
     * 指针pages 就是Page结构体数组起始地址! */
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    // 将Page结构体数组对应空间设置为已占用(设置为kern保留,之后会修改) => 对每一页做标记
    for (i = 0; i < npage; i ++) {
        SetPageReserved(pages + i);
    }

    // 计算空闲物理内存空间的起始地址
    /**
     * => Page结构体数组以上的空间为空闲物理内存空间
     * */
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
    

    // 标记空闲物理内存空间 => 对每一页做标记
    for (i = 0; i < memmap->nr_map; i ++) {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
        if (memmap->map[i].type == E820_ARM) {
            if (begin < freemem) {
                begin = freemem;
            }
            if (end > KMEMSIZE) {
                end = KMEMSIZE;
            }
            if (begin < end) {
                begin = ROUNDUP(begin, PGSIZE);
                end = ROUNDDOWN(end, PGSIZE);
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
// 作用:将物理地址pa开始的size字节映射到虚拟地址la开始的size字节映; 但是在映射时以页为单位,且需要地址对齐
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));         // 检查:逻辑地址、物理地址对应的标志位必须相同    
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;   //计算一共映射多少个页
    la = ROUNDDOWN(la, PGSIZE);             // 地址对齐页大小的整数倍
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        // 填写逻辑地址对应页表项中的物理地址信息(20位的物理页号+标志位)
        *ptep = pa | PTE_P | perm;          // 修改页表项内容:物理页号,以及标志位(perm给这个物理页写权限)
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
void pmm_init(void) {
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);    // 将页目录表的物理地址写入boot_cr3

    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();         // 初始化物理内存管理器

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();                // 计算物理内存相关信息(帧数、最大物理内存地址),初始化空闲链表

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();         // ...

    check_pgdir();

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    // ---------- =>   设置页表(所有页表,共4MB)对应的页目录表项!!!
    // 对PTE_W的解释:只有当一级、二级页表上都设置了用户写权限后,用户才能对对应的物理地址进行读写;
    //              所以可以在一级页表先给用户写权限,再在二级页表上根据需要限制用户的访问,从而对物理页进行保护
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;   

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    // 根据传入的参数,意思是:将物理地址0~KMEMSIZE 映射到 虚拟地址KERNBASE~KERNBASE + KMEMSIZE
    //                     => 这里的目的是将内核虚拟地址映射到固定的物理内存区域
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();

    print_pgdir();

}

//get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
//  pgdir:  the kernel virtual base address of PDT => 页目录表(一级页表)的虚拟地址
//  la:     the linear address need to map         => 要查找的线性地址/虚拟地址
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
// 作用:输入要查找的虚拟/逻辑地址,返回映射这个虚拟地址的二级页表表项的地址(而不是直接返回逻辑地址对应的物理地址!)
//      如果没有对应的二级页表,则根据需要创建
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
    // #if  0  ...   #endfif的作用跟/*...*/的作用是一样的,就是注释
    #if 0
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
    pde_t *pdep=&pgdir[PDX(la)];             // 1.获取la对应页目录表项
    if((*pdep & PTE_P) == 0){                // 2.如果相与为0,说明页目录项对应的二级页表不存在,说明需要分配(entry.S中初始化时就是几乎全部为0)
        if(!create) return NULL;
        else{                                // 3.确定要分配二级页表
            struct Page* page=alloc_page();  //   给对应二级页表分配物理页空间 => 如何保证二级页表在虚拟地址0xFAC00000往上???
            if(page==NULL) return NULL;
            set_page_ref(page,1);            // 4.设置当前页(页表)的引用,只要这个页被映射了一次,引用计数必须加1
            uintptr_t pa = page2pa(page);    // 5.获取物理页对应的物理地址(实际上是物理页号)
            memset(KADDR(pa),0,PGSIZE);      // 6.新申请的物理页全部设为0,,因为这个页代表的虚拟地址都没有被映射
            *pdep=pa|PTE_U|PTE_W|PTE_P;      // 7.设置当前二级页表对应页目录表项(二级页表的物理页号+标志位)
        }
    }
    /**
     * 注:ucore中,一级页表的页表项存储二级页表的物理页号,二级页表的页表项存储数据的物理页号
     *    PDE_ADDR(*pdep)是计算当前要查找的二级页表的物理地址
     *    KADDR(PDE_ADDR(*pdep))是计算要查找的二级页表的内核虚拟地址
     *    ((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]是获取la对应的二级页表项
     *    最后取地址& 是获取la对应二级页表项的指针!
     **/
    return &(((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]); // 8.返回虚拟地址la对应的页表项
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
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
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
    if(*ptep & PTE_P){                       // 1.检查确认这个页表项存在(即页表项对应的物理内存页存在)
        struct Page* page=pte2page(*ptep);   // 2.获取对应物理内存页
        int ref=page_ref_dec(page);          // 3.减少物理页引用计数
        if(ref<=0) free_page(page);          // 4.释放引用计数为0的物理页
        *ptep=0;                             // 5.清空这个二级页表项
        tlb_invalidate(pgdir,la);            // 5.刷新tlb
    }
}

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
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
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_P) {
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page);
        }
        else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
    tlb_invalidate(pgdir, la);
    return 0;
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    if (rcr3() == PADDR(pgdir)) {
        invlpg((void *)la);
    }
}

static void
check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}

static void
check_pgdir(void) {
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

static void
check_boot_pgdir(void) {
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
static const char *
perm2str(int perm) {
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
// paramemters:
//  left:        no use ???
//  right:       the high side of table's range
//  start:       the low side of table's range
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
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
void
print_pgdir(void) {
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

