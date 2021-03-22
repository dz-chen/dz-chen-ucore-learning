#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <stdio.h>
#include <assert.h>
#include <default_sched.h>


/***********************************************************************************
 *              调度框架,不涉及具体算法,任务交给sched_class 
 * .三个调度的关键函数:
 *      wakeup_proc
 *      schedule
 *      run_timer_list
 * .注意timer_list中结点的组织/排序方式
 * 
 * .三个全局变量:
 *      timer_list:定时器队列,每个定时器对应了一个线程,所以timer_list其实是一个睡眠线程组成的队列
 *      rq        :这是所有就绪线程组成的队列
 *      sched_class:调度器类
 * **********************************************************************************/


/**
 * 定时器队列 => 链接的是timer_t结构体(见sched.h)
 * 注意timer_list被组织成了差分数组,从而更新所有阻塞线程的expire时不用遍历整个链表
 * 详见:add_timer()、del_timer()、run_timer_list()体会其优点
 */
static list_entry_t timer_list;

// 任务调度器
static struct sched_class *sched_class;

// 可执行(就绪)队列,通过其成员run_list链接就绪的线程proc
static struct run_queue *rq;

// 将线程proc加入就绪队列
static inline void sched_class_enqueue(struct proc_struct *proc) {
    if (proc != idleproc) {
        sched_class->enqueue(rq, proc);
    }
}

// 从就绪队列删除线程proc
static inline void sched_class_dequeue(struct proc_struct *proc) {
    sched_class->dequeue(rq, proc);
}

static inline struct proc_struct *sched_class_pick_next(void) {
    return sched_class->pick_next(rq);
}

// 当前执行线程的剩余时间片减1
static void sched_class_proc_tick(struct proc_struct *proc) {
    if (proc != idleproc) {
        sched_class->proc_tick(rq, proc);
    }
    else {
        proc->need_resched = 1;
    }
}

static struct run_queue __rq;

/**
 * 初始化调度器 => 绑定特定调度算法的调度类(sched_class)
 * 在kern_init()中被调用
 */
void sched_init(void) {
    list_init(&timer_list);

    sched_class = &default_sched_class;

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;            // 5
    sched_class->init(rq);

    cprintf("sched class: %s\n", sched_class->name);
}


/**
 * 唤醒线程 => 将线程proc放入就绪队列,但是不立即调度!
 */
void wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
    bool intr_flag;
    local_intr_save(intr_flag);                         // 关中断,保证下面操作的原子性
    {
        if (proc->state != PROC_RUNNABLE) {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
                sched_class_enqueue(proc);
            }
        }
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}


/**
 *          线程调度
 * 1.将当前线程放入就绪队列
 * 2.从就绪队列中选择一个线程
 * 3.执行选择的线程 => 调用proc_run
 */ 
void schedule(void) {
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);                     // 关中断
    {
        current->need_resched = 0;                         
        if (current->state == PROC_RUNNABLE) {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
            sched_class_dequeue(next);
        }
        if (next == NULL) {           // 没有就绪的线程,则应该让idle来占用cpu
            next = idleproc;
        }
        next->runs ++;
        if (next != current) {
            proc_run(next);
        }
        // if (next == current) 说明current入队又出队,重新占用cpu
    }
    local_intr_restore(intr_flag);
}

/************************************ 定时器操作 ******************************************/
/**
 * 将定时器timer添加到定时器链表timer_list
 * timer_list是差分数组!!!
 * => 仅在do_sleep()中被调用!
 * */ 
void add_timer(timer_t *timer) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        assert(timer->expires > 0 && timer->proc != NULL);
        assert(list_empty(&(timer->timer_link)));
        list_entry_t *le = list_next(&timer_list);
        while (le != &timer_list) {                     // 向后找,找到第一个比timer更大的定时器
            timer_t *next = le2timer(le, timer_link);
            if (timer->expires < next->expires) {
                next->expires -= timer->expires;
                break;
            }
            timer->expires -= next->expires;
            le = list_next(le);
        }
        list_add_before(le, &(timer->timer_link));
    }
    local_intr_restore(intr_flag);
}

// del timer from timer_list
void del_timer(timer_t *timer) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (!list_empty(&(timer->timer_link))) {
            if (timer->expires != 0) {
                list_entry_t *le = list_next(&(timer->timer_link));
                if (le != &timer_list) {
                    timer_t *next = le2timer(le, timer_link);
                    next->expires += timer->expires;
                }
            }
            list_del_init(&(timer->timer_link));
        }
    }
    local_intr_restore(intr_flag);
}

/**
 * call scheduler to update tick related info, and check the timer is expired?
 * If expired, then wakup proc
 * 仅在每次时钟中断时被调用,即一个节拍调用一次 => 
 * 0.所有线程的到期时间减1
 * 1.遍历定时器,唤醒部分到期的阻塞线程; 
 * 2.唤醒的线程只是放入就绪队列,并不立即执行
 * 每次时钟段中断时被调用,被trap_dispatch()函数调用
 */
void run_timer_list(void) {
    bool intr_flag;
    local_intr_save(intr_flag);                             // 关中断
    {
        list_entry_t *le = list_next(&timer_list);
        if (le != &timer_list) {
            timer_t *timer = le2timer(le, timer_link);
            assert(timer->expires != 0);
            timer->expires --;
            // 唤醒所有已经到期的线程
            while (timer->expires == 0) {  // 为什么以这个为循环条件? => 涉及timer_list的排序、组织方式
                le = list_next(le);
                struct proc_struct *proc = timer->proc;
                if (proc->wait_state != 0) {
                    assert(proc->wait_state & WT_INTERRUPTED);
                }
                else {
                    warn("process %d's wait_state == 0.\n", proc->pid);
                }
                wakeup_proc(proc);
                del_timer(timer);
                if (le == &timer_list) {
                    break;
                }
                timer = le2timer(le, timer_link);
            }
        }
        sched_class_proc_tick(current);         // 当前线程剩余时间片减1
    }
    local_intr_restore(intr_flag);
}
