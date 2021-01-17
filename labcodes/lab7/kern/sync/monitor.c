#include <stdio.h>
#include <monitor.h>
#include <kmalloc.h>
#include <assert.h>

/**************************************************************
 *  基于管程的条件变量的实现
 * ************************************************************/




// Initialize monitor.
void monitor_init (monitor_t * mtp, size_t num_cv) {
    int i;
    assert(num_cv>0);
    mtp->next_count = 0;
    mtp->cv = NULL;
    sem_init(&(mtp->mutex), 1); //unlocked
    sem_init(&(mtp->next), 0);
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
    assert(mtp->cv!=NULL);
    for(i=0; i<num_cv; i++){
        mtp->cv[i].count=0;
        sem_init(&(mtp->cv[i].sem),0);
        mtp->cv[i].owner=mtp;
    }
}

// Unlock one of threads waiting on the condition variable. 
void cond_signal (condvar_t *cvp) {
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
    // 0.如果有等待这个条件变量的进程 => 唤醒在sem上阻塞的进程
    if(cvp->count>0){
        // 0.1 唤醒阻塞在条件变量上的进程
        up(&(cvp->sem));

        // 0.2 由于当前进程唤醒了另一进程,那么当前进程就需要阻塞(阻塞在管程的next信号量上)
        monitor_t* monitor=cvp->owner;
        monitor->next_count++;
        down(&(monitor->next));     

        // 0.3 当前进程被阻塞,此时已经开支执行另一个进程了....

        // 0.4 这个进程被唤醒后并继续执行,monitor的next信号量上的阻塞进程数更新
        monitor->next_count--;
    }

    cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}

// Suspend calling thread on a condition variable waiting for condition Atomically unlocks 
// mutex and suspends calling thread on conditional variable after waking up locks mutex. Notice: mp is mutex semaphore for monitor's procedures
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

    // 0.等待此条件的进程数+1
    cvp->count++;            
    monitor_t* monitor=cvp->owner;

    // 1.有大于等于1个因为执行signal而阻塞的进程,这些进程就睡在monitor.next信号量上(主要是利用next信号量的等待队列)
    if(monitor->next_count>0){           
        up(&(monitor->next));           // 唤醒阻塞队列next上的一个进程
    }
    // 2.没有因为执行signal而阻塞的进程 => 那么需要唤醒的是由于互斥而无法进入管程的进程
    else{
        up(&(monitor->mutex));
    }
   
    // 3.让当前进程阻塞在条件变量的sem上(主要是利用sem的等待队列)
    down(&(cvp->sem));
    
    // 4.此时这个执行流已经暂时停止,cpu转而执行另一个进程了.....
    // 直到这个执行流(进程)被唤醒到就绪队列,等待一段时间后开始执行..

    // 5.被阻塞的进程唤醒了,继续执行,所以条件变量上的count-1
    cvp->count--;

    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}
