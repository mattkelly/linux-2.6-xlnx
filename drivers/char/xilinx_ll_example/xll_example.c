/******************************************************************************
*
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*     AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*     SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*     OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*     APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*     THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*     FOR A PARTICULAR PURPOSE.
*
*     (c) Copyright 2009 Xilinx Inc.
*     All rights reserved.
*
*     This program is free software; you can redistribute it and/or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation; either version 2 of the License, or (at
*     your option) any later version.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
*     MA  02110-1301  USA
*
******************************************************************************/
/*****************************************************************************/
/**
 *
 * @file xll_example.c
 *
 * A minimal Xilinx Local Link DMA loopback core example driver.
 *
 * EXAMPLE USAGE:
 * # cat /etc/issue > /dev/llex0
 * # cat /dev/llex0
 * MontaVista(R) Linux(R) Professional Edition 4.0.1 (0502020)
 * 
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who  Date     Changes
 * ----- ---- -------- -------------------------------------------------------
 * 1.00a bh   12/16/08 First release
 * </pre>
 ******************************************************************************/

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/errno.h>
#include <linux/version.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/cdev.h>
#include <asm/uaccess.h>
#include <asm/time.h> //get_tbl
#include <linux/types.h> //uint, etc.

#include <asm/io.h>
#include <linux/ioport.h>
#include <linux/interrupt.h>
#include <linux/dma-mapping.h>
#include <linux/xilinx_devices.h>

#include <linux/of_device.h>
#include <linux/of_platform.h>

#include "xlldma.h"
#include "xll_example.h"

#define METRICS

#ifdef METRICS
uint32_t cycles_start;
uint32_t cycles_end;
    #define HWTIME_TOTAL        0
    #define HWTIME_KERNBUF      1
    #define HWTIME_USR2KRN      2
	#define HWTIME_MEMTOACC     3
	#define HWTIME_NOLOCKS      4
    #define HWTIME_FIRSTMUTEX   5
	#define HWTIME_SIZE         6
	uint32_t tb_data[HWTIME_SIZE];
#endif

#define DRIVER_NAME         "xilinx_ll_example"
#define DRIVER_DESCRIPTION  "Xilinx Local Link Example driver"
#define DRIVER_VERSION      "1.00a"

/*
 * The major device number used by this driver.
 * Refer to include/linux/major.h 
 */
#define LL_EX_DEV_MAJ       253

int llex_debug = 0;

/*
 * The Local Link example device structure.  Only a single instance is
 * provided for. Systems with multiple cores should replace this item with
 * a list.
 */
struct ll_ex_dev *ll_ex_dev;
struct device *ll_dev;

static void DmaSendHandlerBH(unsigned long p);
static void DmaRecvHandlerBH(unsigned long p);

DECLARE_TASKLET(ExDmaSendBH, DmaSendHandlerBH, 0);
DECLARE_TASKLET(ExDmaRecvBH, DmaRecvHandlerBH, 0);


/************************************************************/

/*
 * xll_ex_DmaSend
 * "transmit" the indicated buffer to the LL Example core.
 */

// Add here to target specific accelerator

static int
xll_ex_DmaSend (void *buff, size_t buff_len, struct ll_ex_dev *ll_ex_dev)
{
    XLlDma_Bd *bd_ptr;
    dma_addr_t phy_addr;
    int        result;

    result = XLlDma_BdRingAlloc(&ll_ex_dev->Dma.TxBdRing, 1, &bd_ptr);
    if (result != XST_SUCCESS) {
        if (llex_debug) {
            printk(KERN_ERR
                   "%s %s: Unable to allocate TX BdRing\n",
                   DRIVER_NAME, __FUNCTION__);
        }
        return result;
    }

    /*
     * Get the physical address of the buffer.
     */
	// changed this
    phy_addr = (u32) dma_map_single(ll_dev, buff, buff_len, DMA_TO_DEVICE);

    XLlDma_mBdSetBufAddr(bd_ptr, phy_addr);
    XLlDma_mBdSetLength(bd_ptr, buff_len);
    XLlDma_mBdSetId(bd_ptr, buff);
    XLlDma_mBdSetStsCtrl(bd_ptr, XLLDMA_BD_STSCTRL_SOP_MASK |
                                 XLLDMA_BD_STSCTRL_EOP_MASK);

    // Here, set APP1 field according to which accelerator this transfer should go to
    XLlDma_mBdWrite(bd_ptr, XLLDMA_BD_USR2_OFFSET, 0xAA);

    /* Enqueue to HW */
    result = XLlDma_BdRingToHw(&ll_ex_dev->Dma.TxBdRing, 1, bd_ptr);
    if (result != XST_SUCCESS) {
        kfree(buff);
        XLlDma_mBdSetId(bd_ptr, NULL);
        ll_ex_dev->errors++;
        printk(KERN_ERR
               "%s: could not send commit TX buffer descriptor (%d).\n",
               DRIVER_NAME, result);

        return XST_FAILURE;
    }

    ll_ex_dev->tx_buffers++;
    ll_ex_dev->tx_bytes += buff_len;

    return XST_SUCCESS;
}

/*
 * File Operations
 */
/************************************************************/

/*
 * ll_ex_open:
 * The user has opened /dev/llex0
 */
