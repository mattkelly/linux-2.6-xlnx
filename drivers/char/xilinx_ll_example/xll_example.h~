
#ifndef __XLL_EXAMPLE_H__
#define __XLL_EXAMPLE_H__

/*************************************************************/
/* SGDMA buffer descriptors must be aligned on a 8-byte boundary. */
#define ALIGNMENT_BD       XLLDMA_BD_MINIMUM_ALIGNMENT
/*
 * Default SEND and RECV buffer descriptors (BD) counts
 * BD Space needed is (XLL_SEND_BD_CNT+XLL_RECV_BD_CNT)*Sizeof(XLlDma_Bd).
 * Each XLlDma_Bd instance currently takes 40 bytes.
 */
#define XLL_SEND_BD_CNT    16
#define XLL_RECV_BD_CNT    16

#define LL_EX_BUF_SIZE     0x400 /* receive buffer size */
#define LL_EX_MIN_BUF_SIZE 5     /* Minumum buffer size supported by core */

/* Default TX/RX Threshold and waitbound values for SGDMA */
#define DFT_TX_THRESHOLD   1
#define DFT_TX_WAITBOUND   254
#define DFT_RX_THRESHOLD   1
#define DFT_RX_WAITBOUND   254

#define XLL_DMA_DCR_BASE   0x98  /* ML507 HDMA 0 DCR base address -> changed for DMA1 DCR on ML510 */

/*
 * Location in the receive descriptor where the ll_example core will
 * place the number of valid bytes in a receive buffer.
 */
#define BdGetRxLen(BdPtr) \
    XLlDma_mBdRead((BdPtr), XLLDMA_BD_USR4_OFFSET)


/*************************************************************/

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

/*
 * The local link example device structure.
 */
struct ll_ex_dev
{
    XLlDma Dma;
    /* Buffer Descriptor space for both TX and RX BD ring */
    void            *desc_virtaddr;    /* virtual address of BD space */
    dma_addr_t       desc_physaddr;    /* physical address of BD space */

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

    /*
     * Device information
     */
    void            *mapaddr;          /* virtual address of ll example core */
    unsigned         physaddr;         /* bus address aof ll example core */
    unsigned         addrsize;         /* Size of periph. address space */
    unsigned         dma_rx_irq, dma_tx_irq; /* Virtual IRQ numbers for DMA */
    unsigned         dma_addr;         /* Address of DMA controller */
    dev_t            devno;
    struct mutex     mutex;
    struct cdev      cdev;

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
    u32  tx_irq;
    u32  rx_irq;
    u32  errors;
};

/*
 * Register definitions
 */
#define LLEX_CTL_REG    0x000
#define LLEX_STS_REG    0x004
#define LLEX_TXFRM_REG  0x008
#define LLEX_RXFRM_REG  0x00C
#define LLEX_TXBYTE_REG 0x010
#define LLEX_RXBYTE_REG 0x014

#define LLEX_APP1_REG   0x018
#define LLEX_APP2_REG		0x01C
#define LLEX_APP3_REG		0x020
#define LLEX_APP4_REG		0x024

#define LLEX_FIFO1_SIZE_REG		0x028
#define LLEX_FIFO2_SIZE_REG		0x02C

#define LLEX_RST_REG    0x100

#endif
