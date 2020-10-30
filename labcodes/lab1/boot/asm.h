#ifndef __BOOT_ASM_H__
#define __BOOT_ASM_H__

/* Assembler macros to create x86 segments */

/* Normal segment */
#define SEG_NULLASM                                             \
    .word 0, 0;                                                 \  
    .byte 0, 0, 0, 0


// 设置段描述符,这个宏定义的依据:段描述符的格式
// => https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1_figs/image003.png
/***************************  解析  ***************************************/
// 由下面分析,低字节放在低地址处,可见使用的是小端模式!!
// (((lim) >> 12) & 0xffff) => 左移12位是因为限长只占20位; &0xffff可见这里是写入描述符中限长低16bit
// ((base) & 0xffff)        => 写入基址的低0~15bit

// (((base) >> 16) & 0xff)        => 写入基址的16~23bit
// (0x90 | (type))                => 0x90=10010000, 保证bit7和bit3为1,同时写入类型 
// (0xC0 | (((lim) >> 28) & 0xf)) => 写入限长的16~19bit,同时保证....位为...
// (((base) >> 24) & 0xff)        => 写入基址的24~31bit 

#define SEG_ASM(type,base,lim)                                  \
    .word (((lim) >> 12) & 0xffff), ((base) & 0xffff);          \
    .byte (((base) >> 16) & 0xff), (0x90 | (type)),             \
        (0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)


/* Application segment type bits */
#define STA_X       0x8     // Executable segment
#define STA_E       0x4     // Expand down (non-executable segments)
#define STA_C       0x4     // Conforming code segment (executable only)
#define STA_W       0x2     // Writeable (non-executable segments)
#define STA_R       0x2     // Readable (executable segments)
#define STA_A       0x1     // Accessed

#endif /* !__BOOT_ASM_H__ */

