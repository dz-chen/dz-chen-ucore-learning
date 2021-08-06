#include <defs.h>
#include <kmalloc.h>
#include <sem.h>
#include <vfs.h>
#include <dev.h>
#include <file.h>
#include <sfs.h>
#include <inode.h>
#include <assert.h>
#include <stdio.h>

/**
 * 初始化文件系统
 * 在init.c/kern_init()函数中被调用
 */ 
void fs_init(void) {
    vfs_init();             // 文件系统抽象层
    dev_init();             // 设备IO层
    sfs_init();             // SFS文件系统
}

void fs_cleanup(void) {
    vfs_cleanup();
}

void
lock_files(struct files_struct *filesp) {
    down(&(filesp->files_sem));
}

void unlock_files(struct files_struct *filesp) {
    up(&(filesp->files_sem));
}
//Called when a new proc init
struct files_struct *files_create(void) {
    //cprintf("[files_create]\n");
    static_assert((int)FILES_STRUCT_NENTRY > 128);
    struct files_struct *filesp;
    if ((filesp = kmalloc(sizeof(struct files_struct) + FILES_STRUCT_BUFSIZE)) != NULL) {
        filesp->pwd = NULL;
        filesp->fd_array = (void *)(filesp + 1);
        filesp->files_count = 0;
        sem_init(&(filesp->files_sem), 1);
        fd_array_init(filesp->fd_array);
    }
    return filesp;
}

//Called when a proc exit
void files_destroy(struct files_struct *filesp) {
//    cprintf("[files_destroy]\n");
    assert(filesp != NULL && files_count(filesp) == 0);
    if (filesp->pwd != NULL) {
        vop_ref_dec(filesp->pwd);
    }
    int i;
    struct file *file = filesp->fd_array;
    for (i = 0; i < FILES_STRUCT_NENTRY; i ++, file ++) {
        if (file->status == FD_OPENED) {
            fd_array_close(file);
        }
        assert(file->status == FD_NONE);
    }
    kfree(filesp);
}

// 关闭文件控制块内的所有已打开文件
void files_closeall(struct files_struct *filesp) {
//    cprintf("[files_closeall]\n");
    assert(filesp != NULL && files_count(filesp) > 0);
    int i;
    struct file *file = filesp->fd_array;
    //skip the stdin & stdout
    for (i = 2, file += 2; i < FILES_STRUCT_NENTRY; i ++, file ++) {
        if (file->status == FD_OPENED) {
            fd_array_close(file);
        }
    }
}


/**
 * 复制文件控制块files_struct
 * 需要完全拷贝打开文件表(fd_array)!!!
 * 主要在创建子进程时使用,见process/proc.c/copy_files()
 */ 
int dup_files(struct files_struct *to, struct files_struct *from) {
//    cprintf("[dup_files]\n");
    assert(to != NULL && from != NULL);
    assert(files_count(to) == 0 && files_count(from) > 0);
    if ((to->pwd = from->pwd) != NULL) {
        vop_ref_inc(to->pwd);
    }
    int i;
    struct file *to_file = to->fd_array, *from_file = from->fd_array;
    for (i = 0; i < FILES_STRUCT_NENTRY; i ++, to_file ++, from_file ++) {
        if (from_file->status == FD_OPENED) {
            /* alloc_fd first */
            to_file->status = FD_INIT;
            fd_array_dup(to_file, from_file);
        }
    }
    return 0;
}

