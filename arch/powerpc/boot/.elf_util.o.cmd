cmd_arch/powerpc/boot/elf_util.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.elf_util.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/elf_util.o arch/powerpc/boot/elf_util.c

deps_arch/powerpc/boot/elf_util.o := \
  arch/powerpc/boot/elf_util.c \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stdarg.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stddef.h \
  arch/powerpc/boot/elf.h \
  arch/powerpc/boot/page.h \
  arch/powerpc/boot/string.h \
  arch/powerpc/boot/stdio.h \

arch/powerpc/boot/elf_util.o: $(deps_arch/powerpc/boot/elf_util.o)

$(deps_arch/powerpc/boot/elf_util.o):
