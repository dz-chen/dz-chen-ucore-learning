#include <defs.h>
#include <stdio.h>
#include <wait.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <dev.h>
#include <vfs.h>
#include <iobuf.h>
#include <inode.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>

#define STDIN_BUFSIZE               4096

// stdin的缓冲区(stdout没有!!)
static char stdin_buffer[STDIN_BUFSIZE];

// 整型:对stdin的buffer的读写指针
static off_t p_rpos, p_wpos;                    

// 等待读写stdin缓冲区的阻塞队列!
static wait_queue_t __wait_queue, *wait_queue = &__wait_queue;  

/****************************************************************************************
 *                            对stdin的操作
 * 1.这些操作为函数指针传递给struct device结构体,见stdin_device_init
 * 2.重点关注dev_stdin_write()被调用的时间(trap.c),尤其是cons_getc(),看一下更底层的细节
 * 3.stdin只可读  <==> 而stdout是只可写
 * 4.不过stdin在内存中有buffer(将从stdin读取的数据放到buffer);多个进程共用buffer,有等待队列!! 
 *   <==> 而stdout是每个进程直接往外设写,在内存中没有缓冲区!
 * 4.这里的stdin_buffer其实就是一个互斥信号量... => 与__down()函数对比!
 * 5.键盘中断发生时,cons_getc()驱动程序从外设读数据到stdin_buffer;
 *      进程需要数据时是从stdin_buffer读取,而不是直接从外设读取!!!
 * **************************************************************************************/

/**
 * 在键盘中断发生后,先调用理解cons_getc()获取字符
 * 再调用dev_stdin_write()将字符写到stdin_buffer
 * 详见trap.c/trap_dispatch() 
 * */
void dev_stdin_write(char c) {
    bool intr_flag;
    if (c != '\0') {
        local_intr_save(intr_flag);
        {
            stdin_buffer[p_wpos % STDIN_BUFSIZE] = c;
            if (p_wpos - p_rpos < STDIN_BUFSIZE) {
                p_wpos ++;
            }
            if (!wait_queue_empty(wait_queue)) {       // 从阻塞队列唤醒进程
                wakeup_queue(wait_queue, WT_KBD, 1);
            }
        }
        local_intr_restore(intr_flag);
    }
}


/**
 * 从stdin_buffer(可理解为键盘中的数据在内存的映射)中读取长度为len的数据到buf中
 * 如果没有数据,则阻塞进程!!!
 * */
static int dev_stdin_read(char *buf, size_t len) {
    int ret = 0;
    bool intr_flag;                                             // 关中断
    local_intr_save(intr_flag);
    {
        for (; ret < len; ret ++, p_rpos ++) {
            try_again:
                if (p_rpos < p_wpos) {                          // 读指针小于写指针=>有键盘输入新字符,读...
                    *buf ++ = stdin_buffer[p_rpos % STDIN_BUFSIZE];
                }
                else {                                // 没有新字符=> 调用read用户态函数的进程需要阻塞,等待字符产生
                    wait_t __wait, *wait = &__wait;
                    wait_current_set(wait_queue, wait, WT_KBD);  // 阻塞进程,阻塞原因:WT_KBD
                    local_intr_restore(intr_flag);

                    schedule();                       // 选取新的进程执行,进入另一个进程的上下文...

                    // 这个阻塞进程被唤醒后才继续执行,唤醒时间见trap.c 

                    local_intr_save(intr_flag);
                    wait_current_del(wait_queue, wait);
                    if (wait->wakeup_flags == WT_KBD) {
                        goto try_again;
                    }
                    break;
                }
        }
    }
    local_intr_restore(intr_flag);
    return ret;
}

static int
stdin_open(struct device *dev, uint32_t open_flags) {
    if (open_flags != O_RDONLY) {
        return -E_INVAL;
    }
    return 0;
}

static int
stdin_close(struct device *dev) {
    return 0;
}


/**
 * 从stdin读数据(将stdin_buffer中的数据读到iob中)
 * 
 * */
static int stdin_io(struct device *dev, struct iobuf *iob, bool write) {
    if (!write) {           // 只读
        int ret;
        if ((ret = dev_stdin_read(iob->io_base, iob->io_resid)) > 0) {
            iob->io_resid -= ret;
        }
        return ret;
    }
    return -E_INVAL;
}

static int
stdin_ioctl(struct device *dev, int op, void *data) {
    return -E_INVAL;
}


/**
 * 1.初始化传入的dev结构体中的成员变量、成员函数
 * 2.初始化stdin缓冲区的读写指针
 * 3.初始化stdin缓冲区的等待队列
 * */
static void stdin_device_init(struct device *dev) {
    dev->d_blocks = 0;
    dev->d_blocksize = 1;
    dev->d_open = stdin_open;
    dev->d_close = stdin_close;
    dev->d_io = stdin_io;
    dev->d_ioctl = stdin_ioctl;

    p_rpos = p_wpos = 0;                
    wait_queue_init(wait_queue);
}


/**
 * 初始化stdin文件设备
 * 包括:创建并初始化inode结点、初始化inode对应的device的成员、将设备加入链表
 * */
void dev_init_stdin(void) {
    struct inode *node;
    if ((node = dev_create_inode()) == NULL) {
        panic("stdin: dev_create_node.\n");
    }
    stdin_device_init(vop_info(node, device));

    int ret;
    if ((ret = vfs_add_dev("stdin", node, 0)) != 0) {
        panic("stdin: vfs_add_dev: %e.\n", ret);
    }
}

