cmd_net/unix/unix.o := ppc_4xx-ld -m elf32ppc    -r -o net/unix/unix.o net/unix/af_unix.o net/unix/garbage.o net/unix/sysctl_net_unix.o 
