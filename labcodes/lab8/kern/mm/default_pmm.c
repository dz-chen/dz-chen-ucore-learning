#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/*  In the First Fit algorithm, the allocator keeps a list of free blocks
 * (known as the free list). Once receiving a allocation request for memory,
 * it scans along the list for the first block that is large enough to satisfy
 * the request. If the chosen block is significantly larger than requested, it
 * is usually splitted, and the remainder will be added into the list as
 * another free block.
 *  Please refer to Page 196~198, Section 8.2 of Yan Wei Min's Chinese book
 * "Data Structure -- C programming language".
*/
// LAB2 EXERCISE 1: YOUR CODE
// you should rewrite functions: `default_init`, `default_init_memmap`,
// `default_alloc_pages`, `default_free_pages`.
/*
 * Details of FFMA(first fit memory allocate)
 * (1) Preparation:
 *  In order to implement the First-Fit Memory Allocation (FFMA), we should
 * manage the free memory blocks using a list. The struct `free_area_t` is used
 * for the management of free memory blocks.
 *  First, you should get familiar with the struct `list` in list.h. Struct
 * `list` is a simple doubly linked list implementation. You should know how to
 * USE `list_init`, `list_add`(`list_add_after`), `list_add_before`, `list_del`,
 * `list_next`, `list_prev`.
 *  There's a tricky method that is to transform a general `list` struct to a
 * special struct (such as struct `page`), using the following MACROs: `le2page`
 * (in memlayout.h), (and in future labs: `le2vma` (in vmm.h), `le2proc` (in
 * proc.h), etc).
 * (2) `default_init`:
 *  You can reuse the demo `default_init` function to initialize the `free_list`
 * and set `nr_free` to 0. `free_list` is used to record the free memory blocks.
 * `nr_free` is the total number of the free memory blocks.
 * (3) `default_init_memmap`:
 *  CALL GRAPH: `kern_init` --> `pmm_init` --> `page_init` --> `init_memmap` -->
 * `pmm_manager` --> `init_memmap`.
 *  This function is used to initialize a free block (with parameter `addr_base`,
 * `page_number`). In order to initialize a free block, firstly, you should
 * initialize each page (defined in memlayout.h) in this free block. This
 * procedure includes:
 *  - Setting the bit `PG_property` of `p->flags`, which means this page is
 * valid. P.S. In function `pmm_init` (in pmm.c), the bit `PG_reserved` of
 * `p->flags` is already set.
 *  - If this page is free and is not the first page of a free block,
 * `p->property` should be set to 0.
 *  - If this page is free and is the first page of a free block, `p->property`
 * should be set to be the total number of pages in the block.
 *  - `p->ref` should be 0, because now `p` is free and has no reference.
 *  After that, We can use `p->page_link` to link this page into `free_list`.
 * (e.g.: `list_add_before(&free_list, &(p->page_link));` )
 *  Finally, we should update the sum of the free memory blocks: `nr_free += n`.
 * (4) `default_alloc_pages`:
 *  Search for the first free block (block size >= n) in the free list and reszie
 * the block found, returning the address of this block as the address required by
 * `malloc`.
 *  (4.1)
 *      So you should search the free list like this:
 *          list_entry_t le = &free_list;
 *          while((le=list_next(le)) != &free_list) {
 *          ...
 *      (4.1.1)
 *          In the while loop, get the struct `page` and check if `p->property`
 *      (recording the num of free pages in this block) >= n.
 *              struct Page *p = le2page(le, page_link);
 *              if(p->property >= n){ ...
 *      (4.1.2)
 *          If we find this `p`, it means we've found a free block with its size
 *      >= n, whose first `n` pages can be malloced. Some flag bits of this page
 *      should be set as the following: `PG_reserved = 1`, `PG_property = 0`.
 *      Then, unlink the pages from `free_list`.
 *          (4.1.2.1)
 *              If `p->property > n`, we should re-calculate number of the rest
 *          pages of this free block. (e.g.: `le2page(le,page_link))->property
 *          = p->property - n;`)
 *          (4.1.3)
 *              Re-caluclate `nr_free` (number of the the rest of all free block).
 *          (4.1.4)
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
 * (5) `default_free_pages`:
 *  re-link the pages into the free list, and may merge small free blocks into
 * the big ones.
 *  (5.1)
 *      According to the base address of the withdrawed blocks, search the free
 *  list for its correct position (with address from low to high), and insert
 *  the pages. (May use `list_next`, `le2page`, `list_add_before`)
 *  (5.2)
 *      Reset the fields of the pages, such as `p->ref` and `p->flags` (PageProperty)
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */


