/* Simple linker script for the ucore kernel.
   See the GNU ld 'info' manual ("info ld") to learn the syntax. */

/********************* 备注 **************************
* 1. "."表示当前地址
* 2. .ld文件中定义的edata[]、end[]是全局变量,会在部分源代码中引用,他们表示相应段的起始或结束地址
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
