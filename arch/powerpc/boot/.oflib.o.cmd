cmd_arch/powerpc/boot/oflib.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.oflib.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/oflib.o arch/powerpc/boot/oflib.c

deps_arch/powerpc/boot/oflib.o := \
  arch/powerpc/boot/oflib.c \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stddef.h \
  arch/powerpc/boot/types.h \
  arch/powerpc/boot/elf.h \
  arch/powerpc/boot/string.h \
  arch/powerpc/boot/stdio.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stdarg.h \
  arch/powerpc/boot/page.h \
  arch/powerpc/boot/ops.h \
  arch/powerpc/boot/of.h \

arch/powerpc/boot/oflib.o: $(deps_arch/powerpc/boot/oflib.o)

$(deps_arch/powerpc/boot/oflib.o):
