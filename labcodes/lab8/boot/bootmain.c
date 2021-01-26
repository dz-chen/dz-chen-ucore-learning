#include <defs.h>
#include <x86.h>
#include <elf.h>

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
 * */

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
3.为什么ELFHDR从0x10000开始?
    => 这个值只是人为定义,不一定必须是这个值,只要满足它在bootloader以上即可
      ...详见内布局:https://chyyuu.gitbooks.io/ucore_os_docs/content/lab2_figs/image003.png
      注意ELFHDR加载到1MB以下; 而OS加载到1MB以上(由kernel.ld指定)
4.bootmain中elfhdr为什么从磁盘的第一个扇区算起(读第一页时offset为0),第一个扇区不是bootloader吗?
    => 见redseg函数,计算secno时自动+1,从而跳过了MBR.也就是说offset是从第二个扇区算起
************************************************************************************************/

#define SECTSIZE        512                         // 扇区大小:512B
#define ELFHDR          ((struct elfhdr *)0x10000)  // scratch space,64k

/* waitdisk - wait for disk ready */
static void waitdisk(void) {
    // 0x1F7端口是磁盘的命令和状态寄存器
    // inb指令从端口读取一个字节,这里就是从0x1F7端口读取状态
    // 然后判断这个状态的bit7(从bit0算起)是否为1,为1则磁盘忙,所以循环等待(状态各bit含义查资料...)!
    while ((inb(0x1F7) & 0xC0) != 0x40)            
        /* do nothing */;
}

/* readsect - read a single sector at @secno into @dst */
static void readsect(void *dst, uint32_t secno) {
    // 相关端口参考:https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1/lab1_3_2_3_dist_accessing.html
    // wait for disk to be ready

    /********* 1.等待磁盘空闲***********/
    waitdisk();
    
    /**********2.通过写磁盘的IO端口,发出读扇区的命令************/
    outb(0x1F2, 1);                             // 存放要读写的扇区数量
    outb(0x1F3, secno & 0xFF);                  // 存放要读写的扇区号码; 如果是LBA模式,就是LBA参数的0-7位故  
    outb(0x1F4, (secno >> 8) & 0xFF);           // 存放读写柱面的低8位字节; 如果是LBA模式,就是LBA参数的8-15位,故&&0xFF
    outb(0x1F5, (secno >> 16) & 0xFF);          // 存放读写柱面的高2位字节...
    //0x1f6 用来存放要读写的磁盘号、磁头号.
    // 其中,bit7:恒为1;  bit6:恒为0; bit5:恒为1;  bit4:0代表第一块硬盘,1代表第二块硬盘; bit3-0:用来存放要读写的磁头号
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);                          // 将命令0x20写入端口0x1F7,表示准备好读磁盘

    // wait for disk to be ready
    waitdisk();

    // read a sector => 从0x1f0端口读取数据
    insl(0x1F0, dst, SECTSIZE / 4);         // 这个指令以4字节为单位,所以/4
}

/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
// 从磁盘逻辑地址0算起的第offset字节开始,读取count字节到内存虚拟地址va处!
static void readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    uintptr_t end_va = va + count;

    // round down to sector boundary
    va -= offset % SECTSIZE;

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;         // 计算要读的第一个扇区号,+1意味着跳过了MBR,才开始算

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
        readsect((void *)va, secno);
    }
}

/* bootmain - the entry of bootloader */
// 进入32位保护模式后,bootloader的主要部分=> 作用:加载ucoreOS
void bootmain(void) {
    // read the 1st page off disk
    // 这里主要目的是从磁盘找到elfhdr,虽然读取一页数据多余,但是并未使用/修改多余的数据!
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);

    // is this a valid ELF?
    if (ELFHDR->e_magic != ELF_MAGIC) {     // 验证魔数
        goto bad;
    }

    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);   // 找到段头部表
    eph = ph + ELFHDR->e_phnum;
    // 读取所有段
    for (; ph < eph; ph ++) {
        // &0xFFFFFF 自动消除高位,仅保留p_va的低24位
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }

    // call the entry point from the ELF header => 进入ucore操作系统
    // note: does not return
    // 入口是kern_entry()函数,在kernel.ld中指定
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
    while (1);
}

