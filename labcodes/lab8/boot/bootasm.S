#include <asm.h>

# ######################################  bootloader源码  #########################################
# 0.流程概述
#    打开A20 => 内存检测 => 使能保护模式 
#    => 跳转到32位保护模式代码 => 设置段寄存器及堆栈指针 => 调用bootmain
# 1.BIOS将其读取到0x7c00开始处,然后执行这段代码
# 2.这段汇编执行完后,调用bootloader的C源码部分bootmain
# 3.为什么栈顶设置为0x7c00,ebp设置为0
#   => bootloader代码从0x7c00开始向上增长,栈从0x7c00开始向下增长刚好不冲突
#      至于ebp,按理说不设置为0也可,这只是一个初始值,以后通过ebp是否等于这个初始值判断其是否为栈底(见kdebug.c)


# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

# .set汇编伪指令,这里相当于设置变量
.set PROT_MODE_CSEG,        0x8                     # kernel code segment selector => GDT中,代码段描述符的偏移
.set PROT_MODE_DSEG,        0x10                    # kernel data segment selector => 数据段描述符的偏移
.set CR0_PE_ON,             0x1                     # protected mode enable flag
.set SMAP,                  0x534d4150

# start address should be 0:7c00, in real mode, the beginning address of the running bootloader
# .global 使得连接程序(ld)能够识别; start代表程序的起始位置,链接器自动寻找
.globl start
start:
# .code16、.code32都是伪指令,告诉编译器生成对应位数处理器的代码
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts => 关中断
    cld                                             # 将标志寄存器flag的方向标志位DF清零(方便打开A20时判断DF)

    # Set up the important data segment registers (DS, ES, SS). 设置段寄存器
    xorw %ax, %ax                                   # Segment number zero => 自身xor,从而置零
    movw %ax, %ds                                   # -> Data Segment     => 数据段
    movw %ax, %es                                   # -> Extra Segment    => 附加段
    movw %ax, %ss                                   # -> Stack Segment    => 堆栈段

    # Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
# seta20.1只是一个标签,方便跳转(类似于goto)
seta20.1:    
    # 等待8042控制寄存器(输入命令的缓冲,0x64)空; 注意需要先关中断,见上面cli命令
    inb $0x64, %al                                  # inb:从IO端口读取一个字节
    testb $0x2, %al                                 # 进行逻辑与,修改ZF标志位,但是不修改参数值
    jnz seta20.1                                    # 前两条命令用于判断8042中输入命令的缓冲是否为空,不空则循环等待

    # 发送写8042内部端口Output Port的命令给控制寄存器0x64(只需将0x61写入控制寄存器即可)
    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port

seta20.2:
    # 等待8042控制寄存器(输入命令的缓冲,0x64)空; 也是为了防止有其他命令在执行
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    # 向0x64发送0xd1命令后,这里才开始真正执行写Output Port
    # (猜测)发送0xd1后,输出缓冲0x60中应该有Output Port的数据,
    #       然后从0x60读取该数据,修改并再次写入0x60,这个修改后的值自动更新到Output Port,从而完成对内部端口的写
    # 只是这里直接向0x60写入固定值0xfd,没有理会Output Port中原本的值; 这个固定值的bit1 为1,意味着打开A20
    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1

probe_memory:
    movl $0, 0x8000
    xorl %ebx, %ebx
    movw $0x8004, %di
start_probe:
    movl $0xE820, %eax
    movl $20, %ecx
    movl $SMAP, %edx
    int $0x15
    jnc cont
    movw $12345, 0x8000
    jmp finish_probe
cont:
    addw $20, %di
    incl 0x8000
    cmpl $0, %ebx
    jnz start_probe
finish_probe:

    # Switch from real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual addresses
    # identical to physical addresses, so that the
    # effective memory map does not change during the switch.
    # 使能和进入保护模式:
    #   1.加载gdtr
    #   2.修改控制寄存器PE位使能保护模式
    #   3.跳转到32位保护模式下的代码
    lgdt gdtdesc                        # 加载gdtdesc的内容到寄存器GDTR
    movl %cr0, %eax                     # 下面三行:修改控制寄存器cr0的PE位,进入保护模式
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0

    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    # 设置好保护模式后,下一条指令应该是32位保护模式的计算方式(CS寄存器的隐形部分+EIP)
    # => 所以这条指令会将CS寄存器设置为PROT_MODE_CSEG(然后将对应的基址读取到CS不可见部分);   EIP设置为protcseg
    ljmp $PROT_MODE_CSEG, $protcseg    #  格式:ljmp 段选择子,段内偏移 => ljmp 0x8,protcseg

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    # 初始化段寄存器(cs是在上面ljmp时自动设置!)
    movw $PROT_MODE_DSEG, %ax                       # 将数据段描述符在GDT中的偏移写入ax
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp                                 # 不是整个栈的底部(也不是栈帧的底部),它处于栈帧的中间部分,用于定位上一个栈帧!
    movl $start, %esp                               # 设置栈顶,0x7c00
    call bootmain                                   # 进入bootmain,在这里边再进入操作系统...

    # If bootmain returns (it shouldn't), loop.
spin:
    jmp spin

.data
# Bootstrap GDT
# 伪指令,指定对齐方式(2^2=4 字节对齐)
.p2align 2                                          # force 4 byte alignment

# 初始化GDT,每个表项占64位,目前gdt仅占24字节
# SEG_NULLASM、SEG_ASM见asm.h
gdt:
    SEG_NULLASM                                     # 第一个段描述符固定为空!
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # 设置代码段
    SEG_ASM(STA_W, 0x0, 0xffffffff)                 # 设置数据段

# 描述全局描述符表的描述符 => 实际上它就是GDTR的内容 
#   .word 0x17  #写入段描述符表的长度 => 为什么是23而不是24? 因为按照地址算是gdt+0,gdt+1,....gdt+23,正好是24字节
#   .long gdt   #写入段描述符表gdt的地址
gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1, 写入GDT长度
    .long gdt                                       # address gdt    , 写入GDT地址
