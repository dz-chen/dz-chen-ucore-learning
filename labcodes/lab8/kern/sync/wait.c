#include <defs.h>
#include <list.h>
#include <sync.h>
#include <wait.h>
#include <proc.h>

/****************************************************************
 *      等待(阻塞)队列相关操作,信号量和条件变量的基础 => 重要!
 * 
 * **************************************************************/


/********************************************** 等待队列的底层函数 *************************************/

// 使用proc初始化wait_t结构
void wait_init(wait_t *wait, struct proc_struct *proc) {
    wait->proc = proc;
    wait->wakeup_flags = WT_INTERRUPTED;
    list_init(&(wait->wait_link));
}


// 初始化等待队列(主要是初始化其头结点)
void wait_queue_init(wait_queue_t *queue) {
    list_init(&(queue->wait_head));
}


// wait节点插入到等待队列(插入到wait_head的前面)
void wait_queue_add(wait_queue_t *queue, wait_t *wait) {
    assert(list_empty(&(wait->wait_link)) && wait->proc != NULL);
    wait->wait_queue = queue;
    list_add_before(&(queue->wait_head), &(wait->wait_link));
}

// 从等待队列中删除wait节点
void wait_queue_del(wait_queue_t *queue, wait_t *wait) {
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
    list_del_init(&(wait->wait_link));
}

// 获取等待队列queue的下一个结点wait节点
wait_t *wait_queue_next(wait_queue_t *queue, wait_t *wait) {
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
    list_entry_t *le = list_next(&(wait->wait_link));
    if (le != &(queue->wait_head)) {
        return le2wait(le, wait_link);
    }
    return NULL;
}


// 获取等待队列queue的上一个结点wait节点
wait_t *wait_queue_prev(wait_queue_t *queue, wait_t *wait) {
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
    list_entry_t *le = list_prev(&(wait->wait_link));
    if (le != &(queue->wait_head)) {
        return le2wait(le, wait_link);
    }
    return NULL;
}


// 取得等待队列中的第一个结点(最早插入的结点)
// 由于队列是循环的,每次插入时在wait_head的前面插入
// wait_head的下一个结点就是当前整个队列中最早插入的结点
wait_t *wait_queue_first(wait_queue_t *queue) {
    list_entry_t *le = list_next(&(queue->wait_head));
    if (le != &(queue->wait_head)) {
        return le2wait(le, wait_link);
    }
    return NULL;
}

// 取得等待队列中的最后一个结点(最后插入的结点)
wait_t *wait_queue_last(wait_queue_t *queue) {
    list_entry_t *le = list_prev(&(queue->wait_head));
    if (le != &(queue->wait_head)) {
        return le2wait(le, wait_link);
    }
    return NULL;
}
 

 // 判断队列是否空
bool wait_queue_empty(wait_queue_t *queue) {
    return list_empty(&(queue->wait_head));
}

// wait是否已经插入了等待队列
bool wait_in_queue(wait_t *wait) {
    return !list_empty(&(wait->wait_link));
}




/********************************************** 等待队列的高层函数 *************************************/

// 唤醒与指定wait关联的进程 => 唤醒只是将其加入就绪队列,并不立即执行 
void wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
    if (del) {
        wait_queue_del(queue, wait);
    }
    wait->wakeup_flags = wakeup_flags;
    wakeup_proc(wait->proc);           // 将proc放入就绪队列(见proc.h)
}

// 唤醒等待队列中第一个阻塞进程
void wakeup_first(wait_queue_t *queue, uint32_t wakeup_flags, bool del) {
    wait_t *wait;
    if ((wait = wait_queue_first(queue)) != NULL) {
        wakeup_wait(queue, wait, wakeup_flags, del);
    }
}


// 唤醒等待队列中的所有阻塞进程
void wakeup_queue(wait_queue_t *queue, uint32_t wakeup_flags, bool del) {
    wait_t *wait;
    if ((wait = wait_queue_first(queue)) != NULL) {
        if (del) {
            do {
                wakeup_wait(queue, wait, wakeup_flags, 1);
            } while ((wait = wait_queue_first(queue)) != NULL);
        }
        else {
            do {
                wakeup_wait(queue, wait, wakeup_flags, 0);
            } while ((wait = wait_queue_next(queue, wait)) != NULL);
        }
    }
}


// 为当前线程初始化wait结点,并将其加入等待队列！
void wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
    assert(current != NULL);
    wait_init(wait, current);
    current->state = PROC_SLEEPING;
    current->wait_state = wait_state;
    wait_queue_add(queue, wait);
}

