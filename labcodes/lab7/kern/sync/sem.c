#include <defs.h>
#include <wait.h>
#include <atomic.h>
#include <kmalloc.h>
#include <sem.h>
#include <proc.h>
#include <sync.h>
#include <assert.h>

/**************************************************************
 * 内核级信号量及其操作 => 重要
 * ucore中信号量的实现,需要基于开/关中断机制
 * ************************************************************/


// 初始化信号量(内部会初始化该信号量对应的等待队列)
// 如果是互斥信号量则将val初始化为1; 同步信号量则初始化为0
void sem_init(semaphore_t *sem, int value) {
    sem->value = value;
    wait_queue_init(&(sem->wait_queue));
}


// P操作的具体实现(wait_state表示阻塞的原因)
static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag);                 // 关中断
    if (sem->value > 0) {                       // 可获得资源
        sem->value --;
        local_intr_restore(intr_flag);
        return 0;
    }

    // 资源不足 => 阻塞当前进程,放入这个sem的阻塞队列; 设置被阻塞的原因为wait_state
    wait_t __wait, *wait = &__wait;
    wait_current_set(&(sem->wait_queue), wait, wait_state); // 此函数:为当前进程初始化wait结点,并将其加入等待队列！
    local_intr_restore(intr_flag);              // 开中断

    // 运行调度器选择另一个进程执行
    schedule();     // => 进入schedule后,便已经是另一个进程的上下文了...

    // ....执行另一个进程
    // 当这个被阻塞的进程被唤醒后,回到它的上下文,从schedule()后接着执行

    //如果被V操作唤醒,则把自身关联的wait从等待队列中删除 
    // => 个人感觉这个操作放到_up函数(唤醒进程时)中逻辑更好一点?
    local_intr_save(intr_flag);
    wait_current_del(&(sem->wait_queue), wait);
    local_intr_restore(intr_flag);

    if (wait->wakeup_flags != wait_state) {         //按理说应该相等!
        return wait->wakeup_flags;  
    }
    return 0;
}


// V操作的具体实现
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag);                     // 关中断
    {
        wait_t *wait;
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {   //队列中没有等待进程
            sem->value ++;
        }
        else {              // 唤醒wait对应的进程,wakeup_wait会将其加入就绪队列
            assert(wait->proc->wait_state == wait_state);    // 有等待进程且等待的原因是这个信号量设置的,则唤醒进程
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
        }
    }
    local_intr_restore(intr_flag);                 // 开中断
}





/****************************** 信号量操作(P/V)的包装函数 *******************************************/

// P操作
void down(semaphore_t *sem) {
    uint32_t flags = __down(sem, WT_KSEM);  //阻塞原因:WT_KSEM(wait kernel semaphore)
    assert(flags == 0);
}


// V操作
void up(semaphore_t *sem) {
    __up(sem, WT_KSEM);
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

