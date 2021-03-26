#include <vmm.h>
#include <sync.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <error.h>
#include <pmm.h>
#include <x86.h>
#include <swap.h>
#include <kmalloc.h>

/**********************************************************************************************
 *                                   虚拟内存管理
 * .一些关键函数
 *      vmm_init() => 检查mm_struct、vma_struct数据结构是否正常;检查do_pgfault是否正常
 *      do_pgfault() => 处理页故障(注意有哪三类页故障)
 * 
 * 
 * *******************************************************************************************/

/* 
  vmm design include two parts: mm_struct (mm) & vma_struct (vma)
  mm is the memory manager for the set of continuous virtual memory  
  area which have the same PDT. vma is a continuous virtual memory area.
  There a linear link list for vma & a redblack link list for vma in mm.
---------------
  mm related functions:
   golbal functions
     struct mm_struct * mm_create(void)
     void mm_destroy(struct mm_struct *mm)
     int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr)
--------------
  vma related functions:
   global functions
     struct vma_struct * vma_create (uintptr_t vm_start, uintptr_t vm_end,...)
     void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
     struct vma_struct * find_vma(struct mm_struct *mm, uintptr_t addr)
   local functions
     inline void check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
---------------
   check correctness functions
     void check_vmm(void);
     void check_vma_struct(void);
     void check_pgfault(void);
*/

static void check_vmm(void);
static void check_vma_struct(void);
static void check_pgfault(void);

/**
 * mm_create -  alloc a mm_struct & initialize it.
 * 动态分配(kmalloc)并初始化一个mm_struct,返回其指针
 * 为什么要动态分配?直接创建一个不行吗 =>
 *  1.直接创建是在栈上分配,函数退出后就不能被访问.而动态分配在堆上,函数退出后还可继续使用;
 *  2.当然也可以选择让需要的mm_struct是全局变量,既不再堆上,也不在栈上,而是在特定的内存段上!
 *  3.但是全局变量导致不能按需释放,不会再次使用的mm_struct也得占用内存空间
 * */
struct mm_struct *mm_create(void) {
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));  // 分配一个mm_struct大小的物理内存空间

    if (mm != NULL) {
        list_init(&(mm->mmap_list));    // 初始化链表头结点(不含数据)
        mm->mmap_cache = NULL;
        mm->pgdir = NULL;
        mm->map_count = 0;

        if (swap_init_ok) swap_init_mm(mm);
        else mm->sm_priv = NULL;
        
        set_mm_count(mm, 0);            // 设置共线mm的线程数
        sem_init(&(mm->mm_sem), 1);     // 设置mm对应的信号量,这里是互斥信号量,主要在创建子线程时使用
    }    
    return mm;
}

/**
 * vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
 * 动态分配一个vma_struct,并用参数vm_start、vm_end等对其初始化
 * 返回分配的堆上内存指针(不过这里是从内核中分配的..)
 * */
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));

    if (vma != NULL) {
        vma->vm_start = vm_start;
        vma->vm_end = vm_end;
        vma->vm_flags = vm_flags;
    }
    return vma;
}


/**
 * find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
 * 遍历mm的链表mmap_list,查找虚拟地址addr所在的vma
 * */
struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr) {
    struct vma_struct *vma = NULL;
    if (mm != NULL) {
        vma = mm->mmap_cache;
        // 查找addr所在的vma,并将mmap_cache设置找到的vma
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
                    vma = le2vma(le, list_link);
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    vma = NULL;
                }
        }
        if (vma != NULL) {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}


/**
 * check_vma_overlap - check if vma1 overlaps vma2 ?
 * 检查是否满足(prev->start) < (prev->end) <= (next->start) < (next->end)
 * */
static inline void check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
}


/** 
 * insert_vma_struct -insert vma in mm's list link
 * 将vma插入到mm的链表mmap_list中
 * (链表按照每个vma的起始虚拟地址排序)
 * */
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

    list_entry_t *le = list;
    // 遍历链表,寻找插入位置
    while ((le = list_next(le)) != list) {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start) {
            break;
        }
        le_prev = le;
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
    }
    if (le_next != list) {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
}

/**
 * mm_destroy - free mm and mm internal fields
 * 释放mm对应的堆空间(kfree完成);会自动释放mm的链表mmap_list(vma)占用的空间
 * */
void mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
    mm=NULL;
}

/**
 * 为虚拟地址addr开始,长度为len字节的虚拟段创建vma结构,将其加入到mm中;
 * 在proc.c中,被load_icode调用
 */ 
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
    if (!USER_ACCESS(start, end)) {
        return -E_INVAL;
    }

    assert(mm != NULL);

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
        goto out;
    }
    ret = -E_NO_MEM;

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;

