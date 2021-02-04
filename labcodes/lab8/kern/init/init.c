#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <console.h>
#include <kdebug.h>
#include <picirq.h>
#include <trap.h>
#include <clock.h>
#include <intr.h>
#include <pmm.h>
#include <vmm.h>
#include <ide.h>
#include <swap.h>
#include <proc.h>
#include <fs.h>
#include <kmonitor.h>

int kern_init(void) __attribute__((noreturn));   // 声明函数属性 => 不会返回!
void grade_backtrace(void);
static void lab1_switch_test(void);

// ucore初始化(在entry.S中被调用)
int kern_init(void) {
    extern char edata[], end[];             // 定义见kernel.ld,分别是bss段的起始、结束地址
    memset(edata, 0, end - edata);          // bss段存储未初始化的以及被初始化为0的全局或静态C变量.
                                            // 这部分在磁盘上的ELF文件中不占空间,但是加载到内存时需要在内存中分配.所以memset...
                                            
    cons_init();                // 初始化终端,包括:cga_init、serial_init、kbd_init

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);

    print_kerninfo();           // 打印内核的基本信息(内核入口、段基址等)

    grade_backtrace();          // 显示堆栈信息,最终调用print_stackframe()

    pmm_init();                 // 初始化物理内存管理(=> 从调用pmm_init开始,进入地址映射的第三个阶段)

    pic_init();                 // 初始化中断控制器(8259A),programable interupt controller
    
    idt_init();                 // 初始化IDT(对比GDT的初始化,在bootasm.S)

    vmm_init();                 // 初始化虚拟内存管理

    sched_init();               // 初始化调度器

    proc_init();                // 进程/线程相关的初始化(创建内核线程idleproc、initproc)

    ide_init();                 // 初始化IDE设备

    swap_init();                // 初始化swap分区 => 物理内存的页面置换(fifo)在这个组件中实现

    fs_init();                  // 初始化文件系统
    
    clock_init();               // 初始化时钟(使能时钟中断)

    intr_enable();              // enable irq interrupt

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    mon_backtrace(0, NULL, NULL);           // 见kmonitor.c,它直接调用print_stackframe
}

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
}

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void
grade_backtrace(void) {
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
}

static void
lab1_print_cur_status(void) {
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
    cprintf("%d:  cs = %x\n", round, reg1);
    cprintf("%d:  ds = %x\n", round, reg2);
    cprintf("%d:  es = %x\n", round, reg3);
    cprintf("%d:  ss = %x\n", round, reg4);
    round ++;
}

static void
lab1_switch_to_user(void) {
    //LAB1 CHALLENGE 1 : TODO
}

static void
lab1_switch_to_kernel(void) {
    //LAB1 CHALLENGE 1 :  TODO
}

static void
lab1_switch_test(void) {
    lab1_print_cur_status();
    cprintf("+++ switch to  user  mode +++\n");
    lab1_switch_to_user();
    lab1_print_cur_status();
    cprintf("+++ switch to kernel mode +++\n");
    lab1_switch_to_kernel();
    lab1_print_cur_status();
}

