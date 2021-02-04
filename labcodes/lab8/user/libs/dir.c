#include <defs.h>
#include <string.h>
#include <syscall.h>
#include <stat.h>
#include <dirent.h>
#include <file.h>
#include <dir.h>
#include <error.h>
#include <unistd.h>


/****************************************************************************
 *                  目录操作的系统调用用户层接口
 * .目录是一个特殊的文件
 * .调用的sys_xxx位于./syscall.c,这里边再间接调用内核中的syscall.c中的系统调用
 * **************************************************************************/
DIR dir, *dirp=&dir;

DIR *opendir(const char *path) {

    if ((dirp->fd = open(path, O_RDONLY)) < 0) {   // 目录就是文件,所以可使用打开文件的open来打开目录
        goto failed;
    }
    struct stat __stat, *stat = &__stat;
    if (fstat(dirp->fd, stat) != 0 || !S_ISDIR(stat->st_mode)) {  // fstat来自./file.c
        goto failed;
    }
    dirp->dirent.offset = 0;
    return dirp;

failed:
    return NULL;
}

// 读取目录信息
struct dirent *readdir(DIR *dirp) {
    if (sys_getdirentry(dirp->fd, &(dirp->dirent)) == 0) {      // 获取目录信息
        return &(dirp->dirent);
    }
    return NULL;
}


// 关闭目录(直接调用关闭文件close)
void closedir(DIR *dirp) {
    close(dirp->fd);
}


// 返回当前工作目录
// 将当前工作目录的绝对路径复制到参数buffer所指的内存空间中,len为buffer的空间大小
int getcwd(char *buffer, size_t len) {
    return sys_getcwd(buffer, len);
}

