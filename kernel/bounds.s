	.file	"bounds.c"

 # rs6000/powerpc options: -mcpu=403 -msdata=data -G 8
 # GNU C version 4.2.2 (powerpc-linux)
 #	compiled by GNU C version 2.96 20000731 (Red Hat Linux 7.3 2.96-113).
 # GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
 # options passed:  -nostdinc
 # -I/tools/dev/repos/linux-2.6-xlnx/arch/powerpc/include -Iinclude
 # -Iarch/powerpc -Iarch/powerpc -imultilib -iprefix -D__unix__
 # -D__gnu_linux__ -D__linux__ -Dunix -D__unix -Dlinux -D__linux
 # -Asystem=linux -Asystem=unix -Asystem=posix -D__KERNEL__
 # -DKBUILD_STR(s)=#s -DKBUILD_BASENAME=KBUILD_STR(bounds)
 # -DKBUILD_MODNAME=KBUILD_STR(bounds) -isystem -include -MD -mcpu=403 -m32
 # -msoft-float -mmultiple -mno-altivec -mno-spe -mspe=no -mno-string
 # -auxbase-strip -g -O2 -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs
 # -Werror-implicit-function-declaration -Wno-format-security
 # -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-aliasing
 # -fno-common -fno-delete-null-pointer-checks -ffixed-r2 -funit-at-a-time
 # -fno-stack-protector -fomit-frame-pointer -fno-strict-overflow
 # -fverbose-asm
 # options enabled:  -falign-loops -fargument-alias -fbranch-count-reg
 # -fcaller-saves -fcprop-registers -fcrossjumping -fcse-follow-jumps
 # -fcse-skip-blocks -fdefer-pop -fearly-inlining
 # -feliminate-unused-debug-types -fexpensive-optimizations -ffunction-cse
 # -fgcse -fgcse-lm -fguess-branch-probability -fident -fif-conversion
 # -fif-conversion2 -finline-functions-called-once -fipa-pure-const
 # -fipa-reference -fipa-type-escape -fivopts -fkeep-static-consts
 # -fleading-underscore -fmath-errno -fmerge-constants
 # -fmove-loop-invariants -fomit-frame-pointer -foptimize-register-move
 # -foptimize-sibling-calls -fpeephole -fpeephole2 -freg-struct-return
 # -fregmove -freorder-blocks -freorder-functions -frerun-cse-after-loop
 # -fsched-interblock -fsched-spec -fsched-stalled-insns-dep
 # -fschedule-insns -fschedule-insns2 -fsection-anchors -fshow-column
 # -fsplit-ivs-in-unroller -fthread-jumps -ftoplevel-reorder
 # -ftrapping-math -ftree-ccp -ftree-ch -ftree-copy-prop -ftree-copyrename
 # -ftree-dce -ftree-dominator-opts -ftree-dse -ftree-fre -ftree-loop-im
 # -ftree-loop-ivcanon -ftree-loop-optimize -ftree-lrs -ftree-pre
 # -ftree-salias -ftree-sink -ftree-sra -ftree-store-ccp
 # -ftree-store-copy-prop -ftree-ter -ftree-vect-loop-version -ftree-vrp
 # -funit-at-a-time -fvar-tracking -fverbose-asm -fzero-initialized-in-bss
 # -m32 -maix-struct-return -mbig -mbig-endian -mbss-plt -mfused-madd
 # -mglibc -mmultiple -mnew-mnemonics -mno-fp-in-toc -mpowerpc
 # -msched-prolog -msoft-float -mstrict-align -mupdate

	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	".text"
.Ltext0:
 # Compiler executable checksum: 1aec0482efbebeb41ccfcf839ce71331

	.align 2
	.globl foo
	.type	foo, @function
foo:
.LFB6:
	.file 1 "kernel/bounds.c"
	.loc 1 14 0
	.loc 1 16 0
#APP
	
->NR_PAGEFLAGS 23 __NR_PAGEFLAGS	 #
	.loc 1 17 0
	
->MAX_NR_ZONES 3 __MAX_NR_ZONES	 #
	.loc 1 19 0
#NO_APP
	blr	 #
.LFE6:
	.size	foo, .-foo
	.section	.debug_frame,"",@progbits
.Lframe0:
	.4byte	.LECIE0-.LSCIE0
.LSCIE0:
	.4byte	0xffffffff
	.byte	0x1
	.string	""
	.uleb128 0x1
	.sleb128 -4
	.byte	0x41
	.byte	0xc
	.uleb128 0x1
	.uleb128 0x0
	.align 2