/************************************************************************************
 *                           默认的物理内存分配算法:first fit
 * **********************************************************************************/


// 空闲块链表 => 一个空闲块(区域)包含多个物理page
// ucore实现时空闲链表结点按地址排序!!!
free_area_t free_area;

#define free_list (free_area.free_list)     // 空闲链表
#define nr_free (free_area.nr_free)         // 总的空闲page个数(不是空闲区域个数)


// 初始化空闲链表
static void default_init(void) {
    list_init(&free_list);                  // 初始化空闲链表结点; free_list是一个空节点(它与链表上其他节点不同)
    nr_free = 0;
}


/**
 * 初始化一个连续的空闲区域,并将其加入空闲链表
 * - base:空闲区域的起始地址(va) => 它不是真正的空闲区域起始地址,它是管理所有物理页的Page数组的起始地址!
 * - n:空闲区域中物理页的个数
 * */
static void default_init_memmap(struct Page *base, size_t n) {
    // 初始化每一个page(属性都转为0)
    for(struct Page* p=base; p!=base+n;p++){
        p->flags=0;
        p->property=0;  
        set_page_ref(p,0);  
    }

    // 初始化这个空闲区域的第一个page!!
    base->property=n;
    SetPageProperty(base);
    nr_free+=n;
    list_add_before(&free_list,&(base->page_link));  //这个空闲区域加入链表(只需加入区域第一个page中的链表项即可!)
}

/****
 * 分配n个物理页
 * 返回分配的区域的第一个page指针
 * 注:返回的不是区域的首地址,而是该区域第一个page的描述结构的地址
 * **/
static struct Page *default_alloc_pages(size_t n) {
    if(n>nr_free) return NULL;
    // 遍历空闲链表,找到第一个拥有超过n个page的空闲区域
    struct Page* page=NULL;
    list_entry_t* le=list_next(&free_list);                // 注意free_list是一个空结点,不含page数据!!
    while(le != &free_list){
        struct Page* p=le2page(le,page_link);
        if(p->property>=n){                                // 找到符合条件的空闲区域       
            page=p;
            break;
        }
        le=list_next(le);
    }

    // 如果找到了满足条件的区域,修改这个区域的第一个page
    if(page!=NULL){
        if(page->property > n){                         // 空闲页数超过需求,需要将这个区域分为两个区域
            struct Page* p=page+n;
            p->property=page->property-n;
            SetPageProperty(p);                         // 多余的page修改为空闲区域,设置其第一个page
            list_add_after(&(page->page_link),&(p->page_link));
        }
        list_del(&(page->page_link));
        nr_free-=n;
        ClearPageProperty(page);                        // 修改域第一个page,标志区域已经分配
    }
    return page;
}


/***
 * 释放从base开始的n个物理页;
 * 释放后的区域加入空闲链表;如果可以合并,需要合并空闲区域
 * 注:base不是该区域真正的地址,它只是描述该区域的结构体的地址
 * **/
static void default_free_pages(struct Page *base, size_t n) {
    // 释放base开始的n个page
    for(struct Page* p=base; p!=base+n;p++){
        p->flags=0;
        p->property=0;
        set_page_ref(p,0);
    }
    base->property=n;
    SetPageProperty(base);  

    // 合并空闲区域
    list_entry_t* le=list_next(&free_list);
    while(le!=&free_list){
        struct Page* p=le2page(le,page_link);
        if(p+p->property==base){           // 合并前面的区域
            p->property+=base->property;
            ClearPageProperty(base);
            base=p;             // 这样方便之后继续合并后面区域
            list_del(&(p->page_link));            
        }        
        else if(base+base->property==p){   // 合并后面的区域
            base->property+=p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }

        le=list_next(le);
    }

    // 插入到空闲链表(注意ucore实现时链表结点按照地址排序)
    le=list_next(&free_list);
    while(le!=&free_list){
        struct Page* p=le2page(le,page_link);
        if(base+base->property<p) break;
        le=list_next(le);
    }
    nr_free+=n;
    list_add_before(le,&(base->page_link));
}

// 返回整个空闲链表中所有空闲页个数
static size_t default_nr_free_pages(void) {
    return nr_free;
}

// 被default_check调用
static void basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

