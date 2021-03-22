#include <stdio.h>
#include <proc.h>
#include <sem.h>
#include <monitor.h>
#include <assert.h>

#define N 5 /* 哲学家数目 */
#define LEFT (i-1+N)%N /* i的左邻号码 */
#define RIGHT (i+1)%N /* i的右邻号码 */
#define THINKING 0 /* 哲学家正在思考 */
#define HUNGRY 1 /* 哲学家想取得叉子 */
#define EATING 2 /* 哲学家正在吃面 */
#define TIMES  4 /* 吃4次饭 */
#define SLEEP_TIME 10

/******************************************************************
 *          基于信号量的哲学家就餐问题
 *          基于管程的哲学家就餐问题
 * 
 * 1.这里的哲学家问题解法很难理解,参考下文可能有点帮助:
 *      https://segmentfault.com/q/1010000011556406
 * 2.
 * ****************************************************************/

/*********************************************************************************************************
                                 philosophers using semaphore 
*********************************************************************************************************/

/*PSEUDO CODE :philosopher problem using semaphore
system DINING_PHILOSOPHERS

VAR
me:    semaphore, initially 1;                    # for mutual exclusion 
s[5]:  semaphore s[5], initially 0;               # for synchronization 
pflag[5]: {THINK, HUNGRY, EAT}, initially THINK;  # philosopher flag 

# As before, each philosopher is an endless cycle of thinking and eating.

procedure philosopher(i)
  {
    while TRUE do
     {
       THINKING;
       take_chopsticks(i);
       EATING;
       drop_chopsticks(i);
     }
  }

# The take_chopsticks procedure involves checking the status of neighboring 
# philosophers and then declaring one's own intention to eat. This is a two-phase 
# protocol; first declaring the status HUNGRY, then going on to EAT.

procedure take_chopsticks(i)
  {
    DOWN(me);               # critical section 
    pflag[i] := HUNGRY;
    test[i];
    UP(me);                 # end critical section 
    DOWN(s[i])              # Eat if enabled 
   }

void test(i)                # Let phil[i] eat, if waiting 
  {
    if ( pflag[i] == HUNGRY
      && pflag[i-1] != EAT
      && pflag[i+1] != EAT)
       then
        {
          pflag[i] := EAT;
          UP(s[i])
         }
    }


# Once a philosopher finishes eating, all that remains is to relinquish the 
# resources---its two chopsticks---and thereby release waiting neighbors.

void drop_chopsticks(int i)
  {
    DOWN(me);                # critical section 
    test(i-1);               # Let phil. on left eat if possible 
    test(i+1);               # Let phil. on rght eat if possible 
    UP(me);                  # up critical section 
   }

*/


//---------- philosophers problem using semaphore ----------------------

int state_sema[N]; /* 记录每个人状态的数组 */
/* 信号量是一个特殊的整型变量 */
semaphore_t mutex; /* 临界区互斥 => 互斥信号量 */ 
semaphore_t s[N]; /* 每个哲学家一个信号量,同步信号量,初始化为0*/ // 这个信号量的含义?

struct proc_struct *philosopher_proc_sema[N];


// 哲学家i尝试获得左右两把叉子
void phi_test_sema(i) /* i：哲学家号码从0到N-1 */
{
    // i的左右都空闲时,他才能进入就餐状态 
    if(state_sema[i]==HUNGRY && state_sema[LEFT]!=EATING
            && state_sema[RIGHT]!=EATING)
    {
        state_sema[i]=EATING;
        up(&s[i]);             // 这里看做是释放一个"资源",从而能够唤醒一个阻塞线程
    }
}


// 哲学家i拿起两只叉子吃饭
void phi_take_forks_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
    down(&mutex); /* 进入临界区 */
    state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
    phi_test_sema(i); /* 试图得到两只叉子 */
    up(&mutex); /* 离开临界区 */
    down(&s[i]); /* 如果得不到叉子就阻塞 */
    /**************************************************************
     * 对这里down(&s[i])的解释:
     * 执行down(&s[i])时存在两种情况 => 
     * 1.phi_test_sema(i)时成功获得叉子,s[i]为1,执行down...
     * 2.phi_test_sema(i)时没有获得叉子(因为左/右有人在吃),s[i]为0,执行down是为了阻塞进程
    ***************************************************************/
}

// 哲学家i放弃左右叉子
void phi_put_forks_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
    down(&mutex); /* 进入临界区 */
    state_sema[i]=THINKING; /* 哲学家进餐结束 */
    phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
    phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
    up(&mutex); /* 离开临界区 */
}


// 每个哲学家都执行此函数
int philosopher_using_semaphore(void * arg) /* i：哲学家号码，从0到N-1 */
{
    int i, iter=0;
    i=(int)arg;
    cprintf("I am No.%d philosopher_sema\n",i);
    while(iter++<TIMES)
    { /* 无限循环 */
        cprintf("Iter %d, No.%d philosopher_sema is thinking\n",iter,i); /* 哲学家正在思考 */
        do_sleep(SLEEP_TIME);
        phi_take_forks_sema(i); 
        /* 需要两只叉子，或者阻塞 */
        cprintf("Iter %d, No.%d philosopher_sema is eating\n",iter,i); /* 进餐 */
        do_sleep(SLEEP_TIME);
        phi_put_forks_sema(i); 
        /* 把两把叉子同时放回桌子 */
    }
    cprintf("No.%d philosopher_sema quit\n",i);
    return 0;    
}

