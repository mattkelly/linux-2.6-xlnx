cmd_drivers/video/console/built-in.o :=  ppc_4xx-ld -m elf32ppc    -r -o drivers/video/console/built-in.o drivers/video/console/dummycon.o drivers/video/console/fbcon.o drivers/video/console/bitblit.o drivers/video/console/font.o drivers/video/console/softcursor.o 