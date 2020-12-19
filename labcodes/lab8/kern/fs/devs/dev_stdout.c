#include <defs.h>
#include <stdio.h>
#include <dev.h>
#include <vfs.h>
#include <iobuf.h>
#include <inode.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>

/******************************************************************************
 *                            对stdout的操作
 * 1.这些操作作为函数指针传递给struct device结构体,见stdout_device_init
 * 2.重点关注stdout_io() => cputchar() 看一下更底层的细节
 * ****************************************************************************/

static int
stdout_open(struct device *dev, uint32_t open_flags) {
    if (open_flags != O_WRONLY) {       // 只写
        return -E_INVAL;
    }
    return 0;
}

static int
stdout_close(struct device *dev) {
    return 0;
}


/**
 * 完成向stdout写数据
 * 将缓冲区iob(struct iobuf)中的数据写到stdout
 * => 建议关注调用的cputchar,看一下底层是如何写到设备的!!!
 * */
static int stdout_io(struct device *dev, struct iobuf *iob, bool write) {
    if (write) {
        char *data = iob->io_base;                      // 缓冲区基址
        for (; iob->io_resid != 0; iob->io_resid --) {
            cputchar(*data ++); // 通过外设驱动将数据输出到串口、并口、CGA... => 见kern/libs/stdio.c,必看!!!
        }
        return 0;
    }
    return -E_INVAL;
}

static int
stdout_ioctl(struct device *dev, int op, void *data) {
    return -E_INVAL;
}


/**
 * 初始化传入的dev结构体中的成员变量、成员函数
 * dev->d_blocks = 0; dev->d_blocksize = 1;
 * dev->d_open = stdout_open;  dev->d_close = stdout_close;
 * ......
 * */
static void stdout_device_init(struct device *dev) {
    dev->d_blocks = 0;
    dev->d_blocksize = 1;
    dev->d_open = stdout_open;
    dev->d_close = stdout_close;
    dev->d_io = stdout_io;
    dev->d_ioctl = stdout_ioctl;
}

/**
 * 初始化stdout设备
 * 包括:创建并初始化inode结点、初始化inode对应的device的成员、将设备加入链表
 **/
void dev_init_stdout(void) {
    struct inode *node;
    if ((node = dev_create_inode()) == NULL) {    //创建一个inode,并完成其部分初始化
        panic("stdout: dev_create_node.\n");
    }

    // vop_info()用于设置inode的__device_info成员(struct device类型), 并返回device的指针
    stdout_device_init(vop_info(node, device));   // 初始化设备; 

    int ret;
    if ((ret = vfs_add_dev("stdout", node, 0)) != 0) {  // 为传入的参数创建一个vfs_dev_t,然后将其加入设备链表
        panic("stdout: vfs_add_dev: %e.\n", ret);
    }
}

