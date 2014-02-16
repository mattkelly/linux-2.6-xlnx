cmd_arch/powerpc/boot/stdlib.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.stdlib.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/stdlib.o arch/powerpc/boot/stdlib.c

deps_arch/powerpc/boot/stdlib.o := \
  arch/powerpc/boot/stdlib.c \
  arch/powerpc/boot/stdlib.h \

arch/powerpc/boot/stdlib.o: $(deps_arch/powerpc/boot/stdlib.o)

$(deps_arch/powerpc/boot/stdlib.o):
