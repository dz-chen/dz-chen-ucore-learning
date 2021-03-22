[toc]

# bootloader(lab1)
## 重难点
### 什么时候跳转到kdebug程序打印函数调用栈(对理解调试很重要)?
在assert(见assert.h)发生错误时,assert会自动调用__panic,而panic再调用print_stackframe()
print_stackframe函数通过ebp访问栈中的调用链,从而完成调用栈的打印  
注:直接调用panic()函数也会导致答应调用栈

## Q&A
- **bootloader的工作?**  
打开A20地址线 => 检测物理内存 => 使能保护模式(并跳转到32保护模式代码) 
=> 设置段寄存器及堆栈指针 => 调用bootmain(加载ucore) => 然后将控制权交给kern_entry()函数...  

- **bootloader中设置了一个临时的GDT!**  
bootloader中设置了临时的GDT,不过之后还会修改...  

- **开机时是实模式,为什么第一条指令地址为0xFFFFFFF0?**  
实模式下地址计算方式为:cs*16+ip  
保护模式下地址计算为:base(cs的隐藏部分)+ip  
80386刚开机时CS的隐藏部分为0xFFFF,CS可见部分为0xF000,IP设置为0x0000FFF0 =>  
按理说第一条指令的地址应该是:0xF000*16+IP=0xFFFF0  
`但是`:intel规定,当CS中的值被改变后,才使用16位实模式方式计算地址!!!所以开机第一条指令仍然是按照保护模式的方式计算的地址!!! => 执行第一条指令后,开始按照实模式方式计算地址(cs*16+ip),使能保护模式后再次按照保护模式方式计算地址(cs隐藏部分+ip)

