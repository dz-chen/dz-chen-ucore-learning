#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <fs.h>
#include <vfs.h>
#include <sysfile.h>

/************************************************************************************************
 *                                      线程的实现与管理
 * .一些重要的全局变量
 *      proc_list:所有线程控制块构成的双向链表
 *      idleproc:空闲线程(第0个内核线程)指针
 *      initproc:第1个内核线程指针
 *      current:当前正在执行的线程指针
 *      hash_list:key是线程id,val是线程控制块的hash_link字段 => 据此根据pid快速找到线程控制块
 * 
 * .关于线程创建的重要函数
 *      创建内核线程:kernel_thread => do_fork
 *      将内核线程转换为用户线程:do_execve => load_icode 
 * 
 * .关于线程调度的重要函数 
 *      cpu_idle => schedule => proc_run => (load_esp0、switch_to)
 * 
 * .关于系统调用的重要函数
 *      
 * ***********************************************************************************************/


/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc, 
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:
                                            
  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+ 
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  + 
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep 
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : get the process's pid

*/

// the process set's list
// 所有进程控制块的双向链表,proc_struct中的成员变量list_link将链接入这个链表中
list_entry_t proc_list;

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)               // 1024
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))         // hash32 来自libs/hash.c

/**
 * has list for process set based on pid
 * 所有进程控制块的哈希表,proc_struct中的成员变量hash_link将基于pid链接入这个哈希表中
 * 通过它可以O(1)快速查找任意一个进程对应的PCB,而不用遍历所有PCB组成的双向链表proc_list
 * 注:hash_list是一个数组,每个数组元素对应一个双向链表,称为bucket
 * 线程加入hash_list是根据pid决定应该插入哪个bucket
 * */
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;

// current proc => 当前正在执行的线程的PCB(TCB)
struct proc_struct *current = NULL;

static int nr_process = 0;              // 当前线程总数

// 定义见process/entry.S、process/switch.S、trap/trapentry.S
/**
 * 1.kernel_thread_entry函数就是给新的内核线程的主体函数fn做了一个准备开始和结束运行的"壳"
 * 2.当内核线程获得cpu后,执行进入kernel_thread_entry(这是在kernel_thread中设置的);
 * 3.在kernel_thread_entry里边才开始调用内核线程的fn
 * */
void kernel_thread_entry(void);                             // process/entry.S
void forkrets(struct trapframe *tf);                        // trap/trapentry.S
void switch_to(struct context *from, struct context *to);   // process/switch.S

/**
 * alloc_proc - alloc a proc_struct and init all fields of proc_struct
 * 动态分配一个PCB/TCB
 * 并完成基本的初始化(各成员变量清0)
 **/
static struct proc_struct *alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    // 只是统一的简单初始化,很多字段之后还会根据具体线程修改
        proc->state=PROC_UNINIT;
        proc->pid=-1;                       
        proc->runs=0;
        proc->kstack=0;
        proc->need_resched=0;
        proc->parent=NULL;
        proc->mm=NULL;
        memset(&(proc->context),0,sizeof(struct context));
        proc->tf=NULL;
        proc->cr3=boot_cr3;                                 // PDT的物理地址(内核的)
        proc->flags=0;
        memset(&(proc->name),0,PROC_NAME_LEN);
    
        //LAB5 YOUR CODE : (update LAB4 steps)
        /*
        * below fields(add in LAB5) in proc_struct need to be initialized	
        *       uint32_t wait_state;                        // waiting state
        *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
        */
        proc->wait_state=0;
        proc->cptr=proc->optr=proc->yptr=NULL;               // 设置子结点、兄弟结点

        //LAB6 YOUR CODE : (update LAB5 steps)
        /*
        * below fields(add in LAB6) in proc_struct need to be initialized
        *     struct run_queue *rq;                       // running queue contains Process
        *     list_entry_t run_link;                      // the entry linked in run queue
        *     int time_slice;                             // time slice for occupying the CPU
        *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
        *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
        *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
        */
        proc->rq=NULL;
        list_init(&(proc->run_link));
        proc->time_slice=0;
        proc->lab6_run_pool.left=proc->lab6_run_pool.right=proc->lab6_run_pool.parent=NULL;
        proc->lab6_stride=0;
        proc->lab6_priority=0;

        //LAB8:EXERCISE2 YOUR CODE HINT:need add some code to init fs in proc_struct, ...
        proc->filesp=NULL;
    }
    return proc;
}

/**
 * set_proc_name - set the name of proc
 * 设置proc的名字
 * */
char *set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

/**
 * get_proc_name - get the name of proc
 * 获取线程proc的名字
 **/
char *get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

/**
 * set_links - set the relation links of process
 * 1.将线程添加到proc_list
 * 2.修改线程proc的关系链(修改proc左右兄弟的yptr/optr链接、修改parent的cptr链接)
 * 3.线程数(nr_process)+1
 * => do_fork中被调用
 */  
static void set_links(struct proc_struct *proc) {
    list_add(&proc_list, &(proc->list_link));
    proc->yptr = NULL;
    if ((proc->optr = proc->parent->cptr) != NULL) {
        proc->optr->yptr = proc;
    }
    proc->parent->cptr = proc;
    nr_process ++;
}

