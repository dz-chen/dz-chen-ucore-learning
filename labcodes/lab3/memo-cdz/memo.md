[toc]

# 练习0:填写已有实验
...略

# 练习1:给未被映射的地址映射上物理页


# 练习2:补充完成基于FIFO的页面替换算法

# 补充:虚拟内存管理
## 基本原理概述
- **什么是虚拟内存**  
简单的说就是程序员或者CPU看到的内存  
(但也有的资料仅仅将磁盘上的swap解释为虚拟内存,稍作注意 => 推荐此处的解释)  

- **几个注意之处**  
1.虚拟内存单元不一定有实际的物理内存单元对应,即实际的物理内存单元可能不存在;  
2.如果虚拟内存单元有实际的物理内存单元,那二者的地址一般是不相等的(即虚拟地址!=物理地址);  
3.通过操作系统实现的某种内存映射可建立虚拟内存与物理内存的对应关系,使得程序员访问的虚拟内存地址自动转换为一个物理内存地址;  

- **作用**  
页表完成虚拟地址到物理地址的转换 => 可通过设置页表项来限定软件运行时的访问空间,确保软件运行不越界,完成内存访问保护的功能(csapp也有讲述);  

- **<font color=red>按需分页</font>**  
通过内存地址虚拟化,可以使得软件在没有访问某虚拟内存地址时不分配具体的物理页,而只有在实际访问某虚拟内存地址时,操作系统再动态地分配物理内存,建立虚拟内存到物理内存的映射关系

- **<font color=red>页面置换</font>**  
把不经常访问的数据所占的内存空间临时写到硬盘上,从而腾出更多的物理内存给经常访问的数据;  
当CPU访问到不经常访问的数据时,再将这些数据从硬盘读取的内存中;  
换出的数据放到哪里?  
![换出到哪里?](./memo-pic/交换空间.png)


## 实验执行流程  
- **1.初始化**  
ucore的总控函数是kern_init()(见init.c)  
vmm前要完成的工作包括:pmm_init、pic_init、idt_init

- **2.虚拟内存管理**  
a. vmm_init() => 用于检查lab3练习1是否正确实现(当然包括执行练习1)  
b. ide_init() =>  为练习2做准备,完成对硬盘分区swap的初始化工作
c. swap_init() => 为练习2做准备 ...















## 关键数据结构 
- **linux虚拟内存的组织方式**  
ucore中组织虚拟内存的两个关键的数据结构与linux类似,如图所示:  
![linux虚拟内存组织](memo-pic/linux虚拟内存组织方式.png)  
更多内容,参考博客:https://blog.csdn.net/strdhgthbbh/article/details/108868196 => 第9.7节
- **mm_struct**  
    ```
    // the control struct for a set of vma using the same PDT
    struct mm_struct {
        list_entry_t mmap_list;        // 链接mm_struct对应的所有vma_struct
        struct vma_struct *mmap_cache; // 指向当前正在使用的vma_struct
                                    // 由于局部性原理,当前正在使用的虚拟地址空间接下来可能还会使用,这是就不需要查链表,而是直接使用这个之指针)
                                    // 从而加快查询速度
        pde_t *pgdir;                  // the PDT of these vma => 指向mm_struct维护的页目录表
        int map_count;                 // the count of these vma => 记录mmap_list中链接的vma_struct的个数
        void *sm_priv;                   // the private data for swap manager => 指向用来链接记录页访问访问情况的链表头(从而建立了mm_struct和swap_mmanager之间的联系)
    };
    ```

- **vma_struct**  
进程(虽然这里尚未谈到进程)的虚拟内存空间会被分成不同的若干区域,每个区域都有其相关的属性和用途,一个合法的地址总是落在某个区域当中的,这些区域也不会重叠.在linux内核中,这样的区域被称之为虚拟内存区域(virtual memory areas),简称vma.一个vma就是一块连续的线性地址空间的抽象,它拥有自身的权限(可读,可写,可执行等等),每一个虚拟内存区域都由一个相关的`struct vma_struct`结构来描述;  
一个 vma_struct其实就对应了一个段!
    ```
    // the virtual continuous memory area(vma), [vm_start, vm_end), 
    // addr belong to a vma means  vma.vm_start<= addr <vma.vm_end 
    struct vma_struct {
        struct mm_struct *vm_mm; // the set of vma using the same PDT 
        uintptr_t vm_start;      // start addr of vma ,PGSIZE对齐的      
        uintptr_t vm_end;        // end addr of vma, not include the vm_end itself,PGSIZE对齐的
        uint32_t vm_flags;       // flags of vma => VM_READ、VM_WRITE、VM_EXEC
        list_entry_t list_link;  // linear list link which sorted by start addr of vma => 将一系列用vma_struct表示的虚拟内存空间链接起来
    };
    ```







