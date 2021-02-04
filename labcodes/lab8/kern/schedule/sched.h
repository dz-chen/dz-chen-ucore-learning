#ifndef __KERN_SCHEDULE_SCHED_H__
#define __KERN_SCHEDULE_SCHED_H__

#include <defs.h>
#include <list.h>
#include <skew_heap.h>

#define MAX_TIME_SLICE 5

struct proc_struct;

// 定时器结点(的定义) => 一个定时器对应一个被阻塞的线程
typedef struct {
    unsigned int expires;       //the expire time
    struct proc_struct *proc;   //the proc wait in this timer. If the expire time is end, then this proc will be scheduled
    list_entry_t timer_link;    // 通过这个成员,链接成一个队列(见sched.c, timer_list)
} timer_t;

#define le2timer(le, member)            \
to_struct((le), timer_t, member)

/**
 * init a timer
 * 初始化定时器(并加入定时器链表) => 它在expires之后唤醒进程proc
 */ 
static inline timer_t *timer_init(timer_t *timer, struct proc_struct *proc, int expires) {
    timer->expires = expires;
    timer->proc = proc;
    list_init(&(timer->timer_link));
    return timer;
}

struct run_queue;

// The introduction of scheduling classes is borrrowed from Linux, and makes the 
// core scheduler quite extensible. These classes (the scheduler modules) encapsulate 
// the scheduling policies. 
// 调度器类
struct sched_class {
    // the name of sched_class
    const char *name;
    // Init the run queue
    void (*init)(struct run_queue *rq);
    // put the proc into runqueue, and this function must be called with rq_lock
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
    // get the proc out runqueue, and this function must be called with rq_lock
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
    // choose the next runnable task
    struct proc_struct *(*pick_next)(struct run_queue *rq);
    // dealer of the time-tick
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
    /* for SMP support in the future
     *  load_balance
     *     void (*load_balance)(struct rq* rq);
     *  get some proc from this rq, used in load_balance,
     *  return value is the num of gotten proc
     *  int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);
     */
};

// 就绪队列(通过成员run_list链接)
// 不包括正在执行的进程(虽然就绪进程与执行进程共享同一状态PROC_RUNNABLE)
struct run_queue {
    list_entry_t run_list;              // 就绪队列的链表头(表头是没有数据的空结点)
    unsigned int proc_num;              // 就绪线程的个数
    int max_time_slice;                 // 时间片
    // For LAB6 ONLY
    skew_heap_entry_t *lab6_run_pool;  // 类似于run_list,只是这里就绪队列被组织成优先队列,供stride算法使用!
};

void sched_init(void);
void wakeup_proc(struct proc_struct *proc);
void schedule(void);
void add_timer(timer_t *timer);     // add timer to timer_list
void del_timer(timer_t *timer);     // del timer from timer_list
void run_timer_list(void);          // call scheduler to update tick related info, and check the timer is expired? If expired, then wakup proc

#endif /* !__KERN_SCHEDULE_SCHED_H__ */

