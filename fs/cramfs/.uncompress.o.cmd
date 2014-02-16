cmd_fs/cramfs/uncompress.o := ppc_4xx-gcc -m32 -Wp,-MD,fs/cramfs/.uncompress.o.d  -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Iarch/powerpc -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -O2 -msoft-float -pipe -Iarch/powerpc -ffixed-r2 -mmultiple -mno-altivec -mno-spe -mspe=no -funit-at-a-time -mno-string -Wa,-m405 -fno-stack-protector -fomit-frame-pointer -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow   -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(uncompress)"  -D"KBUILD_MODNAME=KBUILD_STR(cramfs)"  -c -o fs/cramfs/.tmp_uncompress.o fs/cramfs/uncompress.c

deps_fs/cramfs/uncompress.o := \
  fs/cramfs/uncompress.c \
  include/linux/kernel.h \
    $(wildcard include/config/lbdaf.h) \
    $(wildcard include/config/preempt/voluntary.h) \
    $(wildcard include/config/debug/spinlock/sleep.h) \
    $(wildcard include/config/prove/locking.h) \
    $(wildcard include/config/printk.h) \
    $(wildcard include/config/dynamic/debug.h) \
    $(wildcard include/config/ring/buffer.h) \
    $(wildcard include/config/tracing.h) \
    $(wildcard include/config/numa.h) \
    $(wildcard include/config/ftrace/mcount/record.h) \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stdarg.h \
  include/linux/linkage.h \
  include/linux/compiler.h \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  include/linux/compiler-gcc.h \
    $(wildcard include/config/arch/supports/optimized/inlining.h) \
    $(wildcard include/config/optimize/inlining.h) \
  include/linux/compiler-gcc4.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/linkage.h \
  include/linux/stddef.h \
  include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/phys/addr/t/64bit.h) \
    $(wildcard include/config/64bit.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/types.h \
    $(wildcard include/config/phys/64bit.h) \
  include/asm-generic/int-ll64.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/linux/posix_types.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/posix_types.h \
  include/linux/bitops.h \
    $(wildcard include/config/generic/find/first/bit.h) \
    $(wildcard include/config/generic/find/last/bit.h) \
    $(wildcard include/config/generic/find/next/bit.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/bitops.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/asm-compat.h \
    $(wildcard include/config/power4/only.h) \
    $(wildcard include/config/ibm405/err77.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/synch.h \
    $(wildcard include/config/ppc/e500mc.h) \
    $(wildcard include/config/e500.h) \
    $(wildcard include/config/smp.h) \
  include/linux/stringify.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/feature-fixups.h \
    $(wildcard include/config/ppc64.h) \
  include/asm-generic/bitops/non-atomic.h \
  include/asm-generic/bitops/fls64.h \
  include/asm-generic/bitops/hweight.h \
  include/asm-generic/bitops/find.h \
  include/asm-generic/bitops/sched.h \
  include/linux/log2.h \
    $(wildcard include/config/arch/has/ilog2/u32.h) \
    $(wildcard include/config/arch/has/ilog2/u64.h) \
  include/linux/typecheck.h \
  include/linux/dynamic_debug.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/byteorder.h \
  include/linux/byteorder/big_endian.h \
  include/linux/swab.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/swab.h \
  include/linux/byteorder/generic.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/bug.h \
    $(wildcard include/config/bug.h) \
    $(wildcard include/config/debug/bugverbose.h) \
  include/asm-generic/bug.h \
    $(wildcard include/config/generic/bug.h) \
    $(wildcard include/config/generic/bug/relative/pointers.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/div64.h \
  include/asm-generic/div64.h \
  include/linux/errno.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/errno.h \
  include/asm-generic/errno.h \
  include/asm-generic/errno-base.h \
  include/linux/vmalloc.h \
    $(wildcard include/config/mmu.h) \
  include/linux/spinlock.h \
    $(wildcard include/config/debug/spinlock.h) \
    $(wildcard include/config/generic/lockbreak.h) \
    $(wildcard include/config/preempt.h) \
    $(wildcard include/config/debug/lock/alloc.h) \
  include/linux/preempt.h \
    $(wildcard include/config/debug/preempt.h) \
    $(wildcard include/config/preempt/tracer.h) \
    $(wildcard include/config/preempt/notifiers.h) \
  include/linux/thread_info.h \
    $(wildcard include/config/compat.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/thread_info.h \
    $(wildcard include/config/ppc/256k/pages.h) \
  include/linux/cache.h \
    $(wildcard include/config/arch/has/cache/line/size.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/cache.h \
    $(wildcard include/config/8xx.h) \
    $(wildcard include/config/403gcx.h) \
    $(wildcard include/config/ppc32.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/processor.h \
    $(wildcard include/config/vsx.h) \
    $(wildcard include/config/ppc/prep.h) \
    $(wildcard include/config/task/size.h) \
    $(wildcard include/config/kernel/start.h) \
    $(wildcard include/config/4xx.h) \
    $(wildcard include/config/booke.h) \
    $(wildcard include/config/altivec.h) \
    $(wildcard include/config/spe.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/reg.h \
    $(wildcard include/config/40x.h) \
    $(wildcard include/config/fsl/emb/perfmon.h) \
    $(wildcard include/config/ppc/book3s/64.h) \
    $(wildcard include/config/ppc/book3s/32.h) \
    $(wildcard include/config/ppc/book3e/64.h) \
    $(wildcard include/config/e200.h) \
    $(wildcard include/config/ppc/cell.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/cputable.h \
    $(wildcard include/config/mpc10x/bridge.h) \
    $(wildcard include/config/ppc/83xx.h) \
    $(wildcard include/config/8260.h) \
    $(wildcard include/config/ppc/mpc52xx.h) \
    $(wildcard include/config/bdi/switch.h) \
    $(wildcard include/config/power3.h) \
    $(wildcard include/config/power4.h) \
    $(wildcard include/config/44x.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/reg_booke.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/ptrace.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/page.h \
    $(wildcard include/config/ppc/64k/pages.h) \
    $(wildcard include/config/ppc/16k/pages.h) \
    $(wildcard include/config/page/offset.h) \
    $(wildcard include/config/physical/start.h) \
    $(wildcard include/config/relocatable.h) \
    $(wildcard include/config/flatmem.h) \
    $(wildcard include/config/ppc/std/mmu/64.h) \
    $(wildcard include/config/hugetlb/page.h) \
    $(wildcard include/config/ppc/smlpar.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/kdump.h \
    $(wildcard include/config/crash/dump.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/page_32.h \
    $(wildcard include/config/physical/align.h) \
    $(wildcard include/config/not/coherent/cache.h) \
    $(wildcard include/config/pte/64bit.h) \
  include/asm-generic/getorder.h \
  include/asm-generic/memory_model.h \
    $(wildcard include/config/discontigmem.h) \
    $(wildcard include/config/sparsemem/vmemmap.h) \
    $(wildcard include/config/sparsemem.h) \
  include/linux/list.h \
    $(wildcard include/config/debug/list.h) \
  include/linux/poison.h \
    $(wildcard include/config/illegal/pointer/value.h) \
  include/linux/prefetch.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/system.h \
    $(wildcard include/config/debugger.h) \
    $(wildcard include/config/kexec.h) \
    $(wildcard include/config/6xx.h) \
    $(wildcard include/config/booke/wdt.h) \
    $(wildcard include/config/virt/cpu/accounting.h) \
  include/linux/irqflags.h \
    $(wildcard include/config/trace/irqflags.h) \
    $(wildcard include/config/irqsoff/tracer.h) \
    $(wildcard include/config/trace/irqflags/support.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/irqflags.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/hw_irq.h \
    $(wildcard include/config/ppc/book3e.h) \
    $(wildcard include/config/perf/events.h) \
  include/asm-generic/cmpxchg-local.h \
  include/linux/bottom_half.h \
  include/linux/spinlock_types.h \
  include/linux/spinlock_types_up.h \
  include/linux/lockdep.h \
    $(wildcard include/config/lockdep.h) \
    $(wildcard include/config/lock/stat.h) \
    $(wildcard include/config/generic/hardirqs.h) \
  include/linux/rwlock_types.h \
  include/linux/spinlock_up.h \
  include/linux/rwlock.h \
  include/linux/spinlock_api_up.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/atomic.h \
  include/asm-generic/atomic64.h \
  include/asm-generic/atomic-long.h \
  include/linux/init.h \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/hotplug.h) \
  include/linux/zlib.h \
  include/linux/zconf.h \
  include/linux/cramfs_fs.h \
  include/linux/magic.h \

fs/cramfs/uncompress.o: $(deps_fs/cramfs/uncompress.o)

$(deps_fs/cramfs/uncompress.o):
