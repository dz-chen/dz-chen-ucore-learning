[TOC]

# 练习0 填写已有实验
lab1自己添加的注释过多,使用工具合并不方便 => 仅仅直接将答案复制过来,更多注释参考lab1代码

# 练习1:实现first-fit连续物理内存分配算法
作业结果见default_pmm.c

# 练习2:实现寻找虚拟地址对应的页表项



# 练习3:释放某虚拟地址所在的页并取消对应二级页表项的映射  
...

# 补充:探测系统物理内存布局
## 概述
获取物理内存调用的方法有:BIOS中断调用、直接探测
- **直接探测**
必须在保护模式下完成

- **BIOS中断调用**
1.必须在实模式下完成;都是基于INT 15h中断,具体的有三种参数:88h、e801h、e820h
2.linux kernel是依次尝试INT 15h中断的上述三种参数
3.ucore 是使用e820h,在bootloader进入保护模式之前调用此中断,<font color=red>并且将e820映射结构保存在地址0x8000处</font>
**对"BIOS中断调用"的理解**:INT 15h对应的中断处理例程由BIOS实现; 这与os的ISR(中断服务例程)不同,此时os尚未加载！


## 探测物理内存分布和大小的方法
实模式下调用INT 15h中断,由BIOS的中断服务例程返回内存的详细信息
这些信息通过如下结构描述:
```
// 地址范围描述符(加了nr_map字段)
struct e820map {
    int nr_map; // 当前是第几个map,从0开始编号
    struct {   // 地址范围描述符
        uint64_t addr;          //基址,8byte
        uint64_t size;          //大小,8byte
        uint32_t type;          //类型,4byte
        /************************ 关于上面type的取值解释如下
         *  01h    memory, available to OS
         *  02h    reserved, not available (e.g. system ROM, memory-mapped device)
         *  03h    ACPI Reclaim Memory (usable by OS after reading ACPI tables)
         *  04h    ACPI NVS Memory (OS is required to save this memory between NVS sessions)
         *  other  not defined yet -- treat as Reserved
         * 
         * *************************************************************/
    } __attribute__((packed)) map[E820MAX];
};
```

**INT 15h BIOS中断的调用参数**
```
eax：功能码,当输入e820h时能够探测内存; ucore直接使用e820
edx：534D4150h (即4个ASCII字符"SMAP"),这只是一个签名而已;
ebx：如果是第一次调用或内存区域扫描完毕,则为0. 如果不是,则存放上次调用之后的计数值;
ecx：保存地址范围描述符的内存大小,应该大于等于20字节;
es:di：指向保存地址范围描述符结构的缓冲区,BIOS把信息写入这个结构的起始地址;
```
**INT 15h BIOS中断的返回结果**
```
eflags的CF位:若INT 15中断执行成功,则不置位,否则置位
eax:534D4150h ('SMAP');
es:di：指向保存地址范围描述符的缓冲区,此时缓冲区内的数据已由BIOS填写完毕
ebx:下一个地址范围描述符的计数地址
ecx:返回BIOS往ES:DI处写的地址范围描述符的字节大小
ah：失败时保存出错代码
```
**综上**:<font color=red>我们通过调用INT 15h BIOS中断,递增di的值(20的倍数),让BIOS帮我们查找出一个一个的物理内存布局entry,并放入到一个保存地址范围描述符结构e820map的缓冲区中,供后续的ucore进一步进行物理内存管理</font>


## 实现物理内存探测(重要)
在进入保护模式之前,bootloader调用INT 15h中断;
由BIOS响应这个中断,返回物理内存结构到地址0x8000处,详细代码如下:
```
# ##########################  探测物理内存,lab1没有这部分!
probe_memory:
    movl $0, 0x8000      # 对0x8000处的的4字节置0 => 即将e820map结构体的nr_map字段置0; 注意此时处于实模式!
    xorl %ebx, %ebx
    movw $0x8004, %di    # INT 15h中断调用后,BIOS返回的地址范围描述符的起始地址(忽略了4字节的nr_map字段);见e820map结构体
start_probe:
    movl $0xE820, %eax   # 设置INT 15h中断调用的参数
    movl $20, %ecx       # 设置地址范围描述符的大小为20字节,其大小等于struct e820map的成员变量map的大小
    movl $SMAP, %edx     # 设置edx为534D4150h(即4个ASCII字符"SMAP"),这是一个约定
    int $0x15            # 调用int 0x15中断,要求BIOS返回一个用地址范围描述符表示的内存段信息(返回结果的地址为0x8004,已经存入%di)
    jnc cont             # 如果eflags的CF位为0,则表示还有内存段需要探测 => 跳转到cont,重新设置int 15h的返回地址,继续探测...; CF是进位标志
    movw $12345, 0x8000  # 探测有问题,结束探测
    jmp finish_probe
cont:
    addw $20, %di        # 设置下一个BIOS返回的映射地址描述符的起始地址
    incl 0x8000          # 递增struct e820map的成员变量nr_map
    cmpl $0, %ebx        # 如果INT0x15返回的ebx为零,表示探测结束,否则继续探测
    jnz start_probe
# ##########################  探测物理内存end,lab1没有这部分!
```
这段代码结束后,<font color=red>0x8000处便保存了物理内存分布的信息,这些信息按照e820map的结构组织;
ucore加载后,再使用这部分信息对物理内存进行关系</font>


