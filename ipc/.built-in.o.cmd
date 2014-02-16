cmd_ipc/built-in.o :=  ppc_4xx-ld -m elf32ppc    -r -o ipc/built-in.o ipc/util.o ipc/msgutil.o ipc/msg.o ipc/sem.o ipc/shm.o ipc/ipcns_notifier.o ipc/ipc_sysctl.o ipc/mqueue.o ipc/mq_sysctl.o 