out:
    return ret;
}

/**
 * 将from这个mm_struct复制给to这个mm_struct
 * 注意:
 * 1.不能直接memcpy(),因为涉及很多链表的问题..
 * 2.对copy_range()的调用! => from用户空间的内容拷贝到to用户空间
 * 只有新旧线程属于不同的进程才会调用dup_mm...
 */ 
int dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;   // 这个mmap_list连接了所有vma_struct
    while ((le = list_prev(le)) != list) {
        // 1.复制vma_struct
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
        
        // 2.复制用户空间的内容
        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
}


/**
 * 回收mm_struct对应的[用户]内存空间
 * 1.第一次遍历,解除所有vma_struct的地址映射,并回收对应的物理页
 * 2.第二次遍历,回收所有vma_struct对应的二级页表
 */ 
void exit_mmap(struct mm_struct *mm) {
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    // 第一次遍历,解除vma_struct对应的地址映射、以及物理页
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    // 第二次遍历,回收vma_struct对应的页表
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}


bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
        return 0;
    }
    memcpy(dst, src, len);
    return 1;
}

/**
 * 将数据从内核空间拷贝到用户空间
 * fs/sysfile.c/sysfile_read(...)
 */  
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
        return 0;
    }
    memcpy(dst, src, len);
    return 1;
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
// 初始化虚拟内存管理(主要是检查相关数据结构及函数是否正常)
void vmm_init(void) {
    check_vmm();
}

// check_vmm - check correctness of vmm
// 检查虚拟内存管理(测试mm_struct、vma_struct及其相关函数)
static void check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();      // 剩余的空闲物理内存页数量;
    // 测试大约是31883,仅供内核使用,不过尚未分配使用...
    
    check_vma_struct();        // 测试mm_struct、vma_struct及其相关函数            
    check_pgfault();

    cprintf("check_vmm() succeeded.\n");
}

/***
 * 编写代码分配mm、vma测试两个基础数据结构以及相关函数是否正常
 * */
static void check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();     // 动态分配并初始化一个mm_struct
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0); // 创建并初始化vma
        assert(vma != NULL);
        insert_vma_struct(mm, vma);                        //vma插入mm的有序链表
    }

    for (i = step1 + 1; i <= step2; i ++) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {             //遍历mm的链表,检查分配的虚拟内存段是否正确
        assert(le != &(mm->mmap_list));
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {       // 检查所有vma
        struct vma_struct *vma1 = find_vma(mm, i);
        assert(vma1 != NULL);
        struct vma_struct *vma2 = find_vma(mm, i+1);
        assert(vma2 != NULL);
        struct vma_struct *vma3 = find_vma(mm, i+2);
        assert(vma3 == NULL);
        struct vma_struct *vma4 = find_vma(mm, i+3);
        assert(vma4 == NULL);
        struct vma_struct *vma5 = find_vma(mm, i+4);
        assert(vma5 == NULL);

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
        struct vma_struct *vma_below_5= find_vma(mm,i);
        if (vma_below_5 != NULL ) {
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);         // 释放mm以及所有vma

    cprintf("check_vma_struct() succeeded!\n");
}

struct mm_struct *check_mm_struct;
/**
 * check_pgfault - check correctness of pgfault handler
 * 测试代码--检查页故障处理器 
 * => 缺页时自动发生缺页故障,跳转到trap.c中执行相应代码...
 * 这里是vmm的重点,务必找到缺页的位置,往下分析...
 * */
static void check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
    assert(pgdir[0] == 0);

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);   // 创建一个vma
    assert(vma != NULL);

    insert_vma_struct(mm, vma);

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);     // 检验0x100是否在刚设置的vma中 


    // nr_free_pages() => 此时应该为31882;但是因为缺页异常时,没有二级页表和对应物理页,需要分配两个物理页
    //                    执行下面for循环后,nr_free_pages()就该变为31880
    // 在下面的第一个for开始时处发生缺页异常,会转而执行trap()函数
    //    => 因为虚拟地址0x100(addr+0)在页表中没有对应的映射
    //       pmm.c中的pmm_init()调用boot_map_segment()时,仅仅给KERNBASE~KERNBASE+KMEMSIZE的虚拟地址映射了物理内存
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);

    // nr_free_pages() => 此时应该为31880;但是执行page_remove()后,会释放addr对应的物理页
    //                    所以page_remove(pgdir, ROUNDDOWN(addr, PGSIZE))后;会变成31881
    // 删除addr对应虚拟页的地址映射(缺页异常时完成的映射...)
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));  
    
    // nr_free_pages() => 此时应该为31881;但是执行free_page()会释放第一个页表的物理页(addr的页表)
    //                    所以free_page(pde2page(pgdir[0]))后;会变成31882
    // 删除的是什么? => 释放第一个页表的物理内存
    free_page(pde2page(pgdir[0]));
    // nr_free_pages()    => 此时应该为31882
    pgdir[0] = 0;
    
    mm->pgdir = NULL;
    mm_destroy(mm);
    check_mm_struct = NULL;

    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_pgfault() succeeded!\n");
}