# 补充:以页为单位管理物理内存

## 物理页的数据结构
- **物理页的数据结构**
每个物理页(帧)用一个数据结构Page来表示,Page结构应尽可能小,从而节约内存
```
// 描述物理页(帧)的结构体
struct Page {
    // 若某个页表项设置了某个虚拟页到这个物理页帧的映射,ref会+1
    int ref;                        
    //  flags有32bit,目前只用到两个bit
    // bit 0表示此页是否被保留 => bit 0 为1表示此页保留给操作系统使用;不能放到空闲页链表中
    // bit 1表示此页是否是free的 => bit 1为1表示此页free,可以被分配;否则表示已经分配了
    uint32_t flags;                 // => 见PG_property、 PG_reserved
    // 用于记录某连续物理内存空闲块的大小(个数),空闲块的第一个page才会使用这个字段!!
    unsigned int property;         
    // 双向链表,连接连续的物理内存空闲块,空闲块的第一个page才会使用这个字段!! 连接的是空闲块而不是页!
    list_entry_t page_link;        
};
```

- **管理空闲链表**
一个空闲块由多个frame组成,多个空闲块由双向链表链接成空闲链表;
=> 空闲链表链接的是空闲块而不是空闲页帧;
空闲链表由以下结构体描述
```
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;
```

## 实现细节及内存布局
- **实现细节**
大概就是根据BIOS返回的物理内存信息,将ucore以上的部分区域用于存放Page结构体数组;
Page结构体数组再往上的区域就是空闲物理内存,将这部分加入空间链表;
....详见pmm.c page_init()函数

- **关于lab2中的物理页管理**
1.本实验只实现最简单的物理页内存管理算法.相应实现在defalut_pmm.c中的default_alloc_pages()
和default_free_pages()函数
2.实验2在内存分配和释放方面最主要的作用就是建立一个物理内存页管理框架,这实际上是一个函数指针列表(见pmm.h),如下:
```
struct pmm_manager {
    const char *name;                                 // XXX_pmm_manager's name
    void (*init)(void);                               // initialize internal description&management data structure
                                                      // (free block list, number of free block) of XXX_pmm_manager 
    void (*init_memmap)(struct Page *base, size_t n); // setup description&management data structcure according to
                                                      // the initial free physical memory space 
    struct Page *(*alloc_pages)(size_t n);            // allocate >=n pages, depend on the allocation algorithm 
    void (*free_pages)(struct Page *base, size_t n);  // free >=n pages with "base" addr of Page descriptor structures(memlayout.h)
    size_t (*nr_free_pages)(void);                    // return the number of free pages 
    void (*check)(void);                              // check the correctness of XXX_pmm_manager 
};
```
实验2的重点就是实现上面的init_memmap、alloc_pages、free_apges三个函数

- **内存布局**
完成物理页内存管理初始化后,系统内存布局如下:
![物理页初始化后,系统内存布局](./memo-pic/计算机系统的内存布局.png)

# 补充:实现分页机制
## 段页式管理的基本概念
段式管理在lab1中已经学习,本节主要是在段的基础上分页
- **段页式管理**
x86体系结构将内存地址分为:逻辑地址、线性地址、物理地址;
逻辑地址就是程序指令中使用的地址,物理地址就是实际访问内存的地址;
逻辑地址通过段式管理的地址映射得到线性地址;
线性地址通过页式管理的地址映射得到物理地址;
![...](./memo-pic/段页式管理总体框架图.png)

- **分页机制管理**
段页式管理中的分页机制详细情况如下:
![...](./memo-pic/分页机制管理.png)
图中page directory其实就是一级页表;
一级页表的起始物理地址存放在cr3寄存器中;

