##################################################################### makefile部分基础知识
############################ 几个常用符号
# @ 如果命令前加了@,表示make 执行过程中不显示这条命令,只显示执行结果
# - 如果命令前加了-,表示即使这条命令执行错误,也得继续往下执行
# $ 用于扩展打开makefile中定义的变量
# $$ 用于扩展打开makefile中定义的shell变量 
# $@ 表示目标文件
# $^ 所有依赖文件
# $< 第一个依赖文件

############################ 常用的变量定义(通常这样写,但不一定必须这么写)
# CC: 指定编译器
# CFLAGS: 指定编译参数


############################ 基本的赋值操作
# = 是最基本的赋值
# := 是覆盖之前的值
# ?= 如果没有赋值过就赋值
# += 添加等号后面的值

############################ makefile中规则的定义
# target ...:prerequisites ...(可能带有 | )
# 	command
# 	....
# 注意1.生成target之前,所以生成前提目标prerequisites的命令都需要先被执行
# 注意2.如果一个前提目标比target新,target会被认为太旧而重新生成
# 注意3.如果前提目标列表中出现了 | 意味着|后面的目标即使更新,target也不会重新生成

############################ 一些常用命令
# dd if=... of=... count=... :用于文件备份,将if对应的文件备份到of对应的文件,
# 	最后一个参数代表需要备份的内容的大小(当然还有很多其他选项)


############################ makefile常用函数
# 1.$(addprefix fixstring, string1,string2,.....)  
# 		=> 返回fixstring+string1, fixstring+string2, ...
# 2.$(eval text) => 将text的内容作为makefile的一部分而被make解析和执行
# 3.$(foreach var,list,text) => 将列表list中的单词取出放在变量var中,然后执行text的命令
#		返回的结果将会是每个var带入执行后组成的列表
# 4.$(if condition,text1,text2) => 满足添加则执行text1,否则执行text2
# 5.$(patsubst pattern,replacement,text) =>查找text中的单词,如果匹配pattern,就替换为replacement

############################ call
# call => $(call func, param1, param2,...),调用这个函数,后面紧跟传递的参数, 所以call调用的
# 	返回值就是func调用的返回值
# func中若要使用传递的参数,直接用$(1)、$(2)表示param1、param2
 

############################ 关于makefile的终极目标
# 默认第一个出现的目标就是终极目标,而其他目标是由这个终极目标连带出来的
# 如果需要指定特定的终极目标,可直接指出自定义的终极目标,比如 make clean	
# makefile 中语句的执行顺序,参考:https://blog.csdn.net/qq_35524916/article/details/77131555	


########################### 更多详细内容,参考tools/function.mk .....



