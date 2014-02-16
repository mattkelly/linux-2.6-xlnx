cmd_arch/powerpc/kernel/entry_32.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/kernel/.entry_32.o.d  -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Iarch/powerpc -D__ASSEMBLY__ -Iarch/powerpc -Wa,-m405 -gdwarf-2       -c -o arch/powerpc/kernel/entry_32.o arch/powerpc/kernel/entry_32.S

deps_arch/powerpc/kernel/entry_32.o := \
  arch/powerpc/kernel/entry_32.S \
    $(wildcard include/config/booke.h) \
    $(wildcard include/config/ppc/book3e/mmu.h) \
    $(wildcard include/config/phys/64bit.h) \
    $(wildcard include/config/44x.h) \
    $(wildcard include/config/40x.h) \
    $(wildcard include/config/smp.h) \
    $(wildcard include/config/6xx.h) \
    $(wildcard include/config/e500.h) \
    $(wildcard include/config/trace/irqflags.h) \
    $(wildcard include/config/4xx.h) \
    $(wildcard include/config/ibm405/err77.h) \
    $(wildcard include/config/altivec.h) \
    $(wildcard include/config/spe.h) \
    $(wildcard include/config/xilinx/virtex/5/fxt.h) \
    $(wildcard include/config/ppc/fpu.h) \
    $(wildcard include/config/preempt.h) \
    $(wildcard include/config/ppc/rtas.h) \
    $(wildcard include/config/function/tracer.h) \
    $(wildcard include/config/dynamic/ftrace.h) \
    $(wildcard include/config/function/graph/tracer.h) \
    $(wildcard include/config/mcount.h) \
  include/linux/errno.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/errno.h \
  include/asm-generic/errno.h \
  include/asm-generic/errno-base.h \
  include/linux/sys.h \
  include/linux/threads.h \
    $(wildcard include/config/nr/cpus.h) \
    $(wildcard include/config/base/small.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/reg.h \
    $(wildcard include/config/fsl/emb/perfmon.h) \
    $(wildcard include/config/8xx.h) \
    $(wildcard include/config/ppc64.h) \
    $(wildcard include/config/ppc/book3s/64.h) \
    $(wildcard include/config/ppc/book3s/32.h) \
    $(wildcard include/config/ppc/book3e/64.h) \
    $(wildcard include/config/e200.h) \
    $(wildcard include/config/ppc/cell.h) \
    $(wildcard include/config/ppc32.h) \
  include/linux/stringify.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/cputable.h \
    $(wildcard include/config/vsx.h) \
    $(wildcard include/config/mpc10x/bridge.h) \
    $(wildcard include/config/ppc/83xx.h) \
    $(wildcard include/config/8260.h) \
    $(wildcard include/config/ppc/mpc52xx.h) \
    $(wildcard include/config/bdi/switch.h) \
    $(wildcard include/config/power3.h) \
    $(wildcard include/config/power4.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/asm-compat.h \
    $(wildcard include/config/power4/only.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/types.h \
  include/asm-generic/int-ll64.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
    $(wildcard include/config/64bit.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/feature-fixups.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/reg_booke.h \
    $(wildcard include/config/403gcx.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/page.h \
    $(wildcard include/config/ppc/256k/pages.h) \
    $(wildcard include/config/ppc/64k/pages.h) \
    $(wildcard include/config/ppc/16k/pages.h) \
    $(wildcard include/config/kernel/start.h) \
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
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/mmu.h \
    $(wildcard include/config/ppc/std/mmu/32.h) \
    $(wildcard include/config/ppc/8xx.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/mmu-44x.h \
    $(wildcard include/config/ppc/early/debug/44x.h) \
    $(wildcard include/config/ppc/early/debug/44x/physlow.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/thread_info.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/ppc_asm.h \
    $(wildcard include/config/virt/cpu/accounting.h) \
    $(wildcard include/config/ppc601/sync/fix.h) \
    $(wildcard include/config/ibm440ep/err42.h) \
  include/linux/init.h \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/hotplug.h) \
  include/linux/compiler.h \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/processor.h \
    $(wildcard include/config/ppc/prep.h) \
    $(wildcard include/config/task/size.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/ppc-opcode.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/asm-offsets.h \
  include/generated/asm-offsets.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/unistd.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/ftrace.h \

arch/powerpc/kernel/entry_32.o: $(deps_arch/powerpc/kernel/entry_32.o)

$(deps_arch/powerpc/kernel/entry_32.o):