int ll_ex_open(struct inode *inode, struct file *filp)
{
    struct ll_ex_dev *dev; /* device information */
    int retval;

    retval = 0;
    dev = container_of(inode->i_cdev, struct ll_ex_dev, cdev);
    filp->private_data = dev; /* for other methods */

    mutex_lock(&dev->mutex);

    /*
     * Only one writer and only one reader of the device.
     */
    switch (filp->f_flags & O_ACCMODE) {
    case O_RDONLY:
        if (dev->readers) {
            retval = -EBUSY;
            goto out;
        } else {
            dev->readers++;
            dev->read_off = 0;
        }
        break;
    case O_WRONLY:
        if (dev->writers) {
            retval = -EBUSY;
            goto out;
        } else {
            dev->writers++;
        }
        break;
    case O_RDWR:
    default:
        if (dev->writers || dev->readers) {
            retval = -EBUSY;
            goto out;
        } else {
            dev->writers++;
            dev->readers++;
            dev->read_off = 0;
        }
    }

    dev->opens++;

out:
    mutex_unlock(&dev->mutex);
    return retval; 
}

/*
 * ll_ex_release:
 * The user has closed the device file.
 */
static int ll_ex_release(struct inode *inode, struct file *filp)
{
    struct ll_ex_dev *dev = filp->private_data;

    mutex_lock(&dev->mutex);

    /*
     * Only one writer and only one reader of the device.
     */
    switch (filp->f_flags & O_ACCMODE) {
    case O_RDONLY:
        dev->readers--;
        break;
    case O_WRONLY:
        dev->writers--;
        break;
    case O_RDWR:
    default:
        dev->writers--;
        dev->readers--;
    }

    dev->closes++;

    mutex_unlock(&dev->mutex);
    return 0;
}

/*
 * ll_ex_read:
 * A userspace read of the device file.  Copy one of the receive 
 * buffers to userspace and remove it from the list.
 */
ssize_t ll_ex_read(struct file *filp, char __user *buf, size_t count,
                   loff_t *f_pos)
{

    //asm volatile("sync");

    struct ll_ex_dev *dev = filp->private_data;
    ssize_t retval = 0;
    ssize_t copybytes;
    struct llex_rx_buff *rx_buff;
    int err;

    mutex_lock(&dev->mutex);

    if (llex_debug) {
        printk(KERN_INFO "\n%s: START: f_pos %lld  count %d\n",
               __FILE__, *f_pos, count);
    }

    dev->reads++;

    /*
     * Ensure that the RX Bottom-Half IRQ handler doesn't modify rx_buffer_list
     * while we are looking at it here.
     */
    tasklet_disable(&ExDmaRecvBH);

    /*
     * Anything received from the LL Example core?
     */
    if (list_empty(&ll_ex_dev->rx_buffer_list)) {
        goto out;
    }

    rx_buff = list_entry(ll_ex_dev->rx_buffer_list.next,
                         struct llex_rx_buff, list);

    /*
     * How many bytes to copy -- the lesser of the entire DMA buffer or
     * available user buffer size.
     */
    copybytes = min(rx_buff->data_len - ll_ex_dev->read_off, count);

    /*
     * Copy this buffer to user space.
     */
    err = copy_to_user(buf, rx_buff->data + ll_ex_dev->read_off, copybytes);
    if (err < 0) {
        printk(KERN_INFO
               "%s %s: copy_to_user rx_buff 0x%08x (%d)(%d) error (%d)",
               DRIVER_NAME, __FUNCTION__, (u32)rx_buff, copybytes, count, err);
        goto out;
    }
    count -= copybytes;
    buf += copybytes;
    *f_pos += copybytes;
    retval += copybytes;
    /*
     * If the entire DMA buffer wasn't copied (user buffer full),
     * remember where to continue. 
     */
    if (rx_buff->data_len != copybytes) {
        ll_ex_dev->read_off += copybytes;
        if (llex_debug) {
            printk(KERN_INFO
                   "\n%s: NOFIT: copybytes %d count %d data_len %d \n",
                   __FILE__, copybytes, count, rx_buff->data_len);
        }
    }

    /*
     * If the entire DMA buffer has been copied, free it.
     * With the presently chosen buffer size (1K) it is expected that this
     * should happen every time.
     */
    if ((ll_ex_dev->read_off == 0) ||
        (ll_ex_dev->read_off == rx_buff->data_len)) {
        ll_ex_dev->read_off = 0;
        list_del(&rx_buff->list);
        kfree(rx_buff);
    }

    if (llex_debug) {
        printk(KERN_INFO "\n%s: END: count %d read_off %d retval %d\n",
               __FILE__, count, ll_ex_dev->read_off, retval);
    }

  out:

    tasklet_enable(&ExDmaRecvBH);

    mutex_unlock(&dev->mutex);
    return retval;
}

/*
 * ll_ex_write:
 * A userspace write to the device file. Send the data to the LL Example
 * core by LL DMA.
 */