/*********************************************************************************************************
        ---------- philosophers using monitor (condition variable) ----------------------
*********************************************************************************************************/

/*PSEUDO CODE :philosopher problem using monitor
 * monitor dp
 * {
 *  enum {thinking, hungry, eating} state[5];
 *  condition self[5];
 *
 *  void pickup(int i) {
 *      state[i] = hungry;
 *      if ((state[(i+4)%5] != eating) && (state[(i+1)%5] != eating)) {
 *        state[i] = eating;
 *      else
 *         self[i].wait();
 *   }
 *
 *   void putdown(int i) {
 *      state[i] = thinking;
 *      if ((state[(i+4)%5] == hungry) && (state[(i+3)%5] != eating)) {
 *          state[(i+4)%5] = eating;
 *          self[(i+4)%5].signal();
 *      }
 *      if ((state[(i+1)%5] == hungry) && (state[(i+2)%5] != eating)) {
 *          state[(i+1)%5] = eating;
 *          self[(i+1)%5].signal();
 *      }
 *   }
 *
 *   void init() {
 *      for (int i = 0; i < 5; i++)
 *         state[i] = thinking;
 *   }
 * }
 */

struct proc_struct *philosopher_proc_condvar[N]; // N philosopher
int state_condvar[N];                            // the philosopher's state: EATING, HUNGARY, THINKING  
monitor_t mt, *mtp=&mt;                          // monitor

void phi_test_condvar (i) { 
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
            &&state_condvar[RIGHT]!=EATING) {
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
        state_condvar[i] = EATING ;
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
        cond_signal(&mtp->cv[i]) ;
    }
}


void phi_take_forks_condvar(int i) {
    // 1.获取管程的互斥信号量,确保只有一个线程(的相关代码)进入管程
     down(&(mtp->mutex));
//--------into routine in monitor--------------
     // LAB7 EXERCISE1: YOUR CODE
     // I am hungry
     // try to get fork

    // 2.线程真正需要执行的代码...
    state_condvar[i]=HUNGRY;                // 哲学家i饥饿
    phi_test_condvar(i);                    // 哲学家i视图获得左右叉子
    // state_condvar[i]!=EATING 才是真正需要满足的条件,我们定义的条件变量其实只包含队列,不包含条件
    // 真正的条件需要自己判断!!
    if(state_condvar[i]!=EATING){           // 获取叉子失败,阻塞在该哲学家对应的条件变量上
        cond_wait(&(mtp->cv[i]));
    }
//--------leave routine in monitor--------------
    
    // 3.如果有阻塞在管程的next信号量上的线程,将其唤醒
    if(mtp->next_count>0)
        up(&(mtp->next));
    // 4.否则,将阻塞在管程的互斥信号量mutex上的线程唤醒
    else
        up(&(mtp->mutex));
}



void phi_put_forks_condvar(int i) {
    // 1.试图获得互斥信号量,确保只有一个线程进入管程
    down(&(mtp->mutex));

//--------into routine in monitor--------------
     // LAB7 EXERCISE1: YOUR CODE
     // I ate over
     // test left and right neighbors
    
    // 2.线程i真正需要执行的代码...
    state_condvar[i]=THINKING;      // 哲学家进餐结束
    phi_test_condvar(LEFT);         // 看一下左邻居现在能否进餐 
    phi_test_condvar(RIGHT);        // 看一下右邻居现在能否进餐
//--------leave routine in monitor--------------

    // 3.如果有阻塞在管程的next信号量上的线程,将其唤醒
    if(mtp->next_count>0)
        up(&(mtp->next));
    // 4.否则,将阻塞在管程的互斥信号量mutex上的线程唤醒
    else
        up(&(mtp->mutex));
}



// 每一个线程都会执行这部分内容
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
    int i, iter=0;
    i=(int)arg;
    cprintf("I am No.%d philosopher_condvar\n",i);
    while(iter++<TIMES)
    { /* iterate*/
        cprintf("Iter %d, No.%d philosopher_condvar is thinking\n",iter,i); /* thinking*/
        do_sleep(SLEEP_TIME);
        phi_take_forks_condvar(i); 
        /* need two forks, maybe blocked */
        cprintf("Iter %d, No.%d philosopher_condvar is eating\n",iter,i); /* eating*/
        do_sleep(SLEEP_TIME);
        phi_put_forks_condvar(i); 
        /* return two forks back*/
    }
    cprintf("No.%d philosopher_condvar quit\n",i);
    return 0;    
}


// 使用哲学家就餐问题检验同步机制
void check_sync(void){
    int i;
    //check semaphore              => 基于信号量的哲学家就餐问题
    sem_init(&mutex, 1);    // 互斥信号量,初始化为1
    for(i=0;i<N;i++){
        sem_init(&s[i], 0); // 同步信号量,初始化为0
        int pid = kernel_thread(philosopher_using_semaphore, (void *)i, 0);
        if (pid <= 0) {
            panic("create No.%d philosopher_using_semaphore failed.\n");
        }
        philosopher_proc_sema[i] = find_proc(pid);
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
    }


    //check condition variable    => 基于管程的哲学家就餐问题
    monitor_init(&mt, N);
    for(i=0;i<N;i++){
        state_condvar[i]=THINKING;
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
        if (pid <= 0) {
            panic("create No.%d philosopher_using_condvar failed.\n");
        }
        philosopher_proc_condvar[i] = find_proc(pid);
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
    }
}
