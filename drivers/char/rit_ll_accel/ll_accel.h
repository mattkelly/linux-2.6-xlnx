/*****************************************************************************
 *
 *     Author: Nick Palladino
 *
 *     This program is free software; you can redistribute it and/or modify it
 *     under the terms of the GNU General Public License as published by the
 *     Free Software Foundation; either version 2 of the License, or (at your
 *     option) any later version.
 *
 *     You should have received a copy of the GNU General Public License along
 *     with this program; if not, write to the Free Software Foundation, Inc.,
 *     675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *****************************************************************************/

#ifndef __RIT_DRIVER_H__
#define __RIT_DRIVER_H__

#include <linux/ioctl.h> 
#include <linux/wait.h>
#include <linux/types.h>
#include <linux/spinlock.h>
#include "xlldma.h"

#define LL_ACCEL_MAJOR	0
#define LL_ACCEL_MINOR	0
#define LL_ACCEL_NR_DEVS	4

/*****************************************************************************
 * PLB Slave Registers (Debug/Status)
 *****************************************************************************/
#define LL_ACCEL_APP1_REG				0x000
#define LL_ACCEL_APP2_REG				0x004
#define LL_ACCEL_APP3_REG				0x008
#define LL_ACCEL_APP4_REG				0x00C
#define LL_ACCEL_APP5_REG				0x010

#define LL_ACCEL_FIFO1_CNT_REG	0x010
#define LL_ACCEL_FIFO2_CNT_REG	0x014
#define LL_ACCEL_FIFO3_CNT_REG	0x018
#define LL_ACCEL_FIFO4_CNT_REG	0x01C

/*****************************************************************************
 * Ioctl definitions
 *****************************************************************************/

/* Use 'x' as magic number */
#define LL_ACCEL_IOC_MAGIC  'x'
#define LL_ACCEL_IOCRESET    _IO(LL_ACCEL_IOC_MAGIC, 0)

/*
 * S means "Set" through a ptr,
 * T means "Tell" directly with the argument value
 * G means "Get": reply by setting through a pointer
 * Q means "Query": response is on the return value
 */
#define LL_ACCEL_IOCSBITSTREAM 	_IOW(LL_ACCEL_IOC_MAGIC, 1, bitstream_t*)
//#define LL_ACCEL_RESET					_IOW(LL_ACCEL_IOC_MAGIC,  2)

#define LL_ACCEL_IOC_MAXNR 14

/* DMA Defines */

/* SGDMA buffer descriptors must be aligned on a 8-byte boundary. */
#define ALIGNMENT_BD       XLLDMA_BD_MINIMUM_ALIGNMENT
/*
 * Default SEND and RECV buffer descriptors (BD) counts
 * BD Space needed is (XLL_SEND_BD_CNT+XLL_RECV_BD_CNT)*Sizeof(XLlDma_Bd).
 * Each XLlDma_Bd instance currently takes 40 bytes.
 */
#define XLL_SEND_BD_CNT    16
#define XLL_RECV_BD_CNT    16

#define LL_EX_BUF_SIZE     0x2000 // was 0x400 /* 8192 Bytes receive buffer size */
#define LL_EX_MIN_BUF_SIZE 5     /* Minumum buffer size supported by core */

/* Default TX/RX Threshold and waitbound values for SGDMA */
#define DFT_TX_THRESHOLD   1
#define DFT_TX_WAITBOUND   254
#define DFT_RX_THRESHOLD   1
#define DFT_RX_WAITBOUND   254

#define XLL_DMA_DCR_BASE   0x98  /* ML507 HDMA 0 DCR base address -> 
																	  changed for DMA1 DCR on ML510 */

/*
 * Location in the receive descriptor where the core will
 * place the number of valid bytes in a receive buffer.
 */
#define BdGetRxLen(BdPtr) \
    XLlDma_mBdRead((BdPtr), XLLDMA_BD_USR4_OFFSET)

/* Used for parsing bitstream header */
#define XHI_EVEN_MAGIC_BYTE     0x0f
#define XHI_ODD_MAGIC_BYTE      0xf0

/* Extra mode for IDLE */
#define XHI_OP_IDLE  -1
#define XHI_BIT_HEADER_FAILURE -1

/* The imaginary module length register */
#define XHI_MLR                  15

// Software-controlled Reset Offset
#define SOFT_RST_OFFSET   (0x00000100)

// Common Reset Mask
#define RESET_MASK (0x0000000A)

// Interrupt Generator Offsets
#define INTR_SPACE_OFFSET (0x00000200)
#define INTR_DISR_OFFSET  (INTR_SPACE_OFFSET + 0x00000000)
#define INTR_DIER_OFFSET  (INTR_SPACE_OFFSET + 0x00000008)
#define INTR_DGIER_OFFSET (INTR_SPACE_OFFSET + 0x0000001C)
#define INTR_IPISR_OFFSET (INTR_SPACE_OFFSET + 0x00000020)
#define INTR_IPIER_OFFSET (INTR_SPACE_OFFSET + 0x00000028)


/*****************************************************************************
 * HWICAP
 *****************************************************************************/

