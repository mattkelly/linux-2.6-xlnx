cmd_arch/powerpc/boot/bamboo.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.bamboo.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/bamboo.o arch/powerpc/boot/bamboo.c

deps_arch/powerpc/boot/bamboo.o := \
  arch/powerpc/boot/bamboo.c \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stdarg.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stddef.h \
  arch/powerpc/boot/types.h \
  arch/powerpc/boot/elf.h \
  arch/powerpc/boot/string.h \
  arch/powerpc/boot/stdio.h \
  arch/powerpc/boot/page.h \
  arch/powerpc/boot/ops.h \
  arch/powerpc/boot/dcr.h \
    $(wildcard include/config/bank/enable.h) \
    $(wildcard include/config/size/mask.h) \
    $(wildcard include/config/bank/size.h) \
    $(wildcard include/config/addr.h) \
    $(wildcard include/config/data.h) \
  arch/powerpc/boot/4xx.h \
  arch/powerpc/boot/44x.h \

arch/powerpc/boot/bamboo.o: $(deps_arch/powerpc/boot/bamboo.o)

$(deps_arch/powerpc/boot/bamboo.o):
