#include <defs.h>
#include <x86.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_fifo.h>
#include <list.h>

/*************************************************************************************
 *                                  FIFO页面置换算法
 * 
 * 1.在swap.c中被调用; 内核对页面置换实际使用swap.c中的统一接口
 * 2.最终要的几个函数如下:
 *      _fifo_map_swappable:将page加入置换队列
 *      _fifo_swap_out_victim:选出牺牲页
 * 2.这里置换算法只是管理加入的页面、选出牺牲的页面,并不负责真正的换入、换出工作
 *   => 换入、换出工作在swap.c中由swap_in、swap_out实现!!!
 * **********************************************************************************/


/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a FIFO algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While FIFO is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of FIFO PRA
 * (1) Prepare: In order to implement FIFO PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 */

// 全局变量,页面置换的FIFO队列
// 1.它连接的是物理页面(见Page结构体pra_page_link成员)
// 2.同时它是mm_struct的成员sm_priv(从而将进程与该进程在内存中的页面联系起来)
// !!! 注:其实这全局变量拿来没用,FIFO队列应该是进程私有,代码中结点插入删除实际上是直接在mm->sm_priv上进行的!!!
list_entry_t pra_list_head;       

/**
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *     Now, From the memory control struct mm_struct, we can access FIFO PRA
 * 给mm_struct初始化sm_prov成员
 * => 这一步实际上就是将页面置换FIFO队列指针赋值给mm_struct,将进程与其物理页面关联起来
 */
static int _fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);             // 初始化队列(带头结点的双向链表)
     mm->sm_priv = &pra_list_head;          // 设置进程mm的置换队列
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}


/****
 * (3)_fifo_map_swappable: According FIFO PRA(page replace algo),
 *  we should link the most recent arrival page at the back of pra_list_head qeueue
 *  将page加入置换队列(mm_struct->sm_priv字段)
 * - mm:当前进程的mm_struct 
 * - addr:数据的虚拟地址            =>没用上
 * - page:数据对应的物理内存页描述结构
 * - swap_in:换入内存/换出内存的标志 => 没用上
 */
static int _fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head,entry);            // 头插入加入链表! head是头结点,不存放数据
    return 0;
}


/****
 *  (4)_fifo_swap_out_victim: According FIFO PRA, 
 * we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 * then assign the value of *ptr_page to the addr of this page.
 * 选择要换出的页面,将该页面从队列中删除
 * 使ptr_page指向要换出的页面
 * */
static int _fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
    list_entry_t* le=head->prev;
    assert(le!=head);
    *ptr_page=le2page(le,pra_page_link);
    list_del(le);
     return 0;
}


/***
 * 检查fifo_swap算法是否正确
 * 什么时候换出?
 * 什么时候换入? => do_pgfault()当需要的页面不在内存而在磁盘时
 **/
static int _fifo_check_swap(void) {
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);                           
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==7);
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==8);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==9);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==10);
    cprintf("write Virt Page a in fifo_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==11);
    return 0;
}


static int _fifo_init(void)
{
    return 0;
}

static int _fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int _fifo_tick_event(struct mm_struct *mm)
{
    return 0; 
}

// 默认的置换算法 => 在swap.c中被调用
struct swap_manager swap_manager_fifo =
{
     .name            = "fifo swap manager",
     .init            = &_fifo_init,
     .init_mm         = &_fifo_init_mm,
     .tick_event      = &_fifo_tick_event,
     .map_swappable   = &_fifo_map_swappable,
     .set_unswappable = &_fifo_set_unswappable,
     .swap_out_victim = &_fifo_swap_out_victim,
     .check_swap      = &_fifo_check_swap,
};