/**
 * remove_links - clean the relation links of process
 * 1.将线程从proc_list中移除
 * 2.修改线程proc的关系链(修改proc左右兄弟的yptr/optr链接、修改parent的cptr链接)
 * 3.线程数(nr_process)-1
 * => do_wait中被调用
 **/
static void remove_links(struct proc_struct *proc) {
    list_del(&(proc->list_link));
    if (proc->optr != NULL) {
        proc->optr->yptr = proc->yptr;
    }
    if (proc->yptr != NULL) {
        proc->yptr->optr = proc->optr;
    }
    else {
       proc->parent->cptr = proc->optr;
    }
    nr_process --;
}

/**
 * get_pid - alloc a unique pid for process
 * 分配一个空闲的pid
 * 其代码逻辑比较巧妙,详见lab4文档...
 * */
static int get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        // 遍历所有线程的链表,找到一个合适的pid
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

/**
 * proc_run - make process "proc" running on cpu
 * NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
 * 让线程proc获得cpu并执行(就是从current切换到proc线程)
 * 注意,需要完成:
 *      1.向全局变量ts中存入将执行线程的内核栈顶 => 方便将来特权级切换时找到内核栈顶
 *      2.刷新cr3寄存器(因为将执行的线程页表可能与之前线程不同) => 这一步本质上就是完成页表切换
 *      3.调用switch_to函数 => 完成两个线程context的切换
 **/ 
void proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag);
        {
            current = proc;
            load_esp0(next->kstack + KSTACKSIZE);           // 将内核栈的栈顶位置保存到ts => 方便将来特权级切换时找到内核栈顶
            lcr3(next->cr3);                                // 刷新cr3寄存器 => 实质上是完成页表切换          
            switch_to(&(prev->context), &(next->context));  // 切换context上下文
        }
        
        // switch_to返回后,就已经属于next线程的控制流了...
        local_intr_restore(intr_flag);
    }
}

/**
 * forkret -- the first kernel entry point of a new thread/process
 * NOTE: the addr of forkret is setted in copy_thread function
 *      after switch_to, the current proc will execute here.
 * 新线程任务的入口地址/函数
 * forkret调用forkrets,直接跳转到trapentry.S,然后从中断返回...
 * */
static void forkret(void) {
    forkrets(current->tf);
}

/**
 * hash_proc - add proc into proc hash_list
 * 将线程proc加入hash_list
 * (根据proc->pid决定加入那个bucket)
 * */
static void hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

/**
 * unhash_proc - delete proc from proc hash_list
 * 将线程proc从hash_list中移除
 **/
static void unhash_proc(struct proc_struct *proc) {
    list_del(&(proc->hash_link));
}

/**
 * find_proc - find proc frome proc hash_list according to pid
 * 输入pid => 查找hash_list => 返回线程的proc_struct
 * */
struct proc_struct *find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;  // list是pid对应线程的bucket
        while ((le = list_next(le)) != list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

/**
 * kernel_thread - create a kernel thread using "fn" function
 * NOTE: the contents of temp trapframe tf will be copied to 
 *       proc->tf in do_fork-->copy_thread function
 * 用输入的函数fn,来创建一个内核线程
 * - fn:新线程将要执行的函数
 * - arg:fn函数的参数
 * - clone_flags:调用do_fork时的参数,它指明了新建线程与当前线程是否共享mm_struct、files_struct等(不共享则属于不同进程!)
 * 1.给新建的线程设置好中断帧,方便返回用户态时从正确的位置执行...
 * 2.调用do_fork函数,创建当前线程的一个副本,即子线程...
 * */
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    // 这个trapframe并非保存中断前的信息!!!
    // 它只是保存当前线程的部分寄存器信息,do_fork时复制给子线程,从而提供子线程执行时的初始寄存器值...
    struct trapframe tf;                            
    memset(&tf, 0, sizeof(struct trapframe));
    tf.tf_cs = KERNEL_CS;                           
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;

    tf.tf_regs.reg_ebx = (uint32_t)fn;              // 要调用的函数的地址
    tf.tf_regs.reg_edx = (uint32_t)arg;             // 函数参数的位置
    tf.tf_eip = (uint32_t)kernel_thread_entry;      // 子线程下一条指令的地址,定义在process/entry.S 
                                                    // eip本来是存储段内偏移,但是ucore已将所以段基址设置为0(见pmm.c, gdt[])
    // 上面三条语句就是:暂存新线程的主体函数、参数、入口地址(在入口地址中调用fn)

    return do_fork(clone_flags | CLONE_VM, 0, &tf);  // CLONE_VM表示与新建的线程共享虚拟内存
                                                    // stack参数为0,表示创建内核线程
}


/**
 * setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
 * 给线程proc动态分配一个内核栈
 * 注意内核栈始终位于内核的地址空间(虚拟以及物理)
 **/
static int setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);   
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
// 释放线程proc的内核栈空间
static void put_kstack(struct proc_struct *proc) {
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

/**
 * setup_pgdir - alloc one page as PDT
 * 在内核空间分配一个page,作为mm_struct的pgdir
 * 会复制boot_pgdir
 * */
static int setup_pgdir(struct mm_struct *mm) {
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
        return -E_NO_MEM;
    }
    pde_t *pgdir = page2kva(page);
    memcpy(pgdir, boot_pgdir, PGSIZE);
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;         // ?
    mm->pgdir = pgdir;
    return 0;
}