//page fault number => 发生页故障的次数
volatile unsigned int pgfault_num=0;

/**
 *  do_pgfault - interrupt handler to process the page fault execption
 * => 处理页故障,在trap.c中被调用(trap--> trap_dispatch-->pgfault_handler-->do_pgfault)
 * 什么时候发生页故障?
 * 目标页不存在(未给虚拟地址映射物理地址)、不满足访问权限、相应的物理页帧不再内存(被换到了swap)
 * -mm         : the control struct for a set of vma using the same PDT
 * -error_code : the error code recorded in trapframe->tf_err which is setted by x86 hardware
 * -addr       : the addr which causes a memory access exception, (the contents of the CR2 register)
 *
 * CALL GRAPH: trap--> trap_dispatch-->pgfault_handler-->do_pgfault
 * The processor provides ucore's do_pgfault function with two items of information to aid in diagnosing
 * the exception and recovering from it.
 *   (1) The contents of the CR2 register. The processor loads the CR2 register with the
 *       32-bit linear address that generated the exception. The do_pgfault fun can
 *       use this address to locate the corresponding page directory and page-table
 *       entries.
 *   (2) An error code on the kernel stack. The error code for a page fault has a format different from
 *       that for other exceptions. The error code tells the exception handler three things:
 *         -- The P flag   (bit 0) indicates whether the exception was due to a not-present page (0)
 *            or to either an access rights violation or the use of a reserved bit (1).
 *         -- The W/R flag (bit 1) indicates whether the memory access that caused the exception
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    /**
     * 输入参数的含义:
     *      mm:当前线程/进程的mm
     *      error_code:错误码
     *      addr:触发页错误的虚拟地址
     * */
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    //check the error_code:好好理解!!!
    // 3 = 11,检查错误码的最低两位 => bit0标志该页是否存在; bit标志对该页的请求(R/W) (见函数上的注释)
    switch (error_code & 3) {  
        default:
                /* error code flag : default is 3 ( W/R=1, P=1): write, present */
        case 2: /* error code flag : (W/R=1, P=0): write, not present */  // => 想写页面,但是页面不存在(没有给虚拟地址映射物理地址)
            if (!(vma->vm_flags & VM_WRITE)) {  // 如果要访问的虚拟地址不能写
                cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
                goto failed;
            }
            // else的语义:想写的物理页面不存在(页表中没有映射),但是该虚拟地址可以写,则不算错误,后面会继续处理...
            break;
        case 1: /* error code flag : (W/R=0, P=1): read, present */       // => 想读页面,且页面存在;
            cprintf("do_pgfault failed: error code flag = read AND present\n");
            //  想读页面且页面存在,仍然进入pgfault,应该是权限不足 
            goto failed;
        case 0: /* error code flag : (W/R=0, P=0): read, not present */   // => 想读页面,但是页面不存在
            if (!(vma->vm_flags & (VM_READ | VM_EXEC))) { // 如果要访问的虚拟地址不能读、不能执行
                cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
                goto failed;
            }
            // else的语义:想读的物理页面不在内存,但是该虚拟地址可以读,则不算错误,后面会继续处理...
    }
    /* IF (write an existed addr ) OR                        => 对应switch的default情况; 此时数据在磁盘
     *    (write an non_existed addr && addr is writable) OR => 对应switch的case 2     ; 需要映射addr
     *    (read  an non_existed addr && addr is readable)    => 对应switch的case 0     ; 需要映射addr
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {         //虚拟地址可以写,设置写权限
        perm |= PTE_W;
    }
    addr = ROUNDDOWN(addr, PGSIZE);         // 找到addr所在页的虚拟地址

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    /*LAB3 EXERCISE 1: YOUR CODE
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */
    #if 0
        /*LAB3 EXERCISE 1: YOUR CODE*/
        ptep = ???              //(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
        if (*ptep == 0) {
                                //(2) if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr

        }
        else {
        /*LAB3 EXERCISE 2: YOUR CODE
        * Now we think this pte is a  swap entry, we should load data from disk to a page with phy addr,
        * and map the phy addr with logical addr, trigger swap manager to record the access situation of this page.
        *
        *  Some Useful MACROs and DEFINEs, you can use them in below implementation.
        *  MACROs or Functions:
        *    swap_in(mm, addr, &page) : alloc a memory page, then according to the swap entry in PTE for addr,
        *                               find the addr of disk page, read the content of disk page into this memroy page
        *    page_insert ： build the map of phy addr of an Page with the linear addr la
        *    swap_map_swappable ： set the page swappable
        */
        /*
        * LAB5 CHALLENGE ( the implmentation Copy on Write)
            There are 2 situlations when code comes here.
            1) *ptep & PTE_P == 1, it means one process try to write a readonly page. 
                If the vma includes this addr is writable, then we can set the page writable by rewrite the *ptep.
                This method could be used to implement the Copy on Write (COW) thchnology(a fast fork process method).
            2) *ptep & PTE_P == 0 & but *ptep!=0, it means this pte is a  swap entry.
                We should add the LAB3's results here.
        */
            if(swap_init_ok) {
                struct Page *page=NULL;
                                        //(1）According to the mm AND addr, try to load the content of right disk page
                                        //    into the memory which page managed.
                                        //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
                                        //(3) make the page swappable.
                                        //(4) [NOTICE]: you myabe need to update your lab3's implementation for LAB5's normal execution.
            }
            else {
                cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
                goto failed;
            }
    }
    #endif

    // 下面的内容应该结合上文switch阅读...
    /****************************** LAB3 EXERCISE 1 *********************************/
    // 1.找到addr对应的pte(如果pte所在的页表不存在,则创建页表 => 详看get_pte)
    ptep=get_pte(mm->pgdir,addr,1);
    if(ptep==NULL){
        cprintf("err at vmm.c/do_pgfault():get_pte failed!");
        goto failed;
    }
   
    // 2.如果虚拟地址没有映射到物理地址(根据ptep判断),则分配一个物理页面并完成映射
    if(*ptep==0){
        struct Page* p=pgdir_alloc_page(mm->pgdir,addr,perm);   // 分配物理页面并完成与addr的映射
        if(p==NULL){
            cprintf("err at vmm.c/do_pgfault():pgdir_alloc_page failed!");
            goto failed;
        }
    }
    /****************************** LAB3 EXERCISE 2 *********************************/
    else{  // *ptep不为0,说明页表中存在addr的映射,但是仍然进入pgfault => 映射到的是磁盘!!!
        // 3.从磁盘加载数据到内存....
        if(swap_init_ok){
           struct Page* page=NULL;
           ret=swap_in(mm,addr,&page); // 从磁盘加载数据到内存(传入page双指针,自动分配内存页)
           if(ret!=0){
               cprintf("err at vmm.c/do_pgfault():swap_in failed!");
               goto failed;
           }
           page_insert(mm->pgdir,page,addr,perm);  // 建立addr到物理page的映射
           swap_map_swappable(mm,addr,page,1);     // 设置页可交换 
            page->pra_vaddr=addr;
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
    }
   ret = 0;
failed:
    return ret;
}


