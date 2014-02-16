cmd_drivers/xilinx_common/xdma_channel_sg.o := ppc_4xx-gcc -m32 -Wp,-MD,drivers/xilinx_common/.xdma_channel_sg.o.d  -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Iarch/powerpc -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -O2 -msoft-float -pipe -Iarch/powerpc -ffixed-r2 -mmultiple -mno-altivec -mno-spe -mspe=no -funit-at-a-time -mno-string -Wa,-m405 -fno-stack-protector -fomit-frame-pointer -g -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow   -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(xdma_channel_sg)"  -D"KBUILD_MODNAME=KBUILD_STR(xdma_channel_sg)"  -c -o drivers/xilinx_common/.tmp_xdma_channel_sg.o drivers/xilinx_common/xdma_channel_sg.c

deps_drivers/xilinx_common/xdma_channel_sg.o := \
  drivers/xilinx_common/xdma_channel_sg.c \
  drivers/xilinx_common/xdma_channel.h \
  drivers/xilinx_common/xbasic_types.h \
  include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/lbdaf.h) \
    $(wildcard include/config/phys/addr/t/64bit.h) \
    $(wildcard include/config/64bit.h) \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/types.h \
    $(wildcard include/config/phys/64bit.h) \
  include/asm-generic/int-ll64.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/linux/posix_types.h \
  include/linux/stddef.h \
  include/linux/compiler.h \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  include/linux/compiler-gcc.h \
    $(wildcard include/config/arch/supports/optimized/inlining.h) \
    $(wildcard include/config/optimize/inlining.h) \
  include/linux/compiler-gcc4.h \
  /tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include/asm/posix_types.h \
  drivers/xilinx_common/xstatus.h \
    $(wildcard include/config/error.h) \
  drivers/xilinx_common/xversion.h \
  drivers/xilinx_common/xbuf_descriptor.h \
  drivers/xilinx_common/xdma_channel_i.h \
  drivers/xilinx_common/xio.h \
    $(wildcard include/config/ppc.h) \

drivers/xilinx_common/xdma_channel_sg.o: $(deps_drivers/xilinx_common/xdma_channel_sg.o)

$(deps_drivers/xilinx_common/xdma_channel_sg.o):
