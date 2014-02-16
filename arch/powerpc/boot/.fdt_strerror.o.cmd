cmd_arch/powerpc/boot/fdt_strerror.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/boot/.fdt_strerror.o.d -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -Os -msoft-float -pipe -fomit-frame-pointer -fno-builtin -fPIC -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -g -fno-stack-protector -Iarch/powerpc/boot -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/boot -c -o arch/powerpc/boot/fdt_strerror.o arch/powerpc/boot/fdt_strerror.c

deps_arch/powerpc/boot/fdt_strerror.o := \
  arch/powerpc/boot/fdt_strerror.c \
  arch/powerpc/boot/libfdt_env.h \
  arch/powerpc/boot/types.h \
  arch/powerpc/boot/string.h \
  /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include/stddef.h \
  arch/powerpc/boot/fdt.h \
  arch/powerpc/boot/libfdt.h \
  arch/powerpc/boot/libfdt_env.h \
  arch/powerpc/boot/libfdt_internal.h \

arch/powerpc/boot/fdt_strerror.o: $(deps_arch/powerpc/boot/fdt_strerror.o)

$(deps_arch/powerpc/boot/fdt_strerror.o):