/**
 * 1.对addr~addr+len这段地址进行范围检查 => 是否在用户虚拟地址空间,且在某个vma_struct内
 * 2.对addr!addr+len这段地址进行权限检查 => 对这段虚拟地址进行的操作是否在vma_struct给的权限范围内
 */  
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
    if (mm != NULL) {
        if (!USER_ACCESS(addr, addr + len)) {       // 检查这段地址是否在用户虚拟地址空间      
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end) {
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
                return 0;
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}


/***
 * 从src开始,复制最多max字节数据到dst
 **/ 
bool copy_string(struct mm_struct *mm, char *dst, const char *src, size_t maxn) {
    size_t alen, part = ROUNDDOWN((uintptr_t)src + PGSIZE, PGSIZE) - (uintptr_t)src;
    while (1) {
        if (part > maxn) {
            part = maxn;
        }
        // 检查src~src+part是否合法
        if (!user_mem_check(mm, (uintptr_t)src, part, 0)) {
            return 0;
        }
        if ((alen = strnlen(src, part)) < part) {
            memcpy(dst, src, alen + 1);         // 复制数据
            return 1;
        }
        if (part == maxn) {
            return 0;
        }
        memcpy(dst, src, part);
        dst += part, src += part, maxn -= part;
        part = PGSIZE;
    }
}
