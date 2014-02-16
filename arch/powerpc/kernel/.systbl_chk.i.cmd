cmd_arch/powerpc/kernel/systbl_chk.i := ppc_4xx-gcc -m32 -E -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -O2 -msoft-float -pipe -Iarch/powerpc -ffixed-r2 -mmultiple -mno-altivec -mno-spe -mspe=no -funit-at-a-time -mno-string -Wa,-m405   -fno-stack-protector -fomit-frame-pointer -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow   -Wp,-MD,arch/powerpc/kernel/.systbl_chk.i.d  -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Iarch/powerpc -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -O2 -msoft-float -pipe -Iarch/powerpc -ffixed-r2 -mmultiple -mno-altivec -mno-spe -mspe=no -funit-at-a-time -mno-string -Wa,-m405 -fno-stack-protector -fomit-frame-pointer -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -Werror   -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(systbl_chk)"  -D"KBUILD_MODNAME=KBUILD_STR(systbl_chk)"    -o arch/powerpc/kernel/systbl_chk.i arch/powerpc/kernel/systbl_chk.c

deps_arch/powerpc/kernel/systbl_chk.i := \
  arch/powerpc/kernel/systbl_chk.c \
    $(wildcard include/config/ppc64.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/unistd.h \
    $(wildcard include/config/ppc32.h) \
  include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/lbdaf.h) \
    $(wildcard include/config/phys/addr/t/64bit.h) \
    $(wildcard include/config/64bit.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/types.h \
    $(wildcard include/config/phys/64bit.h) \
  include/asm-generic/int-ll64.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/linux/posix_types.h \
  include/linux/stddef.h \
  include/linux/compiler.h \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  include/linux/compiler-gcc.h \
    $(wildcard include/config/arch/supports/optimized/inlining.h) \
    $(wildcard include/config/optimize/inlining.h) \
  include/linux/compiler-gcc4.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/posix_types.h \
  include/linux/linkage.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/linkage.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/systbl.h \

arch/powerpc/kernel/systbl_chk.i: $(deps_arch/powerpc/kernel/systbl_chk.i)

$(deps_arch/powerpc/kernel/systbl_chk.i):
