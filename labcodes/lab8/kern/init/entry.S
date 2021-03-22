#include <mmu.h>
#include <memlayout.h>

#define REALLOC(x) (x - KERNBASE) 
# KERNBASE:0xC0000000

# bootloader将控制交给kern_entry,执行kern_entry后才调用init.c中的kern_init()函数
# kern_entry的作用:
# 1.初步建立页目录表_boot_gpdir
# 2.使能分页机制(才能使用TLB、cr3寄存器=> cpu通过cr3寄存器自动查找页表等...)
# 3 4 将内核迁移到虚拟地址高端...
# 5.设置内核栈以及堆栈指针,然后才是跳转到内核的C程序


# ################### 补充:地址映射的三个阶段
# 第一阶段:从开始执行bootloader到调用kern_entry之前 : 开启保护模式,创建并启动段表(GDT)
#          => map va 0 ~ ...MB to pa 0 ~ ...MB, 即物理地址等于虚拟地址,且ucore已经放置到了1MB以上
# 第二阶段:从开始执行kern_entry到调用pmm_init之前   : 创建初始页目录表,开启分页模式
#          => 1.刚使能分页机制后,地址映射如下:
#                   map va 0 ~ 4M to pa 0 ~ 4M (temporary)
#                   map va KERNBASE + (0 ~ 4M) to pa 0 ~ 4M, 详见下面__boot_pgdir的定义
#                   即虚拟地址范围的0~4MB以及KERNBASE~KERNBASE+4MB 都映射到同一个物理地址范围0~4MB
#             2.离开kern_entry时,取消了 va 0 ~ 4M to pa 0 ~ 4M 这一映射
#                   只剩下:map va KERNBASE + (0 ~ 4M) to pa 0 ~ 4M, 不过仍然只有4MB物理地址被映射
# 第三阶段:从开始执行pmm_init起....                 :  完善段表和页表
#          =>  map va KERNBASE~.... to pa 0~.... 详见pmm_init
.text
.globl kern_entry
kern_entry:
    # 1.load pa of boot pgdir => 将pgdir的物理地址加载到cr3寄存器
    # 为什么要REALLOC ? => 分页模式下,页目录表__boot_pgdir将虚拟地址KERNBASE~KERNBASE+4MB 映射到物理地址0 ~ 4MB
    #                      进入kern_entry已经属于ucore部分,虚拟地址>KERNBASE,因此要通过REALLOC减去KERNBASE得到物理地址
    movl $REALLOC(__boot_pgdir), %eax    # __boot_pgdir是页目录表的虚拟地址;REALLOC宏将其转换为相对于内核起始地址的偏移
    movl %eax, %cr3                      # cr3存的是物理地址!! 而不是虚拟地址

    # 2.enable paging => 设置cr0的相应标志位,使能分页机制(CR0_PG标志位) => 才能使用TLB等...
    movl %cr0, %eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
    andl $~(CR0_TS | CR0_EM), %eax
    movl %eax, %cr0

    # 3.update eip
    # now, eip = 0x1.....因为刚进入ucore时,最开始处于分段模式,尚未开启分页机制.虚拟地址等于物理地址,此时内核还在0~4MB的低虚拟地址空间运行,在1MB往上的地方
    leal next, %eax                  # lea(load effective address)指令用来将一个内存地址赋给目的操作数
    # set eip = KERNBASE + 0x1.....   跳转到next中,将内核由虚拟地址1MB往上 迁移到 KERNBASE+1MB往上, 
    # 不过物理地址不变,因为__boot_pgdir中虚拟地址0~4MB以及KERNBASE~KERNBASE+4MB都映射到物理地址0~4MB
    # 如何看出设置了eip = KERNBASE + 0x1.. 
    #   => 因为next处于KERNBASE以上的虚拟地址(kernel.ld设置),跳转后自动到了高地址,eip自动更新
    jmp *%eax
next:
    # 4.unmap va 0 ~ 4M, it's temporary mapping
    # 取消页目录表的第一个Entry,于是便没有0~4MB(va) 到 0~4MB(pa)的映射
    # 结合上面的jmp,从而实现将内核由虚拟地址0~4MB迁移到虚拟地址KERNBASE~KERNBASE+4MB 
    # (不过内核所在的物理地址不变,仍然是0~4MB)
    xorl %eax, %eax
    movl %eax, __boot_pgdir

    # 5.set ebp, esp
    # 设置内核栈(bootasm.S中设置的栈应该只是bootloader的栈)
    movl $0x0, %ebp  # 同bootloader中一样,按理说不设置为0也可,这只是一个初始值,以后通过ebp是否等于这个初始值判断其是否为栈底
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp    # 设置内核栈顶
    # now kernel stack is ready , call the first C function
    call kern_init

# should never get here
spin:
    jmp spin

.data
.align PGSIZE
    .globl bootstack
bootstack:
    .space KSTACKSIZE      # 填充8KB空间 => 于是内核栈是从bootstacktop(高va地址) 到 bootstack(低va地址) 增长的区域
    .globl bootstacktop
bootstacktop:

# kernel builtin pgdir
# an initial page directory (Page Directory Table, PDT)
# These page directory table and page table can be reused!
# 此页目录表,暂时只填充了两个有意义的表项:
#   1.第一个有意义的页目录表项,即第一个页目录表项,它对应虚拟地址0-4MB:指向/映射第一个页表__boot_pt1
#   中间填充了很多页目录表项,他们没有意义,只是占用空间
#   2.第二个有意义的页目录表项,即KERNBASE处,它对应虚拟地址KERNBASE~KERNBASE+4MB:同样指向/映射第一个页表__boot_pt1
#   所以,虚拟地址的0~4MB以及KERNBASE~KERNBASE+4MB都映射到同一段物理内存(0~4MB)

.section .data.pgdir
.align PGSIZE
__boot_pgdir:
.globl __boot_pgdir
    # map va 0 ~ 4M to pa 0 ~ 4M (temporary)   虚拟地址的0~4MB映射到物理地址的0~4MB => 这个映射只是临时的
    .long REALLOC(__boot_pt1) + (PTE_P | PTE_U | PTE_W)  # 填写第一个页目录表项,这几个标志位见mmu.h
    .space (KERNBASE >> PGSHIFT >> 10 << 2) - (. - __boot_pgdir) # pad to PDE of KERNBASE => 填充页目录表项到KERNBASE处
    # map va KERNBASE + (0 ~ 4M) to pa 0 ~ 4M
    .long REALLOC(__boot_pt1) + (PTE_P | PTE_U | PTE_W)   # 填写第xxx个页目录表项,与第一个页目录表项映射到同一段物理内存
    .space PGSIZE - (. - __boot_pgdir) # pad to PGSIZE    # 页目录表至少占用4KB(PGSIZE),所以将其填充满
# # 注意:由于表项中的内容都是物理地址,而__boot_pgdir、__boot_pt1都是虚拟地址,所以需要REALLOC来计算物理地址!!

# __boot_pt1是第一个页表(二级页表) => 共4KB/1024项目,它映射的物理地址为0~4MB; 
# 一个页表项对应一个页=>所以共映射了1024*4KB=4MB
# 一个页表项占4B,32bit;实际上只有高20位用于索引页号(高10位PDX、中间10位PTX),低12位可利用来作为标记;
# 页表项的低12bit可用于标记该页的一些属性、权限等,详见mmu.h => 必看!!!
.set i, 0
__boot_pt1:
.rept 1024
    .long i * PGSIZE + (PTE_P | PTE_W)      # 填写的是第i页的物理地址!
    .set i, i + 1
.endr