ssize_t ll_ex_write(struct file *filp, const char __user *buf,
                    size_t count, loff_t *f_pos)
{

#ifdef METRICS
    tb_data[HWTIME_TOTAL] = get_tbl();
    tb_data[HWTIME_FIRSTMUTEX] = get_tbl();
#endif
/*
    #define HWTIME_TOTAL        0
    #define HWTIME_KERNBUF      1
    #define HWTIME_USR2KRN      2 
	#define HWTIME_MEMTOACC     3
	#define HWTIME_INV          4
	#define HWTIME_FLUSH        5
	#define HWTIME_SETUP_M2A    6
	#define HWTIME_SETUP_A2M    7
	#define HWTIME_K2U          8
	#define HWTIME_U2K          9
	#define HWTIME_EXEC         10  
	#define HWTIME_SIZE         11
*/

    struct ll_ex_dev *dev = filp->private_data;
    ssize_t retval = 0;
    void   *buffer;

    //mutex_lock(&dev->mutex);

    #ifdef METRICS
    tb_data[HWTIME_NOLOCKS] = get_tbl();
    tb_data[HWTIME_FIRSTMUTEX] = get_tbl() - tb_data[HWTIME_FIRSTMUTEX];
    #endif

    dev->writes++;

    #ifdef METRICS
    tb_data[HWTIME_KERNBUF] = get_tbl();
    #endif

    if (count < LL_EX_MIN_BUF_SIZE) {
        count = LL_EX_MIN_BUF_SIZE;
    }
    count = min(count, (size_t)LL_EX_BUF_SIZE);

    buffer = kmalloc(count + 1, GFP_KERNEL);
    if (buffer == NULL) {
        retval = -ENOMEM;
        goto out;
    }
    memset(buffer, 0, LL_EX_MIN_BUF_SIZE);

    #ifdef METRICS
    tb_data[HWTIME_KERNBUF] = get_tbl() - tb_data[HWTIME_KERNBUF];
    tb_data[HWTIME_USR2KRN] = get_tbl();
    #endif
        
    if (copy_from_user(buffer, buf, count)) {
        retval = -EFAULT;
        goto out;
    }

    #ifdef METRICS
    tb_data[HWTIME_USR2KRN] = get_tbl() - tb_data[HWTIME_USR2KRN];
    tb_data[HWTIME_MEMTOACC] = get_tbl();
    #endif

    retval = xll_ex_DmaSend(buffer, count, ll_ex_dev);

    #ifdef METRICS
    tb_data[HWTIME_MEMTOACC] = get_tbl() - tb_data[HWTIME_MEMTOACC];
    #endif

    if (retval != XST_SUCCESS) {
        printk(KERN_ERR "%s: write op failed (%d)\n",
               DRIVER_NAME, retval);
        retval = -ERESTARTSYS;
    } else {
        retval = count;
    }
    *f_pos += count;

  out:

    #ifdef METRICS
    tb_data[HWTIME_NOLOCKS] = get_tbl() - tb_data[HWTIME_NOLOCKS];
    #endif

    //mutex_unlock(&dev->mutex);

#ifdef METRICS
    tb_data[HWTIME_TOTAL] = get_tbl() - tb_data[HWTIME_TOTAL];
#endif
    return retval;
}


struct file_operations ll_ex_fops = {
        .owner =    THIS_MODULE,
        .read =     ll_ex_read,
        .write =    ll_ex_write,
        .open =     ll_ex_open,
        .release =  ll_ex_release,
};

/*
 * Driver /proc file operations.
 */
/*****************************************************************/

static void *llex_proc_seq_start (struct seq_file *s, loff_t *pos)
{
    if (*pos == 0) {
        return ll_ex_dev;
    } 

    return NULL;
}

static void *llex_proc_seq_next (struct seq_file *s, void *v, loff_t *pos)
{
    (*pos)++;

    return NULL;
}

static void llex_proc_seq_stop (struct seq_file *s, void *v)
{
}

/*
 * llex_proc_seq_show:
 * Produces the data displayed for a /proc read operation
 */
static int llex_proc_seq_show (struct seq_file *s, void *v)
{
    struct ll_ex_dev *dev;

    dev = v;
    mutex_lock(&dev->mutex);

    seq_printf(s,"\nMAPADDR:  0x%08x", (u32)dev->mapaddr);
    seq_printf(s,"\nReads:    %d", dev->reads);
    seq_printf(s,"\nWrites:   %d", dev->writes);
    seq_printf(s,"\nOpens:    %d", dev->opens);
    seq_printf(s,"\nCloses:   %d", dev->closes);
    seq_printf(s,"\nTX IRQ:   %d", dev->tx_irq);
    seq_printf(s,"\nTX Buff:  %d", dev->tx_buffers);
    seq_printf(s,"\nTX Bytes: %d", dev->tx_bytes);
    seq_printf(s,"\nRX IRQ:   %d", dev->rx_irq);
    seq_printf(s,"\nRX Buff:  %d", dev->rx_buffers);
    seq_printf(s,"\nRX Bytes: %d", dev->rx_bytes);
    seq_printf(s,"\nErrors:   %d", dev->errors);
    seq_printf(s,"\n");

#ifdef METRICS
    seq_printf(s, "DMA Transfer Metrics\n");
    seq_printf(s, "TX Cycles:   %d\n", tb_data[HWTIME_TOTAL]);
    seq_printf(s, "First Mutex: %d\n", tb_data[HWTIME_FIRSTMUTEX]);
    seq_printf(s, "Kernel Buffer: %d\n", tb_data[HWTIME_KERNBUF]);
    seq_printf(s, "User to Kernel: %d\n", tb_data[HWTIME_USR2KRN]);
    seq_printf(s, "Mem to Accel: %d\n", tb_data[HWTIME_MEMTOACC]);
    seq_printf(s, "Time No Locks: %d\n", tb_data[HWTIME_NOLOCKS]);
    seq_printf(s, "\n");
	
/*
    #define HWTIME_KERNBUF      1
    #define HWTIME_USR2KRN      2
	#define HWTIME_MEMTOACC     3
	#define HWTIME_SIZE         4
    
*/

#endif

    seq_printf(s,"\nREGISTERS:");
    seq_printf(s,"\nCTL:      0x%08x", in_be32(dev->mapaddr + LLEX_CTL_REG));
    seq_printf(s,"\nSTS:      0x%08x", in_be32(dev->mapaddr + LLEX_STS_REG));
    seq_printf(s,"\nTXFRM:    %d", in_be32(dev->mapaddr + LLEX_TXFRM_REG));
    seq_printf(s,"\nRXFRM:    %d", in_be32(dev->mapaddr + LLEX_RXFRM_REG));
    seq_printf(s,"\nTXBYTE:   %d", in_be32(dev->mapaddr + LLEX_TXBYTE_REG));
    seq_printf(s,"\nRXBYTE:   %d", in_be32(dev->mapaddr + LLEX_RXBYTE_REG));
    seq_printf(s,"\nAPP1:     %d", in_be32(dev->mapaddr + LLEX_APP1_REG));
		seq_printf(s,"\nAPP2:     %d", in_be32(dev->mapaddr + LLEX_APP2_REG));
		seq_printf(s,"\nAPP3:     %d", in_be32(dev->mapaddr + LLEX_APP3_REG));
		seq_printf(s,"\nAPP4:     %d", in_be32(dev->mapaddr + LLEX_APP4_REG));
    seq_printf(s,"\n");

    seq_printf(s,"\nBuffer Descriptors: 0x%08x (Virtual 0x%08x)", 
               dev->desc_physaddr,
               (unsigned int) dev->desc_virtaddr);

    seq_printf(s,"\n");

    mutex_unlock(&dev->mutex);
    return 0;
}