/**
put_pgdir - free the memory space of PDT
* 回收mm_struct中页目录表占用的物理页
*/
static void put_pgdir(struct mm_struct *mm) {
    free_page(kva2page(mm->pgdir));
}

/**
 * copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
 *         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
 * 复制或者共享当前线程的mm_struct给新建的线程proc
 * - clone_flags:CLONE_VM则共享,否则复制
 * 需要进行的操作有:
 * 1.如果复制参数满足CLONE_VM,则让proc共享current的mm_struct
 * 2,否则:在内核分配新的mm_struct、PDT,然后将current的mm_struct拷贝给proc的mm_struct... => 这时新旧线程属于不同进程
 * 注意调用链:copy_mm-->dup_mmap-->copy_range...阅读下去
 * */
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    struct mm_struct *mm, *oldmm = current->mm;

    /* current is a kernel thread */
    if (oldmm == NULL) {                    // 1.内核线程都不需要mm_struct
        return 0;
    }
    if (clone_flags & CLONE_VM) {           // 2.proc与当前线程共享mm_struct => current、proc线程属于同一进程
        mm = oldmm;
        goto good_mm;
    }

    int ret = -E_NO_MEM;
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }

    // 需要对oldmm进行独占操作,因此上锁
    lock_mm(oldmm);
    {
        ret = dup_mmap(mm, oldmm);       // 3.proc复制当前线程的mm_struct => 二者属于不同的进程
    }
    unlock_mm(oldmm);

    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}

/* copy_thread - setup the trapframe on the  process's kernel stack top and
 *             - setup the kernel entry point and stack of process
 * - proc:新创建的子线程
 * - esp:父线程用户栈的栈顶指针,设置给tf->tf_esp字段,方便中断返回时找到用户栈...
 * 1.补全子线程proc的中断上下文信息
 * 2.补全子线程proc的线程上下文信息
 * 注意:这里proc->tf指向新线程proc内核栈空间的顶部!!! 
 * */
static void copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    // 将proc的tf字段设置为内核栈指针,然后将内核栈中的值设置为传入的tf参数(它来自父线程)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;   // 找到给proc新建的内核栈的栈底
    *(proc->tf) = *tf;              // 将传入的trapframe拷贝到proc的内核栈 => 方便proc返回用户态时出栈,从而获得寄存器值
    proc->tf->tf_regs.reg_eax = 0;
    proc->tf->tf_esp = esp;          // 设置用户态栈顶指针(它等于父线程的用户栈顶),子线程返回用户态时使用(从内核栈获得esp寄存器值)                       
    proc->tf->tf_eflags |= FL_IF;    // 设置eflags ; FL_IF表示内核线程在执行过程中,能响应中断,打断当前的执行
    
    // 至此,新线程proc的中断帧trapframe就设置好了...
    
    // 最后,设置线程上下文context(执行现场),用于线程切换
    // context的作用? => proc_run()是根据context来恢复线程的执行...
    proc->context.eip = (uintptr_t)forkret;        // eip:proc上次停止执行时的下一条(内核态)指令地址
    proc->context.esp = (uintptr_t)(proc->tf);     // esp:proc上次停止执行时的堆栈(内核栈)地址
}

/**
 * copy the files_struct from current to proc
 * - clone_flags:是否需要共享文件控制块
 * - proc:新建的线程
 * 将当前线程的文件控制块赋值给新建的proc;
 * 若属于同一进程则直接共享; 否则需要拷贝...
 **/ 
static int copy_files(uint32_t clone_flags, struct proc_struct *proc) {
    struct files_struct *filesp, *old_filesp = current->filesp;
    assert(old_filesp != NULL);

    if (clone_flags & CLONE_FS) {           // proc与current直接共享文件控制块
        filesp = old_filesp;
        goto good_files_struct;
    }


    // proc与current不共享文件控制块 => 说明不属于同一个进程了...
    // 新建一个文件控制块
    int ret = -E_NO_MEM;
    if ((filesp = files_create()) == NULL) {
        goto bad_files_struct;
    }

    if ((ret = dup_files(filesp, old_filesp)) != 0) {
        goto bad_dup_cleanup_fs;
    }

    // ucore这里虽然并没有给新的proc设置文件控制块,然后他会直接进入good_files_struct
good_files_struct:
    files_count_inc(filesp);
    proc->filesp = filesp;
    return 0;

bad_dup_cleanup_fs:
    files_destroy(filesp);
bad_files_struct:
    return ret;
}

/**
 * decrease the ref_count of files, and if ref_count==0, then destroy files_struct
 * 释放线程的文件控制块
 * 引用计数-1 => 如果还有线程引用则保留,否则回收物理内存
 **/
static void put_files(struct proc_struct *proc) {
    struct files_struct *filesp = proc->filesp;
    if (filesp != NULL) {
        if (files_count_dec(filesp) == 0) {
            files_destroy(filesp);
        }
    }
}

