cmd_arch/powerpc/kernel/vdso32/vdso32_wrapper.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/kernel/vdso32/.vdso32_wrapper.o.d  -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Iarch/powerpc -D__ASSEMBLY__ -Iarch/powerpc -Wa,-m405 -gdwarf-2     -D__VDSO32__ -s   -c -o arch/powerpc/kernel/vdso32/vdso32_wrapper.o arch/powerpc/kernel/vdso32/vdso32_wrapper.S

deps_arch/powerpc/kernel/vdso32/vdso32_wrapper.o := \
  arch/powerpc/kernel/vdso32/vdso32_wrapper.S \
  include/linux/init.h \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/hotplug.h) \
  include/linux/compiler.h \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  include/linux/linkage.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/linkage.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/page.h \
    $(wildcard include/config/ppc/256k/pages.h) \
    $(wildcard include/config/ppc/64k/pages.h) \
    $(wildcard include/config/ppc/16k/pages.h) \
    $(wildcard include/config/kernel/start.h) \
    $(wildcard include/config/page/offset.h) \
    $(wildcard include/config/physical/start.h) \
    $(wildcard include/config/relocatable.h) \
    $(wildcard include/config/ppc64.h) \
    $(wildcard include/config/flatmem.h) \
    $(wildcard include/config/ppc/book3e/64.h) \
    $(wildcard include/config/ppc/std/mmu/64.h) \
    $(wildcard include/config/hugetlb/page.h) \
    $(wildcard include/config/ppc/smlpar.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/types.h \
    $(wildcard include/config/phys/64bit.h) \
  include/asm-generic/int-ll64.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
    $(wildcard include/config/64bit.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/asm-compat.h \
    $(wildcard include/config/power4/only.h) \
    $(wildcard include/config/ibm405/err77.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/kdump.h \
    $(wildcard include/config/crash/dump.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/page_32.h \
    $(wildcard include/config/physical/align.h) \
    $(wildcard include/config/not/coherent/cache.h) \
    $(wildcard include/config/pte/64bit.h) \

arch/powerpc/kernel/vdso32/vdso32_wrapper.o: $(deps_arch/powerpc/kernel/vdso32/vdso32_wrapper.o)

$(deps_arch/powerpc/kernel/vdso32/vdso32_wrapper.o):
