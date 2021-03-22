#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>
#include <proc.h>
#include <sem.h>

//pre define
struct mm_struct;

/***
 * the virtual continuous memory area(vma), [vm_start, vm_end),
 * addr belong to a vma means  vma.vm_start<= addr <vma.vm_end
 * 描述了一个虚拟内存段
 * */ 
struct vma_struct {
    struct mm_struct *vm_mm; // 当前vma_struct所属的mm_struct
    uintptr_t vm_start;      // 该虚拟内存段的起始虚拟地址     
    uintptr_t vm_end;        // 该虚拟内存段的终止虚拟地址 
    uint32_t vm_flags;       // flags of vma => 主要标志该虚拟地址段的读、写、执行权限
    list_entry_t list_link;  // linear list link which sorted by start addr of vma => 链接属于同一个mm_struct的所有虚拟内存段
};

#define le2vma(le, member)                  \
    to_struct((le), struct vma_struct, member)

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004
#define VM_STACK                0x00000008

/***
 * the control struct for a set of vma using the same PDT
 *                 memory manage struct
 * 1.是进程/线程控制块task_struct的成员,负责管理当前进程的虚拟内存空间
 * 2.进程有自己的页表(及页目录表),每个进程的虚拟地址空间使用该进程的页表而不是内核的页表
 * 3.为了实现多线程,一个mm_struct对应一个进程,但是它被多个线程共享(见mm_count)！
 * */
struct mm_struct {
    list_entry_t mmap_list;        // 链表(它是链表头结点,不含数据) => 链接mm_struct管理的所有vma_struct(链表按照各区域的起始va排序)
    struct vma_struct *mmap_cache; // 指向当前正在使用的vma_struct(即段)
                                   // 由于局部性原理,当前正在使用的虚拟地址空间接下来可能还会使用,这时就不需要查链表,而是直接使用这个指针.从而加快查询速度
    pde_t *pgdir;                  // mm_struct维护的页目录表(每个进程不一样 => 所有内线程共享boot_pgdir; 一个用户进程内的所以线程共享一个相同的pgdir)
    int map_count;                 // mmap_list中链接的vma_struct的个数
    void *sm_priv;                 // the private data for swap manager/就是页面置换的FIFO队列
                                   //  => 就是页面置换的FIFO队列(从而建立了mm_struct和swap_mmanager之间的联系,见swap_fifo.c)
                                   // 见swap_fifo.c下的_fifo_init_mm函数
    int mm_count;                  // the number of process which shared the mm => 线程数,进程内的多个线程共享一个mm_struct
    semaphore_t mm_sem;            // 用于保证对mm_strcut的互斥访问,详见lock_mm、unlock_mm 
    int locked_by;                 // the lock owner process's pid
};

struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void vmm_init(void);
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store);
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr);

int mm_unmap(struct mm_struct *mm, uintptr_t addr, size_t len);
int dup_mmap(struct mm_struct *to, struct mm_struct *from);
void exit_mmap(struct mm_struct *mm);
uintptr_t get_unmapped_area(struct mm_struct *mm, size_t len);
int mm_brk(struct mm_struct *mm, uintptr_t addr, size_t len);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);
bool copy_string(struct mm_struct *mm, char *dst, const char *src, size_t maxn);


/**
 * 返回共享此mm_struct的线程个数
 **/  
static inline int mm_count(struct mm_struct *mm) {
    return mm->mm_count;
}

/***
 * 设置共享一个mm_struct的进程数
 * => 准确说应该是线程,多个线程共享相同的虚拟地址空间,通过 mm->mm_count方便实现进程内的多线程
 * **/
static inline void set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
}


// 共享mm的线程数+1
static inline int mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
    return mm->mm_count;
}


// 共享mm_struct的线程数-1
static inline int mm_count_dec(struct mm_struct *mm) {
    mm->mm_count -= 1;
    return mm->mm_count;
}


/**
 * 尝试获取mm_struct上的锁
 * 如果获取成功,则当前线程对mm有独占权
 * 如果获取失败,则当前线程被阻塞
 * => 通过mm_struct上的信号量mm_sem实现锁,这本质就是P操作
 **/ 
static inline void lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        down(&(mm->mm_sem));
        if (current != NULL) {
            mm->locked_by = current->pid;
        }
    }
}


/**
 * 释放mm_struct上的锁...
 * 就是对mm_struct上的信号量mm_sem做V操作
 */ 
static inline void unlock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        up(&(mm->mm_sem));
        mm->locked_by = 0;
    }
}

#endif /* !__KERN_MM_VMM_H__ */