.LECIE0:
.LSFDE0:
	.4byte	.LEFDE0-.LASFDE0
.LASFDE0:
	.4byte	.Lframe0
	.4byte	.LFB6
	.4byte	.LFE6-.LFB6
	.align 2
.LEFDE0:
	.section	".text"
.Letext0:
	.file 2 "include/linux/page-flags.h"
	.file 3 "include/linux/mmzone.h"
	.section	.debug_info
	.4byte	0x178
	.2byte	0x2
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF48
	.byte	0x1
	.4byte	.LASF49
	.4byte	.LASF50
	.4byte	.Ltext0
	.4byte	.Letext0
	.4byte	.Ldebug_line0
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.4byte	.LASF0
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF1
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.4byte	.LASF2
	.uleb128 0x2
	.byte	0x2
	.byte	0x7
	.4byte	.LASF3
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.4byte	.LASF4
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.4byte	.LASF5
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.4byte	.LASF6
	.uleb128 0x4
	.byte	0x4
	.byte	0x7
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.4byte	.LASF7
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF8
	.uleb128 0x2
	.byte	0x4
	.byte	0x5
	.4byte	.LASF9
	.uleb128 0x2
	.byte	0x1
	.byte	0x2
	.4byte	.LASF10
	.uleb128 0x5
	.4byte	.LASF42
	.byte	0x4
	.byte	0x2
	.byte	0x4b
	.4byte	0x143
	.uleb128 0x6
	.4byte	.LASF11
	.sleb128 0
	.uleb128 0x6
	.4byte	.LASF12
	.sleb128 1
	.uleb128 0x6
	.4byte	.LASF13
	.sleb128 2
	.uleb128 0x6
	.4byte	.LASF14
	.sleb128 3
	.uleb128 0x6
	.4byte	.LASF15
	.sleb128 4
	.uleb128 0x6
	.4byte	.LASF16
	.sleb128 5
	.uleb128 0x6
	.4byte	.LASF17
	.sleb128 6
	.uleb128 0x6
	.4byte	.LASF18
	.sleb128 7
	.uleb128 0x6
	.4byte	.LASF19
	.sleb128 8
	.uleb128 0x6
	.4byte	.LASF20
	.sleb128 9
	.uleb128 0x6
	.4byte	.LASF21
	.sleb128 10
	.uleb128 0x6
	.4byte	.LASF22
	.sleb128 11
	.uleb128 0x6
	.4byte	.LASF23
	.sleb128 12
	.uleb128 0x6
	.4byte	.LASF24
	.sleb128 13
	.uleb128 0x6
	.4byte	.LASF25
	.sleb128 14
	.uleb128 0x6
	.4byte	.LASF26
	.sleb128 15
	.uleb128 0x6
	.4byte	.LASF27
	.sleb128 16
	.uleb128 0x6
	.4byte	.LASF28
	.sleb128 17
	.uleb128 0x6
	.4byte	.LASF29
	.sleb128 18
	.uleb128 0x6
	.4byte	.LASF30
	.sleb128 19
	.uleb128 0x6
	.4byte	.LASF31
	.sleb128 20
	.uleb128 0x6
	.4byte	.LASF32
	.sleb128 21
	.uleb128 0x6
	.4byte	.LASF33
	.sleb128 22
	.uleb128 0x6
	.4byte	.LASF34
	.sleb128 23
	.uleb128 0x6
	.4byte	.LASF35
	.sleb128 8
	.uleb128 0x6
	.4byte	.LASF36
	.sleb128 12
	.uleb128 0x6
	.4byte	.LASF37
	.sleb128 8
	.uleb128 0x6
	.4byte	.LASF38
	.sleb128 4
	.uleb128 0x6
	.4byte	.LASF39
	.sleb128 11
	.uleb128 0x6
	.4byte	.LASF40
	.sleb128 6
	.uleb128 0x6
	.4byte	.LASF41
	.sleb128 1
	.byte	0x0
	.uleb128 0x5
	.4byte	.LASF43
	.byte	0x4
	.byte	0x3
	.byte	0xc5
	.4byte	0x168
	.uleb128 0x6
	.4byte	.LASF44
	.sleb128 0
	.uleb128 0x6
	.4byte	.LASF45
	.sleb128 1
	.uleb128 0x6
	.4byte	.LASF46
	.sleb128 2
	.uleb128 0x6
	.4byte	.LASF47
	.sleb128 3
	.byte	0x0
	.uleb128 0x7
	.byte	0x1
	.string	"foo"
	.byte	0x1
	.byte	0xe
	.byte	0x1
	.4byte	.LFB6
	.4byte	.LFE6
	.byte	0x1
	.byte	0x51
	.byte	0x0
	.section	.debug_abbrev
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x10
	.uleb128 0x6
	.byte	0x0
	.byte	0x0
	.uleb128 0x2
	.uleb128 0x24
	.byte	0x0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0x0
	.byte	0x0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0x0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0x0
	.byte	0x0
	.uleb128 0x4
	.uleb128 0x24
	.byte	0x0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.byte	0x0
	.byte	0x0
	.uleb128 0x5
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0x0
	.byte	0x0
	.uleb128 0x6
	.uleb128 0x28
	.byte	0x0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xd
	.byte	0x0
	.byte	0x0
	.uleb128 0x7
	.uleb128 0x2e
	.byte	0x0
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0xc
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x40
	.uleb128 0xa
	.byte	0x0
	.byte	0x0
	.byte	0x0
	.section	.debug_pubnames,"",@progbits
	.4byte	0x16
	.2byte	0x2
	.4byte	.Ldebug_info0
	.4byte	0x17c
	.4byte	0x168
	.string	"foo"
	.4byte	0x0
	.section	.debug_aranges,"",@progbits
	.4byte	0x1c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0x0
	.2byte	0x0
	.2byte	0x0
	.4byte	.Ltext0
	.4byte	.Letext0-.Ltext0
	.4byte	0x0
	.4byte	0x0
	.section	.debug_str,"MS",@progbits,1