PROJ	:= challenge			 # 将变量PROJ定义为challenge
EMPTY	:=
SPACE	:= $(EMPTY) $(EMPTY)     # $表示引用变量EMPTY
SLASH	:= /
V       := @
#need llvm/cang-3.5+
#USELLVM := 1
# try to infer the correct GCCPREFX
ifndef GCCPREFIX                                        # 什么含义??
GCCPREFIX := $(shell if i386-elf-objdump -i 2>&1 | grep '^elf32-i386$$' >/dev/null 2>&1; \
	then echo 'i386-elf-'; \
	elif objdump -i 2>&1 | grep 'elf32-i386' >/dev/null 2>&1; \
	then echo ''; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find an i386-elf version of GCC/binutils." 1>&2; \
	echo "*** Is the directory with i386-elf-gcc in your PATH?" 1>&2; \
	echo "*** If your i386-elf toolchain is installed with a command" 1>&2; \
	echo "*** prefix other than 'i386-elf-', set your GCCPREFIX" 1>&2; \
	echo "*** environment variable to that prefix and run 'make' again." 1>&2; \
	echo "*** To turn off this error, run 'gmake GCCPREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

# try to infer the correct QEMU
ifndef QEMU
QEMU := $(shell if which qemu-system-i386 > /dev/null; \
	then echo 'qemu-system-i386'; exit; \
	elif which i386-elf-qemu > /dev/null; \
	then echo 'i386-elf-qemu'; exit; \
	elif which qemu > /dev/null; \
	then echo 'qemu'; exit; \
	else \
	echo "***" 1>&2; \
	echo "*** Error: Couldn't find a working QEMU executable." 1>&2; \
	echo "*** Is the directory containing the qemu binary in your PATH" 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

# eliminate default suffix rules
# 设置默认支持的后缀,从而只需使用文件名即可(不需添加后缀); SUFIXES应该是makefile关键字
.SUFFIXES: .c .S .h

# delete target files if there is an error (or make is interrupted)
# 设置出错时要删除的文件
.DELETE_ON_ERROR:

# define compiler and flags
# ifndef ... else ... endif 格式
ifndef  USELLVM
HOSTCC		:= gcc
HOSTCFLAGS	:= -g -Wall -O2
CC		:= $(GCCPREFIX)gcc
CFLAGS	:= -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc $(DEFS)
CFLAGS	+= $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
else
HOSTCC		:= clang
HOSTCFLAGS	:= -g -Wall -O2
CC		:= clang
CFLAGS	:= -march=i686 -fno-builtin -fno-PIC -Wall -g -m32 -nostdinc $(DEFS)
CFLAGS	+= $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
endif

CTYPE	:= c S

LD      := $(GCCPREFIX)ld
LDFLAGS	:= -m $(shell $(LD) -V | grep elf_i386 2>/dev/null | head -n 1)
LDFLAGS	+= -nostdlib

OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

COPY	:= cp			    #重定义一些shell的命令操作
MKDIR   := mkdir -p
MV		:= mv
RM		:= rm -f
AWK		:= awk
SED		:= sed
SH		:= sh
TR		:= tr
TOUCH	:= touch -c

OBJDIR	:= obj
BINDIR	:= bin

ALLOBJS	:=
ALLDEPS	:=
TARGETS	:=

include tools/function.mk					# 将include后面的文件内容包含进当前文件

# 函数:返回某个目录下的所有CTYPE类型的文件,$(1)即listf_cc的输入参数,为目录
listf_cc = $(call listf,$(1),$(CTYPE))		# listf定义于 tools/function.mk

# for cc
add_files_cc = $(call add_files,$(1),$(CC),$(CFLAGS) $(3),$(2),$(4))
create_target_cc = $(call create_target,$(1),$(2),$(3),$(CC),$(CFLAGS))

# for hostcc
add_files_host = $(call add_files,$(1),$(HOSTCC),$(HOSTCFLAGS),$(2),$(3))
create_target_host = $(call create_target,$(1),$(2),$(3),$(HOSTCC),$(HOSTCFLAGS))

cgtype = $(patsubst %.$(2),%.$(3),$(1))
objfile = $(call toobj,$(1))
asmfile = $(call cgtype,$(call toobj,$(1)),o,asm)
outfile = $(call cgtype,$(call toobj,$(1)),o,out)
symfile = $(call cgtype,$(call toobj,$(1)),o,sym)

# for match pattern
match = $(shell echo $(2) | $(AWK) '{for(i=1;i<=NF;i++){if(match("$(1)","^"$$(i)"$$")){exit 1;}}}'; echo $$?)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# include kernel/user

INCLUDE	+= libs/

CFLAGS	+= $(addprefix -I,$(INCLUDE))

LIBDIR	+= libs

$(call add_files_cc,$(call listf_cc,$(LIBDIR)),libs,)

# --------------------------------------------------------- 1.生成目标kernel
# kernel
KINCLUDE	+= kern/debug/ \
			   kern/driver/ \
			   kern/trap/ \
			   kern/mm/

KSRCDIR		+= kern/init \
			   kern/libs \
			   kern/debug \
			   kern/driver \
			   kern/trap \
			   kern/mm

# => -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/
KCFLAGS		+= $(addprefix -I,$(KINCLUDE))     

$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))

