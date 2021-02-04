#ifndef __KERN_SYNC_MONITOR_CONDVAR_H__
#define __KERN_SYNC_MOINTOR_CONDVAR_H__

#include <sem.h>
/* In [OS CONCEPT] 7.7 section, the accurate define and approximate implementation of MONITOR was introduced.
 * INTRODUCTION:
 *  Monitors were invented by C. A. R. Hoare and Per Brinch Hansen, and were first implemented in Brinch Hansen's
 *  Concurrent Pascal language. Generally, a monitor is a language construct and the compiler usually enforces mutual exclusion. Compare this with semaphores, which are usually an OS construct.
 * DEFNIE & CHARACTERISTIC:
 *  A monitor is a collection of procedures, variables, and data structures grouped together.
 *  Processes can call the monitor procedures but cannot access the internal data structures.
 *  Only one process at a time may be be active in a monitor.
 *  Condition variables allow for blocking and unblocking.
 *     cv.wait() blocks a process.
 *        The process is said to be waiting for (or waiting on) the condition variable cv.
 *     cv.signal() (also called cv.notify) unblocks a process waiting for the condition variable cv.
 *        When this occurs, we need to still require that only one process is active in the monitor. This can be done in several ways:
 *            on some systems the old process (the one executing the signal) leaves the monitor and the new one enters
 *            on some systems the signal must be the last statement executed inside the monitor.
 *            on some systems the old process will block until the monitor is available again.
 *            on some systems the new process (the one unblocked by the signal) will remain blocked until the monitor is available again.
 *   If a condition variable is signaled with nobody waiting, the signal is lost. Compare this with semaphores, in which a signal will allow a process that executes a wait in the future to no block.
 *   You should not think of a condition variable as a variable in the traditional sense.
 *     It does not have a value.
 *     Think of it as an object in the OOP sense.
 *     It has two methods, wait and signal that manipulate the calling process.
 * IMPLEMENTATION:
 *   monitor mt {
 *     ----------------variable------------------
 *     semaphore mutex;
 *     semaphore next;
 *     int next_count;
 *     condvar {int count, sempahore sem}  cv[N];
 *     other variables in mt;
 *     --------condvar wait/signal---------------
 *     cond_wait (cv) {
 *         cv.count ++;
 *         if(mt.next_count>0)
 *            signal(mt.next)
 *         else
 *            signal(mt.mutex);
 *         wait(cv.sem);
 *         cv.count --;
 *      }
 *
 *      cond_signal(cv) {
 *          if(cv.count>0) {
 *             mt.next_count ++;
 *             signal(cv.sem);
 *             wait(mt.next);
 *             mt.next_count--;
 *          }
 *       }
 *     --------routines in monitor---------------
 *     routineA_in_mt () {
 *        wait(mt.mutex);
 *        ...
 *        real body of routineA
 *        ...
 *        if(next_count>0)
 *            signal(mt.next);
 *        else
 *            signal(mt.mutex);
 *     }
 */

typedef struct monitor monitor_t;

// 条件变量的数据结构
typedef struct condvar{
    semaphore_t sem;        // 通过这个sem,条件变量可直接通过信号量的P、V操作来阻塞、唤醒线程(即实现wait、signal)
    int count;              // 等待条件变量的线程数
    monitor_t * owner;      // 这个条件变量属于哪个管程
} condvar_t;

// 管程的数据结构(一个管程可包含多个条件变量)
typedef struct monitor{
    semaphore_t mutex;      // 互斥信号量,用于保证一次只有一个线程进入管程
    semaphore_t next;       // 这个next用于组织管程中所有由于发出了signal而的阻塞的线程(这些线程就在next的队列上)
    int next_count;         // 由于发出了signal而的阻塞的线程个数(A通过signal唤醒B,则S自身必须被阻塞)
    condvar_t *cv;          // 条件变量数组=>一个管程可有多个条件变量; 
                            //   通过条件变量来组织阻塞线程(条件变量中有信号量,ucore其实是通过信号量来实现wait、signal)
} monitor_t;

// Initialize variables in monitor.
void     monitor_init (monitor_t *cvp, size_t num_cv);

/**
 * 条件变量cvp执行wait()操作 
 * => 阻塞当前线程(顺便也会唤醒一个其他线程)
 */  
void     cond_wait (condvar_t *cvp);      // 阻塞线程


/**
 * 条件变量cvp执行signal()操作 
 * 唤醒一个等待条件变量的线程(顺便也会阻塞当前线程)
 */
void     cond_signal (condvar_t *cvp);   //  唤醒线程

     
#endif /* !__KERN_SYNC_MONITOR_CONDVAR_H__ */