## 系统执行中地址映射的三个阶段(重要)
### 概述
**lab1中的映射**:<font color=red>lab1中的段映射是对等映射关系 => 物理地址和虚拟地址相等</font>(通过让GDT中所有段的基址为0确定了对等映射关系);
```
// lab1的kernel.ld中关于地址映射的部分
/* Load the kernel at this address: "." means the current address */
. = 0x100000;

.text : {
    *(.text .stub .text.* .gnu.linkonce.t.*)
}
```
=> <font color=red>lab1中ld形成的ucore的起始虚拟地址从0x100000开始,由于是对等映射,所以ucore的起始物理地址也是0x100000,这个地址就是ucore的入口函数kern_init的地址地址</font>
综上,lab1中,虚拟地址、线性地址、物理地址间的映射关系为:
```
virt addr=linear addr =phy addr
```
<br>

**lab2中的映射**:lab2中经过了较为复杂的地址映射
```
// lab2的kernel.ld中关于地址映射的部分
/* Load the kernel at this address: "." means the current address */
. = 0xC0100000;
.text : {
    *(.text .stub .text.* .gnu.linkonce.t.*)
}
```
=> lab2中ld形成的ucore的起始虚拟地址从oxC0100000开始,它是ucore入口函数kern_entry(见kern/init/entry.S,与lab1中ucore的入口函数不同)的起始虚拟地址;
但是,实际上lab2和lab1一样,ucore都加载到起始物理地址0x100000处;
可见,lab1和lab2的地址映射不同.甚至,lab2在不同阶段,采用的地址映射方式也不同!!!
<font color=red>注意</font>:起始虚拟地址的变换,并不影响一般的跳转和函数调用,因为它们实际上是相对跳转;但是对于绝对寻址的全局变量引用,就需要使用REALLOC宏进行一些运算来确保地址是正确的(见entry.S)
</br>

下面概述lab2中地址映射的三个阶段:
### 第一阶段(开启保护模式,创建启动段表)
第一阶段是bootloader阶段,即从bootloader的start()函数(见boot/bootasm.S)开始,到ucore的kern_entry()函数(见kern/init/entry.S)之前;
这一阶段,虚拟地址、线性地址、物理地址之间的映射关系与lab1一样,即
```
lab2 stage1: virt addr=linear addr =phy addr
```

### 第二阶段(创建初始页目录表,开启分页模式)
第二阶段为:从kern_entry()函数开始,到pmm_init()函数被执行前(见init/init.c);
**1**.编译好的ucore自带了一个设置好的页目录表(一级页表)和相应的页表(二级页表),他们将0-4MB的线性地址一一映射到物理地址 => 页目录表的加载参考init/entry.S;
**2**.加载页目录项后,进行使能分页机制,对应代码如下(见entry.S):
```
movl %eax, %cr3                    # 将页目录表(一级页表)的起始地址存入cr3寄存器

# enable paging => 设置cr0的相应标志位,使能分页机制
movl %cr0, %eax
orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
andl $~(CR0_TS | CR0_EM), %eax
movl %eax, %cr0
```
进入分页模式后,地址映射关系如下: => ???为什么是这个规则,为何恰好是4MB?
```
virt addr = linear addr = phy addr  //线性地址在0-4MB之内时,三者的映射关系
virt addr = linear addr = phy addr+0xC0000000  // 线性地址在0xC0000000~0xC0000000+4MB之间时...
```
可见,这种映射限制了内核的大小,如果内核大于4MB(由于从0x100000开始编址,实际上是3MB),可能导致打开分页之后,内核崩溃
**3**.此时的内核(eip)还在0-4MB的低虚拟地址区域运行;而最终,内核需要在虚拟地址高地址区域运行,低地址留给用户程序;
=> 需要使用一个绝对跳转来使内核跳转到高虚拟地址,代码如下(见entry.S):
```
# update eip
# now, eip = 0x1.....
leal next, %eax         # lea(load effective address)指令用来将一个内存地址赋给目的操作数
# set eip = KERNBASE + 0x1.....
jmp *%eax
```
跳转完毕后,通过把boot_pgdir[0]对应的第一个页目录表项(0-4MB)清零来取消了临时的页映射关系:
```
# unmap va 0 ~ 4M, it's temporary mapping
xorl %eax, %eax
movl %eax, __boot_pgdir
```
最终,离开这个阶段时,逻辑地址、线性地址、物理地址的映射关系为: => ???与使能分页后映射的关系??
```
virt addr = linear addr = phy addr+0xC0000000 #线性地址在0xC0000000~0xC0000000+4MB之间时...
```
综上,第二阶段的目的就是:<font color=red>更新映射关系的同时,将运行的内核(eip)从低虚拟地址迁移到高虚拟地址而不造成伤害</font>f