- **实模式和保护模式的区别?**  
[实模式和保护模式](https://blog.csdn.net/laviolette/article/details/51658650)  
比较直观的区别是地址计算方式不同;  
根本区别是保护模式提供了安全机制(比如GDT的存在可以控制对不同段的访问权限...)  


# 物理内存管理(lab2)
## 重难点
### slab分配算法(必看)
[Linux slab分配器剖析(必看)](https://www.ibm.com/developerworks/cn/linux/l-linux-slab-allocator/)
[内存分配[四]-Linux中的Slab(1)](https://zhuanlan.zhihu.com/p/105582468)
slab的五层结构体如图:  
![slab分配器结构-5层结构](./review-all-pic/slab分配器结构.gif)

### slob分配算法(slab的简化)
SLOB:Simple List of Blocks(且常与first-fit配合使用)  
[slob: introduce the SLOB allocator(代码)](https://lwn.net/Articles/157944/)  
[SLOB](https://en.wikipedia.org/wiki/SLOB)  
Linux常用的三个内存分配器:`SLUB、SLAB、SLOB`,三者的思路类似,使用场景有所不同[Linux内存分配机制:SLAB/SLUB/SLOB](https://blog.csdn.net/do2jiang/article/details/6423088?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-2&spm=1001.2101.3001.4242)  
[Linux Slob分配器(一)--概述(在实现上比较有参考价值)](http://www.linuxidc.com/Linux/2012-07/64107.htm)

### 红黑树
待整理...
### 关于ucore的物理内存管理及其存在的问题
整个ucoreOS只有一个物理内存管理器,且在物理内存管理初始化的时候,它就将除ucore内核已经占用的物理内存外的其余所有内存加入了空闲链表.之后`不论是内核、还是用户程序需要物理内存时,都是通过物理内存管理器进行分配的`!  
但是:ucore在调用boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);时,直接将所有物理内存映射到了内核的虚拟地址空间(修改了内核页表),且没有分配物理内存; 这就导致,内核可以直接访问没有分配的物理内存,而这块内存也许恰好是分配给用户程序的,从而引起冲突...


## Q&A
- **物理内存管理部分完成的工作有哪些?**  
`1.汇编对整个ucoreOS完成的一些初始化工作`:  
```
   初步建立页目录表_boot_gpdir(只映射了物理内存的0~4MB...)  
=> 使能分页机制  
=> 将内核迁移到虚拟地址高端(重要)  
=> 设置内核栈以及堆栈指针(不再使用bootloader中临时的堆栈)  
=> 跳转到kern_init()函数...  
```
`2.pmm_init所做的一些工作`:  
```
   初始化物理内存管理器(first fit,重点)  
=> 初始化Page[]数组以及属于内核的物理内存的空闲链表(重要)  
=> 建立自映射机制(重要,不过应该没有建立)  
=> 建立内核虚拟空间完整的地址映射(KERNBASE...映射到物理内存0...)  
=> 重新设置GDT(不再使用bootloader中临时建立的gdt)  
```

- **内核页表在哪里?**  
详见memlayout.h,位于虚拟地址0xFAC00000开始的4MB,它在内核空间的顶部还要上面!  
=> 上述只是理想中的页表自映射,虽然实习指导书有提,但是ucore似乎并么有这样做  
真实情况是__boot_pgdir是页目录表,页表分散在ucore的内核虚拟地址空间中,而不是像自映射那样位于固定的4MB连续虚拟内存区域...

- **boot_map_segment虚实地址映射 与 物理内存分配的关系?**  
pmm.c中,boot_map_segment函数应该是存在一定问题的...  
```
按照道理说是:对于一个虚拟地址la,先通过物理内存管理器分配一块物理页pa,然后填写页表完成(la,pa)的映射,正如pgdir_alloc_page()所做的那样;
但是boot_map_segment()比较奇特,它直接填写了部分页表(完成了KERNBASE~KERNBASE+MEMSIZE这段虚拟空间到0~MKEMSIZE这段物理空间的映射),但是并没有分配物理内存
    这就导致:1.内核如果直接访问KERNBASE~KERNBASE这段虚拟地址,那么访问的是物理地址0~MKEMSIZE;
            2.但是内核中有的代码又是动态内存分配获得物理内存,而他们分配的仍然是0~MKEMSIZE这段物理空间,然后填写页表;
            所以1和2可能发生冲突,即内核页表中有两个虚拟地址映射到了同一个物理地址...
```

- **tss的作用?**  
`当外环(如ring3)进入内环(如ring0)时,会自动加载tss中内环的esp和ss`.  
但是tss没有记录ring3的esp和ss => 因为,外环进入内环时,会将这些压入内核堆栈.当从内环返回外环时,从堆栈中恢复就ok啦!  
注意:tss本意是用作任务切换,但是最终并未使用,ucore只是用于陷入内核(时加载内核栈的ss、esp)...  
[TSS的作用](https://www.cnblogs.com/fanzi2009/archive/2009/05/27/1490904.html)  
[TSS(任务状态段)的作用及结构](https://www.cnblogs.com/Gotogoo/p/5250622.html)  

# 虚拟内存管理(lab3)
## 重难点
### 中断描述符表IDT(即中断向量表)
1.由代码可知,中断服务例程的入口地址是在__vectors[ ]中(见vectors.S),若中断号为i,则应该从__vectors[i]中所存储的地址进入中断服务例程.那么,发生中断时,cpu如何能找到__vectors[]呢?  
2.为此,os专门在内存中建立了一张表,称为中断描述符表IDT(也称为中断向量表),发生中断时,cpu根据中断号idx查号IDT的第idx个表项,这个表项称为中断门描述符(详见gatedesc),这个表项中包含了若干信息,其中就有idx号中断的服务例程入口地址 => 也就是说,需要将__vectors[]的第idx个项存入IDT的第idx个项,发生中断时cpu直接查找IDT便可找到中断服务例程的地址!!! 那么,cpu又是如何找到IDT的呢?  
3.cpu通过idtr寄存器找到中断描述符表IDT.OS中很多地方都是类似的方式=> 先查专门的寄存器,然后根据寄存器查找内存中专门的表...比如根据gdtr查找GDT、根据tr寄存器查找TSS、根据cr3查找页目录表  
4.总结:中断发生时cpu的处理过程:  
```
发生编号为idx的中断 => 找idtr寄存器 => 查找IDT的第idx个表项 => 跳转到idx中断对应中断服务例程入口 
=> 中断号压栈 => 跳转到__alltraps将通用寄存器压栈构造参数trapframe => 调用trap函数
=> 调用trap_dispatch,根据中断号进行相应处理...
```

### 发生中断时cpu的处理过程
```
发生编号为idx的中断 => 找idtr寄存器 => 查找IDT的第idx个表项 => 跳转到idx中断对应中断服务例程入口 
=> 中断号压栈 => 跳转到__alltraps将通用寄存器压栈构造参数trapframe => 调用trap函数
=> 调用trap_dispatch,根据中断号进行相应处理...处理完成后中断返回,根据trapframe恢复中断前的寄存器状态
其中"查找IDT的第idx个表项"及以前的部分由cpu自动完成
```

## Q&A
- **虚拟内存管理的核心是什么?**  
页表+缺页中断  

- **CPU如何通知中断处理程序发生缺页异常的?**  
`cpu感知到某个编号的中断`后,自动查找idtr,然后查找IDT,然后跳转到缺页中断服务例程...
WWW
- **什么时候会发生页面故障?**  
1.没有给要访问的虚拟地址映射物理地址;  
2.对要访问的虚拟地址权限不足;  
3.物理页帧不在内存中(被换到了swap)

- **区别ucore中的mm_map()函数 与 linux中的mmap()函数!**  
ucore中:mm_map()只是用于创建vma_struct并加入mm;  
linux下的mmap():内存映射文件...  

- **是谁负责查找页表?**  
`根据虚拟地址查找页表是由cpu硬件自动完成的`!!!  
ucore代码中需要做的就是:  
1.使能分页机制 => 让cpu以后自动查找页表;  
2.告诉cpu查找页表的入口 => 加载cr3寄存器,cpu根据cr3找到页目录表,从而找到页表;  
3.修改页表 => 根据自己需要填充页表,让cpu找到你需要的物理页;  
W

# 线程的实现与调度(lab4、5、6)
## 重难点
### trapframe与context的区别
- **trapframe**  
中断上下文(虽然这个称呼不一定准确):保存发生中断前的寄存器状态,方便从中断返回时恢复寄存器;主要由三个部分组成,如下:
```
/**
 * 保存中断前的相关寄存器信息,方便中断返回时恢复寄存器状态
 * 段寄存器只需使用16位的选择子,所以另外16位设置为tf_paddingx !
 * 注意下面的压栈顺序:tf_ss、tf_esp ....tf_regs
 * 详见tranentry.S,了解压栈构造trapframe的过程,构造trapframe就是将相应信息压入内核栈
 * 如何找到内核栈的? tss,它保存了内核栈的esp和ss
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
    uint32_t tf_trapno;     // 1.tf_regs ....tf_trapno这部分内容调用中断处理程序时压栈,详见vectors.S和trapentry.S
    
    // below here defined by x86 hardware
    uint32_t tf_err;        
    uintptr_t tf_eip;     
    uint16_t tf_cs;
    uint16_t tf_padding4;
    uint32_t tf_eflags;    // 2.tf_err...tf_eflags这部分在执行INT 指令时由硬件压栈
    
    // below here only when crossing rings, such as from user to kernel,这部分涉及栈的切换 
    // 如果是在内核态发生的中断,则不需要这部分
    uintptr_t tf_esp;      // 线程陷入内核前用户栈顶指针寄存器值 => 方便回到用户态时恢复用户栈...
    uint16_t tf_ss;        // 线程陷入内核前的堆栈段段寄存器值
    uint16_t tf_padding5;  // 3.tf_esp...tf_ss这部分在特权级切换时压栈
} __attribute__((packed));
```

- **context**  
线程上下文(虽然这么称呼不一定准确):保存线程上次被切换时的寄存器状态.  
```
// 保存线程被切换时的寄存器状态,方便下次切换回来时恢复当时的状态
// 最重要的寄存器信息 => eip(指令流)、esp(栈)
// 注:线程切换只可能在内核态发生,所以context保存的信息都是在内核态时的寄存器信息...
struct context {
    uint32_t eip;       // 线程上次停止执行时的下一条指令地址;           trapframe也有 
    uint32_t esp;       // 线程上次停止执行时的栈顶指针(这个栈是内核栈);  trapframe也有
    uint32_t ebx;       // trapframe也有
    uint32_t ecx;       // trapframe也有
    uint32_t edx;       // trapframe也有
    uint32_t esi;       // trapframe也有
    uint32_t edi;       // trapframe也有
    uint32_t ebp;       // trapframe也有
};
```
- **区别与联系**  
`trapframe`:
```
0.发生中断并不意味着切换线程,它只是表示有重要的事情需要马上处理 => 不过切换线程必须通过中断/系统调用陷入内核;
1.只要发生中断(包括系统调用、外设中断),都会保存trapframe;
2.它通常保存在内核栈顶,线程控制块的tf字段通常指向内核栈中的这个位置;
3.如果在用户态发生中断:线程需要先陷入内核并切换到内核栈,trapframe就保存在内核栈 => 然后执行中断处理程序(可能发生中断嵌套) =>  如果被中断的线程可以被调度,则切换到其他线程(这个时候又涉及到线程上下文context切换) => 再切换回这个线程 => 中断返回....;  
4如果在内核态发生中断:直接将trapframe保存在当前内核栈顶 => 然后执行中断处理程序(可能发生中断嵌套) => (不能进行线程调度,因为ucore内核不可剥夺) => 中断返回...
```
`context`:
```
1.只在线程切换时保存在线程控制块的context字段,这是一块普通的内存区域,不是堆栈!
2.线程切换只能在内核态发生;
```
`注`:
```
1.他们都需要保存一堆寄存器信息,不过其中最重要的都是eip(找到上次指令位置)、esp(找到上次的栈); 
2.中断不意味着切换线程(姑且可以认为中断处理程序属于被打断的线程)  
3.这里称为上下文不一定准确,通常所说的上下文包含了整个执行环境,而这里context、trapframe只是部分寄存器...
```
### 创建非idle内核线程的过程
以创建initproc为例,主要函数调用关系如下:
```   
                                                                         | setup_kstack 
                                                                         | copy_files
                                                                         |                      | mm_create
kernel_thread(init_main,NULL,0);  => kernel_thread(设置tf) => do_fork => | copy_mm           => | setpu_pgdir
                                                                         |                      | dup_mm      => copy_range(若新进程,复制用户空间)
                                                                         | copy_thread(设置tf、context)
                                                                         | wakeup_proc
                                                                         | list_add
```
注意:调用kernel_thread后,只是创建了线程控制块,并不立即执行;  
- **何时开始执行内核线程的函数呢?**  
`1.线程上下文context切换为init_main` => 由于copy_thread将`context.eip`设置为了forkret,于是将执行(trapentry.S):
```
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp           
    jmp __trapret
```
`2.通过__trapret进入到kernel_thread_entry` => 虽然整个过程并未发生中断,但是kernel_thread中将`tf.tf_eip`设置为kernel_thread_entry,且forkrets中强行跳转到了__trapret,于是将在__trapret中将执行(trapentry.S)中断返回,于是eip寄存器被恢复为kernel_thread_entry,从而控制流进入这个函数:
```
__trapret:
    # restore registers from stack
    popal                         # 恢复所有中断之前的通用寄存器

    # restore %ds, %es, %fs and %gs
    popl %gs
    popl %fs
    popl %es
    popl %ds

    # get rid of the trap number and error code
    addl $0x8, %esp              # trapno和errorno不需要恢复寄存器,所以直接将栈指针+8
    # iret时,会从内核栈陆续恢复eip cs eflags,还会根据是否特权级转换,恢复esp和ss,就是int操作的逆过程
    iret                         # 中断返回
```
`3.在kernel_thread_entry中执行init_main函数` => 由kernel_thread中将`tf.tf_regs.reg_ebx`、`tf.tf_regs.reg_edx`设置为init_main的参数、函数地址,于是下面将执行这个线程的主函数.....执行完成之后do_eixt......
```
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg, 将参数(位于edx寄存器)压栈
    call *%ebx              # call fn,  调用fn函数(位于ebx)

    # 对于用户线程,user_main调用结束后,直接中断返回(kernel_execve的缘故)到用户态执行用户程序,不会执行下面两行指令...
    pushl %eax              # save the return value of fn(arg)        ,调用结束,保存返回值在eax
    call do_exit            # call do_exit to terminate current thread,结束fn对应的这个线程
```
### 创建用户线程的过程(以sh为例)
主要可以`分为两个阶段`:1.在内核创建线程控制块,这时候的线程是内核线程user_main(但是并未立即执行); 2.user_main获得控制权后,将自己修改为用户线程  
#### 第一阶段:创建内核线程控制块  
第一阶段和"创建非idle内核线程的过程"相似:
```
                                                                                    | setup_kstack 
                                                                                    | copy_files
                                                                                    |                | mm_create
initproc执行时调用kernel_thread(user_main,NULL,0);=> kernel_thread(tf) => do_fork => | copy_mm     => | setpu_pgdir
                                                                                    |                | dup_mm => copy_range(若新进程,复制用户空间)
                                                                                    | copy_thread(设置tf、context)
                                                                                    | wakeup_proc
                                                                                    | list_add
```
这个时候只是创建了user_main对应的线程控制块,但是并未立即执行;什么时候执行呢?  
如"创建非idle内核线程所述",user_main线程获得控制权要经过:切换到user_main的context => 通过__trapret进入到kernel_thread_entry => 在kernel_thread_entry中执行user_main函数...  
#### 第二阶段:将内核转换为用户线程
`创建用户线程与非idle内核线程的区别在于,创建用户线程时,user_main不会在kernel_thread_entry中正常返回并执行do_exit`;  
而是在内核发起系统调用sys_exec将线程改成用户线程(主要是修改mm_struct映射用户空间);之后直接中断返回到用户态(因为load_icode中修改了trapframe);接着执行用户态程序(而不会在kernel_thread_entry中正常返回并退出)...函数调用如下:
```
user_main => ... => kernel_execve(调用sys_exec,在内核发起系统调用中断,但是返回时直接返回到用户态程序!) => sys_exec => do_execve ...(接下面)

                  | copy_string
                  | copy_kargv
                  | files_closeall
 =>  do_execve => | sysfile_open(打开可执行目标文件)
                  | lcr3(暂时设置页表为内核页表)
                  | exit_mmap(回收内存空间)
                  | put_pgdir(回收页目录表)
                  | mm_destroy
                  | load_icode             =>| mm_create
                                             | setup_pgdir
                                             | load_icode_read(read exec file)
                                             | sysfile_close
                                             | mm_map(在页表中为用户堆栈段映射物理内存)
                                             | lcr3
                                             | 用户线程主函数的参数放到用户栈
                                             | 设置用户线程的trapframe(于是中断返回时直接到了用户态)
```
完成了这个步骤以后,user_main线程才从内核态中断返回到用户态,执行用户程序...
- **小结**  
用户线程的创建需要分为两个步骤,而ucore这样做其实就是"用户线程的三种实现方式"中的内核实现!

- **以user/hello.c为例,在命令行输入hello后的执行过程**  
```
....待补充
```
### 创建用户线程的过程(以hello为例)
### lab8实现用户线程的原理???
注意对ucore而言,它是通过将内核线程initproc(就是do_execve代码中current)的mm_struct、页表、trapframe等进行了修改然后`initproc就变成了用户线程` => 在lab8中通过命令行执行hello时是这个原理吗?
### 如何创建新的进程(不是线程)
待完成...
### 理解系统调用的过程/实现
- **前期准备**  
主要是初始化IDT,且要保证系统调用对应的中断号0x80能在用户态下发起中断,这部分详见idt_init()函数:
```
// 对于系统调用,需要切换到内核态; 它的权限为ring3;
SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);  // DPL_USER表示允许在用户态产生这个中断
```
### fork/exec/wait/exit详解
#### 线程退出(eixt)
线程退出需要回收线程控制块、内核栈等内容;如果页表、进程数据没有其他线程共享了,这部分内容也会被回收...  
但是内核栈、线程控制块这部分内容会让父线程回收(详见do_wait)...  
详见do_exit()函数
#### 等待子线程结束(真正销毁线程,wait)
### 进程始终是在内核态完成切换的!
假定有两个用户进程,在二者进行进程切换的过程中,具体的步骤如下:  
首先在执行某进程A的用户代码时,出现了一个中断(例如是一个外设产生的中断),这个时候就会从进程A的用户态切换到内核态(`过程(1)`),并且保存好进程A的trapframe;当内核态处理中断时发现需要进行进程切换时,ucore要通过schedule函数选择下一个将占用CPU执行的进程(即进程B),然后会调用proc_run函数,proc_run函数进一步调用switch_to函数,切换到进程B的内核态(`过程(2)`),继续进程B上一次在内核态的操作,并通过iret指令,最终将执行权转交给进程B的用户空间(`过程(3)`).  

当进程B由于某种原因发生中断之后(`过程(4)`),会从进程B的用户态切换到内核态,并且保存好进程B的trapframe;当内核态处理中断时发现需要进行进程切换时,即需要切换到进程A,ucore再次切换到进程A(`过程(5)`),会执行进程A上一次在内核调用schedule(具体还要跟踪到 switch_to 函数)函数返回后的下一行代码,这行代码当然还是在进程A的上一次中断处理流程中.最后当进程A的中断处理完毕的时候,执行权又会反交给进程A的用户代码(`过程(6)`).  
注意事项:
```
a) 需要透彻理解在进程切换以后,程序是从哪里开始执行的?需要注意到虽然指令还是同一个cpu上执行,但是此时已经是另外一个进程在执行了,且使用的资源已经完全不同了.
b) 内核在第一个程序运行的时候,需要进行哪些操作?可以确定,内核启动第一个用户进程的过程,实际上是从进程启动时的内核状态切换到该用户进程的内核状态的过程,而且该用户进程在用户态的起始入口应该是forkret.
c) 进程切换始终是在内核态进行的(从A的内核态切换到B的内核态!!!)
```
### 用户态陷入内核后,执行的代码还是用户线程吗?
### 理解copy_from_user和copy_to_user的必要!
### 不同进程使用的物理内存不会重叠!
### 内核是不可抢占的,但是内核在特殊情况下主动放弃cpu(同步、IO)!
在执行任意内核代码时,CPU控制权不可被强制剥夺;但是有以下两个特例,内核会主动放弃cpu:
```
1.线程同步互斥操作,比如争抢一个信号量、锁
2.进行磁盘读写等耗时的异步操作,由于等待完成的耗时太长,ucore会调用schedule让其他就绪进程执行 => 据此整理unix的5中IO模型!!!!!
```
`而用户线程是在任意位置都可以被中断打断,并失去cpu控制权的`  
搜寻一下实验五的代码,可发现在如下几处地方调用了shedule函数:  
|  编号   | 位置  | 原因 |
|  ----  | ----  | ---- |
|  1     | proc.c::do_exit  | 用户线程执行结束,主动放弃CPU控制权 |
|  2     | proc.c::do_wait  | 用户线程等待子进程结束,主动放弃CPU控制权.|
|  3     | proc.c::init_main| a. initproc内核线程等待所有用户进程结束,如果没有结束,就主动放弃CPU控制权; b. initproc内核线程在所有用户进程结束后,让kswapd内核线程执行10次,用于回收空闲内存资源 |
|  4     | proc.c::cpu_idle | idleproc内核线程的工作就是等待有处于就绪态的进程或线程,如果有就调用schedule函数|
|  5     | sync.h::lock	    | 在获取锁的过程中,如果无法得到锁,则主动放弃CPU控制权 |
|  6     | trap.c::trap     | 如果当前线程在用户态被打断,且当前线程控制块的成员变量need_resched设置为1,则当前线程会放弃CPU控制权|  
第1、2、5处的执行位置体现了由于获取某种资源一时等不到满足、进程要退出、进程要睡眠等原因而不得不主动放弃CPU.  
第3、4处的执行位置比较特殊,initproc内核线程等待用户进程结束而执行schedule函数;idle内核线程在没有进程处于就绪态时才执行,一旦有了就绪态的进程,它将执行schedule函数完成进程调度.  
第6处的位置比较特殊:
```
if (!in_kernel) {
    ……

    if (current->need_resched) {
        schedule();
    }
}
```
这里表明了只有当进程在用户态执行到"任意"某处用户代码位置时发生了中断,且当前进程控制块成员变量need_resched为1(表示需要调度了)时,才会执行shedule函数.这实际上体现了对用户进程的可抢占性.`如果没有第一行的if语句,那么就可以体现对内核代码的可抢占性.但如果要把这一行if语句去掉,我们就不得不实现对ucore中的所有全局变量的互斥访问操作,以防止所谓的racecondition现象,这样ucore的实现复杂度会增加不少`.  
### 斜堆实现优先队列(stride算法使用) => 待学习
### 定时器是如何使用的?
详见sched.c中run_timer_list、add_timer等函数.  
1.当一个线程主动睡眠时(见do_sleep),为线程创建一个timer,同时将timer加入定时器队列,并切换线程;  
2.当每次时钟中断,就需要执行run_timer_list,判断各定时器是否到期,如果到期则需要唤醒相应线程...
### 哪些地方需要切换线程(即调用schedule函数)?
1.`进行IO操作时`:详见dev_stdin.c/dev_stdin_read函数 =>为什么ucore进行磁盘IO时没有切换线程???  
2.`发生部分需要阻塞当前线程的系统调用时`:如do_exit、do_wait、do_sleep  
3.`idleproc线程的任务就是专门调用schedule`:详见cpu_idle()  
4.`因为获取信号量失败而阻塞时`:详见信号量的__down()函数  
5.`从用户态切换到内核态且need_reshed为1时`:详见trap()函数...
### 在内核发生中断时,处理程序属于哪个线程?
详见trap()函数,待整理....
### 理解为什么子线程的资源需要由父线程回收
如果子线程能完全回收自己,那说明子线程有栈、线程控制块;如果有这些东西,说明子线程没有完全回收...   
这形成了一个悖论,所以子线程只能回收部分自己的资源,内核栈、线程控制块等需要父线程来回收
### trap()函数分析

## Q&A
- **线程从用户态陷入内核时会切换线程吗(或者说会被阻塞吗)**  
通常来说,是的.系统调用函数很有可能不能马上执行完成(比如IO操作),所以通常会阻塞当前用户线程,直到系统调用完成相关操作后再通知该用户线程.trap.c中trap()函数可印证:  
```
// 如果中断是在用户态发生的
if (!in_kernel) {
    if (current->flags & PF_EXITING) {S
        do_exit(-E_KILLED);
    }
    if (current->need_resched) {    // 释放当前线程的cpu,选择新的线程投入执行
        schedule();
    }
}
```
这个说法正确吗?? 


- **线程切换时上下文保存在哪里?**  
线程上下文主要是部分寄存器信息,主要保存在proc_struct的context字段.完成上下文切换的地方在:proc_run => switch_to...(switch_to会将旧线程的上下文保存到该线程的context字段;从新线程的context字段恢复寄存器值!)

- **为什么进行io是需要从内核空间向用户空间拷贝数据?**  
??

- **用户线程之间如何避免使用到同一块物理内存的?**  
??

- **idleproc使用的内核栈是新建的吗?**  
idleproc是第一个内核线程,它直接使用entry.S中的内核栈bootstack,并没有新分配内核栈!!!  
但是,`其他内核线程和用户线程的内核栈,都得单独新建`  

- **新建的线程何时加入proc_list、hash_list?**  
在do_fork()中...

- **所有线程控制块都在内核空间!**  
即所以线程(用户线程以及内核线程)的proc_struct都在内核虚拟空间(内核物理地址空间)  

- **理解C语言main(int argc,char argv)的由来?**  
参数argc、argv是由操作系统读取命令行并整理出argc、argv,然后给应用程序创建线程时传递的!

- **到底是进程同步还是线程同步?**  
多数情况下应该将讨论限制在线程;  
因为同一个进程内的多个线程共享了数据,所以存在同步问题;  
而多个进程之间地址空间是隔离的,共享数据的情况很少,这时候不需要同步(除非进程间共享了数据!)

- **ucore的就绪队列只有一个?**  
是的,ucore的`就绪队列`只有一个,通过全局变量rq管理(见sched.c);  
不过,阻塞队列有多个,每个信号量都有对应的`阻塞队列`; 甚至一个管程对应了三个阻塞队列...
而且,除了阻塞队列以外,还有一个特殊的`队列timer_lis`t` => 这是由所有睡眠的线程组成的队列

- **ucore中涉及的线程状态/声明周期的三种队列**  
就绪队列:整个ucore只有一个,为全局变量rq  
定时器队列:整个ucore只有一个,为全局变量timer_list
阻塞/等待队列:若干个,每个信号量都有对应的阻塞队列; 甚至一个管程对应了三个阻塞队列

- **僵尸线程的子线程如何处理?**  
在某个线程成为僵尸线程之前,需要将其子线程设置为initproc的子线程,所以他的子线程最后将由initproc回收.见do_exit()  

- **线程的用户栈在哪里?**  
??
- **do_exit并没与完全回收资源,最终回收内核栈以及线程控制块的代码在哪里?**  
在do_wait()函数中!  

- **理解中断的优先级高于线程**  
`只要发生中断,都必须立即进行处理`;如果是在中断处理程序中发生中断,就形成了中断嵌套(不过可以禁止中断嵌套);  
所以当前线程的控制流会改变,cpu需要马上执行中断处理程序;  


# 线程同步(lab7)
## 重难点
### 什么是管程
### 通过信号量实现锁
参考vmm.c中对mm_struct上锁 => 需要对哪个共享对象上锁,给它一个互斥信号量字段即可,对它进行P操作就是上锁的过程
```
static inline void lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        down(&(mm->mm_sem));
        if (current != NULL) {
            mm->locked_by = current->pid;
        }
    }
}
```
## Q&A
- **PV操作不一定是原子的!**  
通常说PV操作是原子,但是查看ucore源码可知:  
1.其实在P/V函数的内部就可能进行线程调度,该函数并不是原子的...  
2.而且其中通过开关中断,仅仅保证了关键部分的原子性,在非关键部分随时都可能被抢占调度...  

- **ucore中的信号量还仅仅只是内核信号量!**  
内核信号量与用户信号量原理一样,但是不能在内核之外使用;  
还应该为其提供用户态接口,这样用户线程才能通过系统调用....  
说法正确吗?? --3.14

- **条件变量中只包含队列,并没有条件!**  
见check_sync.c中调用cond_wait()之处,先判断条件,不符合条件则阻塞到条件变量的队列上;  
所以这里`条件变量的目的只是提供阻塞队列,真正的条件还需要自己判断`;  
Java中的Condition也是如此!!!!

- **到底是进程同步还是线程同步?**  
多数情况下应该将讨论限制在线程;  
因为同一个进程内的多个线程共享了数据,所以存在同步问题;  
而多个进程之间地址空间是隔离的,共享数据的情况很少,这时候不需要同步(除非进程间共享了数据!)


# 文件系统(lab8)
## Q&A

# 总结
## 各lab的代码的工作
- **lab1:bootloader的工作有哪些?**  
```
   打开A20地址线  
=> 检测物理内存  
=> 使能保护模式(并跳转到32保护模式代码)  
=> 设置段寄存器及堆栈指针(临时的堆栈)  
=> 调用bootmain(加载ucore)  
=> 将控制交给kern_entry()函数...  
```


- **lab2:物理内存管理完成的工作有哪些?**  
`1.汇编对整个ucoreOS完成的一些初始化工作`:  
```
   初步建立页目录表_boot_gpdir(只映射了物理内存的0~4MB...)  
=> 使能分页机制  
=> 将内核迁移到虚拟地址高端(重要)  
=> 设置内核栈以及堆栈指针(不再使用bootloader中临时的堆栈)  
=> 跳转到kern_init()函数...  
```
`2.pmm_init()所做的一些工作`:  
```
   初始化物理内存管理器(first fit,重点)  
=> 初始化Page[]数组以及属于内核的物理内存的空闲链表(重要)  
=> 建立自映射机制(重要,不过应该没有建立)  
=> 建立内核空间完整的地址映射(KERNBASE...映射到物理内存0...)  
=> 重新设置GDT(不再使用bootloader中临时建立的gdt)  
```

- **lab3:虚拟内存管理完成的工作有哪些?**  
`1.开始vmm_init之前的准备工作`:  
```
   pic_init():初始化中断控制器8259A
   idt_init():初始化中断描述符表(就是中断向量表)
   这两个部分都是为中断做准备,这样虚拟内存管理器才能处理缺页中断
```
`2.vmm_init()所在的工作=> vmm的主要工作`:  
```
   check_vma_struct():检查vma结构是否正常
   check_pgfault():检查缺页处理机制是否正常,会发生缺页异常,最终由do_pgfault处理,它是vmm的核心... 
整个vmm的核心就是do_pgfault(),它主要针对三类页故障进行处理:
   1.如果权限不足,直接退出;
   2.如果没有映射物理地址,则完成映射并分配物理页
   3.如果已经映射了物理地址仍然缺页,则从swap换入物理页
```
`3.其他,在vmm_init之后`:  
```
   ide_init():初始化IDE设别(为磁盘io做准备)
   swap_init():完成对硬盘分区swap的初始化+页面置换管理器fifo的初始化+swap算法检验 => 这样vmm才能挂起进程,将其换出到磁盘...
```

- **lab4:实现内核线程完成的工作有哪些?**  
主要工作在proc_init()函数中:  
```
   初始化线程链表、线程hash表
=> 将ucore获得控制权以来的代码打造成idleproc,即第0个内核线程
=> 创建第1个内核线程initproc  

若不考虑lab5-8新加入的内容,
关于如何创建initproc的,需关注/必看:kernel_thread => do_fork => (copy_thread、copy_mm、copy_files等)
关于创建两个内核线程后如何调度的,需关注/必看:cpu_idle => schedule => proc_run => (load_esp0、switch_to)
```

- **lab5:实现用户线程完成的工作有哪些?**  
主要是在lab4的基础上,添加了用户进程的创建与管理工作:
....待完成...

- **lab6:线程调度完成的工作有哪些?**  
`初始化的工作主要在sched_init()中`:
```
   初始化定时器队列timer_list
=> 初始化调度器sched_class(选择RR或者stride算法)
```
何时进行调度并不确定,不过多半涉及到`三个关键函数`:
```
wakeup_proc():把一个线程放入到就绪线程队列,它通过调用调度类接口函数sched_class_enqueue实现,这使得wakeup_proc的实现与具体调度算法无关; 

schedule():完成与调度框架和调度算法相关三件事情:1.把当前占用CPU执行线程放入就绪队列;2.从就绪队列中选择一个"合适"线程;3.将控制切换到选择的线程(通过调用proc_run).也是通过调度类的接口完成,与具体算法无关

run_timer_list():在每次时钟中断时被调用,对每个定时器(睡眠线程)时间减1,唤醒超时的线程;同时会将当前线程时间片减1.也是通过调度类的接口完成,与具体算法无关 
```

- **lab7:线程同步完成的工作有哪些?**  

- **lab8:文件系统完成的工作有哪些?**  
文件系统的初始化工作在fs_init()中完成:
```
   vfs_init();             // 文件系统抽象层初始化
   dev_init();             // 设备IO层初始化
   sfs_init();             // SFS文件系统初始化
```



## 在ucore中找到的部分问题
- **自映射并没有真正实现**  
- **boot_map_segment()直接填写页表,可能导致内核页表中两个虚拟地址映射到同一个物理地址**  

## 其他
- **打印函数调用栈的原理**  
通过每次函数调用时压入的ebp值,遍历调用链...  

- **PV操作不一定是原子的!**  
通常说PV操作是原子,但是查看ucore源码可知:  
1.其实在P/V函数的内部就可能进行线程调度,该函数并不是原子的...  
2.而且其中通过开关中断,仅仅保证了关键部分的原子性,在非关键部分随时都可能被抢占调度...  

- **查找页表是cpu自动完成的**  
所以才需要使能分页机制、加载cr3寄存器,都是为cpu自动查找页表做准备...  

- **cpu查找关键数据结构的方式**  
```
gdtr:用于查找GDT
idtr:用于查找IDT
cr3:用于查找页目录表(从而找到页表)

cs:用于在GDT中查找代码段
ds:用于在GDT中查找数据段
ss:用于在GDT中查找堆栈段
tr:用于在GDT中查找TSS
....
```

- **所以线程都有自己的内核栈,且所有内核栈都在内核空间!**  
`对于内核线程`:  
只有idleproc的内核栈直接使用entry.S中设置的栈bootstack(因为entry.S也被归属于idleproc线程了)  
其他内核线程在创建时,也必须动态分配一个内核栈,且这个栈在内核空间(内核的虚拟地址空间、物理地址空间)  
`对于用户线程`:  
也必须动态分配一个内核栈,且这个栈在内核空间;而它在用户态执行时的栈,则在用户空间  


- **所有线程控制块都在内核空间!**  
即所以线程(用户线程以及内核线程)的proc_struct都在内核虚拟空间(内核物理地址空间)  

- **理解C语言main(int argc,char argv)的由来?**  
参数argc、argv是由操作系统读取命令行并整理出argc、argv,然后给应用程序创建线程时传递的!

- **创建用户线程的工作都是由内核线程完成的!**  
由内核线程initproc完成

- **对ucore而言,它的虚拟空间映射了所有物理地址!**  
pmm_init()中调用boot_map_segment()时,直接将所有物理内存映射到了内核的页表中(不过没有分配),所有内核可以直接访问所有物理内存;而之后用户线程分配这些物理内存,并映射到用户线程的页表;  
=> 所以所有物理内存既映射到了内核页表,也映射到了用户线程的页表; 从而内核可以直接操作用户线程的内容!!!

# ucore完善计划
.理解用户线程,实现自己创建用户线程  
.给ucore实现用户信号量  
.在用户空间提供创建线程的系统调用(目前执行可执行文件只是创建进程)  


# tmp-不确定的问题
- load_icode中,为什么用户程序数据仍然读取到了内核虚拟空间, load_icode_read(fd, page2kva(page) + off, size, offset)) ???
- boot_map_segment中内核空间直接映射所有物理地址,是为了方便内核操作用户线程的用户空间内容???
- copy_range需要再次探索...
- 为什么ucore进行磁盘IO时没有切换线程??? 
- do_execve中为何mm_count_dec(mm) ?
- do_execve待深入...
- 线程栈与进程栈如何布局/或者说地址关系如何? 
- lab5中第一个用户进程是由第二个内核线程initproc通过把hello应用程序执行码覆盖到initproc的用户虚拟内存空间来创建,lab8中通过命令行创建是否有所不同?!!!