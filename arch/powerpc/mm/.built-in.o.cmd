cmd_arch/powerpc/mm/built-in.o :=  ppc_4xx-ld -m elf32ppc    -r -o arch/powerpc/mm/built-in.o arch/powerpc/mm/fault.o arch/powerpc/mm/mem.o arch/powerpc/mm/pgtable.o arch/powerpc/mm/gup.o arch/powerpc/mm/init_32.o arch/powerpc/mm/pgtable_32.o arch/powerpc/mm/mmu_context_nohash.o arch/powerpc/mm/tlb_nohash.o arch/powerpc/mm/tlb_nohash_low.o arch/powerpc/mm/44x_mmu.o arch/powerpc/mm/dma-noncoherent.o 