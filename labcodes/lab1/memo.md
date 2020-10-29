[TOC]

# 关于本project
- ./boot :bootloader相关代码
- ./bios-bootloader.s：导出的qemu执行的指令，包括bios、bootloader
- 
写在前面:多读实验指导书!


# 练习1
相关笔记见Makefile文件


# 练习2:使用qemu执行并调试
## 2.1 关于开机启动的第一条指令
参考:[4.10 补充：关于第一条指令及线性地址的计算](https://blog.csdn.net/strdhgthbbh/article/details/109059645)
##  2.2 如何一次查看所有执行的指令
=> qemu的启动选项加上：-d in_asm -D  bootasm.s,将执行的指令输出到指定文件


# 练习3:分析bootloader进入保护模式的过程
## 3.1 bootloader启动过程
BIOS将通过读取硬盘主引导扇区中的bootloader到内存,然后将控制交给bootloader,bootloader完成:
- 切换到保护模式,启用分段机制
- 读取磁盘ELF执行文件(ucore操作系统)到内存
- 将控制交给ucore操作系统

bootloader的实现文件:./boot/asm.h、 ./boot/bootasm.S、bootmain.c

## 3.2 保护模式和分段机制

### 实模式
将整个物理内存看做分段的区域....,<font color=red>修改A20地址线可完成从实模式到保护模式的切换</font>

### 保护模式
保护模式下,386的32根地址线才全部有效,此时不再仅仅使用物理地址.地址转换过程:
逻辑地址 => 线性地址 => 物理地址
需要使用GDT、LDT
地址转换方式.....详见博客笔记


### 分段机制
.地址转换过程..... => 需要使用:段选择子(CS寄存器)、段描述符表、描述符表寄存器
.分段相关内容中的端描述符、段描述符表可以参考源码:bootasm.S、mmu.h、pmm.c
.<font color=red>这里所说的分段与编译器中描述的代码段、数据段、堆栈段含义是一致的</font>

- 段描述符
段描述符表中的一个数据项，包括:段基址、段限长、段属性
详见./kern/mm/mmu.h中的segdesc数据结构!!

- 全局描述符表GDT
由段描述符构成的数组
其起始地址保存在全局描述符表寄存器GDTR中
第一个段描述符设定为空段描述符
详见./boot/bootasm.S 和 kern/mm/pmm.c

- 段选择子
CS/DS段的程序员可见部分,16位
低2位描述特权级 => <font color=red>对DS而言是请求特权级(RPL); 对CS而言是当前特权级(CPL)</font>
第3位用于选择段描述符表(0:GDT、1:LDT)
高13位:到段描述符的索引

### 特权级
0代表最高权限;3代表普通权限,通常给应用程序使用
<font color=red>CS寄存器中的CPL总是等于CPU的当前特权级</font>
**内存访问特权级检查**
![图片来自lab1指导书](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1_figs/image006.png)
- CPL
定义了当前所执行程序的特权级别
- DPL
描述了段本身能被访问的真正特权级
- RPL
描述了进程对段访问的请求权限,意思是当前进程想要的请求权限(即进程对应代码访问数据的权限???)


## 3.x 地址映射
<font color=red>物理地址空间取决于CPU实现的物理地址位数,而不是实际的内存条大小!</font>
通常将IO外设映射到物理地址空间的高地址部分;
将内存条映射到物理地址空间的低地址部分,从0开始一一对应
详见:[地址空间](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1/lab1_3_2_2_address_space.html)


## 3.3 bootloader源码分析
从./boot/bootasm.S开始看,内有详细注释

## 3.4 相关要点/问题速览
- **为何要开启A20,如何开启A20**
早期的8086只有20条数据线(A0~A19);80386要使用32位地址,开启A20地址线后,才能使用
开启方式:见./boot/bootasm.S

- **如何使能和进入保护模式**
 CR0寄存器最低位PE标志是否保护模式
 1.将cr0内容读取
 2.然后通过:orl $CR0_PE_ON, %eax 设置PE位为1
 3.最后将设置好的内容写入cr0,即可开启保护模式 
 4.开启保护模式后,立即跳转到32位下的代码:ljmp $PROT_MODE_CSEG, $protcseg 
  详见./boot/bootasm.S

- **如何初始化GDT表**
 详见bootasm.S文件gdt、gdtdesc处

- **为何bootloader设置栈时,要将ebp设置为0,将esp设置为0x7c00?**
???

- **设置A20时的代码逻辑?**
???



# 杂七杂八
