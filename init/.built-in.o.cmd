cmd_init/built-in.o :=  ppc_4xx-ld -m elf32ppc    -r -o init/built-in.o init/main.o init/version.o init/mounts.o init/initramfs.o 