### 第三阶段(完善段表和页表)
第三阶段为:从pmm_init函数被调用开始;
阶段二仅仅映射了物理地址的0~4MB,并不全面;并且对段表而言,缺少了运行ucore所需的用户段描述符以及TSS等 =>
pmm_init()函数完成以下工作:
&nbsp;&nbsp;&nbsp;&nbsp;1.将页目录表项补充完整,从0-4MB扩充到0-KMEMSIZE;
&nbsp;&nbsp;&nbsp;&nbsp;2.更新了段映射机制,使用了一个新的段表(包括内核态的断码段、数据段;以及用户态的代码段、数据段、TSS段);

最终的虚拟地址、线性地址、物理地址映射关系:
```
virt addr = linear addr = phy addr + 0xC0000000  #对所有线性地址
```

# 补充:建立虚拟页和物理页帧的地址映射关系(重要)

# 补充:物理内存页分配算法实现(结合练习1看)
本节主要描述First Fit的实现
1.需要熟悉相关数据结构及其操作,详看./libs/list.h、free_area_t、pmm_manager等
2.First Fit的实现需要重写`default_init`, `default_init_memmap`, `default_alloc_pages`, `default_free_pages`,详见./kern/mm/default_pmm.c
...略

# 补充:链接脚本及其中各符号的解读
```
/* Simple linker script for the ucore kernel.
   See the GNU ld 'info' manual ("info ld") to learn the syntax. */

/********************* 备注 **************************
* 1. "."表示当前地址
* 2. .ld文件中定义的edata[]、end[]是全局变量,会在部分源代码中引用(init.c),他们表示相应段的起始或结束地址
* 3. elf三类文件格式参考csapp第七章
*****************************************************/


OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)       /* cpu类型 */
ENTRY(kern_entry)       /* 程序入口*/

SECTIONS {
    /* Load the kernel at this address: "." means the current address */
    . = 0xC0100000;      /* 内核被链接到从这个虚拟地址开始的虚拟地址空间 */
    .text : {            /* .text 表示代码段起始地址 */
        *(.text .stub .text.* .gnu.linkonce.t.*)
    }

    PROVIDE(etext = .); /* Define the 'etext' symbol to this value */

    .rodata : {
        *(.rodata .rodata.* .gnu.linkonce.r.*)
    }

    /* Include debugging information in kernel memory */
    .stab : {
        PROVIDE(__STAB_BEGIN__ = .);
        *(.stab);
        PROVIDE(__STAB_END__ = .);
        BYTE(0)     /* Force the linker to allocate space
                   for this section */
    }

    .stabstr : {
        PROVIDE(__STABSTR_BEGIN__ = .);
        *(.stabstr);
        PROVIDE(__STABSTR_END__ = .);
        BYTE(0)     /* Force the linker to allocate space
                   for this section */
    }

    /* Adjust the address for the data segment to the next page */
    . = ALIGN(0x1000);

    /* The data segment */
    .data : {
        *(.data)
    }

    . = ALIGN(0x1000);
    .data.pgdir : {
        *(.data.pgdir)
    }

    PROVIDE(edata = .);  /* edata代表数据段的结束地址 */

    .bss : {            /* .bss也是数据段的结束地址,同时还是BSS段的起始地址*/
        *(.bss)
    }

    PROVIDE(end = .);  /* end 是BSS段的结束地址*/

    /DISCARD/ : {
        *(.eh_frame .note.GNU-stack)
    }
}
```
.ld文件中给出的地址是ucore内的的链接地址 == ucore内核的虚拟地址;  
bootloader加载ucore内核用到的加载地址 == ucore内核的物理地址; (这一条详见bootmain.c)



# 补充:ucore采用的自映射机制(重要,未完全懂?)
## 为什么需要自映射
通过boot_map_segment函数(见pmm.c)建立了基于一一映射关系的页目录表项和页表项,这里的映射关系为:  
```
virtual addr (KERNBASE~KERNBASE+KMEMSIZE) = physical_addr (0~KMEMSIZE)
```  
这样只要给出一个虚地址和一个物理地址,就可以设置相应PDE和PTE,就可完成正确的映射关系  

如果我们这时需要按虚拟地址的地址顺序显示整个页目录表和页表的内容,则要查找页目录表的页目录表项内容,根据页目录表项内容找到页表的物理地址,再转换成对应的虚地址,然后访问页表的虚地址,搜索整个页表的每个页目录项.这样过程比较繁琐.  