/* do_fork      parent process for a new child process
 * - clone_flags: 创建子线程时是否需要共享某些数据结构(mm_struct、file_struct)
 * - stack:       父线程的用户栈虚拟地址; 如果为0,说明是要创建一个内核线程(不需要用户栈)
 * - tf:          trapframe,部分寄存器值与父线程相同,部分不同 => 用于构造子线程的tf字段!
 * 创建当前线程的一个副本,他们的执行上下文、代码、数据都一样; 但是存储位置不同
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE

	//LAB5 YOUR CODE : (update LAB4 steps)
    /* Some Functions
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
    *    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
    *    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */

    //LAB8:EXERCISE2 YOUR CODE  HINT:how to copy the fs in parent's proc_struct?
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid

    proc=alloc_proc();                      // 1.动态分配PCB(TCB),设置父进/线程
    if(proc==NULL) goto fork_out;
    proc->parent=current;

    int res_flag=0;
    res_flag=setup_kstack(proc);            // 2.给新建的线程分配内核栈(每个线程私有)
    if(res_flag!=0) goto bad_fork_cleanup_proc;

    res_flag=copy_files(clone_flags,proc);      // lab8添加; 复制文件控制块
    if(res_flag!=0) goto bad_fork_cleanup_kstack;

    res_flag=copy_mm(clone_flags,proc);     // 3.复制或者共享当前线程的mm_struct给进程proc
    if(res_flag!=0) goto bad_fork_cleanup_proc;

    copy_thread(proc,stack,tf);             // 4.初始化proc的成员tf、context

    bool intr_save;                         // 5.将新建的子线程加入proc_list、hash_list
    local_intr_save(intr_save); // 关中断        
    {
        proc->pid=get_pid();
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_save);

    wakeup_proc(proc);                      // 6.唤醒新建线程 => 使新建线程处于RUNNABLE状态                      
    ret=proc->pid;                          // 7.设置返回值(返回新建线程的id)
	
fork_out:
    return ret;

bad_fork_cleanup_fs:  //for LAB8
    put_files(proc);
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

/**
 * do_exit - called by sys_exit
 * - error_code:退出码
 *   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
 *   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
 *   3. call scheduler to switch to other process
 * 当前线程退出(进入僵尸状态)
 * 1.如果没有其他线程共享mm_struct,则会回收整个进程的用户空间,然后唤醒父线程 => 剩余资源(内核栈、线程控制块)由其父线程回收
 * 2.如果还有其他线程共享mm_struct,则只是减少引用计数,然后唤醒父线程 => 剩余资源(内核栈、线程控制块)由其父线程回收
 * 3.之后进行线程调度,选择就绪队列中另外一个线程执行...
 * 注意:若当前线程还有子线程,则需要将子线程修改为initproc的子线程
 **/ 
