# _start是所有应用程序的起始用户态执行地址,它最终调用umain函数
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp

    # load argc and argv
    movl (%esp), %ebx
    lea 0x4(%esp), %ecx


    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp

    # save argc and argv on stack
    pushl %ecx
    pushl %ebx

    # call user-program function
    call umain             # 见umain.c
1:  jmp 1b

    
