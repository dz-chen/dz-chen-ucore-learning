PROJ	:= 8
EMPTY	:=
SPACE	:= $(EMPTY) $(EMPTY)
SLASH	:= /

V       := @
#need llvm/cang-3.5+
#USELLVM := 1
# try to infer the correct GCCPREFX
ifndef GCCPREFIX
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
.SUFFIXES: .c .S .h

# delete target files if there is an error (or make is interrupted)
.DELETE_ON_ERROR:

# define compiler and flags
ifndef  USELLVM
HOSTCC		:= gcc
## for mksfs program, -D_FILE_OFFSET_BITS=64 can guarantee sizeof(off_t)==8,  sizeof(ino_t) ==8
## for 64 bit gcc, to build 32-bit mksfs, you can use below line
## HOSTCFLAGS	:= -g -Wall -m32 -O2 -D_FILE_OFFSET_BITS=64
HOSTCFLAGS	:= -g -Wall -O2 -D_FILE_OFFSET_BITS=64

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

GDB		:= $(GCCPREFIX)gdb
CTYPE	:= c S

LD      := $(GCCPREFIX)ld
LDFLAGS	:= -m $(shell $(LD) -V | grep elf_i386 2>/dev/null | head -n 1)
LDFLAGS	+= -nostdlib

OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

COPY	:= cp
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

USER_PREFIX	:= __user_

include tools/function.mk

listf_cc = $(call listf,$(1),$(CTYPE))

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
filename = $(basename $(notdir $(1)))
ubinfile = $(call outfile,$(addprefix $(USER_PREFIX),$(call filename,$(1))))

# for match pattern
match = $(shell echo $(2) | $(AWK) '{for(i=1;i<=NF;i++){if(match("$(1)","^"$$(i)"$$")){exit 1;}}}'; echo $$?)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# include kernel/user

INCLUDE	+= libs/

CFLAGS	+= $(addprefix -I,$(INCLUDE))

LIBDIR	+= libs

$(call add_files_cc,$(call listf_cc,$(LIBDIR)),libs,)

# -------------------------------------------------------------------
# user programs

UINCLUDE	+= user/include/ \
			   user/libs/

USRCDIR		+= user

ULIBDIR		+= user/libs

UCFLAGS		+= $(addprefix -I,$(UINCLUDE))
USER_BINS	:=

$(call add_files_cc,$(call listf_cc,$(ULIBDIR)),ulibs,$(UCFLAGS))
$(call add_files_cc,$(call listf_cc,$(USRCDIR)),uprog,$(UCFLAGS))

UOBJS	:= $(call read_packet,ulibs libs)

define uprog_ld
__user_bin__ := $$(call ubinfile,$(1))
USER_BINS += $$(__user_bin__)
$$(__user_bin__): tools/user.ld
$$(__user_bin__): $$(UOBJS)
$$(__user_bin__): $(1) | $$$$(dir $$$$@)
	$(V)$(LD) $(LDFLAGS) -T tools/user.ld -o $$@ $$(UOBJS) $(1)
	@$(OBJDUMP) -S $$@ > $$(call cgtype,$$<,o,asm)
	@$(OBJDUMP) -t $$@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$$$/d' > $$(call cgtype,$$<,o,sym)
endef

$(foreach p,$(call read_packet,uprog),$(eval $(call uprog_ld,$(p))))

# -------------------------------------------------------------------
# kernel

KINCLUDE	+= kern/debug/ \
			   kern/driver/ \
			   kern/trap/ \
			   kern/mm/ \
			   kern/libs/ \
			   kern/sync/ \
			   kern/fs/    \
			   kern/process/ \
			   kern/schedule/ \
			   kern/syscall/  \
			   kern/fs/swap/ \
			   kern/fs/vfs/ \
			   kern/fs/devs/ \
			   kern/fs/sfs/ 


KSRCDIR		+= kern/init \
			   kern/libs \
			   kern/debug \
			   kern/driver \
			   kern/trap \
			   kern/mm \
			   kern/sync \
			   kern/fs    \
			   kern/process \
			   kern/schedule \
			   kern/syscall  \
			   kern/fs/swap \
			   kern/fs/vfs \
			   kern/fs/devs \
			   kern/fs/sfs

