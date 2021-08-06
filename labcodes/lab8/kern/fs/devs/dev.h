#ifndef __KERN_FS_DEVS_DEV_H__
#define __KERN_FS_DEVS_DEV_H__

#include <defs.h>


/*************************************************************************************************
 *                  设备文件IO层:将所有设备模型化为文件
 * 1.device通过与类型为设备的inode关联(见vfs_dev_t)被模型化为文件 !!
 * 
 * 2.device 这个数据结构能够支持对块设备(比如磁盘)、字符设备(比如键盘、串口)的表示,完成对设备的基本操作;
 * 
 * 3.ucore虚拟文件系统为了把这些设备链接在一起,定义了一个设备链表,即双向链表vdev_list,
 *      通过访问此链表,可以找到ucore能够访问的所有设备文件: vfs_dev_t -> inode -> in_info = device
 *
 * 
 * **********************************************************************************************/




struct inode;
struct iobuf;

/**
 * Filesystem-namespace-accessible device.
 * d_io is for both reads and writes; the iobuf will indicates the direction.
 * 
 * 设备访问接口
 * vfs_dev_t结构将device与inode联系起来(见kern/fs/vfs/vfsdev.c),必看!
 * => 即:vfs_dev_t -> inode -> in_info = device
 */
struct device {
    size_t d_blocks;                                                // 设备占用的数据块的个数
    size_t d_blocksize;                                             // 数据块大小
    int (*d_open)(struct device *dev, uint32_t open_flags);         // 打开设备的函数指针...
    int (*d_close)(struct device *dev);                             
    int (*d_io)(struct device *dev, struct iobuf *iob, bool write); // 读/写的操作
    int (*d_ioctl)(struct device *dev, int op, void *data);         // 用ioctl方式控制设备的函数指针
};

#define dop_open(dev, open_flags)           ((dev)->d_open(dev, open_flags))
#define dop_close(dev)                      ((dev)->d_close(dev))
#define dop_io(dev, iob, write)             ((dev)->d_io(dev, iob, write))
#define dop_ioctl(dev, op, data)            ((dev)->d_ioctl(dev, op, data))

void dev_init(void);
struct inode *dev_create_inode(void);

#endif /* !__KERN_FS_DEVS_DEV_H__ */