int do_exit(int error_code) {
    if (current == idleproc) {                      // idleproc线程不能退出(即内核进程不能退出)
        panic("idleproc exit.\n");
    }
    if (current == initproc) {                      // initproc线程不能退出(即内核进程不能退出)
        panic("initproc exit.\n");
    }

    struct mm_struct *mm = current->mm;
     // mm != NULL说明是用户进程,可以对其进行回收工作...
    if (mm != NULL) {                      
        lcr3(boot_cr3);         // 切换到内核页表,从而确保后续释放用户内存和进程页表能正常进行
        if (mm_count_dec(mm) == 0) {  // 没有其他线程共享这个mm_struct,则可以释放相应物理空间
            exit_mmap(mm);    //回收mm_struct的用户内存空间(用户占用的物理内存以及二级页表都被回收)
            put_pgdir(mm);    //回收mm_struct的页目录表占用的物理内存
            mm_destroy(mm);   // 释放mm_struct以及vma_strcut占用的空间
        }
        // else ... => 如果还有其他线程共享这个mm_struct
        current->mm = NULL;   // 表示用户物理内存空间、管理用户线程占用的内核空间都已经被回收...
    }
    put_files(current);       //for LAB8,回收当前线程的文件控制块
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code; // 退出码,之后给父线程使用

    // 至此,current线程已不能被调度,后续还需要它的父线程来回收其内核栈、线程控制块...
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {   
        // 如果父线程正在等待当前线程,则唤醒父线程,方便父线程尽快回收子线程资源...
        proc = current->parent;              
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }

        // 如果当前线程还有子线程,则需要将子线程的父线程指针修改为initproc
        // 且各个子线程指针需要插入到initproc的子进程链表中
        while (current->cptr != NULL) {
            proc = current->cptr;        // 子线程
            current->cptr = proc->optr;  // 找到当前线程的另一个子线程
    
            proc->yptr = NULL;
            if ((proc->optr = initproc->cptr) != NULL) {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;   // 将子线程的父线程指针修改为initproc
            initproc->cptr = proc;     // 将子线程作为initproc的第一个字线程
            // 如果某个子进程的执行状态是PROC_ZOMBIE,则需要唤醒initproc来完成对此子进程的最后回收工作;  
            if (proc->state == PROC_ZOMBIE) {
                if (initproc->wait_state == WT_CHILD) {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    
    // 主动放弃当前线程控制权,选取一个新的线程执行
    schedule();

    panic("do_exit will not return!! %d.\n", current->pid);
}

/**
 * load_icode_read is used by load_icode in LAB8
 * 从文件fd中偏移offset开始,读取len字节到缓冲区buf中
 */ 
static int load_icode_read(int fd, void *buf, size_t len, off_t offset) {
    int ret;
    if ((ret = sysfile_seek(fd, offset, LSEEK_SET)) != 0) {
        return ret;
    }
    if ((ret = sysfile_read(fd, buf, len)) != len) {
        return (ret < 0) ? ret : -1;
    }
    return 0;
}

/**
 * load_icode -  called by sys_exec-->do_execve
 * 从文件系统加载可执行文件(注意与之前的版本对比,加入文件系统后,load_icode有较大改变)
 * - fd:可执行文件对应的文件描述符; - argc:函数的参数个数; - kargv:函数参数
 * 这个过程中要完成的工作有:
 * 1.创建新的mm_struct
 * 2.分配新的PDT([且拷贝了内核PDT]=>从而能正确映射内核虚拟空间)
 * 3.读取可执行程序到用户进程空间
 * 4.调用mm_map()设置用户堆栈段虚拟空间
 * 5.设置current的mm_struct、cr3为新建的,刷新cr3寄存器使用新建的PDT
 * 6.用户线程main函数的参数入栈(复制到用户栈空间,而不是通过push指令)
 * 7.给current设置trapframe,使得中断返回时进入用户线程环境
 * */
static int load_icode(int fd, int argc, char **kargv) {
    /* LAB8:EXERCISE2 YOUR CODE  HINT:how to load the file with handler fd  in to process's memory? how to setup argc/argv?
     * MACROs or Functions:
     *  mm_create        - create a mm
     *  setup_pgdir      - setup pgdir in mm
     *  load_icode_read  - read raw data content of program file
     *  mm_map           - build new vma
     *  pgdir_alloc_page - allocate new memory for  TEXT/DATA/BSS/stack parts
     *  lcr3             - update Page Directory Addr Register -- CR3
     */
	/* (1) create a new mm for current process
     * (2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
     * (3) copy TEXT/DATA/BSS parts in binary to memory space of process
     *    (3.1) read raw data content in file and resolve elfhdr
     *    (3.2) read raw data content in file and resolve proghdr based on info in elfhdr
     *    (3.3) call mm_map to build vma related to TEXT/DATA
     *    (3.4) callpgdir_alloc_page to allocate page for TEXT/DATA, read contents in file
     *          and copy them into the new allocated pages
     *    (3.5) callpgdir_alloc_page to allocate pages for BSS, memset zero in these pages
     * (4) call mm_map to setup user stack, and put parameters into user stack
     * (5) setup current process's mm, cr3, reset pgidr (using lcr3 MARCO)
     * (6) setup uargc and uargv in user stacks
     * (7) setup trapframe for user environment
     * (8) if up steps failed, you should cleanup the env.
     */
    assert(argc>=0 && argc<= EXEC_MAX_ARG_NUM);

    // (1) create a new mm for current process
    if(current->mm!=NULL){      // 在do_execve()中已经将其置为NULL
        panic("load_icode:current->mm must be empty.\n");
    }
    int ret=-E_NO_MEM;
    struct mm_struct* mm;
    if((mm=mm_create())==NULL){
        goto bad_mm;
    }

    // (2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT(这里说法不对,是复制了boot_pgdir,而不是直接等于)
    if(setup_pgdir(mm)!=0){    // 在内核分配新的空间,创建页目录表      
        goto bad_pgdir_cleanup_mm;
    }

    // (3) copy TEXT/DATA/BSS parts in binary to memory space of process
    //     => 这一部分可以与前几个lab对比,区别在于这里是从文件系统读取,而之前是直接读取内存中的数据!
    //        这个过程中会分配物理内存、修改页表,且地址映射时的虚拟地址是用户空间的地址...
    // (3.1) read raw data content in file and resolve elfhdr
    struct Page* page;
    struct elfhdr __elf,*elf=&__elf;
    if(ret=load_icode_read(fd,elf,sizeof(struct elfhdr),0)!=0){
        goto bad_elf_cleanup_pgdir;
    }
    if(elf->e_magic!=ELF_MAGIC){
        ret=-E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    struct proghdr __ph,*ph=&__ph;
    uint32_t vm_flags, perm, phnum;
    for (phnum = 0; phnum < elf->e_phnum; phnum ++) {     // 读取所有段(elf->e_phnum即段数)
        
        // (3.2) read raw data content in file and resolve proghdr based on info in elfhdr
        off_t phoff = elf->e_phoff + sizeof(struct proghdr) * phnum;    //第phnum个proghdr(描述一个段)
        // 读取一个proghdr
        if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), phoff)) != 0) {
            goto bad_cleanup_mmap;
        }
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            continue ;
        }

        // (3.3) call mm_map to build vma related to TEXT/DATA
        vm_flags = 0, perm = PTE_U;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE) perm |= PTE_W;
        // mm_map(....)为当前段创建vma,并插入到mm中
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        off_t offset = ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;
        // (3.4) call pgdir_alloc_page to allocate page for TEXT/DATA, read contents in file
        //        and copy them into the new allocated pages
        end = ph->p_va + ph->p_filesz;
        while (start < end) {
            // 给本段的当前页分配物理页(修改页表)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            // 将数据读取到物理页中=>按理说这里读取的是用户程序,为什么要放到内核地址空间?
            if ((ret = load_icode_read(fd, page2kva(page) + off, size, offset)) != 0) {
                goto bad_cleanup_mmap;
            }
            start += size, offset += size;
        }
        end = ph->p_va + ph->p_memsz;

        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }

        // (3.5) call pgdir_alloc_page to allocate pages for BSS, memset zero in these pages
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    sysfile_close(fd);          // 关闭可执行目标文件

    // (4) call mm_map to setup user stack, and put parameters into user stack
    vm_flags = VM_READ | VM_WRITE | VM_STACK;      // 设堆栈段
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    
    // (5) setup current process's mm, cr3, reset pgidr (using lcr3 MARCO)
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));            //让cpu使用用户程序的页表

    // (6) setup uargc and uargv in user stacks => 用户线程main函数的参数入栈
    //setup argc, argv
    uint32_t argv_size=0, i;
    for (i = 0; i < argc; i ++) {
        argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }

    uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
    char** uargv=(char **)(stacktop  - argc * sizeof(char *));
    
    argv_size = 0;
    for (i = 0; i < argc; i ++) {
        uargv[i] = strcpy((char *)(stacktop + argv_size ), kargv[i]);
        argv_size +=  strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }
    
    stacktop = (uintptr_t)uargv - sizeof(int);
    *(int *)stacktop = argc;
    
    // (7) setup trapframe for user environment
    struct trapframe *tf = current->tf; 
    memset(tf, 0, sizeof(struct trapframe));
    tf->tf_cs = USER_CS;
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
    tf->tf_esp = stacktop;                          // 设置用户栈顶
    tf->tf_eip = elf->e_entry;                      // 设置程序入口地址
    tf->tf_eflags = FL_IF;                          // 允许被中断
    ret = 0;