# => obj/kern/init/init.o obj/kern/libs/stdio.o obj/kern/libs/readline.o obj/kern/debug/panic.o obj/kern/debug/kdebug.o obj/kern/debug/kmonitor.o obj/kern/driver/clock.o obj/kern/driver/console.o obj/kern/driver/picirq.o obj/kern/driver/intr.o obj/kern/trap/trap.o obj/kern/trap/vectors.o obj/kern/trap/trapentry.o obj/kern/mm/pmm.o  obj/libs/string.o obj/libs/printfmt.o
KOBJS	= $(call read_packet,kernel libs)

# create kernel target
# 生成kernal路径:bin/kernel
kernel = $(call totarget,kernel)		

# 定义目标规则 => 生成kernel需要依赖tools/kernel.ld
$(kernel): tools/kernel.ld

######## 对于下面几行:
# line1:定义kernel目标的规则及其依赖
# line2:cdz添加的输出提示
# line3:也只是一个输出提示;@不会输出整条命令=> 最终只会打印+ ld bin/kernel;没有@会打印整条命令
# line4:执行链接=> -o指定输出文件; -T使用指定的脚本来链接(而不使用ld默认的链接脚本); KOBJS是被链接的文件
# line5:翻译过来就是执行objdump -S bin/kernel > obj/kernel.asm => 将链接后的kernel文件反汇编并输出到obj/kernel.asm文件
# line6:防疫过来是... => 将kernel中的符号表输出到文件obj/kernel.sym
$(kernel): $(KOBJS)
	$(warning ************************************** 即将生成kernel目标 )
	@echo + ld $@
	$(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
	$(V)$(OBJDUMP) -S $@ > $(call asmfile,kernel)
	$(V)$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)
## 紧接着上面规则内的命令之后执行 => ???? 为什么这句没执行,生成bootblock的规则就不会执行 ??
$(call create_target,kernel)

# --------------------------------------------------------- 2.生成目标bootblock(就是MBR中的程序) 

# create bootblock => boot/bootasm.S boot/bootmain.c
bootfiles = $(call listf_cc,boot)		# 列出boot目录下.c .S结尾的文件 

# 对bootfiles列表中的每个文件进行编译(调用的cc_compile函数在function.mk中)
$(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))

# 生成bootblock的路径:bin/bootblock	
bootblock = $(call totarget,bootblock)

# 定义bootblock的生成规则
# line1:定义bootblock目标及其依赖;'|'左侧的前提目标是obj/boot/bootasm.o obj/boot/bootmain.o; '|'右侧的命名前提目标是bin/sign
# line2:cdz添加的输出提示
# line3:也只是一个输出提示;@不会输出整条命令=> 最终只会打印+ ld bin/kernel;没有@会打印整条命令
# line4:执行链接:ld -m elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o
#		其中,-N表示指定读取/写入文本和数据段; -e start使用符号start作为程序的初始执行点; -Ttext 0x7C00指定文本段的起始地址为ox7c00
# line5:执行命令:objdump -S obj/bootblock.o > obj/bootblock.asm
# line6:执行命令:objcopy -S -O binary obj/bootblock.o obj/bootblock.out => 即复制二进制文件
# line7:执行命令:bin/sign   obj/bootblock.out bin/bootblock => 从而生成目标文件bootblock
$(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)
	$(warning ************************************** 即将生成bootblock目标 )
	@echo + ld $@
	$(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)
	$(V)$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)
	$(V)$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)
	$(V)$(call totarget,sign) $(call outfile,bootblock) $(bootblock)

$(call create_target,bootblock)

# --------------------------------------------------------- 3.生成目标sign 
# create 'sign' tools => 生成bin/sign这个工具,在生成bootblock时会使用
# => 因此下面的语句比bootblock的规则先执行
$(call add_files_host,tools/sign.c,sign,sign)
$(call create_target_host,sign,sign)

# --------------------------------------------------------- 4.生成目标ucore.img 
# create ucore.img
# 生成ucore.img
UCOREIMG	:= $(call totarget,ucore.img)		# 调用totarget函数(来自function.mk), 参数为ucore.img => bin/ucore.img

