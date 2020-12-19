#include <defs.h>
#include <mmu.h>
#include <sem.h>
#include <ide.h>
#include <inode.h>
#include <kmalloc.h>
#include <dev.h>
#include <vfs.h>
#include <iobuf.h>
#include <error.h>
#include <assert.h>


#define DISK0_BLKSIZE                   PGSIZE                      // 一页4096字节
#define DISK0_BUFSIZE                   (4 * DISK0_BLKSIZE)         //一个disk0_buffer 4字节
#define DISK0_BLK_NSECT                 (DISK0_BLKSIZE / SECTSIZE)  // 一个disk0块占8个扇区

// 磁盘数据在内存的缓冲,见disk0_device_init(),动态分配内存;4个page
static char *disk0_buffer;

// 信号量,disk0是互斥访问的!
static semaphore_t disk0_sem;

/******************************************************************************
 *                            对disk0的操作
 * 0. disk0就是磁盘设备,在ucore中默认使用ide接口
 * 1.这些操作作为函数指针传递给struct device结构体,见stdout_device_init
 * 3.注意磁盘时互斥访问的,这里通过锁(基于信号量)保证互斥
 * 4.对磁盘的读写都经过了disk0_buffer作为中转!!!
 * ****************************************************************************/


/**
 * 基于信号量的锁
 * */
static void lock_disk0(void) {
    down(&(disk0_sem));
}

static void
unlock_disk0(void) {
    up(&(disk0_sem));
}

static int
disk0_open(struct device *dev, uint32_t open_flags) {
    return 0;
}

static int
disk0_close(struct device *dev) {
    return 0;
}


/**
 * 从磁盘读数据
 * 即:从磁盘blkno开始的nblks块数据读取到disk0_buffer
 * */
static void
disk0_read_blks_nolock(uint32_t blkno, uint32_t nblks) {
    int ret;
    uint32_t sectno = blkno * DISK0_BLK_NSECT, nsecs = nblks * DISK0_BLK_NSECT;
    if ((ret = ide_read_secs(DISK0_DEV_NO, sectno, disk0_buffer, nsecs)) != 0) {
        panic("disk0: read blkno = %d (sectno = %d), nblks = %d (nsecs = %d): 0x%08x.\n",
                blkno, sectno, nblks, nsecs, ret);
    }
}

/**
 * 写数据到磁盘
 * 即:将disk0_buffer中的nblks块的数据,写到磁盘blkno处
 * */
static void
disk0_write_blks_nolock(uint32_t blkno, uint32_t nblks) {
    int ret;
    uint32_t sectno = blkno * DISK0_BLK_NSECT, nsecs = nblks * DISK0_BLK_NSECT;
    if ((ret = ide_write_secs(DISK0_DEV_NO, sectno, disk0_buffer, nsecs)) != 0) {
        panic("disk0: write blkno = %d (sectno = %d), nblks = %d (nsecs = %d): 0x%08x.\n",
                blkno, sectno, nblks, nsecs, ret);
    }
}


/**
 * 对disk0的io操作
 * 将iob中数据写到磁盘 或者 从磁盘读取数据到iob
 * */
static int disk0_io(struct device *dev, struct iobuf *iob, bool write) {
    off_t offset = iob->io_offset;
    size_t resid = iob->io_resid;
    uint32_t blkno = offset / DISK0_BLKSIZE;
    uint32_t nblks = resid / DISK0_BLKSIZE;

    /* don't allow I/O that isn't block-aligned => ucore中为了简便,必须block对齐,但是比较浪费空间 */
    if ((offset % DISK0_BLKSIZE) != 0 || (resid % DISK0_BLKSIZE) != 0) {
        return -E_INVAL;
    }

    /* don't allow I/O past the end of disk0 */
    if (blkno + nblks > dev->d_blocks) {
        return -E_INVAL;
    }

    /* read/write nothing ? */
    if (nblks == 0) {
        return 0;
    }

    lock_disk0();                               // 锁住硬盘(这个锁由信号量实现)
    while (resid != 0) {
        size_t copied, alen = DISK0_BUFSIZE;
        if (write) {                            // 1.写
            iobuf_move(iob, disk0_buffer, alen, 0, &copied);      // 从iob复制数据到disk0_buffer
            assert(copied != 0 && copied <= resid && copied % DISK0_BLKSIZE == 0);
            nblks = copied / DISK0_BLKSIZE;
            disk0_write_blks_nolock(blkno, nblks);
        }
        else {                                  // 2.读
            if (alen > resid) {
                alen = resid;
            }
            nblks = alen / DISK0_BLKSIZE;
            disk0_read_blks_nolock(blkno, nblks);
            iobuf_move(iob, disk0_buffer, alen, 1, &copied);      // 从disk0_buffer复制数据到iob
            assert(copied == alen && copied % DISK0_BLKSIZE == 0);
        }
        resid -= copied, blkno += nblks;
    }
    unlock_disk0();
    return 0;
}

static int
disk0_ioctl(struct device *dev, int op, void *data) {
    return -E_UNIMP;
}


/**
  * 初始化传入的dev结构体中的成员变量、成员函数
  * 注意:会检查设备是否可用、会初始化disk0的信号量、会分配内存缓冲区
 * */
static void disk0_device_init(struct device *dev) {
    static_assert(DISK0_BLKSIZE % SECTSIZE == 0);
    if (!ide_device_valid(DISK0_DEV_NO)) {              // 检查disk0磁盘是否可用
        panic("disk0 device isn't available.\n");
    }
    dev->d_blocks = ide_device_size(DISK0_DEV_NO) / DISK0_BLK_NSECT;
    dev->d_blocksize = DISK0_BLKSIZE;
    dev->d_open = disk0_open;
    dev->d_close = disk0_close;
    dev->d_io = disk0_io;
    dev->d_ioctl = disk0_ioctl;
    sem_init(&(disk0_sem), 1);              // disk0是互斥访问的

    static_assert(DISK0_BUFSIZE % DISK0_BLKSIZE == 0);
    if ((disk0_buffer = kmalloc(DISK0_BUFSIZE)) == NULL) {  // 初始化磁盘数据在内存的缓冲区
        panic("disk0 alloc buffer failed.\n");
    }
}


/**
 * 初始化disk0设备
 * 包括:创建并初始化inode结点、初始化inode对应的device的成员、将设备加入链表
 **/
void dev_init_disk0(void) {
    struct inode *node;
    if ((node = dev_create_inode()) == NULL) {
        panic("disk0: dev_create_node.\n");
    }
    disk0_device_init(vop_info(node, device));

    int ret;
    if ((ret = vfs_add_dev("disk0", node, 1)) != 0) {
        panic("disk0: vfs_add_dev: %e.\n", ret);
    }
}

