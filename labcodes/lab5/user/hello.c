#include <stdio.h>
#include <ulib.h>

int main(void) {
    cprintf("Hello world!!.\n");
    cprintf("I am process %d.\n", getpid());   //getpid()内部,调用系统调用sys_getpid
    cprintf("hello pass.\n");
    return 0;
}

