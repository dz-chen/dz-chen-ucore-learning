#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <defs.h>
#include <mmu.h>
#include <sem.h>
#include <atomic.h>

#define SECTSIZE            512
#define PAGE_NSECT          (PGSIZE / SECTSIZE)

#define SWAP_DEV_NO         1       // 交换分区
#define DISK0_DEV_NO        2       // 第一块磁盘
#define DISK1_DEV_NO        3       // 第二块磁盘

void fs_init(void);
void fs_cleanup(void);

struct inode;
struct file;

/*
 * process's file related informaction
 * 文件控制块(进程内多个线程共享)
 * 进程/线程访问文件的数据接口,即它是进程/线程的成员变量(见process/proc.h)
 */
struct files_struct {
    struct inode *pwd;      // 进程当前执行目录的内存指针 (print work directory)
    struct file *fd_array;  // 进程打开文件的数组(或者就叫打开文件表)
    int files_count;        // 进程内访问此文件控制块的线程数,即代表着进程内的线程数
    semaphore_t files_sem;  // 确保对进程控制块中files_struct的互斥访问
};

#define FILES_STRUCT_BUFSIZE                       (PGSIZE - sizeof(struct files_struct))
#define FILES_STRUCT_NENTRY                        (FILES_STRUCT_BUFSIZE / sizeof(struct file))

void lock_files(struct files_struct *filesp);
void unlock_files(struct files_struct *filesp);

struct files_struct *files_create(void);
void files_destroy(struct files_struct *filesp);
void files_closeall(struct files_struct *filesp);
int dup_files(struct files_struct *to, struct files_struct *from);

/*返回共享文件控制块的线程数*/
static inline int files_count(struct files_struct *filesp) {
    return filesp->files_count;
}

/**
 * 共享文件控制块的线程数+1
 **/
static inline int files_count_inc(struct files_struct *filesp) {
    filesp->files_count += 1;
    return filesp->files_count;
}

/**
 * 共享文件控制块的线程数-1
 */ 
static inline int files_count_dec(struct files_struct *filesp) {
    filesp->files_count -= 1;
    return filesp->files_count;
}

#endif /* !__KERN_FS_FS_H__ */