/* Configuration Commands */
#define XHI_CMD_NULL                0
#define XHI_CMD_WCFG                1
#define XHI_CMD_MFW                 2
#define XHI_CMD_DGHIGH              3
#define XHI_CMD_RCFG                4
#define XHI_CMD_START               5
#define XHI_CMD_RCAP                6
#define XHI_CMD_RCRC                7
#define XHI_CMD_AGHIGH              8
#define XHI_CMD_SWITCH              9
#define XHI_CMD_GRESTORE            10
#define XHI_CMD_SHUTDOWN            11
#define XHI_CMD_GCAPTURE            12
#define XHI_CMD_DESYNCH             13
#define XHI_CMD_IPROG               15 /* Only in Virtex5 */
#define XHI_CMD_CRCC                16 /* Only in Virtex5 */
#define XHI_CMD_LTIMER              17 /* Only in Virtex5 */

/* Packet constants */
#define XHI_SYNC_PACKET             0xAA995566UL
#define XHI_DUMMY_PACKET            0xFFFFFFFFUL
#define XHI_NOOP_PACKET             (XHI_TYPE_1 << XHI_TYPE_SHIFT)
#define XHI_TYPE_2_READ ((XHI_TYPE_2 << XHI_TYPE_SHIFT) | \
			(XHI_OP_READ << XHI_OP_SHIFT))

#define XHI_TYPE_2_WRITE ((XHI_TYPE_2 << XHI_TYPE_SHIFT) | \
			(XHI_OP_WRITE << XHI_OP_SHIFT))

#define XHI_TYPE2_CNT_MASK          0x07FFFFFF

#define XHI_TYPE_1_PACKET_MAX_WORDS 2047UL
#define XHI_TYPE_1_HEADER_BYTES     4
#define XHI_TYPE_2_HEADER_BYTES     8

/* Constant to use for CRC check when CRC has been disabled */
#define XHI_DISABLED_AUTO_CRC       0x0000DEFCUL

/* Meanings of the bits returned by get_status */
#define XHI_SR_CFGERR_N_MASK 0x00000100 /* Config Error Mask */
#define XHI_SR_DALIGN_MASK 0x00000080 /* Data Alignment Mask */
#define XHI_SR_RIP_MASK 0x00000040 /* Read back Mask */
#define XHI_SR_IN_ABORT_N_MASK 0x00000020 /* Select Map Abort Mask */
#define XHI_SR_DONE_MASK 0x00000001 /* Done bit Mask  */


/************ Constant Definitions *************/

#define XHI_PAD_FRAMES              0x1
#define XHI_DEVICE_ID_CODE_MASK		0x0FFFFFFF

/* Mask for calculating configuration packet headers */
#define XHI_WORD_COUNT_MASK_TYPE_1  0x7FFUL
#define XHI_WORD_COUNT_MASK_TYPE_2  0x1FFFFFUL
#define XHI_TYPE_MASK               0x7
#define XHI_REGISTER_MASK           0xF
#define XHI_OP_MASK                 0x3

#define XHI_TYPE_SHIFT              29
#define XHI_REGISTER_SHIFT          13
#define XHI_OP_SHIFT                27

#define XHI_TYPE_1                  1
#define XHI_TYPE_2                  2
#define XHI_OP_WRITE                2
#define XHI_OP_READ                 1


/**
* This typedef contains bitstream header information.
*/
typedef struct
{
    unsigned int header_length;     /* Length of header in 32 bit words */
    unsigned int bitstream_length;   /* Length of bitstream to read in bytes*/
    unsigned char *design_name;     /* Design name read from bitstream header */
    unsigned char *part_name;       /* Part name read from bitstream header */
    unsigned char *data;            /* Date read from bitstream header */
    unsigned char *time;            /* Bitstream creation time read from header */
    unsigned int magic_length;      /* Length of the magic numbers in header */

} bit_header_t;

typedef struct
{
    unsigned int size;
    unsigned char *data;
} bitstream_t;


/*
 * A list of receive buffers awaiting a read request from user space.
 */
struct llex_rx_buff
{
    struct list_head list;

    size_t  data_len;
    /*
     * The actual buffer data immediately follows this structure.  It must
     * be cache line aligned as the buffer is in cached memory, and
     * dma_map_single() / dma_unmap_single() perform cache management. This
     * structure can be corrupted by unintended cache operations if it falls
     * in the same cache line as the buffer data.
     */
    ____cacheline_aligned char    data[0];
};



struct dma_channel {
	/* DMA fields */
	XLlDma Dma;
  /* Buffer Descriptor space for both TX and RX BD ring */
  void            *desc_virtaddr;    /* virtual address of BD space */
  dma_addr_t       desc_physaddr;    /* physical address of BD space */

	unsigned         dma_rx_irq, dma_tx_irq; /* Virtual IRQ numbers for DMA */
  unsigned         dma_addr;         /* Address of DMA controller */

	struct mutex     mutex;						 /* Used for sharing channel */
  
  struct mutex     read_mutex;	
  struct mutex     write_mutex;	
  spinlock_t       lock;
  unsigned long    lock_flags;

