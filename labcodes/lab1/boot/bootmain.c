#include <defs.h>
#include <x86.h>
#include <elf.h>

/************************************ bootloader的C语言部分 *************************************
作用:读取硬盘扇区、加载ELF格式的OS
由bootasm.S调用

************************************ 等待磁盘准备代码解析
while ((inb(0x1F7) & 0xC0) != 0x40) 
=> 0x1F7是第一个IDE通道的最后一个IO寄存器地址,为状态和命令寄存器
通过端口操作指令inb读取0x1f7寄存器内容,再判断是否忙状态,忙则等待,不忙则从0x1f0端口读数据



************************************ 注意事项
1.elfhdr结构体描述ELF头; proghdr结构体描述段头部表,一个段对应一个proghdr
2.这里一个page对应8个扇区,共4096byte
3.为什么ELFHDR从0x10000开始? => 1MB以下是BIOS和bootloader等程序,1MB以上才是操作系统
4.为什么 va -= offset % SECTSIZE; va要减去这个部分??


************************************************************************************************/



/* *********************************************************************
 * This a dirt simple boot loader, whose sole job is to boot
 * an ELF kernel image from the first IDE hard disk.
 *
 * DISK LAYOUT
 *  * This program(bootasm.S and bootmain.c) is the bootloader.
 *    It should be stored in the first sector of the disk.
 *
 *  * The 2nd sector onward holds the kernel image.
 *
 *  * The kernel image must be in ELF format.
 *
 * BOOT UP STEPS
 *  * when the CPU boots it loads the BIOS into memory and executes it
 *
 *  * the BIOS intializes devices, sets of the interrupt routines, and
 *    reads the first sector of the boot device(e.g., hard-drive)
 *    into memory and jumps to it.
 *
 *  * Assuming this boot loader is stored in the first sector of the
 *    hard-drive, this code takes over...
 *
 *  * control starts in bootasm.S -- which sets up protected mode,
 *    and a stack so C code then run, then calls bootmain()
 *
 *  * bootmain() in this file takes over, reads in the kernel and jumps to it.
 * **/

#define SECTSIZE        512                             // 扇区大小:512B
#define ELFHDR          ((struct elfhdr *)0x10000)      // scratch space => 操作系统从1MB开始

/* waitdisk - wait for disk ready */
static void waitdisk(void) {
    while ((inb(0x1F7) & 0xC0) != 0x40)     
        /* do nothing */;
}

/* readsect - read a single sector at @secno into @dst */
/* 读取一个磁盘扇区:读取扇区号为secno的内容到内存dst位置 */
static void readsect(void *dst, uint32_t secno) {

    // 1.wait for disk to be ready
    waitdisk();

    /********* 2.写IO端口,发出读扇区命令 ********/
    //0x1f2存放要读写的扇区数量
    outb(0x1F2, 1);                         // count = 1
    // 0x1f3用来存放要读写的扇区号码,就是偏移量
    outb(0x1F3, secno & 0xFF);
    //0x1f4 用来存放读写柱面的低8位字节
    outb(0x1F4, (secno >> 8) & 0xFF);
    //0x1f5 用来存放读写柱面的高2位字节
    outb(0x1F5, (secno >> 16) & 0xFF);
    //0x1f6 用来存放要读写的磁盘号，磁头号。7-bit：恒为1；6-bit：恒为0；5-bit：恒为1；
	//4-bit：0代表第一块硬盘，1代表第二块硬盘
	//3~0-bit：用来存放要读写的磁头号
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    //0x1f7 用来存放硬盘操作后的状态，以下为设置为1的情况
	//7-bit 控制器忙碌
	//6-bit 磁盘驱动器准备好了
	//5-bit 写入错误
	//4-bit 搜索完成
	//3-bit 扇区缓冲区没有准备好
	//2-bit 是否正确读取磁盘数据
	//1-bit 磁盘每转一周将此位设置为1
	//0-bit 之前的命令因发生错误而结束
    outb(0x1F7, 0x20);                      // cmd 0x20 - read sectors

    // 3.wait for disk to be ready
    waitdisk();

    // 4.read a sector => 从0x1f0端口读取数据
    insl(0x1F0, dst, SECTSIZE / 4);        // 这里的读取指令以4字节为单位,所以 SECTSIZE/4   
}

/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
// 从距离第一个扇区的起点偏移offset处开始,复制count字节数据到内存va处,通常是读取一整个段
// typedef unsigned long uintptr_t, 4字节
static void readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    uintptr_t end_va = va + count;

    // round down to sector boundary
    // 为什么va要减??  保证每次读取时的内存地址va,始终在扇区的边界上; 感觉仍有点不懂
    // 参考:https://stackoverflow.com/questions/51863984/xv6-bootmain-c-readseg-round-down-to-sector-boundary
    va -= offset % SECTSIZE;                

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;       // 计算开始扇区号

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order. 
    for (; va < end_va; va += SECTSIZE, secno ++) {     // 一次读取一个扇区数据
        readsect((void *)va, secno);
    }
}

/* bootmain - the entry of bootloader */
// => 1.先读取第一页(包括elf header);  2.然后根据elf header读取所有剩余段 3.直接调用elfdhr指出的OS代码入口...

void bootmain(void) {
    // read the 1st page off disk => 这里一页对应8个扇区 => 512B*8
    // readseg(va,count,offset)   => 从偏移内核offset开始,读取count字节数据到虚拟地址va处 
    // 为什么读elf header就要直接读一页? => 可能是多读数据保证不会漏掉elf header的内容
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
    // is this a valid ELF? => 检验读到内存的数据
    if (ELFHDR->e_magic != ELF_MAGIC) {             // => 魔数常用于检验文件格式
        goto bad;
    }



    struct proghdr *ph, *eph;
    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);  //e_phoff指出proghdr表的位置偏移
    eph = ph + ELFHDR->e_phnum;                                    // e_phnum指出段头部表中段数量
    // 读取os内核,所有段!
    for (; ph < eph; ph ++) {
        // p_va:段的第一个字节将被放到内存中的虚拟地址
        // p_memsz:段占用的字节数
        // p_offset:段离elf文件头的偏移值
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }



    // call the entry point from the ELF header
    // note: does not return
    // e_entry:程序入口的虚拟地址; 注意不返回,直接调用OS的代码开始运行....
    // => 调用的函数为:kern/init/init.c中的kern_init
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
    while (1);
}

