cmd_drivers/i2c/built-in.o :=  ppc_4xx-ld -m elf32ppc    -r -o drivers/i2c/built-in.o drivers/i2c/busses/built-in.o drivers/i2c/chips/built-in.o drivers/i2c/algos/built-in.o 
