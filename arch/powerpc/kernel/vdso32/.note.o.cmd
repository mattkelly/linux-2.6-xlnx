cmd_arch/powerpc/kernel/vdso32/note.o := ppc_4xx-gcc -m32 -Wp,-MD,arch/powerpc/kernel/vdso32/.note.o.d  -nostdinc -isystem /tools/dev/eldk/usr/bin/../lib/gcc/powerpc-linux/4.2.2/include -I/home/nlp3276/git/linux-2.6-xlnx/arch/powerpc/include -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -Iarch/powerpc -D__ASSEMBLY__ -Iarch/powerpc -Wa,-m405 -gdwarf-2     -D__VDSO32__ -s   -c -o arch/powerpc/kernel/vdso32/note.o arch/powerpc/kernel/vdso32/note.S

deps_arch/powerpc/kernel/vdso32/note.o := \
  arch/powerpc/kernel/vdso32/note.S \
  include/linux/uts.h \
  include/linux/version.h \

arch/powerpc/kernel/vdso32/note.o: $(deps_arch/powerpc/kernel/vdso32/note.o)

$(deps_arch/powerpc/kernel/vdso32/note.o):
