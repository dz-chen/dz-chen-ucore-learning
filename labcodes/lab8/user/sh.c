#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <dir.h>
#include <file.h>
#include <error.h>
#include <unistd.h>

#define printf(...)                     fprintf(1, __VA_ARGS__)
#define putc(c)                         printf("%c", c)

#define BUFSIZE                         4096
#define WHITESPACE                      " \t\r\n"
#define SYMBOLS                         "<|>&;"

char shcwd[BUFSIZE];

/********************************************************************************************
 *                             命令行程序
 * .系统启动创建的第一个用户进程就是sh(见proc.c,user_main函数)
 * .之后在命令行界面输入sfs(即disk0)中有的可执行文件名,即可执行相应程序...
 * .文件描述符
 *      0:stdin
 *      1:stdout
 *      2:stderr
 * .部分函数比较难以理解,待学习...
 * ******************************************************************************************/


int gettoken(char **p1, char **p2) {
    char *s;
    if ((s = *p1) == NULL) {
        return 0;
    }
    while (strchr(WHITESPACE, *s) != NULL) {
        *s ++ = '\0';
    }
    if (*s == '\0') {
        return 0;
    }

    *p2 = s;
    int token = 'w';
    if (strchr(SYMBOLS, *s) != NULL) {
        token = *s, *s ++ = '\0';
    }
    else {
        bool flag = 0;
        while (*s != '\0' && (flag || strchr(WHITESPACE SYMBOLS, *s) == NULL)) {
            if (*s == '"') {
                *s = ' ', flag = !flag;
            }
            s ++;
        }
    }
    *p1 = (*s != '\0' ? s : NULL);
    return token;
}


/**
 * 读取命令行参数(整行数据),虚拟地址在用户空间!
 */
char * readline(const char *prompt) {
    static char buffer[BUFSIZE];            // static是静态的,可以传递出去...
    if (prompt != NULL) {
        printf("%s", prompt);
    }
    int ret, i = 0;
    while (1) {
        char c;
        if ((ret = read(0, &c, sizeof(char))) < 0) {
            return NULL;
        }
        else if (ret == 0) {
            if (i > 0) {
                buffer[i] = '\0';
                break;
            }
            return NULL;
        }

        if (c == 3) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            putc(c);
            buffer[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
            putc(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
            putc(c);
            buffer[i] = '\0';
            break;
        }
    }
    return buffer;
}

// 提示正确的输入个数
void usage(void) {
    printf("usage: sh [command-file]\n");
}

int reopen(int fd2, const char *filename, uint32_t open_flags) {
    int ret, fd1;
    close(fd2);
    if ((ret = open(filename, open_flags)) >= 0 && ret != fd2) {
        close(fd2);
        fd1 = ret, ret = dup2(fd1, fd2);
        close(fd1);
    }
    return ret < 0 ? ret : 0;
}

int testfile(const char *name) {
    int ret;
    if ((ret = open(name, O_RDONLY)) < 0) {
        return ret;
    }
    close(ret);
    return 0;
}

/**
 * 执行命令行输入的可执行程序(输入为cmd)
 * 注意:这是由两个步骤组成
 * 1.fork系统调用创建子线程并返回用户态
 * 2.在子线程内执行__exec系统调用转而执行用户应用程序
 */ 
int runcmd(char *cmd) {
    static char argv0[BUFSIZE];
    const char *argv[EXEC_MAX_ARG_NUM + 1];
    char *t;
    int argc, token, ret, p[2];
again:
    argc = 0;
    while (1) {
        switch (token = gettoken(&cmd, &t)) {
            case 'w':
                if (argc == EXEC_MAX_ARG_NUM) {
                    printf("sh error: too many arguments\n");
                    return -1;
                }
                argv[argc ++] = t;
                break;
            case '<':
                if (gettoken(&cmd, &t) != 'w') {
                    printf("sh error: syntax error: < not followed by word\n");
                    return -1;
                }
                if ((ret = reopen(0, t, O_RDONLY)) != 0) {
                    return ret;
                }
                break;
            case '>':
                if (gettoken(&cmd, &t) != 'w') {
                    printf("sh error: syntax error: > not followed by word\n");
                    return -1;
                }
                if ((ret = reopen(1, t, O_RDWR | O_TRUNC | O_CREAT)) != 0) {
                    return ret;
                }
                break;
            case '|':
            //  if ((ret = pipe(p)) != 0) {
            //      return ret;
            //  }
                if ((ret = fork()) == 0) {
                    close(0);
                    if ((ret = dup2(p[0], 0)) < 0) {
                        return ret;
                    }
                    close(p[0]), close(p[1]);
                    goto again;
                }
                else {
                    if (ret < 0) {
                        return ret;
                    }
                    close(1);
                    if ((ret = dup2(p[1], 1)) < 0) {
                        return ret;
                    }
                    close(p[0]), close(p[1]);
                    goto runit;
                }
                break;
            case 0:
                goto runit;
            case ';':
                if ((ret = fork()) == 0) { // 创建子线程,执行命令行输入的程序
                    goto runit;          
                }
                else {                     // 对于父进程,等待子进程退出..
                    if (ret < 0) {
                        return ret;
                    }
                    waitpid(ret, NULL);
                    goto again;
                }
                break;
            default:
                printf("sh error: bad return %d from gettoken\n", token);
                return -1;
        }
    }

runit:                          // 执行命令行输入的可执行程序
    if (argc == 0) {
        return 0;
    }
    else if (strcmp(argv[0], "cd") == 0) {
        if (argc != 2) {
            return -1;
        }
        strcpy(shcwd, argv[1]);
        return 0;
    }
    if ((ret = testfile(argv[0])) != 0) {
        if (ret != -E_NOENT) {
            return ret;
        }
        snprintf(argv0, sizeof(argv0), "/%s", argv[0]);
        argv[0] = argv0;
    }
    argv[argc] = NULL;
    return __exec(NULL, argv);      // 执行其他用户程序,argv包含了程序路径,输入参数等信息...
}

// shell的主程序
int main(int argc, char **argv) {
    printf("user sh is running!!!\n");
    int ret, interactive = 1;
    if (argc == 2) {
        if ((ret = reopen(0, argv[1], O_RDONLY)) != 0) {
            return ret;
        }
        interactive = 0;
        //printf("-------------------------- test by cdz,argc=0 in command");
    }
    else if (argc > 2) {
        usage();            // 提示正确的参数形式
        return -1;
    }
    //printf("-------------------------- test by cdz,argc=%d\n",argc);  // 系统启动时就创建了sh进程,且没有输入参数; 这里argc应该为1(进程名字) 

    //shcwd = malloc(BUFSIZE);

    assert(shcwd != NULL);

    char *buffer;          // 存储在命令行输入的数据                         
    while ((buffer = readline((interactive) ? "$ " : NULL)) != NULL) {
        shcwd[0] = '\0';
        int pid;
        if ((pid = fork()) == 0) {              // 返回0则是子线程...
            ret = runcmd(buffer);
            exit(ret);
        }

        // sh进程返回...
        assert(pid >= 0);
        if (waitpid(pid, &ret) == 0) {        // 等待子线程结束  
            if (ret == 0 && shcwd[0] != '\0') {
                ret = 0;
            }
            if (ret != 0) {
                printf("error: %d - %e\n", ret, ret);
            }
        }
    }
    return 0;
}

