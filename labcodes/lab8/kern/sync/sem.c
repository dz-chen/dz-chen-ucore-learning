#include <defs.h>
#include <wait.h>
#include <atomic.h>
#include <kmalloc.h>
#include <sem.h>
#include <proc.h>
#include <sync.h>
#include <assert.h>

/**************************************************************
 *              内核级信号量及其操作P/V
 * .ucore中信号量的实现,需要基于开/关中断机制
 * ************************************************************/


// 初始化信号量(内部会初始化该信号量对应的等待队列)
// 如果是互斥信号量则将val初始化为1; 同步信号量则初始化为0
void sem_init(semaphore_t *sem, int value) {
    sem->value = value;
    wait_queue_init(&(sem->wait_queue));
}

// P操作的具体实现(wait_state表示被阻塞的原因)
static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag);         // 关中断
    if (sem->value > 0) {               // val>0 说明可获得资源,于是val减1然后退出,不用阻塞当前线程
        sem->value --;
        local_intr_restore(intr_flag);  // 开中断
        return 0;
    }

    // 控制流到达此处说明资源不足 => 阻塞当前线程,放入sem的阻塞队列中,设置被阻塞原因为wait_state
    wait_t __wait, *wait = &__wait;
    wait_current_set(&(sem->wait_queue), wait, wait_state);  // 见wait.c => 为当前线程初始化wait结点,并将其加入等待队列！
    local_intr_restore(intr_flag);

    // 调度器选择另一个线程执行
    schedule();    // => 进入schedule并执行proc_run()后,便进入另一个线程的上下文了
    
    // .... 这一段时间都是在执行另一个线程,控制流暂时不会往下面几行代码执行


    //如果控制流到达下面的代码,说明此线程被V操作唤醒 
    // 把自身关联的wait从等待队列中删除
    local_intr_save(intr_flag);
    wait_current_del(&(sem->wait_queue), wait); //见wait.h => 将wait(当前线程)从等待队列中删除
    local_intr_restore(intr_flag);

    if (wait->wakeup_flags != wait_state) {
        return wait->wakeup_flags;
    }
    return 0;
}

// V操作的具体实现
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag);                 // 关中断
    {
        wait_t *wait;
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {     //队列中没有等待线程
            sem->value ++;
        }
        else {           // 唤醒wait对应的线程,wakeup_wait会将其加入就绪队列
            assert(wait->proc->wait_state == wait_state);
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
        }
    }
    local_intr_restore(intr_flag);
}



/****************************** 信号量操作(P/V)的包装函数 *******************************************/
// V操作
void up(semaphore_t *sem) {
    __up(sem, WT_KSEM);    //阻塞原因:WT_KSEM(wait kernel semaphore)
}

/**
 * P操作
 * 它如果阻塞了当前线程T,则会在down函数尚未返回时直接进入了另一个线程的上下文
 * 线程T被唤醒并获得cpu后,继续从被中断的地方开始执行,然后down才返回
 */ 
void down(semaphore_t *sem) {
    uint32_t flags = __down(sem, WT_KSEM);
    assert(flags == 0);
}


bool try_down(semaphore_t *sem) {
    bool intr_flag, ret = 0;
    local_intr_save(intr_flag);
    if (sem->value > 0) {
        sem->value --, ret = 1;
    }
    local_intr_restore(intr_flag);
    return ret;
}

