#include <ulib.h>
#include <unistd.h>
#include <file.h>
#include <stat.h>

int main(int argc, char *argv[]);

static int initfd(int fd2, const char *path, uint32_t open_flags) {
    int fd1, ret;
    if ((fd1 = open(path, open_flags)) < 0) {
        return fd1;
    }
    if (fd1 != fd2) {
        close(fd2);
        ret = dup2(fd1, fd2);
        close(fd1);
    }
    return ret;
}

/**
 * 所有应用程序执行的第一个c函数
 * 它将调用应用程序的main函数,并在main函数结束后调用exit函数,exit再通过系统调用sys_exit回收线程资源!
 **/
void umain(int argc, char *argv[]) {
    int fd;
    if ((fd = initfd(0, "stdin:", O_RDONLY)) < 0) {
        warn("open <stdin> failed: %e.\n", fd);
    }
    if ((fd = initfd(1, "stdout:", O_WRONLY)) < 0) {
        warn("open <stdout> failed: %e.\n", fd);
    }
    int ret = main(argc, argv);
    exit(ret);
}