####下面几行体现了makefile的基本规则 => 
#line1:冒号前表示目标文件;冒号后表示生成目标需要依赖的文件; line2-4是生成目标文件对应的命令
#line2:/dev/zero是提供空字符的文件(设备),$@表示目标文件 => 此语句含义是使用10000个空的block来填充/初始化目标文件
#line3:conv=notrunc表示在复制过程中不截短输出文件
#line4:seek表示从开头跳过blocks个块后再复制
$(UCOREIMG): $(kernel) $(bootblock)	
	$(warning ************************************** 即将生成ucore.img目标 )			
	$(V)dd if=/dev/zero of=$@ count=10000		
	$(V)dd if=$(bootblock) of=$@ conv=notrunc
	$(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc

$(call create_target,ucore.img)					# create_target可以有多个参数,此处只传递了一个


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

$(call finish_all)

IGNORE_ALLDEPS	= clean \
				  dist-clean \
				  grade \
				  touch \
				  print-.+ \
				  handin

ifeq ($(call match,$(MAKECMDGOALS),$(IGNORE_ALLDEPS)),0)
-include $(ALLDEPS)
endif

# files for grade script

TARGETS: $(TARGETS)

.DEFAULT_GOAL := TARGETS

.PHONY: qemu qemu-nox debug debug-nox
qemu-mon: $(UCOREIMG)
	$(V)$(QEMU)  -no-reboot -monitor stdio -hda $< -serial null
qemu: $(UCOREIMG)
	$(V)$(QEMU) -no-reboot -parallel stdio -hda $< -serial null
log: $(UCOREIMG)
	$(V)$(QEMU) -no-reboot -d int,cpu_reset  -D q.log -parallel stdio -hda $< -serial null
qemu-nox: $(UCOREIMG)
	$(V)$(QEMU)   -no-reboot -serial mon:stdio -hda $< -nographic
TERMINAL        :=gnome-terminal
debug: $(UCOREIMG)
	$(V)$(QEMU) -S -s -parallel stdio -hda $< -serial null &
	$(V)sleep 2
	$(V)$(TERMINAL) -e "gdb -q -tui -x tools/gdbinit"
	
debug-nox: $(UCOREIMG)
	$(V)$(QEMU) -S -s -serial mon:stdio -hda $< -nographic &
	$(V)sleep 2
	$(V)$(TERMINAL) -e "gdb -q -x tools/gdbinit"

.PHONY: grade touch

GRADE_GDB_IN	:= .gdb.in
GRADE_QEMU_OUT	:= .qemu.out
HANDIN			:= proj$(PROJ)-handin.tar.gz

TOUCH_FILES		:= kern/trap/trap.c

MAKEOPTS		:= --quiet --no-print-directory

grade:
	$(V)$(MAKE) $(MAKEOPTS) clean
	$(V)$(SH) tools/grade.sh

touch:
	$(V)$(foreach f,$(TOUCH_FILES),$(TOUCH) $(f))

print-%:
	@echo $($(shell echo $(patsubst print-%,%,$@) | $(TR) [a-z] [A-Z]))

.PHONY: clean dist-clean handin packall tags
clean:
	$(V)$(RM) $(GRADE_GDB_IN) $(GRADE_QEMU_OUT) cscope* tags
	-$(RM) -r $(OBJDIR) $(BINDIR)

dist-clean: clean
	-$(RM) $(HANDIN)

handin: packall
	@echo Please visit http://learn.tsinghua.edu.cn and upload $(HANDIN). Thanks!

packall: clean
	@$(RM) -f $(HANDIN)
	@tar -czf $(HANDIN) `find . -type f -o -type d | grep -v '^\.*$$' | grep -vF '$(HANDIN)'`

tags:
	@echo TAGS ALL
	$(V)rm -f cscope.files cscope.in.out cscope.out cscope.po.out tags
	$(V)find . -type f -name "*.[chS]" >cscope.files
	$(V)cscope -bq 
	$(V)ctags -L cscope.files