# 补充:page fault异常处理  
当启动分页机制以后,如果一条指令或数据的虚拟地址所对应的物理页框不再内存中或者访问的类型有错误(比如写一个只读页或用户态程序访问内核态数据等),就会发生页访问异常.这部分主要涉及到函数do_pgfault()(见vmm.c)  

- **<font color=red>发生页访问异常的原因</font>**  
1.目标页帧不存在(即页表项全为0,表示该线性地址/虚拟地址与物理地址尚未建立映射或者映射已经撤销);  
2.相应的物理页帧不在内存中(页表项非空但Present标志位=0,表示该页在swap分区或者磁盘文件中);  
3.不满足访问权限(Present标志位为1,但是低权限的程序视图访问高权限的地址空间,或者有程序视图写只读页面).  

- **保存异常地址与错误码**  
出现上述情况时,CPU将产生异常的线性地址/虚拟地址存储在`CR2`寄存器,并将表示页访问异常的errorCode保存到中断栈中
    ```
    [提示]页访问异常错误码有32位.位0为1表示对应物理页不存在;位1为1表示写异常(比如写了只读页);位2为1表示访问权限异常(比如用户态程序访问内核空间的数据

    [提示] CR2是页故障线性地址寄存器,保存最后一次出现页故障的全32位线性地址.CR2用于发生页异常时报告出错信息.当发生页异常时,处理器把引起页异常的线性地址保存在CR2中,操作系统中对应的中断服务例程可以检查CR2的内容,从而查出线性地址空间中的哪个页引起本次异常
    ```

- **保存中断现场**  
由于页访问异常也是一种异常/中断,所以针对一般异常的硬件处理操作是必须要做的,即`CPU在当前内核栈保存当前被打断的程序现场`,即依次压入当前被打断程序使用的EFLAGS、CS、EIP、errorCode;由于页访问异常的中断号是0xE，CPU把异常中断号0xE对应的中断服务例程的地址(vectors.S中的标号vector14处)加载到CS和EIP寄存器中,开始执行中断服务例程.这时ucore开始处理异常中断,首先需要保存硬件没有保存的寄存器.在vectors.S中的标号vector14处先把中断号压入内核栈,然后再在trapentry.S中的标号__alltraps处把DS、ES和其他通用寄存器都压栈.自此,被打断的程序执行现场（context）被保存在内核栈中  

- **中断服务例程**  
保存中断现场后,由trap.c中的trap函数开始进入了中断服务例程的处理流程,调用过程如下:  
    ```
    trap--> trap_dispatch-->pgfault_handler-->do_pgfault
    ```  
最后,do_pgfault的调用关系如图(见vmm.c):  
![do_pgfault](memo-pic/do_pgfault.png)  


- **更多细节**  
产生页访问异常后,CPU把引起页访问异常的线性地址装到寄存器CR2中,并给出了出错码errorCode,说明了页访问异常的类型.ucore OS会把这个值保存在struct trapframe 的tf_err成员变量中.而中断服务例程会调用页访问异常处理函数do_pgfault进行具体处理.这里的页访问异常处理是实现按需分页、页换入换出机制的关键之处.  
w
ucore中do_pgfault函数是完成页访问异常处理的主要函数,它根据从CPU的控制寄存器CR2中获取的页访问异常的物理地址以及根据errorCode的错误类型来查找此地址是否在某个VMA的地址范围内以及是否满足正确的读写权限,如果在此范围内并且权限也正确,这认为这是一次合法访问,但没有建立虚实对应关系.所以需要分配一个空闲的内存页,并修改页表完成虚地址到物理地址的映射,刷新TLB,然后调用iret中断,返回到产生页访问异常的指令处重新执行此指令.如果该虚地址不在某VMA范围内，则认为是一次非法访问.  