out:
    return ret;
// (8) if up steps failed, you should cleanup the env.
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}

/**
 * this function isn't very correct in LAB8
 * 释放kargv对应的内存空间
 **/ 
static void put_kargv(int argc, char **kargv) {
    while (argc > 0) {
        kfree(kargv[-- argc]);
    }
}

/**
 * 将argv中的参数复制到kargv
 */ 
static int copy_kargv(struct mm_struct *mm, int argc, char **kargv, const char **argv) {
    int i, ret = -E_INVAL;
    if (!user_mem_check(mm, (uintptr_t)argv, sizeof(const char *) * argc, 0)) {
        return ret;
    }
    for (i = 0; i < argc; i ++) {
        char *buffer;
        if ((buffer = kmalloc(EXEC_MAX_ARG_LEN + 1)) == NULL) {
            goto failed_nomem;
        }
        if (!copy_string(mm, buffer, argv[i], EXEC_MAX_ARG_LEN + 1)) {
            kfree(buffer);
            goto failed_cleanup;
        }
        kargv[i] = buffer;
    }
    return 0;

failed_nomem:
    ret = -E_NO_MEM;
failed_cleanup:
    put_kargv(i, kargv);
    return ret;
}

/**
 * do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
 *           - call load_icode to setup new memory space accroding binary prog.
 * - name:用户程序名
 * - argc:命令行参数个数
 * - argv:命令行参数,argc[0]是程序路径
 * 给用户程序name创建线程
 * 1.复制程序名和参数到内核空间
 * 2.调用load_icode加载可执行文件
 * 注意对ucore而言,它是通过将内核线程user_main(就是下面代码中current)的mm_struct、页表、trapframe等进行了修改
 * 然后user_main就变成了用户线程
 **/
int do_execve(const char *name, int argc, const char **argv) {
    static_assert(EXEC_MAX_ARG_LEN >= FS_MAX_FPATH_LEN);
    struct mm_struct *mm = current->mm;                     // 父线程的mm_struct(即current)
    if (!(argc >= 1 && argc <= EXEC_MAX_ARG_NUM)) {
        return -E_INVAL;
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));  //初始化local_name
    
    char *kargv[EXEC_MAX_ARG_NUM];
    const char *path;
    
    int ret = -E_INVAL;
    
    lock_mm(mm);             // 上锁---------------------------------
    if (name == NULL) {
        snprintf(local_name, sizeof(local_name), "<null> %d", current->pid);
    }
    else {
        // 将程序名复制到local_name
        if (!copy_string(mm, local_name, name, sizeof(local_name))) { 
            unlock_mm(mm);
            return ret;
        }
    }
        // 将参数复制到kargv
    if ((ret = copy_kargv(mm, argc, kargv, argv)) != 0) {
        unlock_mm(mm);
        return ret;
    }
    path = argv[0];
    unlock_mm(mm);         // 释放锁 ---------------------------------
    
    files_closeall(current->filesp);    // 关闭所有已经打开文件
    /* sysfile_open will check the first argument path, thus we have to use a user-space pointer, and argv[0] may be incorrect */    
    int fd;
    // 打开可执行目标文件(即应用程序)
    if ((ret = fd = sysfile_open(path, O_RDONLY)) < 0) {
        goto execve_exit;
    }
    if (mm != NULL) {
        lcr3(boot_cr3);             // 设置页表为内核空间页表
        // 为什么要判断这个???
        if (mm_count_dec(mm) == 0) {        // 仅当没有其他线程共享mm_struct时才能销毁...为什么要减1?
            exit_mmap(mm);     // 回收mm的用户内存空间
            put_pgdir(mm);     // 回收页目录表   
            mm_destroy(mm);
        }
        current->mm = NULL;        // 由于目前处于内核,所以直接将mm置为NULL(对内核线程而言,他们共享boot_pgdir,不需要mm_struct)
    }
    ret= -E_NO_MEM;
    if ((ret = load_icode(fd, argc, kargv)) != 0) {
        goto execve_exit;
    }
    put_kargv(argc, kargv);
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    put_kargv(argc, kargv);
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}

