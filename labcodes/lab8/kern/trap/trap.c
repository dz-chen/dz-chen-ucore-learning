#include <defs.h>
#include <mmu.h>
#include <memlayout.h>
#include <clock.h>
#include <trap.h>
#include <x86.h>
#include <stdio.h>
#include <assert.h>
#include <console.h>
#include <vmm.h>
#include <swap.h>
#include <kdebug.h>
#include <unistd.h>
#include <syscall.h>
#include <error.h>
#include <sched.h>
#include <sync.h>
#include <proc.h>

#define TICK_NUM 100

static void print_ticks() {
    cprintf("%d ticks\n",TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}

/* *
 * Interrupt descriptor table:
 *
 * Must be built at run time because shifted function addresses can't
 * be represented in relocation records.
 * IDT:256项,每项8字节
 * */
static struct gatedesc idt[256] = {{0}};

// idtr内容
static struct pseudodesc idt_pd = {
    sizeof(idt) - 1, (uintptr_t)idt     // 限长,基址
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void idt_init(void) {
    /* LAB1 YOUR CODE : STEP 2 */
    /* (1) Where are the entry addrs of each Interrupt Service Routine (ISR)?
    *     All ISR's entry addrs are stored in __vectors. where is uintptr_t __vectors[] ?
    *     __vectors[] is in kern/trap/vector.S which is produced by tools/vector.c
    *     (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
    *     You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later.
    * (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
    *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
    * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
    *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
    *     Notice: the argument of lidt is idt_pd. try to find it!
    */
    extern uintptr_t __vectors[];   //每个中断服务例程的入口地址(相对于段基址的偏移)
    for(int i=0;i<156;i++){
        int istrap=0;               // 不是陷阱(是中断,陷阱不会关中断,从而导致中断嵌套; 除此之外无区别)
        int sel=GD_KTEXT;           // 段选择子(内核代码段)
        int off=__vectors[i];       // 中断服务程序的地址偏移
        int dpl=DPL_KERNEL;         // 系统调用中断T_SYSCALL使用特权级3(之后会有特权切换); 其他全为0
        SETGATE(idt[i],istrap,sel,off,dpl);
    }
    // 对于系统调用,需要切换到内核态; 它的权限为ring3; 这里使用中断号121
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
    
    lidt(&idt_pd);                 // 加载IDT的基址和限长到IDTR


    /* LAB5 YOUR CODE */ 
    //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
    //so you should setup the syscall interrupt gate in here
}



/************************************
 * 返回中断号对应中断名称
 * 以下每个中断名对应的中断号见trap.h
 * **********************************/
static const char * trapname(int trapno) {
    static const char * const excnames[] = {
        "Divide error",
        "Debug",
        "Non-Maskable Interrupt",
        "Breakpoint",
        "Overflow",
        "BOUND Range Exceeded",
        "Invalid Opcode",
        "Device Not Available",
        "Double Fault",
        "Coprocessor Segment Overrun",
        "Invalid TSS",
        "Segment Not Present",
        "Stack Fault",
        "General Protection",
        "Page Fault",
        "(unknown trap)",
        "x87 FPU Floating-Point Error",
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
        return excnames[trapno];
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
        return "Hardware Interrupt";
    }
    return "(unknown trap)";
}

/* trap_in_kernel - test if trap happened in kernel 
 * 判断中断发生在内核还是用户态
 * 依据:tf_cs是中断前cs值,若它等于内核的代码段选择子,说明中断发生在内核
 * */
bool
trap_in_kernel(struct trapframe *tf) {
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
}

static const char *IA32flags[] = {
    "CF", NULL, "PF", NULL, "AF", NULL, "ZF", "SF",
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

// 打印trapframe信息
void print_trapframe(struct trapframe *tf) {
    cprintf("trapframe at %p\n", tf);
    print_regs(&tf->tf_regs);
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
    cprintf("  es   0x----%04x\n", tf->tf_es);
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
    cprintf("  err  0x%08x\n", tf->tf_err);
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);

    if (!trap_in_kernel(tf)) {
        cprintf("  esp  0x%08x\n", tf->tf_esp);
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
    }
}


// 打印通用寄存器值
void print_regs(struct pushregs *regs) {
    cprintf("  edi  0x%08x\n", regs->reg_edi);
    cprintf("  esi  0x%08x\n", regs->reg_esi);
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
    cprintf("  edx  0x%08x\n", regs->reg_edx);
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
    cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static inline void
print_pgfault(struct trapframe *tf) {
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}

static int
pgfault_handler(struct trapframe *tf) {
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
        assert(current == idleproc);
        mm = check_mm_struct;
    }
    else {
        if (current == NULL) {
            print_trapframe(tf);
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
}

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

// 根据中断号,分发到对应的处理程序
static void trap_dispatch(struct trapframe *tf) {
    char c;

    int ret=0;

    switch (tf->tf_trapno) {
        case T_PGFLT:  //page fault
            if ((ret = pgfault_handler(tf)) != 0) {
                print_trapframe(tf);
                if (current == NULL) {
                    panic("handle pgfault failed. ret=%d\n", ret);
                }
                else {
                    if (trap_in_kernel(tf)) {
                        panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
                    }
                    cprintf("killed by kernel.\n");
                    panic("handle user mode pgfault failed. ret=%d\n", ret); 
                    do_exit(-E_KILLED);
                }
            }
            break;
        case T_SYSCALL:                 // 如果是系统调用(int 0x80) => 会有特权级切换!
            // 注:ucore的所有系统调用共享一个中断号(0x80),进入内核后再根据调用的函数编号分发到处理函数
            syscall();                  // 见syscall/syscall.c
            break;
        case IRQ_OFFSET + IRQ_TIMER:
            #if 0
                LAB3 : If some page replacement algorithm(such as CLOCK PRA) need tick to change the priority of pages,
                then you can add code here. 
            #endif
                /* LAB1 YOUR CODE : STEP 3 */
                /* handle the timer interrupt */
                /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
                * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
                * (3) Too Simple? Yes, I think so!
                */
                ticks++;
                if(ticks%TICK_NUM==0)
                    print_ticks();
                

                /* LAB5 YOUR CODE */
                /* you should upate you lab1 code (just add ONE or TWO lines of code):
                *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
                */
                /* LAB6 YOUR CODE */
                /* you should upate you lab5 code
                * IMPORTANT FUNCTIONS:
                * sched_class_proc_tick
                */         
                /* LAB7 YOUR CODE */
                /* you should upate you lab6 code
                * IMPORTANT FUNCTIONS:
                * run_timer_list
                */
                break;
        case IRQ_OFFSET + IRQ_COM1:
        case IRQ_OFFSET + IRQ_KBD:
            // There are user level shell in LAB8, so we need change COM/KBD interrupt processing.
            c = cons_getc();            // cons_getc很重要,看下去!!!
            {
                extern void dev_stdin_write(char c);
                dev_stdin_write(c);
            }
            break;
        //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
        case T_SWITCH_TOU:
        case T_SWITCH_TOK:
            panic("T_SWITCH_** ??\n");
            break;
        case IRQ_OFFSET + IRQ_IDE1:
        case IRQ_OFFSET + IRQ_IDE2:
            /* do nothing */
            break;
        default:
            print_trapframe(tf);
            if (current != NULL) {
                cprintf("unhandled trap.\n");
                do_exit(-E_KILLED);
            }
            // in kernel, it must be a mistake
            panic("unexpected trap in kernel.\n");

    }
}

/* *
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * 在tfapentry.S中被调用;
 * 参数trapframe是中断前的相关寄存器环境(通过在trapentry.S中压栈设置)
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
        trap_dispatch(tf);
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
        current->tf = tf;
    
        bool in_kernel = trap_in_kernel(tf);
    
        trap_dispatch(tf);
    
        current->tf = otf;
        if (!in_kernel) {
            if (current->flags & PF_EXITING) {
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
                schedule();
            }
        }
    }
}

