cmd_arch/powerpc/boot/inftrees.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.inftrees.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/inftrees.o arch/powerpc/boot/inftrees.c

deps_arch/powerpc/boot/inftrees.o := \
  arch/powerpc/boot/inftrees.c \
  arch/powerpc/boot/zutil.h \
  arch/powerpc/boot/zlib.h \
  arch/powerpc/boot/zconf.h \
  arch/powerpc/boot/string.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stddef.h \
  arch/powerpc/boot/inftrees.h \

arch/powerpc/boot/inftrees.o: $(deps_arch/powerpc/boot/inftrees.o)

$(deps_arch/powerpc/boot/inftrees.o):
