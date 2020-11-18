#include <mmu.h>
#include <memlayout.h>

#define REALLOC(x) (x - KERNBASE)

# bootloader将控制交给kern_entry,执行kern_entry后才调用init.c中的kern_init()函数

.text
.globl kern_entry
kern_entry:
    # 1.load pa of boot pgdir => 将pgdir的地址加载到cr3寄存器,即设置页目录表、设置第一个页表
    movl $REALLOC(__boot_pgdir), %eax  # __boot_pgdir是页目录表的虚拟地址;REALLOC宏将其转换为在内核中的相对地址
    movl %eax, %cr3                    # 将页目录表(一级页表)的起始地址存入cr3寄存器

    # 2.enable paging => 设置cr0的相应标志位,使能分页机制(CR0_PG标志位)
    movl %cr0, %eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
    andl $~(CR0_TS | CR0_EM), %eax
    movl %eax, %cr0

    # 3.update eip 
    # now, eip = 0x1.....,因为最开始处于分段模式,尚未开启分页机制,虚拟地址等于物理地址 => 内核处于物理地址1MB往上...
    leal next, %eax         # lea(load effective address)指令用来将一个内存地址赋给目的操作数
    # set eip = KERNBASE + 0x1....., 跳转到next中,将内核由虚拟地址1MB往上 迁移到 KERNBASE+1MB往上, 
    # 不过物理地址不变,因为__boot_pgdir中虚拟地址0~4MB以及KERNBASE~KERNBASE+4MB都映射到物理地址0~4MB
    # 如何看出设置了eip = KERNBASE + 0x1.. => 因为next处于KERNBASE以上的虚拟地址,跳转后自动到了高地址,eip自动更新
    jmp *%eax
next:
    # unmap va 0 ~ 4M, it's temporary mapping
    # 取消页目录表的第一个Entry,之后要将内核由虚拟地址0~4MB迁移到虚拟地址KERNBASE~KERNBASE+4MB (不过内核所在的物理地址不变)
    xorl %eax, %eax          # eax置0
    movl %eax, __boot_pgdir  # __boot_pgdir第一个表项清0

    # set ebp, esp     => 设置内核栈
    # ebp设置为0的依据? 此时栈顶到底算是在哪里??
    movl $0x0, %ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
    # now kernel stack is ready , call the first C function
    call kern_init

# should never get here
spin:
    jmp spin

.data
.align PGSIZE
    .globl bootstack
bootstack:
    .space KSTACKSIZE
    .globl bootstacktop
bootstacktop:

# kernel builtin pgdir => 页目录表(一级页表)
# an initial page directory (Page Directory Table, PDT)
# These page directory table and page table can be reused!
# 此页目录表,暂时只填充了两个有意义的表项:
#   第一个有意义的页目录表项,即第一个页目录表项,它对应虚拟地址0-4MB:指向/映射第一个页表__boot_pt1
#   第二个有意义的页目录表项,即KERNBASE处,它对应虚拟地址KERNBASE~KERNBASE+4MB:同样指向/映射第一个页表__boot_pt1
#   所以,虚拟地址的0~4MB以及KERNBASE~KERNBASE+4MB都映射到同一段物理内存(0~4MB)
.section .data.pgdir  # .section表示定义一个段
.align PGSIZE
__boot_pgdir:
.globl __boot_pgdir 
    # 1.map va 0 ~ 4M to pa 0 ~ 4M (temporary) 虚拟地址的0~4MB映射到物理地址的0~4MB => 这个映射只是临时的
    .long REALLOC(__boot_pt1) + (PTE_P | PTE_U | PTE_W)       # 填写第一个页目录表项
    .space (KERNBASE >> PGSHIFT >> 10 << 2) - (. - __boot_pgdir) # pad to PDE of KERNBASE => 填充页目录表项到KERNBASE处
    
    # 2.map va KERNBASE + (0 ~ 4M) to pa 0 ~ 4M
    .long REALLOC(__boot_pt1) + (PTE_P | PTE_U | PTE_W)       # 填写第xxx个页目录表项,与第一个页目录表项映射到同一段物理内存
    .space PGSIZE - (. - __boot_pgdir) # pad to PGSIZE        # 页目录表至少占用4KB(PGSIZE),所以将其填充满



# __boot_pt1是第一个页表(二级页表) => 共4KB; 一个页表项对应一个页=>所以共映射了1024*4KB=4MB
# 一个页表项占4B,32bit;实际上只有高20位用于索引页号(高10位PDX、中间10位PTX),低12位可利用来作为标记;
# 页表项的低12bit可用于标记该页的一些属性、权限等,详见mmu.h => 必看!!!
.set i, 0
__boot_pt1:
.rept 1024   # 重复1024次,即编译结果中有1024个.long i * PGSIZE + (PTE_P | PTE_W)
    .long i * PGSIZE + (PTE_P | PTE_W)  # i * PGSIZE 为页号,占高20bit; ...
    .set i, i + 1
.endr

