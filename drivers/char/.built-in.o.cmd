cmd_drivers/char/built-in.o :=  ppc_4xx-ld -m elf32ppc    -r -o drivers/char/built-in.o drivers/char/mem.o drivers/char/random.o drivers/char/tty_io.o drivers/char/n_tty.o drivers/char/tty_ioctl.o drivers/char/tty_ldisc.o drivers/char/tty_buffer.o drivers/char/tty_port.o drivers/char/pty.o drivers/char/misc.o drivers/char/vt_ioctl.o drivers/char/vc_screen.o drivers/char/selection.o drivers/char/keyboard.o drivers/char/consolemap.o drivers/char/consolemap_deftbl.o drivers/char/vt.o drivers/char/defkeymap.o drivers/char/rit_fifo/built-in.o drivers/char/rit_ll_accel/built-in.o 
