#ifndef __KERN_SYNC_WAIT_H__
#define __KERN_SYNC_WAIT_H__

#include <list.h>

typedef struct {
    list_entry_t wait_head;            // wait_queue的队头
} wait_queue_t;

struct proc_struct;

// 等待队列上的一个节点(通过wait_link与队列联系)
// 可见,ucore实现中不止一个等待/阻塞队列; 而就绪队列只有一个!
typedef struct {
    struct proc_struct *proc;           // 等待/阻塞进程
    uint32_t wakeup_flags;              // 进程被放入等待队列的原因标记
    wait_queue_t *wait_queue;           // 此wait_t结构所属的wait_queue
    list_entry_t wait_link;             // 通过这个结点链接到对应的wait_queue
} wait_t;

// 从等待队列的节点,转换到wait_t结构
#define le2wait(le, member)         \   
    to_struct((le), wait_t, member)

void wait_init(wait_t *wait, struct proc_struct *proc);
void wait_queue_init(wait_queue_t *queue);
void wait_queue_add(wait_queue_t *queue, wait_t *wait);
void wait_queue_del(wait_queue_t *queue, wait_t *wait);

wait_t *wait_queue_next(wait_queue_t *queue, wait_t *wait);
wait_t *wait_queue_prev(wait_queue_t *queue, wait_t *wait);
wait_t *wait_queue_first(wait_queue_t *queue);
wait_t *wait_queue_last(wait_queue_t *queue);

bool wait_queue_empty(wait_queue_t *queue);
bool wait_in_queue(wait_t *wait);
void wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del);
void wakeup_first(wait_queue_t *queue, uint32_t wakeup_flags, bool del);
void wakeup_queue(wait_queue_t *queue, uint32_t wakeup_flags, bool del);

void wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state);

#define wait_current_del(queue, wait)                                       \
    do {                                                                    \
        if (wait_in_queue(wait)) {                                          \
            wait_queue_del(queue, wait);                                    \
        }                                                                   \
    } while (0)

#endif /* !__KERN_SYNC_WAIT_H__ */

