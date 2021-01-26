#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <x86.h>
#include <intr.h>
#include <mmu.h>
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
    if (read_eflags() & FL_IF) {            // 判断EFLAS的中断屏蔽位
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void
__intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

// 将EFLAGS中断屏蔽位信息保存到x中(0或者1)
// 然后屏蔽中断
#define local_intr_save(x)      do { x = __intr_save(); } while (0)

// 使用x恢复EFLAGS的中断屏蔽位 => 使能或者继续保持中断屏蔽
#define local_intr_restore(x)   __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */

