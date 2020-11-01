[TOC]

# 关于本project
- ./boot :bootloader相关代码
- ./bios-bootloader.s：导出的qemu执行的指令，包括bios、bootloader
- 
每个练习的最后一个子目录下,包含练习要求回答的问题,以及自己的思考; 其余子目录是相关笔记
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
**注意**:<font color=rde>保护模式下,汇编指令中的地址是逻辑地址(即操作系统中所称的虚拟地址)</font>

### 分段机制
.地址转换过程..... => 需要使用:段选择子(CS寄存器)、段描述符表、描述符表寄存器
.分段相关内容中的端描述符、段描述符表可以参考源码:bootasm.S、mmu.h、pmm.c
.<font color=red>这里所说的分段与编译器中描述的代码段、数据段、堆栈段含义是一致的</font>

- 段描述符
段描述符表中的一个数据项，包括:段基址、段限长、段属性
详见./kern/mm/mmu.h中的segdesc数据结构!!
<font color=red>段描述符格式如下,注意基址、限长的各个bit并不是连续的!!</font>:
![段描述符格式,图片来自lab1实验指导书](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1_figs/image003.png)

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

## 3.4 相关要点/问题速览(重要)---未完成
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
 再见asm.h中的宏定义,重要! => 理清楚是大端还是小端,段描述符的填充过程


- **为何bootloader设置栈时,要将ebp设置为0,将esp设置为0x7c00?**
参考:[函数堆栈](:https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1/lab1_3_3_1_function_stack.html)

- **设置A20时的代码逻辑?**
???

- **GDT表的地址是如何确定的,何时执行初始化GDT表的汇编代码?**
???




# 练习4:分析bootloader加载ELF格式的OS的过程
## 4.1 硬盘访问概述
### IDE
IDE即"电子集成驱动器",它的本意是指把"硬盘控制器"与"盘体"集成在一起的硬盘驱动器.一般每个主板上有两个IDE接口/通道(IDE1和IDE2).每个接口可以分别接两个硬盘或者两个光驱.在机箱内主板上连接硬盘和光驱的接口就是IDE接口
第一个IDE通道通过访问IO地址0x1f0~0x1f7来实现
第二个IDE通道通过访问IO地址0x170~0x17f来实现
每个通道的主从盘通过第6个IO偏移地址寄存器来设置(对第一个IDE接口来说,寄存器就是0x1f6)
IDE1几个寄存器详情参考:[磁盘IO地址和对应功能](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1/lab1_3_2_3_dist_accessing.html)

