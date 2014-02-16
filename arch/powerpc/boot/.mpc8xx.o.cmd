cmd_arch/powerpc/boot/mpc8xx.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.mpc8xx.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/mpc8xx.o arch/powerpc/boot/mpc8xx.c

deps_arch/powerpc/boot/mpc8xx.o := \
  arch/powerpc/boot/mpc8xx.c \
  arch/powerpc/boot/ops.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stddef.h \
  arch/powerpc/boot/types.h \
  arch/powerpc/boot/string.h \
  arch/powerpc/boot/fsl-soc.h \
  arch/powerpc/boot/mpc8xx.h \
  arch/powerpc/boot/stdio.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stdarg.h \
  arch/powerpc/boot/io.h \

arch/powerpc/boot/mpc8xx.o: $(deps_arch/powerpc/boot/mpc8xx.o)

$(deps_arch/powerpc/boot/mpc8xx.o):
