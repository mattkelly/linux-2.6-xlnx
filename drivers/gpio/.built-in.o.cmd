cmd_drivers/gpio/built-in.o :=  ppc_4xx-ld -m elf32ppc    -r -o drivers/gpio/built-in.o drivers/gpio/gpiolib.o drivers/gpio/xilinx_gpio.o 