/*
 * /proc SEQ operations
 */
static struct seq_operations llex_proc_seq_ops = {
        .start = llex_proc_seq_start,
        .next  = llex_proc_seq_next,
        .stop  = llex_proc_seq_stop,
        .show  = llex_proc_seq_show
};

/*
 * The open() operation sets up the sequence operators.
 */
static int llex_proc_open(struct inode *inode, struct file *file)
{
        return seq_open(file, &llex_proc_seq_ops);
}

/*
 * Create a set of file operations for our proc file.
 * only open() is provided locally.
 */
static struct file_operations llex_proc_ops = {
        .owner   = THIS_MODULE,
        .open    = llex_proc_open,
        .read    = seq_read,
        .llseek  = seq_lseek,
        .release = seq_release
};


/*****************************************************************/

/*
 * Allocate a receive buffer, and associated structure which describes it.
 */
static struct llex_rx_buff *alloc_rx_buff (size_t len)
{
    struct llex_rx_buff *rx_buff;

    rx_buff = (struct llex_rx_buff *)
              kmalloc(sizeof(struct llex_rx_buff) + len, GFP_ATOMIC);
    rx_buff->data_len = len;
    INIT_LIST_HEAD(&rx_buff->list);

    return rx_buff;
}

/*
 * ll_ex_DmaSetupRecvBuffers:
 * allocates as many DMA buffers as it can up to the number of free RX
 * buffer descriptors.
 */
static void ll_ex_DmaSetupRecvBuffers(struct ll_ex_dev *ll_ex)
{
    int free_bd_count;
    int num_buffs;
    u32 new_buff_physaddr;
    XLlDma_Bd *BdPtr, *BdCurPtr;
    int result;

    free_bd_count = XLlDma_mBdRingGetFreeCnt(&ll_ex->Dma.RxBdRing);

    result = XLlDma_BdRingAlloc(&ll_ex->Dma.RxBdRing, free_bd_count, &BdPtr);
    if (result != XST_SUCCESS) {
        /* we really shouldn't get this */
        printk(KERN_ERR "%s: XLlDma: BdRingAlloc unsuccessful (%d)\n",
               DRIVER_NAME, result);
        return;
    }

    BdCurPtr = BdPtr;

    for (num_buffs = 0; num_buffs < free_bd_count; num_buffs++) {
        struct llex_rx_buff *rx_buff;

        /*
         * Allocate a new buffer
         */
        rx_buff = alloc_rx_buff(LL_EX_BUF_SIZE);
        if (rx_buff == NULL) {
            printk(KERN_ERR "%s: kmalloc buffer unsuccessful\n",
                   DRIVER_NAME);
            return;
        }

        /* Get dma handle (physical address) of the new buffer */

	new_buff_physaddr = (u32) dma_map_single(ll_dev, rx_buff->data,
                                                 LL_EX_BUF_SIZE,
                                                 DMA_FROM_DEVICE);

        XLlDma_mBdSetBufAddr(BdCurPtr, new_buff_physaddr);
        XLlDma_mBdSetLength(BdCurPtr, LL_EX_BUF_SIZE);
        XLlDma_mBdSetId(BdCurPtr, rx_buff);
        // LLDMA Driver bug; no flags should be required on RX descriptors.
        XLlDma_mBdSetStsCtrl(BdCurPtr, XLLDMA_BD_STSCTRL_SOP_MASK |
                                       XLLDMA_BD_STSCTRL_EOP_MASK);

        BdCurPtr = XLlDma_mBdRingNext(&ll_ex->Dma.RxBdRing, BdCurPtr);
    }

    /* enqueue RxBD with the attached buffers such that it is
     * ready for frame reception */
    result = XLlDma_BdRingToHw(&ll_ex->Dma.RxBdRing, num_buffs, BdPtr);
    if (result != XST_SUCCESS) {
        printk(KERN_ERR
               "%s: (DmaSetupRecvBuffers) BdRingToHw unsuccessful (%d)\n",
               DRIVER_NAME, result);
        BdCurPtr = BdPtr;
        while (num_buffs > 0) {
            XLlDma_mBdSetId(BdCurPtr, NULL);
            BdCurPtr = XLlDma_mBdRingNext(&ll_ex->Dma.RxBdRing,
                           BdCurPtr);
            num_buffs--;
        }
        return;
    }
}