### 硬盘的LBA模式和CHS模式
CHS(Cylinder Head Sector)
LBA(Logical Block Addressing)
二者代表对磁盘的不同编址方式,详见:[硬盘LBA 和CHS的关系](https://blog.csdn.net/zztan/article/details/70861021?utm_medium=distribute.pc_relevant.none-task-blog-title-3&spm=1001.2101.3001.4242)

### ucore如何实现硬盘访问
<font color=red>ucore的bootloader访问硬盘采用LBA模式的PIO(Program IO)方式</font>来加载OS,即所有的IO操作都是通过CPU访问硬盘的IO地址寄存器来完成
一个扇区大小为512B,读取一个扇区流程(详见./boot/bootmain.c中readsect函数):
- 1.等待磁盘准备好
- 2.发出读取扇区命令
- 3.等待磁盘准备好
- 4.把磁盘扇区数据读到指定内存

## 4.2 ELF文件格式概述
### 三种ELF文件
- 可重定位目标文件 => xxx.o
- 可执行目标文件 => a.out
- 共享目标文件   => xxx.so

### ELF可执行目标文件格式(重要)
**elf header**在文件开始处描述了整个文件的组织.ELF的文件头包含整个执行文件的控制结构.其定义在elf.h中:
```
struct elfhdr {
	uint32_t e_magic;	// 魔数，elf文件的前四字节分别为（0x7f，E，L，F）
	uint8_t e_elf[12];        //这12字节没有定义
	uint16_t e_type;        //目标文件属性
	uint16_t e_machine;    //硬件平台类型
	uint32_t e_version;    //elf的版本
	uint32_t e_entry;        //程序入口
	uint32_t e_phoff;        //程序头表偏移量，bootmain函数中的第一行的那个结构便是程序表头的结构
	uint32_t e_shoff;        //节表头偏移量，节表多用来储存程序会用到的数据
	uint32_t e_flags;        //处理器特定标志 
	uint16_t e_ehsize;       //elf头部长度 
	uint16_t e_phentsize;    //程序头表中一个条目的长度 
	uint16_t e_phnum;        //程序头表条目数目 
	uint16_t e_shentsize;    //节头表中一个条目的长度 
	uint16_t e_shnum;        //节头表条目个数 
	uint16_t e_shstrndx;    //节头表字符索引 
};
```
**program header**描述与程序执行直接相关的目标文件结构信息,用来在文件中定位各个段的映像,同时包含其他一些用来为程序创建进程映像所必需的信息.可执行文件的程序头部是一个program header结构的数组,每个结构描述了一个段或者系统准备程序执行所必需的其它信息,目标文件的"段"包含一个或者多个 "节区"(section),也就是"段内容(Segment Contents)".程序头部仅对于可执行文件和共享目标文件有意义.可执行目标文件在ELF头部的e_phentsize和e_phnum成员中给出其自身程序头部的大小.程序头部的数据结构如下表所示:
```
struct proghdr {
  uint type;   // 段类型
  uint offset;  // 段相对文件头的偏移值
  uint va;     // 段的第一个字节将被放到内存中的虚拟地址
  uint pa;
  uint filesz;
  uint memsz;  // 段在内存映像中占用的字节数
  uint flags;
  uint align;
};
```
**elf可执行文件的完整格式如下**:
![典型elf可执行目标文件](https://img-blog.csdnimg.cn/20200830222244830.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3N0cmRoZ3RoYmJo,size_16,color_FFFFFF,t_70#pic_center)
上文中的elf header即ELF头; <font color=red>program header即段头部表</font>

## 4.3 相关要点/问题速览(重要)

- **bootloader如何读取硬盘扇区/理解读取扇区代码**
```
// 读取编号为secno的扇区到dst处;扇区编址方法采用LBA,以PIO方式读取
static void readsect(void *dst, uint32_t secno) {
    // 1.wait for disk to be ready
    waitdisk();

    // 2.写IO端口,发出读扇区命令 => 更详细解析参考bootmain.c
    outb(0x1F2, 1);                         // count = 1
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);                      // cmd 0x20 - read sectors

    // 3.wait for disk to be ready
    waitdisk();

    // 4.read a sector => 从0x1f0端口读取数据
    insl(0x1F0, dst, SECTSIZE / 4);        // 这里的读取指令以4字节为单位,所以 SECTSIZE/4   
}
```

- **bootloader如何加载ELF格式的OS?**
先读取第一个page,其中包含elf header
然后根据读取到的elf header加载所有剩余段,这个过程会读取段头部表各项proghdr
最后调用/跳转到elf header指定的程序入口地址,直接开始执行OS程序....
详见bootmain函数!

- **为什么ELFHDR定义为0x10000?**
=> 1MB地址空间以下是BIOS以及bootloader等程序
1MB地址以上才是操作系统

- **为什么读取前va要修改为:va -= offset % SECTSIZE; ??**
保证每次读取一个段时,修正的内存地址va始终在扇区的边界上
详见[xv6: bootmain.c readseg() “round down to sector boundary”
](https://stackoverflow.com/questions/51863984/xv6-bootmain-c-readseg-round-down-to-sector-boundary)
.... 仍有稍许不懂 ???




# 练习5:实现函数调用堆栈跟踪
## 5.1 操作系统启动过程
bootloader将ucore将在到内存后,就跳转到ucore在内存中的入口位置(跳转见bootmain.c,ELF头中有入口地址)
这个入口地址就是:./kern/init/init.c中的kern_init函数的起始地址;之后主要完成的工作为:
- 初始化终端
- 显示字符串
- 显示堆栈中的多层函数调用关系
- 切换到保护模式,弃用分段机制
- <font color=red>初始化中断控制器,设置中断描述符表,初始化时钟中断,使能整个系统的中断机制</font>
- 执行while(1)死循环
...详见./kern/init/init.c

## 5.2 函数堆栈(十分重要!)
### 函数调用栈结构
```
|  栈底方向     |   高位地址
-----------------             => 一个栈帧
|    ...       |
|   参数3       |
|   参数2       |
|   参数1       |
|  返回地址     |
|  上一层[ebp]  | <---------[ebp],据此形成了函数调用链!!!
|  局部变量     |
|    ...       |  
-----------------
|    ...       |
|   参数3       |
|   参数2       |
|   参数1       |
|  返回地址     |
|  上一层[ebp]  | <---------[ebp],这里入栈的ebp值是上一个函数执行时,ebp寄存器的内容,据此可找到上一个函数的栈帧
|  局部变量     |
|    ...       |  低位地址
-----------------   
    .....
```
执行函数的实际指令前入栈的内容:参数、返回地址、ebp
执行函数的实际指令过程中入栈的内容:局部变量

### ebp寄存器及函数调用过程
**ebp寄存器存储的内容**:<font color=red>一个相对于堆栈段地址的**偏移**,这个偏移用于标志当前函数栈帧的位置(并不是网上广为流程的栈底!)</font>
**ebp寄存器的作用**:<font color=red>ebp所指地址往上可获取函数参数;ebp所指地址往下可获取函数局部变量</font>
**ebp所指地址处存储的内容**:上一个函数执行时,ebp寄存器的内容 => 从而形成函数调用链
<br/>

**函数调用过程**
- 1.零到多个push指令 
=> 参数入栈
- 2.call指令
调用函数....不过注意:
a.call指令隐含了返回值入栈这一动作
b.编译器会在函数对应的指令前插入ebp入栈的指令,见3.
- 3.ebp寄存器入栈,同时更新ebp
```
# 这部分由编译器插到函数指令最开始处
pushl %ebp                 #将上一个函数的ebp内容入栈
movl %esp, %ebp            #更新当前函数ebp的值
```
- 4.执行指令
这才真正开始执行函数体对应的指令....

### 获取函数调用信息
**注意**:ebp寄存器存储的内容是到堆栈段开始地址的偏移,而不是真正的地址!,所以:
- ss:[ebp]为上一帧的ebp值
- ss:[ebp+4]为返回地址
- ss:[ebp+8]为第一个参数值
- ss:[ebp-4]为第一个局部变量

## 5.3 相关要点/问题速览(重要)
- **为什么为什么更新ebp、eip的顺序会影响print_debuginfo的调用结果以及eip后续的值???**
在kdebug.c中,为什么???
- **为什么自己编写的代码eip结果与下面的参考代码rip结果总是差1???**
???


# 练习6:完善中断初始化和处理
## 6.1 中断概述
- **中断机制**
CPU与外设通信时,不是CPU按时轮询外设 <=> 而是外设完成某一事件后主动通知CPU
这就是中断,它会打断CPU当前工作,转而完成外设通知的事件相关的工作,然后再回到之前的工作
**中断是实现进程/线程抢占式调度的重要基石**
本节所说的中断是广义中断,不仅仅指外部中断

- **三种特殊的中断事件**
**外部中断**:由外设引起的外部事件如I/0中断、时钟中断、控制台中断等;这是异步产生的(即产生时刻不确定),也称异步中断
**内部中断/异常**:CPU执行期间检测到不正常或非法的条件(除零、地址访问越界等);这是同步的,也称同步中断
**陷入中断/软中断**:由于系统调用引发的中断称为陷入中断/软中断
**注意**:...可参照csapp ecf, 不过表述上稍有差异 => csapp将这里的内部中断称为故障和终止

## 6.2 中断描述符表(IDT)与IDTR
类似于全局描述符表,IDT把每个中断/异常编号和一个指向中断服务例程的描述符联系起来;
IDT的每个表项占8byte,第一个表项可存放数据;
IDT的起始地址存放在IDTR寄存器中;
- **IDT与IDTR关系**
![IDT与IDTR关系](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1_figs/image007.png)

- **操作IDTR的指令—LIDT与SIDT指令**
**LIDT(Load IDT register)**:使用一个包含线性地址基址和界限的内存操作数来加载IDTR(源操作数指向一个6字节数据的内存地址,这6字节数据包含4字节基址,2字节界限);操作系统创建IDT时需要执行它来设定IDT的起始地址;只能在特权级0执行(参考:./libs/x86.h )
**SIDT(Store IDT register)()**:拷贝IDTR的基址和极限部分到一个内存地址;可在任意特权级执行

- **中断/异常向量**
最多256个,但是没有全部用完
**[0...31]**:用于Exception和NMI
**[32,255]**:保留给用户定义的Interrupt,用户可将其用作I/O中断、或者系统调用




## IDT gate descripter

## 6.x 相关要点/问题速览(重要)
- **中断描述符表(保护模式下的中断向量表)中一个表项多少字节?**
8bytes

- **中断描述符表项哪几位代表中断处理代码的入口?**
.....

