#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>
#include <skew_heap.h>

// process's state in his life cycle
// 线程状态
enum proc_state {
    PROC_UNINIT = 0,  // uninitialized            => 已经创建,但是尚未完成初始化(设置栈、文件表、pid、页表、name...等)
    PROC_SLEEPING,    // sleeping                 => 阻塞(或者说是等待),ucore没有区分二者,不过java区分阻塞和等待
    PROC_RUNNABLE,    // runnable(maybe running)  => 可运行(在就绪队列中,或者正在执行)
    PROC_ZOMBIE,      // almost dead, and wait parent proc to reclaim his resource => 已经结束,但是尚未回收
};

// Saved registers for kernel context switches.
// Don't need to save all the %fs etc. segment registers,
// because they are constant across kernel contexts.
// Save all the regular registers so we don't need to care
// which are caller save, but not the return register %eax.
// (Not saving %eax just simplifies the switching code.)
// The layout of context must match code in switch.S.
struct context {
    uint32_t eip;
    uint32_t esp;
    uint32_t ebx;
    uint32_t ecx;
    uint32_t edx;
    uint32_t esi;
    uint32_t edi;
    uint32_t ebp;
};

#define PROC_NAME_LEN               50
#define MAX_PROCESS                 4096
// 8192
#define MAX_PID                     (MAX_PROCESS * 2)           

extern list_entry_t proc_list;

struct inode;

/**
 *              进程控制块(线程控制块)
 * 1.在ucore中,以线程为调度单位,PCB实质上就是TCB => 故一个proc_struct描述的就是一个线程
 * 2.mm_struct、files_struct进程内多个线程共享;
 *   run_queue是所有线程(不管是否属于一个进程)共享,整个os只有一个run_queue;
 *   除此之外的所有字段都是线程私有的!
 * */
struct proc_struct {
    enum proc_state state;                      // 线程状态:PROC_UNINIT、PROC_SLEEPING、PROC_RUNNABLE、PROC_ZOMBIE
    int pid;                                    // 线程ID
    int runs;                                   // 线程已经被执行了的次数
    uintptr_t kstack;                           // 内核栈的虚拟地址(位于内核物理/虚拟地址空间,内核栈是线程私有的!)
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU? => 若当前线程正在执行,则此值应该为1; 否则为0
    struct proc_struct *parent;                 // 父线程/进程的结构体;(除idle外,其他都有父进程/线程)
    struct mm_struct *mm;                       // 虚拟地址管理结构 => 这个是进程内多个线程共享!
    struct context context;                     // 线程上下文
    struct trapframe *tf;                       // 中断上下文?
    uintptr_t cr3;                              // 页目录表的物理地址(cr3寄存器内容) => 进程内多个线程共享
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // 线程名
    list_entry_t list_link;                     // Process link list
    list_entry_t hash_link;                     // Process hash list
    int exit_code;                              // exit code (be sent to parent proc)
    uint32_t wait_state;                        // waiting state
    struct proc_struct *cptr, *yptr, *optr;     // relations between processes
    struct run_queue *rq;                       // 就绪队列的指针(整个os只有一个就绪队列,因此这个指针应该是所有线程共享的)
    list_entry_t run_link;                      // 通过这个字段链接进就绪队列(Round Robin)
    int time_slice;                             // 剩余时间片大小=> 对于正在执行的线程,每隔一个节拍会减1
    skew_heap_entry_t lab6_run_pool;            // 类似于run_list,只是这里就绪队列被组织成优先队列,供stride算法使用!
    uint32_t lab6_stride;                       // stride值,供stride算法使用 => 每次调度时选取stride值最小的线程执行
                                                //
    uint32_t lab6_priority;                     // 线程优先级,供stride算法使用
    struct files_struct *filesp;                // 文件相关的信息(进程内的所有线程共享) => 进程的工作目录、打开文件表、共享文件的线程数...
};

#define PF_EXITING                  0x00000001      // getting shutdown

#define WT_INTERRUPTED               0x80000000                    // the wait state could be interrupted
#define WT_CHILD                    (0x00000001 | WT_INTERRUPTED)  // wait child process
#define WT_KSEM                      0x00000100                    // wait kernel semaphore
#define WT_TIMER                    (0x00000002 | WT_INTERRUPTED)  // wait timer
#define WT_KBD                      (0x00000004 | WT_INTERRUPTED)  // wait the input of keyboard

#define le2proc(le, member)         \
    to_struct((le), struct proc_struct, member)

extern struct proc_struct *idleproc, *initproc, *current;

void proc_init(void);
void proc_run(struct proc_struct *proc);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
void cpu_idle(void) __attribute__((noreturn));

struct proc_struct *find_proc(int pid);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_exit(int error_code);
int do_yield(void);
int do_execve(const char *name, int argc, const char **argv);
int do_wait(int pid, int *code_store);
int do_kill(int pid);
//FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority);
int do_sleep(unsigned int time);
#endif /* !__KERN_PROCESS_PROC_H__ */

