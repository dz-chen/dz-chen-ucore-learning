#include <stdio.h>
#include <monitor.h>
#include <kmalloc.h>
#include <assert.h>

/*************************************************************
 *                      管程实现
 * ***********************************************************/
// Initialize monitor.
// 初始化管程mtp(动态分配num_cv个条件条件变量)
void monitor_init (monitor_t * mtp, size_t num_cv) {
    int i;
    assert(num_cv>0);
    mtp->next_count = 0;
    mtp->cv = NULL;
    sem_init(&(mtp->mutex), 1); //unlocked
    sem_init(&(mtp->next), 0);
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);   // 分配条件变量(num_cv个)
    assert(mtp->cv!=NULL);
    for(i=0; i<num_cv; i++){                // 初始化管程内的所有条件变量
        mtp->cv[i].count=0;
        sem_init(&(mtp->cv[i].sem),0);  // 初始化为0的原因:同步信号量,而不是互斥
        mtp->cv[i].owner=mtp;
    }
}


/**
 * 条件变量cvp执行wait()操作 
 * => 阻塞当前线程(顺便也会唤醒一个其他线程)
 */  
void cond_wait (condvar_t *cvp) {
    //LAB7 EXERCISE1: YOUR CODE
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
    /*
        *         cv.count ++;
        *         if(mt.next_count>0)
        *            signal(mt.next)
        *         else
        *            signal(mt.mutex);
        *         wait(cv.sem);
        *         cv.count --;
        */
    // 0.等待此条件的线程数+1
    cvp->count++;
    monitor_t* mt=cvp->owner;

    // 1.有大于等于1个因为执行signal而阻塞的线程,这些线程就睡眠在monitor.next信号量上(主要是利用next信号量的阻塞队列)
    if(mt->next_count > 0){
        up(&(mt->next));       // 唤醒阻塞队列next上的一个线程
    }
    // 2.没有因为执行signal而阻塞的线程 => 那么需要唤醒的是由于互斥而无法进入管程的线程
    else{
        up(&(mt->mutex));
    }

    // 3.让当前线程阻塞在条件变量的sem上
    down(&(cvp->sem));

    // 4.此时cond_wait的控制流已经暂时停止,cpu转而执行另一个线程
    // ......知道这个线程被唤醒到就绪队列,等待一段时间后开始执行

    // 5.被阻塞的线程唤醒了,继续执行,所以条件变量上的count-1
    cvp->count--;
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}

/**
 * 条件变量cvp执行signal()操作 
 * 唤醒一个等待条件变量的线程(顺便也会阻塞当前线程)
 */
void  cond_signal (condvar_t *cvp) {
    //LAB7 EXERCISE1: YOUR CODE
    cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
    /*
    *      cond_signal(cv) {
    *          if(cv.count>0) {
    *             mt.next_count ++;
    *             signal(cv.sem);
    *             wait(mt.next);
    *             mt.next_count--;
    *          }
    *       }
    */
    // 0.如果有等待这个条件变量的线程 => 唤醒一个阻塞在条件变量(的sem队列)上的线程
    if(cvp->count>0){
        // 0.1 唤醒一个阻塞在条件变量上的线程
        up(&(cvp->sem));

        // 0.2 由于当前线程唤醒了另一个线程,那么当前线程就需要阻塞(不过不是阻塞在条件变量,而是阻塞到管程的next信号量上)
        monitor_t* mt=cvp->owner;
        mt->next_count++;
        down(&(mt->next));

        // 0.3 当前线程被阻塞,此时已经开始指令另一个线程...

        // 0.4 这个线程被唤醒并继续执行,更新monitor的next信号量上的阻塞线程数
        mt->next_count--;
    }
    cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}