/**
 * do_yield - ask the scheduler to reschedule
 * 当前线程让出cpu
 * => 仅仅修改need_resched,并不立即切换线程...
 **/
int do_yield(void) {
    current->need_resched = 1;
    return 0;
}

/**
 * do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
 *         - proc struct of this child.
 * NOTE: only after do_wait function, all resources of the child proces are free.
 * - pid:想要回收的僵尸线程的id; 0表示任意一个,不为0表示特定线程
 * 完成僵尸子线程的回收工作 => 回收内核栈、线程控制块
 * 
 **/
int do_wait(int pid, int *code_store) {
    struct mm_struct *mm = current->mm;
    if (code_store != NULL) {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0) {                                 // pid不为0,回收特定僵尸
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    else {                                          // pid为0,回收任意僵尸线程
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {  // 遍历current的子线程链表
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }

    // 控制流进入这里,说明没有找到要回收的子线程;但是current有子线程,则需要继续等待...
    if (haskid) {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;

        schedule();   // 阻塞当前线程,进入另一个线程的控制流....
        
        // 这个if仅kill导致,也就是当前线程已经被kill了
        if (current->flags & PF_EXITING) {      // 如果当前线程也可以退出了(比如被kill了)...
            do_exit(-E_KILLED);
        }
        goto repeat;            // 此线程被唤醒后,继续寻找可以回收的子线程...
    }
    return -E_BAD_PROC;

found:      // 找到了要回收的线程 => proc
    if (proc == idleproc || proc == initproc) {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL) {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);            // 将要回收的线程从hash_list中移除
        remove_links(proc);           // 删除proc的关系链  
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);                 // 回收内核栈
    kfree(proc);                      // 回收线程控制块
    return 0;
}

/**
 * do_kill - kill process with pid by set this process's flags with PF_EXITING
 * - pid:要杀死的线程号码
 * kill 指定线程
 * 注意:只是修改pid线程的flag标志位为PF_EXITING,并不会立即回收;
 *      对ucore而言,要等到被kill的pid线程回收其子线程后,pid线程才会exit,之后才能被回收=> 详见do_wait;
 *      这里kill应该类似于Java的interrupt,只是修改标志,具体怎么处理由被kill的线程决定...
 **/  
int do_kill(int pid) {
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
        if (!(proc->flags & PF_EXITING)) {
            proc->flags |= PF_EXITING;             // 只是修改flag标志位为PF_EXITING,并不会立即杀死
            if (proc->wait_state & WT_INTERRUPTED) {
                wakeup_proc(proc);
            }
            return 0;
        }
        return -E_KILLED;
    }
    return -E_INVAL;
}

/**
 * kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
 * - name:可执行目标文件名
 * - argv:执行目标文件时的命令行参数
 * 1.此函数整理出命令行参数,然后调用系统调用SYS_exec,详见syscall/syscall.c
 * 2.SYS_exec在调用do_execve()实现创建用户线程 => 其实就是将当前内核线程改造成用户线程
 * 3.在user_main中被调用...
 * 4.此函数不会正常返回,因为它发起的系统调用时修改了trapframe,中断返回时直接返回到了用户态!!!
 **/ 
static int kernel_execve(const char *name, const char **argv) {
    int argc = 0, ret;
    while (argv[argc] != NULL) {
        argc ++;
    }

    //cprintf("------------------------------ test by cdz,begin sys_call in kernel to create user thread!\n");
    // 通过系统调用SYS_exec创建用户线程 => 在内核发生系统调用中断
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (argc), "b" (argv)
        : "memory");
    
    // 这个函数不会返回,因为上面执行的系统调用中修改了trapframe,从中断返回时直接就到了用户态,而不是从这里开始接着往下执行...
    //cprintf("------------------------------ test by cdz,begin sys_call in kernel to create user thread!\n");
    return ret;
}

#define __KERNEL_EXECVE(name, path, ...) ({                         \
const char *argv[] = {path, ##__VA_ARGS__, NULL};       \
                     cprintf("kernel_execve: pid = %d, name = \"%s\".\n",    \
                             current->pid, name);                            \
                     kernel_execve(name, argv);                              \
})

#define KERNEL_EXECVE(x, ...)                   __KERNEL_EXECVE(#x, #x, ##__VA_ARGS__)

#define KERNEL_EXECVE2(x, ...)                  KERNEL_EXECVE(x, ##__VA_ARGS__)

#define __KERNEL_EXECVE3(x, s, ...)             KERNEL_EXECVE(x, #s, ##__VA_ARGS__)

#define KERNEL_EXECVE3(x, s, ...)               __KERNEL_EXECVE3(x, s, ##__VA_ARGS__)

/**
 * user_main - kernel thread used to exec a user program
 * - arg:执行编译好的用户程序时输入的命令行参数
 * 创建用户线程
 * 最终调用kernel_execve()函数实现
 **/
