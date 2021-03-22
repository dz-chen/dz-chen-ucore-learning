#include <memlayout.h>

# vectors.S sends all traps here.
# idt(trap.c)找到vector.s中的中断处理程序入口地址
# vector.s中所有中断处理程序统一跳转到此
.text
.globl __alltraps
__alltraps:
    # PUSH registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    # 相关寄存器压栈,构造参数trapframe(trap.h) => 需注意,这里的栈已经是内核栈了!!!
    pushl %ds
    pushl %es
    pushl %fs
    pushl %gs
    pushal          # pushal即: Push All General-Purpose Registers => 将所有通用寄存器压栈

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax    # GD_KDATA是内核数据段的选择子,见memlayout.h
    movw %ax, %ds           # 设置内核数据段选择子(它是相对GDT的偏移)
    movw %ax, %es

    # PUSH %esp to pass a pointer to the trapframe as an argument to trap() 
    # 由于trap的参数是一个指针,所以这里将trapframe的地址压栈 => 即下面压栈的内容,而栈中那一项本身(不是内容)就成了指针!!!
    # 比较重要,仔细理解!!! 这里pushl %esp其实就是参数入栈,只是参数是指针
    pushl %esp              # esp是栈顶指针; 由于刚才压栈的数据构成了trapframe,所以esp就是trapframe的地址

    # call trap(tf), where tf=%esp
    # call是子程序调用指令,它隐含有返回值入栈的操作、以及ebp入栈的操作
    # 而jmp是无条件跳转指令,没有栈操作
    call trap                     # 见trap.c,上面一堆指令就是构造 trap(struct trapframe *tf)的参数tf
    
    # call 执行完毕之后...
    
    # POP the pushed stack pointer
    popl %esp                     # popl 以及_trapret都是将之前压栈的内容出栈

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal                         # 恢复所有中断之前的通用寄存器

    # restore %ds, %es, %fs and %gs
    popl %gs
    popl %fs
    popl %es
    popl %ds

    # get rid of the trap number and error code
    addl $0x8, %esp              # trapno和errorno不需要恢复寄存器,所以直接将栈指针+8
    # iret时,会从内核栈陆续恢复eip cs eflags,还会根据是否特权级转换,恢复esp和ss,就是int操作的逆过程
    iret                         # 中断返回


.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp          # 
    jmp __trapret