	/*
   * DMA statistics
   */

	u32  tx_irq;
  u32  rx_irq;
  u32  errors;

};

struct plb_info {
	void            *mapaddr;          /* virtual address of ll example core */
  unsigned         physaddr;         /* bus address aof ll example core */
  unsigned         addrsize;         /* Size of periph. address space */
	int 						 virq;
	//wait_queue_head_t wait_queue; // Wait Queue for sleeping on interrupts
  //int read_ready;		// Ready flag for interrupts

  //struct mutex    mutex;

};

struct ll_accel_dev {

	// may be possible to have own channel eventually, for now shared channel
	struct dma_channel *dma;

	// Each accelerator has it's own rx list that packets are appended to
	struct list_head rx_buffer_list;   /* RX Buffers awaiting user read */
  size_t           read_off;         /* offset into present buffer */


  /*
   * Number of present device readers (max 1)
   */
  int              readers;
  /*
   * Number of present device writers (max 1)
   */
  int              writers;

	struct mutex mutex;
	//struct semaphore sem;     /* mutual exclusion semaphore     */
	struct cdev cdev;	  			/* Char device structure		*/

	// vars for blocking
	wait_queue_head_t wait_queue; // Wait Queue for sleeping on interrupts
  int read_ready;		// Ready flag for interrupts

	wait_queue_head_t wait_done; // Wait Queue for waiting for accelerator processing
  int accel_done;							 // Accelerator done processing
	
	wait_queue_head_t write_wait_queue; // Wait Queue for sleeping on interrupts
  int write_done;		// Ready flag for interrupts

	/*
   * Driver statistics
   */
  u32  reads;
  u32  writes;
  u32  opens;
  u32  closes;
  u32  tx_buffers;
  u32  tx_bytes;
  u32  rx_buffers;
  u32  rx_bytes;

};

/*
 * HWICAP structs
 */

struct hwicap_drvdata {
	u32 write_buffer_in_use;  /* Always in [0,3] */
	u8 write_buffer[4];
	u32 read_buffer_in_use;	  /* Always in [0,3] */
	u8 read_buffer[4];
	resource_size_t mem_start;/* phys. address of the control registers */
	resource_size_t mem_end;  /* phys. address of the control registers */
	resource_size_t mem_size;
	void __iomem *base_address;/* virt. address of the control registers */

	struct device *dev;
	struct cdev cdev;	/* Char device structure */
	dev_t devt;

	const struct hwicap_driver_config *config;
	const struct config_registers *config_regs;
	void *private_data;
	bool is_open;
	struct mutex sem;
};

struct hwicap_driver_config {
	/* Read configuration data given by size into the data buffer.
	   Return 0 if successful. */
	int (*get_configuration)(struct hwicap_drvdata *drvdata, u32 *data,
			u32 size);
	/* Write configuration data given by size from the data buffer.
	   Return 0 if successful. */
	int (*set_configuration)(struct hwicap_drvdata *drvdata, u32 *data,
			u32 size);
	/* Get the status register, bit pattern given by:
	 * D8 - 0 = configuration error
	 * D7 - 1 = alignment found
	 * D6 - 1 = readback in progress
	 * D5 - 0 = abort in progress
	 * D4 - Always 1
	 * D3 - Always 1
	 * D2 - Always 1
	 * D1 - Always 1
	 * D0 - 1 = operation completed
	 */
	u32 (*get_status)(struct hwicap_drvdata *drvdata);
	/* Reset the hw */
	void (*reset)(struct hwicap_drvdata *drvdata);
};

struct config_registers {
	u32 CRC;
	u32 FAR;
	u32 FDRI;
	u32 FDRO;
	u32 CMD;
	u32 CTL;
	u32 MASK;
	u32 STAT;
	u32 LOUT;
	u32 COR;
	u32 MFWR;
	u32 FLR;
	u32 KEY;
	u32 CBC;
	u32 IDCODE;
	u32 AXSS;
	u32 C0R_1;
	u32 CSOB;
	u32 WBSTAR;
	u32 TIMER;
	u32 BOOTSTS;
	u32 CTL_1;
};

/**
 * hwicap_type_1_read - Generates a Type 1 read packet header.
 * @reg: is the address of the register to be read back.
 *
 * Generates a Type 1 read packet header, which is used to indirectly
 * read registers in the configuration logic.  This packet must then
 * be sent through the icap device, and a return packet received with
 * the information.
 **/
static inline u32 hwicap_type_1_read(u32 reg)
{
	return (XHI_TYPE_1 << XHI_TYPE_SHIFT) |
		(reg << XHI_REGISTER_SHIFT) |
		(XHI_OP_READ << XHI_OP_SHIFT);
}

/**
 * hwicap_type_1_write - Generates a Type 1 write packet header
 * @reg: is the address of the register to be read back.
 **/
static inline u32 hwicap_type_1_write(u32 reg)
{
	return (XHI_TYPE_1 << XHI_TYPE_SHIFT) |
		(reg << XHI_REGISTER_SHIFT) |
		(XHI_OP_WRITE << XHI_OP_SHIFT);
}

#endif	