static int user_main(void *arg) {
    #ifdef TEST                       // lab8始终不会进入TEST
        #ifdef TESTSCRIPT
            KERNEL_EXECVE3(TEST, TESTSCRIPT);
        #else
            KERNEL_EXECVE2(TEST);
        #endif
    #else
        //cprintf("------------------------------ test by cdz,not define TEST in user_main\n");
        KERNEL_EXECVE(sh);              // lab8中系统启动时创建的是命令行进程,输入命令时再创建新的线程...
    #endif
    panic("user_main execve failed.\n");
}

/**
 * init_main - the second kernel thread used to create user_main kernel threads
 * 第1个内核线程将要执行的代码(或者说是用init_main来创建第1个内核线程即initproc,第0个是idleproc)
 * 注意init_main内部会再次创建新的线程(使用user_main函数)
 * init_main中创建的user_main就是第一个用户线程
 **/
static int init_main(void *arg) {
    int ret;
    if ((ret = vfs_set_bootfs("disk0:")) != 0) {
        panic("set boot fs failed: %e.\n", ret);
    }
    
    size_t nr_free_pages_store = nr_free_pages();
    size_t kernel_allocated_store = kallocated();

    // 创建第一个用户进程,它是命令行程序sh,不需要参数,所以arg为NULL
    int pid = kernel_thread(user_main, NULL, 0);    
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }
    extern void check_sync(void);

    check_sync();      // check philosopher sync problem => 检查线程同步(通过哲学家就餐问题)    
    
    while (do_wait(0, NULL) == 0) {

        schedule();
    }
    fs_cleanup();
        
    cprintf("all user-mode processes have quit.\n");
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
    assert(nr_process == 2);
    assert(list_next(&proc_list) == &(initproc->list_link));
    assert(list_prev(&proc_list) == &(initproc->list_link));

    cprintf("init check memory pass.\n");
    return 0;
}

/**
 * proc_init - set up the first kernel thread idleproc "idle" by itself and 
 *           - create the second kernel thread init_main
 * 1.初始化线程链表、线程hash表
 * 2.将ucore执行以来的所有部分初始为idle线程(第0个内核线程)
 * 3.创建第1个内核线程initproc
 **/
void proc_init(void) {
    int i;
    // 1.初始化线程链表(会链接所有线程)
    list_init(&proc_list); 

    // 2.初始化hash_list的所有bucket,通过hash可O(1)查找任意进程的PCB
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i);
    }

    // 3.ucore开始执行至今,尚无进程/线程;
    // 这里通过alloc_proc给当前执行的上下文分配一个进程控制块并初始化,将init/entry.S至今的部分打造成第0个线程(idleproc)!
    if ((idleproc = alloc_proc()) == NULL) {
        panic("cannot alloc idleproc.\n");
    }
    idleproc->pid = 0;                              //线程id  => 下面部分完成idleproc的初始化
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;        // idleproc的内核栈就是整个内核的内核栈!
                                                    // 但是,其他内核线程和用户线程的内核栈,都得单独新建
    idleproc->need_resched = 1;                     // 可以被调度
    
    if ((idleproc->filesp = files_create()) == NULL) {  // 创建文件管理的指针
        panic("create filesp (idleproc) failed.\n");
    }
    files_count_inc(idleproc->filesp);              // 共享文件控制块的线程数+1
    set_proc_name(idleproc, "idle");                // 设置线程名             
    nr_process ++;                                  // 第0个线程(之后仅在set_links中才会自加...)
    current = idleproc; // 设置当前正在执行的线程为idle => 至此,ucore启动以来的所有执行过程都被认为属于idle线程


    // 4.创建除idle以外的第1个内核线程! 注意它与idleproc的创建方式不同...
    // initproc创建时指定了线程执行的代码/函数,其他内核线程、用户线程也需要这样创建
    // 而idleproc仅仅创建了线程控制块,并没有显示指定执行的代码 
    //      => 不过,除了其他内核线程和用户线程以外,剩余的代码都是idleproc执行;包括cpu_idle(它在cpu_idle中被调用)
    // 注意:在initproc中还会创建其他用户线程...
    int pid = kernel_thread(init_main, NULL, 0);
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}


/**
 * cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
 * 在kern_init中被调用
 * 执行cpu_idle时说明没有其他线程执行了,于是执行idleproc
 * 它的作用只是空转并选择其他可调用的线程投入运行
 **/
void cpu_idle(void) {
    while (1) {
        if (current->need_resched) {
            schedule();
            // schedule可能尚未返回,控制流已经进入另一个线程...
        }
    }
}

//FOR LAB6, set the process's priority (bigger value will get more CPU time) 
// 设置线程优先级(优先级越高,被执行得越频繁)
void lab6_set_priority(uint32_t priority)
{
    if (priority == 0)
        current->lab6_priority = 1;
    else current->lab6_priority = priority;
}

// do_sleep - set current process state to sleep and add timer with "time"
//          - then call scheduler. if process run again, delete timer first.
int do_sleep(unsigned int time) {
    if (time == 0) {
        return 0;
    }
    bool intr_flag;
    local_intr_save(intr_flag);
    timer_t __timer, *timer = timer_init(&__timer, current, time);
    current->state = PROC_SLEEPING;
    current->wait_state = WT_TIMER;
    add_timer(timer);
    local_intr_restore(intr_flag);

    schedule();

    del_timer(timer);
    return 0;
}
