# 在kernel_thread(...)中设置tf.tf_eip=kernel_thread_entry
# kernel_thread_entry函数就是给新的内核线程的主体函数fn做了一个准备开始和结束运行的"壳"
# 它可以看做是新线程的入口
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg, 将参数(位于edx寄存器)压栈 => 为什么是这两个寄存器? => 详见kernel_thread中设置的中断帧
    call *%ebx              # call fn,  调用fn函数(位于ebx)

    # 对于用户线程,user_main调用结束后,直接中断返回(kernel_execve的缘故)到用户态执行用户程序,不会执行下面两行指令...
    pushl %eax              # save the return value of fn(arg)        ,调用结束,保存返回值在eax
    call do_exit            # call do_exit to terminate current thread,结束fn对应的这个线程