# 补充:页面置换机制的实现 
## 页面替换算法  
...略  
参考:[第九讲:页面置换算法](https://blog.csdn.net/strdhgthbbh/article/details/109776877)
下面主要详细讨论页面置换机制的实现  

## 页面置换机制(重要)  
写在前面:实验三中仅实现了简单的页面置换机制,但现在还没有涉及实验四和实验五才实现的内核线程和用户进程,所以还无法通过内核线程机制实现一个完整意义上的虚拟内存页面置换功能.  

- **1.哪些页可以被换出?**  
`基本原则上`:只有映射到用户空间并且被用户程序直接访问的页才能被交换,而被内核直接使用的内核空间的页面不能被换出  
`为什么不能换出内核使用的页面`:保证操作系统的高效和实时  
    ```
    但在实验三实现的ucore中,我们只是实现了换入换出机制,还没有设计用户态执行的程序,所以我们在实验三中仅仅通过执行check_swap函数在内核中分配一些页,模拟对这些页的访问,然后通过do_pgfault来调用swap_map_swappable函数来查询这些页的访问情况并间接调用相关函数,换出"不常用"的页到磁盘上.
    ```  

- **<font color=red>2.虚拟内存页如何与磁盘上的扇区建立映射关系</font>?**  
`当一个PTE描述在内存中的页时`:PTE_P应该为1表示在内存中,且它还应该维护各种权限和 虚拟地址<=>物理地址 的映射关系;  
`当一个PTE描述在磁盘/swap的页时`:PTE_P应为0表示不在内存,且它还应该维护 虚拟地址<=> swap/磁盘上扇区 的映射关系;  
所以,当虚存访问的页不在内存中时,触发page fault => os根据PTE描述的swap向将相应的物理页建立起来,并根据虚存所描述的权限重新设置好PTE使得内存访问能够继续正常进行.  
<br/>  
当一个PTE描述swap/磁盘上的页时,页表项按照如下方式组织:
    ```
    * swap_entry_t
    * --------------------------------------------
    * |         offset        |   reserved   | 0 |
    * --------------------------------------------
    *           24 bits            7 bits    1 bit
    ```
即高24bit用与表示此页在磁盘上的起始扇区号(0号扇区不使用!);中间7bit保留给后续扩展使用;最低1bit为0表示虚实地址映射关系不存在  
<br/>
通常,一个页为4KB,一个扇区为512B,所以8个扇区对应一个页;在ucore中,使用第二个IDE硬盘包保存被换出的扇区  

- **3.何时执行换入换出操作?**  
**换入时机**  
当de_pgfault()函数判断出产生页访问异常的地址处于合法虚拟地址空间,且对应页保存在swap/磁盘中,则是执行页换入的时机 => 调用swap_in函数完成页面换入  
**换出时机**  
`积极换出策略`:操作系统周期性地主动将某些页面换出....  
`消极换出策略`:只有当试图得到空闲块且当前没有可供分配的物理页时,才执行换出  

- **<font color=red>4.页面替换算法对应的数据结构</font>**  
为了表示物理页可被换出或已被换出的情况,对`Page`结构扩展如下:
    ```
    struct Page {  
    ……   
    list_entry_t pra_page_link; //按页的第一次访问时间进行排序的一个链表,这个链表的开始表示第一次访问时间最近的页，链表结尾表示第一次访问时间最远的页
    uintptr_t pra_vaddr;        // pra_vaddr用来记录此物理页对应的虚拟页起始地址
    };
    ```
当一个物理页(struct Page)需要被swap出去的时候,首先需要确保它已经分配了一个位于磁盘上的swap page(由连续的8个扇区组成).这里为了简化设计,在swap_check函数中建立了每个虚拟页唯一对应的swap page,其对应关系设定为:虚拟页对应的PTE的索引值 = swap page的扇区起始位置*8.  
为了实现各种页替换算法,ucore设计了一个页替换算法的类框架swap_manager:  
    ```
    struct swap_manager  
    {  
        const char *name;  
        /* Global initialization for the swap manager */  
        int (*init) (void);  
        /* Initialize the priv data inside mm_struct */  
        int (*init_mm) (struct mm_struct *mm);  
        /* Called when tick interrupt occured */  
        int (*tick_event) (struct mm_struct *mm);  
        /* Called when map a swappable page into the mm_struct */  
        int (*map_swappable) (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);   
        /* When a page is marked as shared, this routine is called to delete the addr entry from the swap manager */
        int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);  
        /* Try to swap out a page, return then victim */  
        int (*swap_out_victim) (struct mm_struct *mm, struct Page *ptr_page, int in_tick);  
        /* check the page relpacement algorithm */  
        int (*check\_swap)(void);   
    };
    ```  
这里关键的两个函数指针是map_swappable和swap_out_vistim,前一个函数用于记录页访问情况相关属性,后一个函数用于挑选需要换出的页.显然第二个函数依赖于第一个函数记录的页访问情况.tick_event函数指针也很重要,结合定时产生的中断,可以实现一种积极的换页策略  

- **5.swap_check检查的实现**  
1.调用mm_create建立mm变量,并调用vma_create创建vma变量,设置合法的访问范围为4KB~24KB;
2.调用free_page等操作,模拟形成一个只有4个空闲 physical page;并设置了从4KB~24KB的连续5个虚拟页的访问操作;
3.设置记录缺页次数的变量pgfault_num=0,执行check_content_set函数,使得起始地址分别对起始地址为0x1000, 0x2000, 0x3000, 0x4000的虚拟页按时间顺序先后写操作访问,由于之前没有建立页表,所以会产生page fault异常,如果完成练习1,则这些从4KB~20KB的4虚拟页会与ucore保存的4个物理页帧建立映射关系;
4.然后对虚页对应的新产生的页表项进行合法性检查;
5.然后进入测试页替换算法的主体,执行函数check_content_access,并进一步调用到_fifo_check_swap函数,如果通过了所有的assert,这进一步表示FIFO页替换算法基本正确实现;
6.最后恢复ucore环境。

# 相关要点/问题速览
- 