cmd_arch/powerpc/boot/inffast.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.inffast.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/inffast.o arch/powerpc/boot/inffast.c

deps_arch/powerpc/boot/inffast.o := \
  arch/powerpc/boot/inffast.c \
    $(wildcard include/config/have/efficient/unaligned/access.h) \
  arch/powerpc/boot/zutil.h \
  arch/powerpc/boot/zlib.h \
  arch/powerpc/boot/zconf.h \
  arch/powerpc/boot/string.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stddef.h \
  arch/powerpc/boot/inftrees.h \
  arch/powerpc/boot/inflate.h \
  arch/powerpc/boot/inffast.h \

arch/powerpc/boot/inffast.o: $(deps_arch/powerpc/boot/inffast.o)

$(deps_arch/powerpc/boot/inffast.o):