/*
 * Interrupt handlers
 */
/*****************************************************************/

/*
 * xllex_dma_rx_interrupt:
 * DMA receive interrupt handler (data from LL Example core)
 */
static irqreturn_t xllex_dma_rx_interrupt(int irq, void *dev_id)
{
    u32 irq_status;
    struct ll_ex_dev *ll_ex_dev = dev_id;

    ll_ex_dev->rx_irq++;

    /* Read pending interrupts */
    irq_status = XLlDma_mBdRingGetIrq(&ll_ex_dev->Dma.RxBdRing);

    XLlDma_mBdRingAckIrq(&ll_ex_dev->Dma.RxBdRing, irq_status);

    if ((irq_status & XLLDMA_IRQ_ALL_ERR_MASK)) {
        XLlDma_Reset(&ll_ex_dev->Dma);
        ll_ex_dev->errors++;
        return IRQ_HANDLED;
    }

    if ((irq_status & (XLLDMA_IRQ_DELAY_MASK | XLLDMA_IRQ_COALESCE_MASK))) {
        XLlDma_mBdRingIntDisable(&ll_ex_dev->Dma.RxBdRing,
                                 XLLDMA_CR_IRQ_ALL_EN_MASK);
        /*
         * Schedule the bottom half handler -- DmaRecvHandlerBH()
         */
        tasklet_schedule(&ExDmaRecvBH);
    }

    return IRQ_HANDLED;
}

/*
 * DMA receive interrupt handler Bottom Half
 * Received buffers are removed from the descriptor ring and added to 
 * rx_buffer_list for later processing.
 */
static void DmaRecvHandlerBH(unsigned long p)
{
    u32                  buff_phys_addr;
    u32                  len;
    struct llex_rx_buff *rx_buff;
    int                  result;
    XLlDma_Bd           *BdPtr, *BdCurPtr;
    unsigned int         bd_processed, bd_processed_saved;
    int                  dma_rx_int_mask;

    dma_rx_int_mask = XLLDMA_CR_IRQ_ALL_EN_MASK;

    if ((bd_processed =
         XLlDma_BdRingFromHw(&ll_ex_dev->Dma.RxBdRing, XLL_RECV_BD_CNT,
                 &BdPtr)) > 0)
    {
        bd_processed_saved = bd_processed;
        BdCurPtr = BdPtr;
        do {
            /*
             * Regular length field not updated on rx,
             * USR4 updated instead.
             */
            len = BdGetRxLen(BdCurPtr);

            /* get pointer to buffer structure */
            rx_buff = (void *)
                XLlDma_mBdGetId(BdCurPtr);

            /* get and free up dma handle used by the buffer */
            buff_phys_addr =
                (dma_addr_t)
                XLlDma_mBdGetBufAddr(BdCurPtr);
            /*
             * Invalidate the data cache for this buffer.
             */
            dma_unmap_single(ll_dev, buff_phys_addr,
                             LL_EX_BUF_SIZE,
                             DMA_FROM_DEVICE);
            rx_buff->data_len = len;

            /* reset ID */
            XLlDma_mBdSetId(BdCurPtr, NULL);

            ll_ex_dev->rx_buffers++;
            ll_ex_dev->rx_bytes += len;

            /*
             * Add this buffer to the received list for later processing in
             * ll_ex_read().
             */
            list_add_tail(&rx_buff->list, &ll_ex_dev->rx_buffer_list);
  
            BdCurPtr =
                XLlDma_mBdRingNext(&ll_ex_dev->Dma.RxBdRing,
                           BdCurPtr);
            bd_processed--;
        } while (bd_processed > 0);

        /* give the descriptor back to the driver */
        result = XLlDma_BdRingFree(&ll_ex_dev->Dma.RxBdRing,
                       bd_processed_saved, BdPtr);
        if (result != XST_SUCCESS) {
            printk(KERN_ERR
                   "%s: XLlDma: BdRingFree unsuccessful (%d)\n",
                   DRIVER_NAME, result);
            return;
        }

        ll_ex_DmaSetupRecvBuffers(ll_ex_dev);
    }
    XLlDma_mBdRingIntEnable(&ll_ex_dev->Dma.RxBdRing, dma_rx_int_mask);
}

/*
 * xllex_dma_tx_interrupt:
 * DMA transmit completion interrupt.
 */
static irqreturn_t xllex_dma_tx_interrupt(int irq, void *dev_id)
{
    u32 irq_status;
    struct ll_ex_dev *ll_ex_dev = dev_id;

    ll_ex_dev->tx_irq++;

    /* Read pending interrupts */
    irq_status = XLlDma_mBdRingGetIrq(&(ll_ex_dev->Dma.TxBdRing));

    XLlDma_mBdRingAckIrq(&(ll_ex_dev->Dma.TxBdRing), irq_status);

    if ((irq_status & XLLDMA_IRQ_ALL_ERR_MASK)) {
        XLlDma_Reset(&ll_ex_dev->Dma);
        ll_ex_dev->errors++;
        return IRQ_HANDLED;
    }

    if ((irq_status & (XLLDMA_IRQ_DELAY_MASK | XLLDMA_IRQ_COALESCE_MASK))) {
        XLlDma_mBdRingIntDisable(&ll_ex_dev->Dma.TxBdRing,
                                 XLLDMA_CR_IRQ_ALL_EN_MASK);
        /*
         * Schedule Bottom Half interrupt handler -- DmaSendHandlerBH()
         */
        tasklet_schedule(&ExDmaSendBH);
    }

    return IRQ_HANDLED;
}

