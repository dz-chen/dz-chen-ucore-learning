#include <defs.h>
#include <unistd.h>
#include <stdarg.h>
#include <syscall.h>
#include <stat.h>
#include <dirent.h>

#define MAX_ARGS            5

/***********************************************************************************
 *                              所有系统调用的用户态接口
 * 
 * 1.向上为用户层程序提供接口(被./file.c、./dir.c中的函数read()、wrrite()、close()等调用)
 *   向下调用内核的相关系统调用接口(调用kern/syscall/syscall.c中的内核函数)
 * 2.如何实现调用内核的函数?
 *   a.每一个sys_xxx函数都会调用本文件下的syscall(num,..),num代表此函数编号
 *   b.本文件下的syscall(num,..)通过int 0x80陷入内核
 *   c.内核根据陷入时设置的函数编号,调用对应的函数...
 *   d.内核系统调用返回、用户syscall返回.....
 * *********************************************************************************/

static inline int syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    // 设置要调用的系统函数的编号、输入参数等信息
    // 但是所有系统调用共享一个中断号0x80;
    // 从int 0x80进入系统调用后,再根据函数的编号分发到具体的系统调用程序
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
          "c" (a[1]),
          "b" (a[2]),
          "D" (a[3]),
          "S" (a[4])
        : "cc", "memory");
    return ret;
}

int
sys_exit(int error_code) {
    return syscall(SYS_exit, error_code);
}

int
sys_fork(void) {
    return syscall(SYS_fork);
}

int
sys_wait(int pid, int *store) {
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
}

int
sys_kill(int pid) {
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int c) {
    return syscall(SYS_putc, c);
}

int
sys_pgdir(void) {
    return syscall(SYS_pgdir);
}

void
sys_lab6_set_priority(uint32_t priority)
{
    syscall(SYS_lab6_set_priority, priority);
}

int
sys_sleep(unsigned int time) {
    return syscall(SYS_sleep, time);
}

int
sys_gettime(void) {
    return syscall(SYS_gettime);
}

int
sys_exec(const char *name, int argc, const char **argv) {
    return syscall(SYS_exec, name, argc, argv);
}

int
sys_open(const char *path, uint32_t open_flags) {
    return syscall(SYS_open, path, open_flags);
}

int
sys_close(int fd) {
    return syscall(SYS_close, fd);
}

int
sys_read(int fd, void *base, size_t len) {
    return syscall(SYS_read, fd, base, len);
}

int
sys_write(int fd, void *base, size_t len) {
    return syscall(SYS_write, fd, base, len);
}

int
sys_seek(int fd, off_t pos, int whence) {
    return syscall(SYS_seek, fd, pos, whence);
}

int
sys_fstat(int fd, struct stat *stat) {
    return syscall(SYS_fstat, fd, stat);
}

int
sys_fsync(int fd) {
    return syscall(SYS_fsync, fd);
}

int
sys_getcwd(char *buffer, size_t len) {
    return syscall(SYS_getcwd, buffer, len);
}

int
sys_getdirentry(int fd, struct dirent *dirent) {
    return syscall(SYS_getdirentry, fd, dirent);
}

int
sys_dup(int fd1, int fd2) {
    return syscall(SYS_dup, fd1, fd2);
}
