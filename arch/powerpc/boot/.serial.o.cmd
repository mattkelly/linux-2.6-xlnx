cmd_arch/powerpc/boot/serial.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.serial.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/serial.o arch/powerpc/boot/serial.c

deps_arch/powerpc/boot/serial.o := \
  arch/powerpc/boot/serial.c \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stdarg.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stddef.h \
  arch/powerpc/boot/types.h \
  arch/powerpc/boot/string.h \
  arch/powerpc/boot/stdio.h \
  arch/powerpc/boot/io.h \
  arch/powerpc/boot/ops.h \

arch/powerpc/boot/serial.o: $(deps_arch/powerpc/boot/serial.o)

$(deps_arch/powerpc/boot/serial.o):