我们需要有一个简洁的方法来实现这个查找.ucore做了一个很巧妙的地址自映射设计 => 把页目录表和页表放在一个连续的4MB虚拟地址空间中,并设置页目录表自身的虚地址<==>物理地址映射关系.这样在已知页目录表起始虚地址的情况下,通过连续扫描这特定的4MB虚拟地址空间,就很容易访问每个页目录表项和页表项内容.  

## ucore自映射的实现
- **1.设置常量VPT**  
在memlayout.h中定义常量`VTP=0xFAC00000`,对应的二进制表示为 `1111 1010 1100 0000 0000 0000 0000 0000`
注意这个虚拟地址的高10位为1003,中10位为0,低12位也为0!

- **2.映射页表**  
在pmm.c中设置两个全局变量
```
 // 32位整数 => vpt就代表了页表(二级页表)的起始虚拟地址(也就是一级页表中第一个表项指向的页表的虚拟地址)
pte_t * const vpt = (pte_t *)VPT; 
// vpd=0xFAFEB000,它是页目录表(一级页表)的起始虚拟地址,其高10bit和中10bit都是1003  
// 为什么vpd要这样设置??
pde_t * const vpd = (pde_t *)(PGADDR(PDX(VPT), PDX(VPT), 0));  
```  
且在pmm_init()函数中执行:  
```
// 设置页表(所有页表,共4MB)对应的页目录表项!!!
boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W; 
```  

- **3.print_pgdir()打印页表内容**  
执行结果:
```
PDE(0e0) c0000000-f8000000 38000000 urw          
  |-- PTE(38000) c0000000-f8000000 38000000 -rw
PDE(001) fac00000-fb000000 00400000 -rw
  |-- PTE(000e0) faf00000-fafe0000 000e0000 urw
  |-- PTE(00001) fafeb000-fafec000 00001000 -rw
```  
其中`PDE(0e0) c0000000-f8000000 38000000 urw`表示:
1.页目录表中相邻的224(0e0)项具有相同权限;  
2.这224项映射的虚拟地址范围是c0000000-f8000000;  
3.虚拟地址大小为38000000(共896MB,恰好与224项对应,224*4MB);  
4.具体权限为urw(存在,用户可读、可写)  
同理可得`PDE(001) fac00000-fb000000 00400000 -rw`...这一段恰好是所有页表(4MB)对应的页目录表项

- **4.用户程序通过自映射机制访问页表**  
自映射机制还可方便用户态程序访问页表.因为页表是内核维护的,用户程序很难知道自己页表的映射结构,VPT 实际上在内核地址空间的,我们可以用同样的方式实现一个用户地址空间的映射(比如 pgdir[UVPT] = PADDR(pgdir) | PTE_P | PTE_U,注意,这里不能给写权限,并且 pgdir 是每个进程的 page table,不是 boot_pgdir).这样,用户程序就可以用和内核一样的 print_pgdir 函数遍历自己的页表结构了




# 相关要点/问题速览
- **如何将Page结构体数组放到指定位置(它需要紧接在ucore内核代码后)?**  
????

- **如何根据双向链表节点获取对应的物理页?**  
???

- **如何在建立页表的过程中维护页表和GDT的关系,确保ucore能够在各时间段上正常寻址?**  
??

- **哪些物理内存空间需要建立页映射关系?**  
??

- **具体的页映射关系是什么?**  
??
- **页目录表的起始地址设置在哪里?**  
??
- **页表的起始地址设置在哪里,需要多大空间?**  
??
- **如何设置页目录表项的内容?**  
??
- **如何设置页表项的内容?**  
??

- **如何理解地址映射的第二阶段?**  
??

- **entry.S中内栈那样设置的依据(为何ebp设置为0,为何内核栈填充满之后才设置esp)?**  
??

- **页目录表__boot_pgdir在哪里?页表在哪里?**  
页目录表在内核代码中;  
页表(二级页表)在0xFAC00000往上的4MB范围内=> 共1MB个页表项,恰好对应4GB物理内存  

- **get_pte()函数中,给二级页表分配物理空间时,如何保证二级页表的虚拟地址在0xFAC00000往上的4MB范围内??**  
??

- **对于struct Page* page;计算page对应物理页号的原理??**  
参见pmm.h,page2pa()函数

- **为什么pmm.c中令vpd=0xFAFEB000,使得页目录表夹在4MB的页表虚拟地址空间的内部??**  
??

