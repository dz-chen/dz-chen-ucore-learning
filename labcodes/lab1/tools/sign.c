#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>   /* ubuntu下来自/usr/include/x86_64-linux-gnu/sys 目录 */

/**************** 作用:将程序填充至512bytes以符号MBR格式   **********************/
/*****************************************************************************
 * struct stat 是文件元数据的结构体,原始定义在bits/stat.h中 
 *      => 结构体内容可参考:https://www.cnblogs.com/yaowen/p/4801541.html
 * 
 * 
 ****************************************************************************/


int main(int argc, char *argv[]) {
    struct stat st;
    if (argc != 3) {
        fprintf(stderr, "Usage: <input filename> <output filename>\n");
        return -1;
    }
    if (stat(argv[1], &st) != 0) {              // 如果检索文件失败(stat函数将文件元数据读取到st结构体中)
        fprintf(stderr, "Error opening file '%s': %s\n", argv[1], strerror(errno));
        return -1;
    }

    // 484 bytes => 即之前生成二进制程序bootblock.out共484自己 
    // 后面需要将其填充至1个block的大小(即512byte)
    printf("'%s' size: %lld bytes\n", argv[1], (long long)st.st_size); 
    if (st.st_size > 510) {
        fprintf(stderr, "%lld >> 510!!\n", (long long)st.st_size);
        return -1;
    }
    char buf[512];
    memset(buf, 0, sizeof(buf));
    FILE *ifp = fopen(argv[1], "rb");
    int size = fread(buf, 1, st.st_size, ifp);
    if (size != st.st_size) {
        fprintf(stderr, "read '%s' error, size is %d.\n", argv[1], size);
        return -1;
    }
    fclose(ifp);
    buf[510] = 0x55;    // 设置主引导扇区的结束标志字(2字节:0x55AA)
    buf[511] = 0xAA;
    FILE *ofp = fopen(argv[2], "wb+");
    size = fwrite(buf, 1, 512, ofp);
    if (size != 512) {
        fprintf(stderr, "write '%s' error, size is %d.\n", argv[2], size);
        return -1;
    }
    fclose(ofp);
    printf("build 512 bytes boot sector: '%s' success!\n", argv[2]);
    return 0;
}

