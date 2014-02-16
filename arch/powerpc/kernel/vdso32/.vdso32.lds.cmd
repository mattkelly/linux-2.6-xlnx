cmd_arch/powerpc/kernel/vdso32/vdso32.lds := ppc_4xx-gcc -m32 -E -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -O2 -msoft-float -pipe -Iarch/powerpc -ffixed-r2 -mmultiple -mno-altivec -mno-spe -mspe=no -funit-at-a-time -mno-string -Wa,-m405   -fno-stack-protector -fomit-frame-pointer -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow   -Wp,-MD,arch/powerpc/kernel/vdso32/.vdso32.lds.d  -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Iarch/powerpc   -P -C -Upowerpc -P -C -Upowerpc -D__ASSEMBLY__ -DLINKER_SCRIPT -o arch/powerpc/kernel/vdso32/vdso32.lds arch/powerpc/kernel/vdso32/vdso32.lds.S

deps_arch/powerpc/kernel/vdso32/vdso32.lds := \
  arch/powerpc/kernel/vdso32/vdso32.lds.S \
    $(wildcard include/config/ppc64.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/vdso.h \

arch/powerpc/kernel/vdso32/vdso32.lds: $(deps_arch/powerpc/kernel/vdso32/vdso32.lds)

$(deps_arch/powerpc/kernel/vdso32/vdso32.lds):