KCFLAGS		+= $(addprefix -I,$(KINCLUDE))

$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))

KOBJS	= $(call read_packet,kernel libs)

# create kernel target
kernel = $(call totarget,kernel)

$(kernel): tools/kernel.ld

$(kernel): $(KOBJS)
	@echo + ld $@
	$(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
	@$(OBJDUMP) -S $@ > $(call asmfile,kernel)
	@$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)

$(call create_target,kernel)

# -------------------------------------------------------------------

# create bootblock
bootfiles = $(call listf_cc,boot)
$(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))

bootblock = $(call totarget,bootblock)

# 定义bootblock的生成规则
# line1:定义bootblock目标及其依赖;'|'左侧的前提目标是obj/boot/bootasm.o obj/boot/bootmain.o; '|'右侧的命名前提目标是bin/sign
# line2:也只是一个输出提示;@不会输出整条命令=> 最终只会打印+ ld bin/kernel;没有@会打印整条命令
# line3:执行链接:ld .... obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o
#		其中,-N表示指定读取/写入文本和数据段; -T 指定链接程序
# line4:执行命令:objdump -S obj/bootblock.o > obj/bootblock.asm
# line5:执行命令:objcopy -S -O binary obj/bootblock.o obj/bootblock.out => 即复制二进制文件
# line6:执行命令:bin/sign   obj/bootblock.out bin/bootblock
# 		执行sign的作用,将加载程序bootblock.out填充至512bytes以符号MBR格式(sign只是一个工具程序,是bootloader符合MBR格式)
$(bootblock): $(call toobj,boot/bootasm.S) $(call toobj,$(bootfiles)) | $(call totarget,sign)
	@echo + ld $@
	$(V)$(LD) $(LDFLAGS) -N -T tools/boot.ld $^ -o $(call toobj,bootblock)
	@$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)
	@$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)
	@$(call totarget,sign) $(call outfile,bootblock) $(bootblock)

$(call create_target,bootblock)

# -------------------------------------------------------------------

# create 'sign' tools
$(call add_files_host,tools/sign.c,sign,sign)
$(call create_target_host,sign,sign)

# -------------------------------------------------------------------
# create 'mksfs' tools
$(call add_files_host,tools/mksfs.c,mksfs,mksfs)
$(call create_target_host,mksfs,mksfs)

# -------------------------------------------------------------------
# create ucore.img
UCOREIMG	:= $(call totarget,ucore.img)

