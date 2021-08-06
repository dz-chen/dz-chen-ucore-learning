#ifndef __KERN_FS_SFS_SFS_H__
#define __KERN_FS_SFS_SFS_H__

#include <defs.h>
#include <mmu.h>
#include <list.h>
#include <sem.h>
#include <unistd.h>

/***********************************************************************************************
 *                                          SFS
 * 1.Simple FS (SFS) definitions visible to ucore. This covers the on-disk format and is used by
 * tools that work on SFS volumes, such as mksfs.
 * 2.为了简单,ucore中SFS的一个block对应一个page(4k=8个扇区)
 * 3.SFS文件系统(位于disk0)布局 => |super block| root-dir inode| freemap | (inode)/(file data)/(dir data) blocks|
 *     3.1 超块用于记录文件系统信息
 *     3.2 超块之后紧接着的一个block是root-dir inode,用于记录根目录相关信息
 *     3.3 freemap是所有block的位图,相关操作见bitmap.[ch]
 * 4.ucore为了简单,一个inode虽然不满一个block,但是依然独占整个block
 * 5.SFS文件系统的信息是如何加载到内存的? => 见sfs_fs.c下的sfs_do_mount(),它加载超块和位图这两个全局信息
 * 6.区分inode和disk_inode => 前者在打开文件后才创建,它的某个成员就是disk_inode的指针!!
 * 7.注意sfs_disk_inode如何表示目录的!!!
 * 8.ucore直接使用磁盘块号作为索引节点的编号(别的系统不一定)
 ***********************************************************************************************/

#define SFS_MAGIC                                   0x2f8dbe2a              /* magic number for sfs */
#define SFS_BLKSIZE                                 PGSIZE                  /* size of block */
#define SFS_NDIRECT                                 12                      /* # of direct blocks in inode */
#define SFS_MAX_INFO_LEN                            31                      /* max length of infomation */
#define SFS_MAX_FNAME_LEN                           FS_MAX_FNAME_LEN        /* max length of filename */
#define SFS_MAX_FILE_SIZE                           (1024UL * 1024 * 128)   /* max file size (128M)=> 由于只使用了一级间接索引,128M应该不正确!! */
#define SFS_BLKN_SUPER                              0                       /* block the superblock lives in */
#define SFS_BLKN_ROOT                               1                       /* location of the root dir inode */
#define SFS_BLKN_FREEMAP                            2                       /* 1st block of the freemap */

/* # of bits in a block */
#define SFS_BLKBITS                                 (SFS_BLKSIZE * CHAR_BIT)

/* # of entries in a block => 1024,一级间接索引的条目个数 */
#define SFS_BLK_NENTRY                              (SFS_BLKSIZE / sizeof(uint32_t))

/* file types */
#define SFS_TYPE_INVAL                              0       /* Should not appear on disk */
#define SFS_TYPE_FILE                               1       // 普通文件
#define SFS_TYPE_DIR                                2       // 目录
#define SFS_TYPE_LINK                               3       // 硬链接




/**
 * On-disk superblock
 * 超块(文件系统的第一个block),包含文件系统的基本信息
 * 
 *                          SFS在磁盘上的布局
 * **********************************************************************
 * | superblock | root-dir node |  freemap | inode、file data、dir data |
 * **********************************************************************
 * 
 * 挂载SFS的地方,参考:sfs_fs.c/sfs_do_mount()
 **/
struct sfs_super {
    uint32_t magic;                           /* magic number, should be SFS_MAGIC => 通过这个字段来判断从磁盘加载的文件系统是不是SFS */
    uint32_t blocks;                          /* # of blocks in fs                 => 所有block的数量(ucore以block=4K为基本单位) */
    uint32_t unused_blocks;                   /* # of unused blocks in fs          => 尚未使用的block数量 */
    char info[SFS_MAX_INFO_LEN + 1];          /* infomation for sfs                => 只是一个字符串 "simple file system" */
};

/**
 * filesystem for sfs
 * 在内存 中表示整个具体的文件系统,fs -> sfs_fs 指向这个具体的文件系统
 */
struct sfs_fs {
    struct sfs_super super;                         /* on-disk superblock => 超级块,包含关于文件系统的所有关键参数 */
    struct device *dev;                             /* device mounted on */
    struct bitmap *freemap;                         /* blocks in use are mared 0 */
    bool super_dirty;                               /* true if super/freemap modified */
    void *sfs_buffer;                               /* buffer for non-block aligned io */
    semaphore_t fs_sem;                             /* semaphore for fs */
    semaphore_t io_sem;                             /* semaphore for io */
    semaphore_t mutex_sem;                          /* semaphore for link/unlink and rename */
    list_entry_t inode_list;                        /* inode linked-list */
    list_entry_t *hash_list;                        /* inode hash linked-list */
};


/**
 * inode for sfs =>对硬盘上的inode的包装,故sfs_inode可被看做vnode
 * 内存sfs_inode是在打开文件后才创建的,磁盘上并没有这部分信息!!!
 * 内存sfs_inode包含sfs_disk_inode的指针,在此基础上增加了一些其他有用信息
 **/