.LASF25:
	.string	"PG_head"
.LASF48:
	.string	"GNU C 4.2.2"
.LASF21:
	.string	"PG_reserved"
.LASF45:
	.string	"ZONE_NORMAL"
.LASF28:
	.string	"PG_mappedtodisk"
.LASF39:
	.string	"PG_slob_free"
.LASF11:
	.string	"PG_locked"
.LASF15:
	.string	"PG_dirty"
.LASF24:
	.string	"PG_writeback"
.LASF22:
	.string	"PG_private"
.LASF34:
	.string	"__NR_PAGEFLAGS"
.LASF47:
	.string	"__MAX_NR_ZONES"
.LASF36:
	.string	"PG_fscache"
.LASF13:
	.string	"PG_referenced"
.LASF27:
	.string	"PG_swapcache"
.LASF43:
	.string	"zone_type"
.LASF7:
	.string	"long unsigned int"
.LASF3:
	.string	"short unsigned int"
.LASF31:
	.string	"PG_swapbacked"
.LASF35:
	.string	"PG_checked"
.LASF1:
	.string	"unsigned char"
.LASF49:
	.string	"kernel/bounds.c"
.LASF26:
	.string	"PG_tail"
.LASF42:
	.string	"pageflags"
.LASF4:
	.string	"unsigned int"
.LASF50:
	.string	"/tools/dev/repos/linux-2.6-xlnx"
.LASF12:
	.string	"PG_error"
.LASF6:
	.string	"long long unsigned int"
.LASF37:
	.string	"PG_pinned"
.LASF18:
	.string	"PG_slab"
.LASF19:
	.string	"PG_owner_priv_1"
.LASF17:
	.string	"PG_active"
.LASF23:
	.string	"PG_private_2"
.LASF5:
	.string	"long long int"
.LASF16:
	.string	"PG_lru"
.LASF8:
	.string	"char"
.LASF32:
	.string	"PG_unevictable"
.LASF38:
	.string	"PG_savepinned"
.LASF14:
	.string	"PG_uptodate"
.LASF40:
	.string	"PG_slub_frozen"
.LASF41:
	.string	"PG_slub_debug"
.LASF2:
	.string	"short int"
.LASF20:
	.string	"PG_arch_1"
.LASF9:
	.string	"long int"
.LASF46:
	.string	"ZONE_MOVABLE"
.LASF30:
	.string	"PG_buddy"
.LASF0:
	.string	"signed char"
.LASF29:
	.string	"PG_reclaim"
.LASF10:
	.string	"_Bool"
.LASF33:
	.string	"PG_mlocked"
.LASF44:
	.string	"ZONE_DMA"
	.ident	"GCC: (GNU) 4.2.2"
	.section	.note.GNU-stack,"",@progbits
