#ifndef __KERN_TRAP_TRAP_H__
#define __KERN_TRAP_TRAP_H__

#include <defs.h>

/* Trap Numbers */

/* Processor-defined: */
#define T_DIVIDE                0   // divide error
#define T_DEBUG                 1   // debug exception
#define T_NMI                   2   // non-maskable interrupt
#define T_BRKPT                 3   // breakpoint
#define T_OFLOW                 4   // overflow
#define T_BOUND                 5   // bounds check
#define T_ILLOP                 6   // illegal opcode
#define T_DEVICE                7   // device not available
#define T_DBLFLT                8   // double fault
// #define T_COPROC             9   // reserved (not used since 486)
#define T_TSS                   10  // invalid task switch segment
#define T_SEGNP                 11  // segment not present
#define T_STACK                 12  // stack exception
#define T_GPFLT                 13  // general protection fault
#define T_PGFLT                 14  // page fault
// #define T_RES                15  // reserved
#define T_FPERR                 16  // floating point error
#define T_ALIGN                 17  // aligment check
#define T_MCHK                  18  // machine check
#define T_SIMDERR               19  // SIMD floating point error

/* Hardware IRQ numbers. We receive these as (IRQ_OFFSET + IRQ_xx) */
// 注:IRQ即:中断请求
#define IRQ_OFFSET              32  // IRQ 0 corresponds to int IRQ_OFFSET

#define IRQ_TIMER               0
#define IRQ_KBD                 1
#define IRQ_COM1                4
#define IRQ_IDE1                14
#define IRQ_IDE2                15
#define IRQ_ERROR               19
#define IRQ_SPURIOUS            31

/* *
 * These are arbitrarily chosen, but with care not to overlap
 * processor defined exceptions or interrupt vectors.
 * */
#define T_SWITCH_TOU                120    // user/kernel switch
#define T_SWITCH_TOK                121    // user/kernel switch

/****
 * registers as pushed by pushal
 * pushal即: Push All General-Purpose Registers => 将所有通用寄存器压栈
 * 存储通用寄存器中的值 
 **/
struct pushregs {
    uint32_t reg_edi;
    uint32_t reg_esi;
    uint32_t reg_ebp;
    uint32_t reg_oesp;          /* Useless */
    uint32_t reg_ebx;
    uint32_t reg_edx;
    uint32_t reg_ecx;
    uint32_t reg_eax;
};



/**
 * 1.保存中断前的相关寄存器信息,方便中断返回时恢复寄存器状态;最重要的寄存器信息 => eip(指令流)、esp(栈)
 * 2.段寄存器只需使用16位的选择子,所以另外16位设置为tf_paddingx !
 * 3.注意下面的压栈顺序:tf_ss、tf_esp ....tf_regs
 * 4.详见tranentry.S,了解压栈构造trapframe的过程,构造trapframe就是将相应信息压入内核栈
 * 5.如何找到内核栈的? tss,它保存了内核栈的esp和ss
 * 6.若中断发生在用户态,则存储的是用于态程序的信息 => esp是用户栈顶!!!
 * 7.若中断发生在内核态,则存储的是用户态程序的信息 => esp是内核栈顶!!!
 **/
struct trapframe {
    struct pushregs tf_regs;  // 储存通用寄存器中的值
    uint16_t tf_gs;
    uint16_t tf_padding0;
    uint16_t tf_fs;
    uint16_t tf_padding1;
    uint16_t tf_es;
    uint16_t tf_padding2;
    uint16_t tf_ds;
    uint16_t tf_padding3;
    uint32_t tf_trapno;     // tf_regs ....tf_trapno这部分内容调用中断处理程序时压栈,详见vectors.S和trapentry.S
    
    // below here defined by x86 hardware
    uint32_t tf_err;        
    uintptr_t tf_eip;     
    uint16_t tf_cs;
    uint16_t tf_padding4;
    uint32_t tf_eflags;    // tf_err...tf_eflags这部分在执行INT 指令时由硬件压栈
    
    // below here only when crossing rings, such as from user to kernel,这部分涉及栈的切换 
    // 如果是在内核态发生的中断,则不需要这部分
    uintptr_t tf_esp;      // 线程陷入内核前用户栈顶指针寄存器值 => 方便回到用户态时恢复用户栈...
    uint16_t tf_ss;        // 线程陷入内核前的堆栈段段寄存器值
    uint16_t tf_padding5;  // tf_esp...tf_ss这部分在特权级切换时压栈
} __attribute__((packed));

void idt_init(void);
void print_trapframe(struct trapframe *tf);
void print_regs(struct pushregs *regs);
bool trap_in_kernel(struct trapframe *tf);

#endif /* !__KERN_TRAP_TRAP_H__ */

