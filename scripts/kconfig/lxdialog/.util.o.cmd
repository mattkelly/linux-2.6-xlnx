cmd_scripts/kconfig/lxdialog/util.o := gcc -Wp,-MD,scripts/kconfig/lxdialog/.util.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer   -I/usr/include/ncurses -DCURSES_LOC="<ncurses.h>" -DLOCALE   -c -o scripts/kconfig/lxdialog/util.o scripts/kconfig/lxdialog/util.c

deps_scripts/kconfig/lxdialog/util.o := \
  scripts/kconfig/lxdialog/util.c \
    $(wildcard include/config/color.h) \
  /usr/lib/gcc/x86_64-redhat-linux/4.1.2/include/stdarg.h \
  scripts/kconfig/lxdialog/dialog.h \
  /usr/include/sys/types.h \
  /usr/include/features.h \
  /usr/include/sys/cdefs.h \
  /usr/include/bits/wordsize.h \
  /usr/include/gnu/stubs.h \
  /usr/include/gnu/stubs-64.h \
  /usr/include/bits/types.h \
  /usr/lib/gcc/x86_64-redhat-linux/4.1.2/include/stddef.h \
  /usr/include/bits/typesizes.h \
  /usr/include/time.h \
  /usr/include/endian.h \
  /usr/include/bits/endian.h \
  /usr/include/sys/select.h \
  /usr/include/bits/select.h \
  /usr/include/bits/sigset.h \
  /usr/include/bits/time.h \
  /usr/include/sys/sysmacros.h \
  /usr/include/bits/pthreadtypes.h \
  /usr/include/fcntl.h \
  /usr/include/bits/fcntl.h \
  /usr/include/unistd.h \
  /usr/include/bits/posix_opt.h \
  /usr/include/bits/confname.h \
  /usr/include/getopt.h \
  /usr/include/ctype.h \
  /usr/include/stdlib.h \
  /usr/include/alloca.h \
  /usr/include/string.h \
  /usr/include/bits/string.h \
  /usr/include/bits/string2.h \
  /usr/lib/gcc/x86_64-redhat-linux/4.1.2/include/stdbool.h \
  /usr/include/libintl.h \
  /usr/include/locale.h \
  /usr/include/bits/locale.h \
  /usr/include/ncurses/ncurses.h \
  /usr/include/ncurses/ncurses_dll.h \
  /usr/include/stdio.h \
  /usr/include/libio.h \
  /usr/include/_G_config.h \
  /usr/include/wchar.h \
  /usr/include/bits/wchar.h \
  /usr/include/gconv.h \
  /usr/include/bits/stdio_lim.h \
  /usr/include/bits/sys_errlist.h \
  /usr/include/bits/stdio.h \
  /usr/include/ncurses/unctrl.h \
  /usr/include/ncurses/curses.h \

scripts/kconfig/lxdialog/util.o: $(deps_scripts/kconfig/lxdialog/util.o)

$(deps_scripts/kconfig/lxdialog/util.o):