# 生成规则中 => dd命令用于读取、转换并输出数据
# if:输入文件  of:输出文件
# line1:/dev/zero是提供空字符的文件(设备),$@表示目标文件 
#       => 使用10000个空的block来填充目标文件(block默认为512B),因此生成了一个5.12MB的目标文件
# line2:if输入是boltloader,of输出是目标文件,conv=notrunc表示不对数据进行截断 
#		=> 直接将bootloader复制到目标文件最开始处(bootloader大小不超过512B) 
# line3:....seek从输出文件头开始跳过多少block再复制 
#		=> 从输出目标文件跳过512B再开始复制(第一个扇区属于bootloader)
$(UCOREIMG): $(kernel) $(bootblock)
	$(V)dd if=/dev/zero of=$@ count=10000
	$(V)dd if=$(bootblock) of=$@ conv=notrunc
	$(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc

$(call create_target,ucore.img)

# -------------------------------------------------------------------

# create swap.img
SWAPIMG		:= $(call totarget,swap.img)

$(SWAPIMG):
	$(V)dd if=/dev/zero of=$@ bs=1024k count=128

$(call create_target,swap.img)

# -------------------------------------------------------------------
# create sfs.img
SFSIMG		:= $(call totarget,sfs.img)
SFSBINS		:=
SFSROOT		:= disk0

define fscopy
__fs_bin__ := $(2)$(SLASH)$(patsubst $(USER_PREFIX)%,%,$(basename $(notdir $(1))))
SFSBINS += $$(__fs_bin__)
$$(__fs_bin__): $(1) | $$$$(dir $@)
	@$(COPY) $$< $$@
endef

$(foreach p,$(USER_BINS),$(eval $(call fscopy,$(p),$(SFSROOT)$(SLASH))))

$(SFSROOT):
	if [ ! -d "$(SFSROOT)" ]; then mkdir $(SFSROOT); fi

$(SFSROOT):
	$(V)$(MKDIR) $@

$(SFSIMG): $(SFSROOT) $(SFSBINS) | $(call totarget,mksfs)
	$(V)dd if=/dev/zero of=$@ bs=1024k count=128
	@$(call totarget,mksfs) $@ $(SFSROOT)

$(call create_target,sfs.img)


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

$(call finish_all)

IGNORE_ALLDEPS	= clean \
				  dist-clean \
				  grade \
				  touch \
				  print-.+ \
				  run-.+ \
				  build-.+ \
				  sh-.+ \
				  script-.+ \
				  handin

ifeq ($(call match,$(MAKECMDGOALS),$(IGNORE_ALLDEPS)),0)
-include $(ALLDEPS)
endif

# files for grade script

TARGETS: $(TARGETS)

.DEFAULT_GOAL := TARGETS

QEMUOPTS = -hda $(UCOREIMG) -drive file=$(SWAPIMG),media=disk,cache=writeback -drive file=$(SFSIMG),media=disk,cache=writeback 

.PHONY: qemu qemu-nox debug debug-nox monitor
qemu-mon: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU)  -no-reboot -monitor stdio $(QEMUOPTS) -serial null

# 在qemu-6.0.0中, make qemu 使用了-no-reboot 参数会导致键盘输入时无法产生中断; 
# $(V)$(QEMU)  -no-reboot -parallel stdio $(QEMUOPTS) -serial null
qemu: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU) -serial stdio $(QEMUOPTS) -parallel null

qemu-nox: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU)  -no-reboot -serial mon:stdio $(QEMUOPTS) -nographic

monitor: $(UCOREIMG) $(SWAPING) $(SFSIMG)
	$(V)$(QEMU)  -no-reboot  -monitor stdio $(QEMUOPTS) -serial null

TERMINAL := gnome-terminal

debug: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU) -S -s -parallel stdio $(QEMUOPTS) -serial null &
	$(V)sleep 2
	$(V)$(TERMINAL) -e "$(GDB) -q -x tools/gdbinit"

debug-nox: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU) -S -s -serial mon:stdio $(QEMUOPTS) -nographic &
	$(V)sleep 2
	$(V)$(TERMINAL) -e "$(GDB) -q -x tools/gdbinit"

RUN_PREFIX	:= _binary_$(OBJDIR)_$(USER_PREFIX)
MAKEOPTS	:= --quiet --no-print-directory

run-%: build-%
	$(V)$(QEMU) -parallel stdio $(QEMUOPTS) -serial null

sh-%: script-%
	$(V)$(QEMU) -parallel stdio $(QEMUOPTS) -serial null

run-nox-%: build-%
	$(V)$(QEMU) -serial mon:stdio $(QEMUOPTS) -nographic

build-%: touch
	$(V)$(MAKE) $(MAKEOPTS) "DEFS+=-DTEST=$*" 

script-%: touch
	$(V)$(MAKE) $(MAKEOPTS) "DEFS+=-DTEST=sh -DTESTSCRIPT=/script/$*"

.PHONY: grade touch buildfs

GRADE_GDB_IN	:= .gdb.in
GRADE_QEMU_OUT	:= .qemu.out
HANDIN			:= proj$(PROJ)-handin.tar.gz

TOUCH_FILES		:= kern/process/proc.c

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
	$(V)$(RM) $(GRADE_GDB_IN) $(GRADE_QEMU_OUT)  $(SFSBINS) cscope* tags
	$(V)$(RM) -r $(OBJDIR) $(BINDIR) $(SFSROOT)

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