/*
 * DMA send interrupt handler Bottom Half
 * Transmit completion - buffers which have been sent to the LL Example core
 * are removed from the ring and freed.
 */
static void DmaSendHandlerBH (unsigned long p)
{
    XLlDma_Bd    *BdPtr, *BdCurPtr;
    unsigned long len;
    dma_addr_t    dma_phys_addr;
    void         *dma_buff;
    unsigned int  bd_processed, bd_processed_save;
    int           dma_tx_int_mask;
    int           result;

    result = XST_SUCCESS;
    dma_tx_int_mask = XLLDMA_CR_IRQ_ALL_EN_MASK;

    bd_processed_save = 0;
    while ((bd_processed =
        XLlDma_BdRingFromHw(&ll_ex_dev->Dma.TxBdRing, XLL_SEND_BD_CNT,
                    &BdPtr)) > 0)
    {

        bd_processed_save = bd_processed;
        BdCurPtr = BdPtr;
        do {
            len = XLlDma_mBdGetLength(BdCurPtr);
            dma_phys_addr = (dma_addr_t) XLlDma_mBdGetBufAddr(BdCurPtr);
            dma_unmap_single(ll_dev, dma_phys_addr, len,
                     DMA_TO_DEVICE);

            /* get ptr to buffer */
            dma_buff = (void *) XLlDma_mBdGetId(BdCurPtr);
            if (dma_buff) {
                kfree(dma_buff);
            }

            /* reset BD id */
            XLlDma_mBdSetId(BdCurPtr, NULL);

            BdCurPtr = XLlDma_mBdRingNext(&ll_ex_dev->Dma.TxBdRing,
                           BdCurPtr);
            bd_processed--;
        } while (bd_processed > 0);

        result = XLlDma_BdRingFree(&ll_ex_dev->Dma.TxBdRing,
                       bd_processed_save, BdPtr);
        if (result != XST_SUCCESS) {
            printk(KERN_ERR
                   "%s: XLlDma: BdRingFree() error %d.\n",
                   DRIVER_NAME, result);
            return;
        }
    }
    XLlDma_mBdRingIntEnable(&ll_ex_dev->Dma.TxBdRing, dma_tx_int_mask);
}

/*
 * Driver Initialization
 */
/*****************************************************************/

/*
 * descriptor_init:
 * Allocate and set up RX/TX DMA descriptors.
 */
static int descriptor_init (struct ll_ex_dev *ll_ex_dev) 
{
    int   recvsize, sendsize;
    int   dftsize;
    u32  *recvpoolptr, *sendpoolptr;
    void *recvpoolphy, *sendpoolphy;
    int   result;

/*
 * Buffer Descriptr
 * word byte    description
 * 0    00h next ptr 
 * 1    04h buffer addr
 * 2    08h buffer len 
 * 3    0Ch sts/ctrl | app data (0) 
 * 7    1Ch app data (4) [rx recv length (bits 18-31 LSB)]
 */

    /* calc size of descriptor space pool */
    dftsize = XLlDma_mBdRingMemCalc(ALIGNMENT_BD,
                      XLL_RECV_BD_CNT + XLL_SEND_BD_CNT);
    printk(KERN_INFO "%s: buffer descriptor size: %d (0x%0x)\n",
           DRIVER_NAME, dftsize, dftsize);

    /*
     * Allocate DMA descriptors
     */
    ll_ex_dev->desc_virtaddr = kmalloc(dftsize, GFP_KERNEL);
    if (ll_ex_dev->desc_virtaddr == 0) {
        printk(KERN_ERR "%s: Unable to allocate descriptors\n", DRIVER_NAME);
        return -ENOMEM;
    }
    /*
     * The physical address is what the DMA engine needs to use.
     */
    ll_ex_dev->desc_physaddr = (dma_addr_t)
                               virt_to_phys(ll_ex_dev->desc_virtaddr);

    /* calc size of send and recv descriptor space */
    recvsize = XLlDma_mBdRingMemCalc(ALIGNMENT_BD, XLL_RECV_BD_CNT);
    sendsize = XLlDma_mBdRingMemCalc(ALIGNMENT_BD, XLL_SEND_BD_CNT);

    recvpoolptr = ll_ex_dev->desc_virtaddr;
    recvpoolphy = (void *) ll_ex_dev->desc_physaddr;
    sendpoolptr = (void *) ((u32) ll_ex_dev->desc_virtaddr + recvsize);
    sendpoolphy = (void *) ((u32) ll_ex_dev->desc_physaddr + recvsize);

    result = XLlDma_BdRingCreate(&ll_ex_dev->Dma.RxBdRing, (u32) recvpoolphy,
                     (u32) recvpoolptr, ALIGNMENT_BD,
                     XLL_RECV_BD_CNT);
    if (result != XST_SUCCESS)
    {
        printk(KERN_ERR "%s: DMA Ring Create (RECV). Error: %d\n",
               DRIVER_NAME, result);
        return -EIO;
    }

    result = XLlDma_BdRingCreate(&ll_ex_dev->Dma.TxBdRing, (u32) sendpoolphy,
                     (u32) sendpoolptr, ALIGNMENT_BD,
                     XLL_SEND_BD_CNT);
    if (result != XST_SUCCESS)
    {
        printk(KERN_ERR "%s: DMA Ring Create (SEND). Error: %d\n",
               DRIVER_NAME, result);
        return -EIO;
    }

    /*
     * Allocate a full ring worth of receive buffers.
     */

    ll_ex_DmaSetupRecvBuffers(ll_ex_dev);

    return 0;
}

