cmd_arch/powerpc/boot/ps3-head.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.ps3-head.o.d -D__ASSEMBLY__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -traditional -nostdinc -c -o arch/powerpc/boot/ps3-head.o arch/powerpc/boot/ps3-head.S

deps_arch/powerpc/boot/ps3-head.o := \
  arch/powerpc/boot/ps3-head.S \
  arch/powerpc/boot/ppc_asm.h \

arch/powerpc/boot/ps3-head.o: $(deps_arch/powerpc/boot/ps3-head.o)

$(deps_arch/powerpc/boot/ps3-head.o):
