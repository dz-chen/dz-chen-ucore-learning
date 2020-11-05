#include <stdio.h>

/********************************************************************************
 * 作用:生成中断向量到中断处理程序入口地址的映射 => 生成的内容见kern/trap/vectors.S
 * ******************************************************************************/

int main(void) {
    printf("# handler\n");
    printf(".text\n");
    printf(".globl __alltraps\n");

    int i;
    for (i = 0; i < 256; i ++) {
        printf(".globl vector%d\n", i);
        printf("vector%d:\n", i);
        if (i != 8 && (i < 10 || i > 14) && i != 17) {
            printf("  pushl $0\n");
        }
        printf("  pushl $%d\n", i);
        printf("  jmp __alltraps\n");
    }
    printf("\n");
    printf("# vector table\n");
    printf(".data\n");
    printf(".globl __vectors\n");
    printf("__vectors:\n");
    for (i = 0; i < 256; i ++) {
        printf("  .long vector%d\n", i);
    }
    return 0;
}

