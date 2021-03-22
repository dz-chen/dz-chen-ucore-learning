# 从from线程切换到to线程
# 主要完成:
#   1.保存from线程的现场寄存器信息到from线程的context
#   2.恢复to线程上次停止执行时的寄存器现场(从to线程的context)
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers => 保存from线程的执行现场寄存器值,出入from线程的context字段
    movl 4(%esp), %eax          # eax points to from
    popl 0(%eax)                # save eip !popl
    movl %esp, 4(%eax)          # 
    movl %ebx, 8(%eax)
    movl %ecx, 12(%eax)
    movl %edx, 16(%eax)
    movl %esi, 20(%eax)
    movl %edi, 24(%eax)
    movl %ebp, 28(%eax)

    # restore to's registers => 从to线程的context字段恢复上次停止执行时的现场寄存器信息
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
                                # eax now points to to
    movl 28(%eax), %ebp
    movl 24(%eax), %edi
    movl 20(%eax), %esi
    movl 16(%eax), %edx
    movl 12(%eax), %ecx
    movl 8(%eax), %ebx
    movl 4(%eax), %esp
    pushl 0(%eax)               # push eip => 

    ret

