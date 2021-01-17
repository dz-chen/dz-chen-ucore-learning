#include <asm.h>

# ######################################### bootloader源码 ##########################################
# .BIOS加载bootloader后,控制跳转到这里(bootasm.S),此段代码在物理内存的起始地址就是0x7c00
# .然后由这段汇编再去调用bootloader的C源码=> call bootmain
#  => 作用:
# 1.开启地址线A20
# 2.开启保护模式
# ....
# 对比bios-bootloader.s看(约19000行左右开始)


# ########################################## seta20代码解读(开启A20)
# ####################### 前置知识:8042芯片
# 0x64端口:命令端口
# 0x60端口:数据端口

# ########################################## 开启保护模式代码解读
# CR0寄存器最低位PE标志是否保护模式
# => 将cr0内容读取
#    然后通过:orl $CR0_PE_ON, %eax 设置PE位为1
#    最后将设置好的内容写入cr0,即可开启保护模式     
#    开启保护模式后,立即跳转到32位下的代码:ljmp $PROT_MODE_CSEG, $protcseg !!



# ########################################## 设置堆栈指针代码解读
# movl $0x0, %ebp         # 栈帧基址(不是栈底!!!) 
# movl $start, %esp       # 栈顶 start==0x7c00
# call bootmain
# ebp并不是栈帧的基址,它其实处于栈帧的中间位置,用于定位栈帧的相关内容
# => 详细知识参考:https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1/lab1_3_3_1_function_stack.html
# 这么设置相当于将bootloader看做第一帧...

# ########################################## 初始化段描述符表代码解读
# ..... 见gtd 部分以及 asm.h


# ########################################## 初始化段描述符表寄存器内容的代码解读
# .word 0x17                                      # sizeof(gdt) - 1 => 设置GDT的长度, .word伪指令:在当前位置放置一个16bit的字...
# .long gdt                                       # address gdt     => 设置GDT的基址, .long伪指令:.....



# ********************************************* 下为代码 ****************************************************


# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

# .set 指令类似于宏定义,应该是伪指令
.set PROT_MODE_CSEG,        0x8                     # kernel code segment selector,内核代码段选择子
.set PROT_MODE_DSEG,        0x10                    # kernel data segment selector,内核数据段选择子
.set CR0_PE_ON,             0x1                     # protected mode enable flag,  开启保护模式

# start address should be 0:7c00, in real mode, the beginning address of the running bootloader
# .globl 指令定义start为外部程序可访问的标签/全局符号
.globl start

# ################################# => 以下为start标签对应的代码
start:
# .code16、.code32都是伪指令,告诉编译器生成对应的代码
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts           => 关中断:禁止中断发生
    cld                                             # String operations increment  => 清方向标志,让方向标志位DF置零

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero  => xor异或,从而将寄存器置零
    movw %ax, %ds                                   # -> Data Segment      => 数据段寄存器置零
    movw %ax, %es                                   # -> Extra Segment     => 附加数据段...
    movw %ax, %ss                                   # -> Stack Segment     => 堆栈段....

    # 1.Enable A20:                                                   
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
    # 为了兼容早期PC机器,实模式下第20个地址线不能使用,超过1MB的地址自动从0重新开始计算
    # seta20代码用于打开A20地址线
seta20.1:  # 这个标签应该是属于.code16伪指令标签内部的
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty). => inb端口操作指令,从port 0x64读取一个字节
    testb $0x2, %al                                 # test将两个操作数进行逻辑与,并设置标志位ZF; 但是不改变操作数!!!
    jnz seta20.1                                    # 结果不为0则跳转; 即标志位ZF不为0则跳转; ZF在EFLAGS寄存器中

    movb $0xd1, %al                                 # 0xd1 -> port 0x64 => 0x64端口,对应8042芯片,键盘控制器直接读写8042
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty). => 循环等待
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1

    # 2.Switch from real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual addresses
    # identical to physical addresses, so that the
    # effective memory map does not change during the switch.
    lgdt gdtdesc                                    # lgdt指令:加载全局描述符表
    movl %cr0, %eax                                 # 从cr0加载32位长字到eax寄存器,修改寄存器内容
    orl $CR0_PE_ON, %eax                            # or指令:进行逻辑或,结果放入目的操作数 => 保证PE位为1
    movl %eax, %cr0                                 # 将设置好后的内容放入CR0,开启保护模式

    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    # 设置好保护模式后,下一条指令应该是32位保护模式的计算方式(CS寄存器的隐形部分+EIP)
    # => 所以这条指令会将CS寄存器设置为PROT_MODE_CSEG(然后将对应的基址读取到CS不可见部分);   EIP设置为protcseg
    ljmp $PROT_MODE_CSEG, $protcseg                 # ljmp 段选择子,段内偏移 => ljmp 0x8,protcseg




.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    # PROT_MODE_DSEG:0x10 => 设置其他段的选择子为0x10
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    # 设置堆栈指针并调用C函数(bootmain.c的bootmain函数)
    movl $0x0, %ebp                                 # 栈帧基址 
    movl $start, %esp                               # 栈顶 start==0x7c00
    call bootmain

    # If bootmain returns (it shouldn't), loop.
spin:
    jmp spin


# .p2align是伪指令,意在告诉编译器使用2^2=4 字节对齐
.p2align 2                                          # force 4 byte alignment


# 定义全局描述符表,SEG_NULLASM、SEG_ASM两个宏来自asm.h
# 每个表项/段描述符占8个字节 => 64位
# 段描述符格式:https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1_figs/image003.png
# 基址32位; 限长20位; 属性... ; 注意基址、限长的bit不是连续的!!!
# SEG_ASM(type,base,lim)
# 注意ucore为了简便,代码段、数据段的基址是一样的
gdt:
    SEG_NULLASM                                     # null seg  => 第一个段描述符设定为空段描述符
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
    SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel


# 描述全局描述符表的描述符 => 实际上它就是GDTR的内容 
#   .word 0x17  #写入段描述符表的长度 => 为什么是23而不是24? 因为按照地址算是gdt+0,gdt+1,....gdt+23,正好是24字节
#   .long gdt   #写入段描述符表gdt的地址
gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1 => .word伪指令:在当前位置放置一个16bit的字...
    .long gdt                                       # address gdt     => .long伪指令:.....