/*
 * Remove the driver hooks from the system.
 * NOTE: No attempt is made to free memory allocated for DMA when an
 * error occurs.
 */
static void xll_example_remove(void)
{
    dev_t devno;

    tasklet_kill(&ExDmaSendBH);
    tasklet_kill(&ExDmaRecvBH);
    remove_proc_entry("driver/ll_example_drvr", NULL);

    if (ll_ex_dev) {
        cdev_del(&ll_ex_dev->cdev);

        free_irq(ll_ex_dev->dma_rx_irq, ll_ex_dev);
        free_irq(ll_ex_dev->dma_tx_irq, ll_ex_dev);

        if (ll_ex_dev->mapaddr) {
            iounmap(ll_ex_dev->mapaddr);
        }

        kfree(ll_ex_dev);
    }

    devno = MKDEV(LL_EX_DEV_MAJ, 0);
    unregister_chrdev_region(devno, 1);
}

/*
 * xll_example_setup:
 * Hook the driver into the filesystem and perform hardware setup.
 */
static int xll_example_setup (struct ll_ex_dev *ll_ex_dev)
{
    dev_t devno;
    int   err;
    u32   dma_tx_int_mask, dma_rx_int_mask;
    struct proc_dir_entry *proc_entry;
 
    devno = MKDEV(LL_EX_DEV_MAJ, 0);
    ll_ex_dev->devno = devno;
    err = register_chrdev_region(devno, 1, "ll_example");
    if (err < 0) {
        printk(KERN_ERR "%s: Unable to register chrdev %d.\n",
               DRIVER_NAME, LL_EX_DEV_MAJ);
        goto cleanup;
    }

    /*
     * Memory Map LL_EXAMPLE core to a virtual address
     */
    ll_ex_dev->mapaddr = ioremap(ll_ex_dev->physaddr, ll_ex_dev->addrsize);
    printk("%s: mapped to 0x%08x.\n", DRIVER_NAME, (u32)ll_ex_dev->mapaddr);

    printk("%s: DMA DCR address: 0x%0x\n", DRIVER_NAME, ll_ex_dev->dma_addr);
    XLlDma_Initialize(&ll_ex_dev->Dma, ll_ex_dev->dma_addr);

    /*
     * Initialize the LLDMA descriptor ring.
     */
    err = descriptor_init(ll_ex_dev);
    if (err) {
        printk(KERN_ERR
               "%s: Descriptor init failed (%d).\n",
               DRIVER_NAME, err);
        err = -EIO;
        goto cleanup;
    }

    /*
     * set the packet threshold and wait bound for both TX/RX directions
     */
    dma_tx_int_mask = XLLDMA_CR_IRQ_ALL_EN_MASK;
    err = XLlDma_BdRingSetCoalesce(&ll_ex_dev->Dma.TxBdRing,
              DFT_TX_THRESHOLD, DFT_TX_WAITBOUND);
    if (err != XST_SUCCESS)
    {
        printk(KERN_ERR
               "%s: could not set SEND pkt threshold/waitbound, ERROR %d",
               DRIVER_NAME, err);
    }
    XLlDma_mBdRingIntEnable(&ll_ex_dev->Dma.TxBdRing, dma_tx_int_mask);

    dma_rx_int_mask = XLLDMA_CR_IRQ_ALL_EN_MASK;
    err = XLlDma_BdRingSetCoalesce(&ll_ex_dev->Dma.RxBdRing,
              DFT_RX_THRESHOLD, DFT_RX_WAITBOUND);
    if (err != XST_SUCCESS)
    {
        printk(KERN_ERR
               "%s: Could not set RECV pkt threshold/waitbound ERROR %d",
               DRIVER_NAME, err);
    }
    XLlDma_mBdRingIntEnable(&ll_ex_dev->Dma.RxBdRing, dma_rx_int_mask);

    /*
     * Allocate DMA interrupts and register driver interrupt handler.
     */
    printk(KERN_INFO
           "%s: allocating interrupt %d for dma tx.\n",
           DRIVER_NAME, ll_ex_dev->dma_tx_irq);
    err = request_irq(ll_ex_dev->dma_tx_irq,
                 &xllex_dma_tx_interrupt, 0, "xilinx_dma_tx_int", ll_ex_dev);
    if (err) {
        printk(KERN_ERR
               "%s: could not allocate interrupt %d (%d).\n",
               DRIVER_NAME, ll_ex_dev->dma_tx_irq, err);
        goto cleanup;
    }

    printk(KERN_INFO
           "%s: allocating interrupt %d for dma rx.\n",
           DRIVER_NAME, ll_ex_dev->dma_rx_irq);
    err = request_irq(ll_ex_dev->dma_rx_irq,
                 &xllex_dma_rx_interrupt, 0, "xilinx_dma_rx_int", ll_ex_dev);
    if (err) {
        printk(KERN_ERR
               "%s: could not allocate interrupt %d.\n",
               DRIVER_NAME, ll_ex_dev->dma_rx_irq);
        goto cleanup;
    }

    if (XLlDma_BdRingStart(&ll_ex_dev->Dma.TxBdRing) == XST_FAILURE) {
        printk(KERN_ERR "%s: XLlTemac: could not start dma tx channel\n",
               DRIVER_NAME);
        err = -EIO;
        goto cleanup;
    }
    if (XLlDma_BdRingStart(&ll_ex_dev->Dma.RxBdRing) == XST_FAILURE) {
        printk(KERN_ERR "%s: XLlTemac: could not start dma rx channel\n",
               DRIVER_NAME);
        err = -EIO;
        goto cleanup;
    }

    /*
     * Plug the character device into the filesystem
     */
    cdev_init(&ll_ex_dev->cdev, &ll_ex_fops);
    ll_ex_dev->cdev.owner = THIS_MODULE;
    err = cdev_add(&ll_ex_dev->cdev, devno, 1);
    if (err) {
        printk(KERN_NOTICE "Error %d adding %s", err, DRIVER_NAME);
        goto cleanup;
    }

    proc_entry = create_proc_entry("driver/ll_example_drvr", 0, NULL);
    if (proc_entry) {
        proc_entry->proc_fops = &llex_proc_ops;
    }

cleanup:
    if (err) {
        xll_example_remove();
    }
    return err;
}

