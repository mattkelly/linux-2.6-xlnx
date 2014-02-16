cmd_fs/fat/built-in.o :=  ppc_4xx-ld -m elf32ppc    -r -o fs/fat/built-in.o fs/fat/fat.o fs/fat/vfat.o fs/fat/msdos.o 