struct sfs_inode {
    struct sfs_disk_inode *din;      // sfs_disk_inode的指针(关键)
    uint32_t ino;                    // 此inode的编号 => ucore直接使用磁盘块号
    bool dirty;                      // 这个inode是否被修改
    int reclaim_count;               // 对应文件的引用计数; 为0后则会删除这个内存inode 
    semaphore_t sem;                 /* semaphore for din */
    list_entry_t inode_link;         /* entry for linked-list in sfs_fs */
    list_entry_t hash_link;          /* entry for hash linked-list in sfs_fs */
};


/**
 *  inode (on disk)
 *  一个sfs_disk_inode对应了一个实际位于磁盘上的文件,这个inode存储了文件的相关信息
 * 存储在硬盘中,需要时读入内存
 * 
 * 注1:如果此disk_inode对应的是一个目录 =>
 *     direct指向的则是目录项的数据结构disk_entry,通过这个结构才能继续查找文件
 *     indirect指向的则是disk_entry的索引...
 * 注2:ucore中一个文件最多可存储数据12*4K+1024*4K=48K+4MB
 *     推导:直接索引12个(SFS_NDIRECT) => 可找到数据12*4K
 *          一级间接索引1024个(索引块的大小/索引条目的大小=4096/sizeof(int)=1024) => 可找到1024*4K
 * 注3:磁盘块号!=扇区号,最终对磁盘的访问通常是以扇区为单位,但是os通常定义了block,数据以block为单位
 *     ucore中一个block定义为page大小(4k),恰好是8个扇区 
 * 注4:为了实现简单ucore磁盘上的每个inode都占用了一个block(虽然很显然没使用完) !
 * 
 * 注5:对于普通文件,索引值指向的block中保存的是文件中的数据;
 *     而对于目录,索引值指向的数据 保存的是目录下所有的文件名以及对应的索引节点所在的索引块(磁盘块)所形成的数组
 *     => 即可以理解为: sfs_disk_inode->data=sfs_disk_entry[] !!!
 *
**/
struct sfs_disk_inode {
    uint32_t size;                   // 如果inode表示常规文件,则size是文件大小
    uint16_t type;                   // inode的文件类型 => 可能是SFS_TYPE_DIR
    uint16_t nlinks;                 // 此inode的硬连接数
    uint32_t blocks;                 // 此inode/文件对应数据块的个数
    uint32_t direct[SFS_NDIRECT];    // 此inode的直接数据块索引值(即直接存储一小部分数据所在的磁盘块号,有SFS_NDIRECT个)
    uint32_t indirect;               // 此inode的一级间接数据块索引值; 为0表示不使用间接索引(因为block0是超块);指向索引块
//    uint32_t db_indirect;          /* double indirect blocks */
//   unused
};

/**
 * file entry (on disk) => 目录项
 * 存储在硬盘中,需要时读入内存
 * 注意sfs_disk_entry与sfs_disk_inode的关系: sfs_disk_inode若是目录,则其数据部分是一个sfs_disk_entry[]数组
 * 通过读取ino这个block的数据，能够得到相应的文件或文件夹的inode
 */
struct sfs_disk_entry {
    uint32_t ino;                      /* 目录项对应的文件/子目录的索引块值(ucore直接取磁盘块号 => linux下其实有专门的代码来分配编号) */
    char name[SFS_MAX_FNAME_LEN + 1];  /* 文件名 */
};


#define sfs_dentry_size                             \
    sizeof(((struct sfs_disk_entry *)0)->name)



#define le2sin(le, member)                          \
    to_struct((le), struct sfs_inode, member)


/* hash for sfs */
#define SFS_HLIST_SHIFT                             10
#define SFS_HLIST_SIZE                              (1 << SFS_HLIST_SHIFT)
#define sin_hashfn(x)                               (hash32(x, SFS_HLIST_SHIFT))

/* size of freemap (in bits) */
#define sfs_freemap_bits(super)                     ROUNDUP((super)->blocks, SFS_BLKBITS)

/* size of freemap (in blocks) */
#define sfs_freemap_blocks(super)                   ROUNDUP_DIV((super)->blocks, SFS_BLKBITS)


/* 位于vfs层的fs 和 inode */
struct fs;
struct inode;

void sfs_init(void);
int sfs_mount(const char *devname);

void lock_sfs_fs(struct sfs_fs *sfs);
void lock_sfs_io(struct sfs_fs *sfs);
void unlock_sfs_fs(struct sfs_fs *sfs);
void unlock_sfs_io(struct sfs_fs *sfs);

int sfs_rblock(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
int sfs_wblock(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
int sfs_rbuf(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
int sfs_wbuf(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
int sfs_sync_super(struct sfs_fs *sfs);
int sfs_sync_freemap(struct sfs_fs *sfs);
int sfs_clear_block(struct sfs_fs *sfs, uint32_t blkno, uint32_t nblks);

int sfs_load_inode(struct sfs_fs *sfs, struct inode **node_store, uint32_t ino);

#endif /* !__KERN_FS_SFS_SFS_H__ */