/*
 * Initialize the driver
 * This function is called as the result of an Open Firmware (device tree)
 * match of an entry in xll_example_of_match[] against
 * linux/arch/powerpc/boot/dts/ml507.dts which contains an
 * xps-ll-example-1.00.a  compatible entry.
 */
static int __devinit xll_example_of_probe (struct of_device *ofdev,
                                           const struct of_device_id *match)
{
    struct device_node *dma_of_node;
    const phandle      *llink_connected_handle;
    struct resource     r_mem, r_irq;
    int err;

    printk(KERN_INFO "Device Tree Probing \'%s\'\n",
                        ofdev->node->name);

    /*
     * Allocate a private structure to manage this device.
     */
    ll_ex_dev = kmalloc(sizeof(struct ll_ex_dev), GFP_KERNEL);
    if (ll_ex_dev == NULL) {
        return -ENOMEM;
    }
    memset(ll_ex_dev, 0, sizeof(struct ll_ex_dev));
    mutex_init(&ll_ex_dev->mutex);
    INIT_LIST_HEAD(&ll_ex_dev->rx_buffer_list);

    /*
     * What is the physical address of the peripheral?
     */
    err = of_address_to_resource(ofdev->node, 0, &r_mem);
    if (err) {
        dev_warn(&ofdev->dev, "invalid address\n");
        return err;
    }
    ll_ex_dev->physaddr = r_mem.start;
    ll_ex_dev->addrsize = r_mem.end - r_mem.start + 1;

    /*
     * Which Local Link DMA engine is this core connected to?
     */
    llink_connected_handle =
        of_get_property(ofdev->node, "llink-connected", NULL);
    if (llink_connected_handle == NULL) {
        printk(KERN_ERR "%s: no Locallink connection found.\n", DRIVER_NAME);
        return -ENODEV;
    }

    dma_of_node = of_find_node_by_phandle(*llink_connected_handle);
    if (dma_of_node == NULL) {
        printk(KERN_ERR "%s: no DMA controller found.\n", DRIVER_NAME);
        return -ENODEV;
    }

    /*
     * Address of the DMA controller?
     */
    err = of_address_to_resource(dma_of_node, 0, &r_mem);
    if (err) {
        u32 * dcrreg_property;

        /*
         * The DMA controller is not a memory-mapped peripheral (MPMC);
         * the only other choice is DCR (ML507).
         */

        dcrreg_property = (u32 *)of_get_property(dma_of_node, "dcr-reg", NULL); 
        if (dcrreg_property) {
            ll_ex_dev->dma_addr = *dcrreg_property;
        } else {
            printk(KERN_ERR "%s: Unable to determine DMA controller address.\n",
                   DRIVER_NAME);
            return -ENODEV;
        }

    } else {
        /*
         * Address of memory mapped DMA controller (MPMC).
         */
        ll_ex_dev->dma_addr = r_mem.start;
    }

    /* DMA RX and TX IRQs */

    err = of_irq_to_resource(dma_of_node, 0, &r_irq);
    if (err == NO_IRQ) {
        printk(KERN_ERR "%s: First DMA IRQ not found.\n", DRIVER_NAME);
        return err;
    }
    ll_ex_dev->dma_rx_irq = r_irq.start;

    err = of_irq_to_resource(dma_of_node, 1, &r_irq);
    if (err == NO_IRQ) {
        printk(KERN_ERR "%s: Second DMA IRQ not found.\n", DRIVER_NAME);
        return err;
    }
    ll_ex_dev->dma_tx_irq = r_irq.start;

    /* Set the device for map/unmap calls */
    ll_dev = &ofdev->dev;	

    /*
     * Hook the driver into the system and perform hardware setup.
     */
    err = xll_example_setup(ll_ex_dev);

    return err;
}

static int __devexit xll_example_of_remove(struct of_device *dev)
{
    xll_example_remove();
    return 0;
}

/*
 * List of items which might be found in the device tree which could
 * be serviced by this driver.
 */
static struct of_device_id xll_example_of_match[] = {
    { .compatible = "xlnx,xps-ll-example-1.00.a", },
    {}
};

MODULE_DEVICE_TABLE(of, xll_example_of_match);

static struct of_platform_driver xll_example_of_driver = {
    .name        = DRIVER_NAME,
    .match_table = xll_example_of_match,
    .probe       = xll_example_of_probe,
    .remove      = __devexit_p(xll_example_of_remove)
};

/*
 * Absolute initialization entry point for the driver.
 * Everything begins here.
 */
static int __init xll_example_init(void)
{
    int status;

    status = of_register_platform_driver(&xll_example_of_driver);

    return status;
}

static void __exit xll_example_cleanup(void)
{
    of_unregister_platform_driver(&xll_example_of_driver);
}

module_init(xll_example_init);
module_exit(xll_example_cleanup);

MODULE_AUTHOR("Xilinx, Inc.");
MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
MODULE_LICENSE("GPL");
