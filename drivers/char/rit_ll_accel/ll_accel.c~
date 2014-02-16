/*****************************************************************************
 *
 * Author: Nick Palladino
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *****************************************************************************/

/*****************************************************************************
 *
 * This driver allows for DMA transfers to fifo acclelerators via a LocalLink
 * interface. Partial Dynamic Reconfiguration is performed by utilizing the 
 * HWICAP IP available from Xilinx. This driver can support multiple DMA 
 * channels. The number of accelerators per channel is variable. This can be 
 * configured in the dts file or at runtime with module parameters when loading
 * the driver. To actually change the number of accelerators, the hardware 
 * design must be modified and a new static firmware must be generated. For the
 * purposes of this research, a single channel is utilized and the number of 
 * available reconfigurable partitions is set to 4 in the hardware design. The
 * HWICAP functionality in this driver is only a subset of the Xilinx driver.
 * For the purposes of this research, only writing to Virtex-5 devices is 
 * supported. The HWICAP code was moved to this driver so that accelerator 
 * configuration access and protection could be handled in kernel space.
 *
 *****************************************************************************/

#define DEBUG	1
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

#include <asm/uaccess.h>
#include <linux/dma-mapping.h>

#include <linux/interrupt.h>

#include <linux/proc_fs.h>
#include <linux/seq_file.h>

// was #include "xlldma.h"
#include "ll_accel.h"
#include "fifo_icap.h"

#define DRIVER_NAME         "ll_accel"
#define DRIVER_DESCRIPTION  "LocalLink DMA/PDR Framework"
#define DRIVER_VERSION      "1.00a"

#define HWTIME
#define UNIMPLEMENTED 0xFFFF

#ifdef HWTIME
	#define HWTIME_READ_TOTAL	  0
	#define HWTIME_WRITE_TOTAL  1
	#define HWTIME_MEM2ACC      2
	#define HWTIME_ACC2MEM      3
	#define HWTIME_K2U          4
	#define HWTIME_U2K          5
	#define HWTIME_WRITE_DONE		6
	#define HWTIME_DMA_TX_SETUP	7
	#define HWTIME_DMA_RX_SETUP	8
	#define HWTIME_ACCEL_DONE	  9
  #define HWTIME_MEM2ICAP     10
  #define HWTIME_ICAP_TOTAL   11
	#define HWTIME_SIZE         12
	uint32_t tb_data[HWTIME_SIZE];
	//unsigned int total_blocks;
	//uint32_t tb_data[HWTIME_SIZE], tb_temp;
#endif

// Global variables

int ll_accel_major = LL_ACCEL_MAJOR;
int ll_accel_minor = LL_ACCEL_MINOR;
int ll_accel_nr_devs = LL_ACCEL_NR_DEVS;	/* number of bare devices */

unsigned long tx_cycles;
unsigned int rx_done;
unsigned int rx_start;
unsigned int plb_cycles, tb_cycles;
unsigned int rx_ints = 0;
//unsigned int rx_sop;
//unsigned int rx_eop;
unsigned int rx_complete;
unsigned int after_dma_send;
unsigned int tx_poll_time;

unsigned int tx_int, rx_int, done_int, done_plb;

struct ll_accel_dev *ll_accel_devices;
struct device *ll_dev;
struct dma_channel *dma;
struct plb_info *plb;
struct hwicap_drvdata *drvdata;

// sysfs class
static struct class *ll_accel_class;

static void DmaSendHandlerBH(unsigned long p);
static void DmaRecvHandlerBH(unsigned long p);

DECLARE_TASKLET(ExDmaSendBH, DmaSendHandlerBH, 0);
DECLARE_TASKLET(ExDmaRecvBH, DmaRecvHandlerBH, 0);

// HWICAP structs
static struct hwicap_driver_config fifo_icap_config = {
	.get_configuration = fifo_icap_get_configuration,
	.set_configuration = fifo_icap_set_configuration,
	.get_status = fifo_icap_get_status,
	.reset = fifo_icap_reset,
};

static const struct config_registers v5_config_registers = {
	.CRC = 0,
	.FAR = 1,
	.FDRI = 2,
	.FDRO = 3,
	.CMD = 4,
	.CTL = 5,
	.MASK = 6,
	.STAT = 7,
	.LOUT = 8,
	.COR = 9,
	.MFWR = 10,
	.FLR = UNIMPLEMENTED,
	.KEY = UNIMPLEMENTED,
	.CBC = 11,
	.IDCODE = 12,
	.AXSS = 13,
	.C0R_1 = 14,
	.CSOB = 15,
	.WBSTAR = 16,
	.TIMER = 17,
	.BOOTSTS = 22,  //18,
	.CTL_1 = 24,    //19,
};

/*****************************************************************************
 * HWICAP Functions
 * 
 * These are taken from the xilinx_hwicap driver, some code duplication is the
 * result if you are using the HWICAP driver in your kernel as well. However,
 * this should never be the case, otherwise bad things will happen due to this
 * driver and the Xilinx driver fighting over the same hardware.
 *****************************************************************************/

/*
 * hwicap_command_desync - Send a DESYNC command to the ICAP port.fread
 * @drvdata: a pointer to the drvdata.
 *
 * This command desynchronizes the ICAP After this command, a
 * bitstream containing a NULL packet, followed by a SYNCH packet is
 * required before the ICAP will recognize commands.
 */
static int hwicap_command_desync(struct hwicap_drvdata *drvdata)
{
	u32 buffer[4];
	u32 index = 0;

	/*
	 * Create the data to be written to the ICAP.
	 */
	buffer[index++] = hwicap_type_1_write(drvdata->config_regs->CMD) | 1;
	buffer[index++] = XHI_CMD_DESYNCH;
	buffer[index++] = XHI_DUMMY_PACKET;
	buffer[index++] = XHI_DUMMY_PACKET;	// was noop

	/*
	 * Write the data to the FIFO and intiate the transfer of data present
	 * in the FIFO to the ICAP device.
	 */
	return drvdata->config->set_configuration(drvdata,
			&buffer[0], index);
}

/*
 * hwicap_get_configuration_register - Query a configuration register.
 * @drvdata: a pointer to the drvdata.
 * @reg: a constant which represents the configuration
 *		register value to be returned.
 * 		Examples:  XHI_IDCODE, XHI_FLR.
 * @reg_data: returns the value of the register.
 *
 * Sends a query packet to the ICAP and then receives the response.
 * The icap is left in Synched state.
 */
static int hwicap_get_configuration_register(struct hwicap_drvdata *drvdata,
		u32 reg, u32 *reg_data)
{
	int status;
	u32 buffer[6];
	u32 index = 0;

	/*
	 * Create the data to be written to the ICAP.
	 */

	buffer[index++] = XHI_DUMMY_PACKET;
	buffer[index++] = XHI_SYNC_PACKET;
	buffer[index++] = XHI_NOOP_PACKET;

	/*
	 * Write the data to the FIFO and initiate the transfer of data present
	 * in the FIFO to the ICAP device.
	 */
	status = drvdata->config->set_configuration(drvdata,
						    &buffer[0], index);
	if (status)
		return status;

	/* If the syncword was not found, then we need to start over. */
	status = drvdata->config->get_status(drvdata);
	if ((status & XHI_SR_DALIGN_MASK) != XHI_SR_DALIGN_MASK) {
		printk("SYNC WORD NOT FOUND\n");
		return -EIO;
	}

	index = 0;
	buffer[index++] = hwicap_type_1_read(reg) | 1;
	buffer[index++] = XHI_NOOP_PACKET;
	buffer[index++] = XHI_NOOP_PACKET;

	/*
	 * Write the data to the FIFO and intiate the transfer of data present
	 * in the FIFO to the ICAP device.
	 */
	status = drvdata->config->set_configuration(drvdata,
			&buffer[0], index);
	if (status)
		return status;

	/*
	 * Read the configuration register
	 */
	status = drvdata->config->get_configuration(drvdata, reg_data, 1);
	if (status)
		return status;

	return 0;
}

/*
 * 
 */
static int hwicap_initialize_hwicap(void)
{
	int status;
	u32 idcode;

	dev_dbg(drvdata->dev, "initializing\n");

	/* Abort any current transaction, to make sure we have the
	 * ICAP in a good state. */
	dev_dbg(drvdata->dev, "Reset...\n");
	drvdata->config->reset(drvdata);

	dev_dbg(drvdata->dev, "Desync...\n");
	status = hwicap_command_desync(drvdata);
	if (status)
		return status;

	/* Attempt to read the IDCODE from ICAP.  This
	 * may not be returned correctly, due to the design of the
	 * hardware.
	 */
  dev_dbg(drvdata->dev, "Reading Dummy IDCODE...\n");
	printk("Reading Dummy IDCODE...\n");
	status = hwicap_get_configuration_register(
			drvdata, drvdata->config_regs->IDCODE, &idcode);

	dev_dbg(drvdata->dev, "Reading IDCODE...\n");
	printk("Reading IDCODE...\n");
	status = hwicap_get_configuration_register(
			drvdata, drvdata->config_regs->IDCODE, &idcode);

  idcode &= XHI_DEVICE_ID_CODE_MASK;
	dev_dbg(drvdata->dev, "IDCODE = %x\n", idcode);
	printk("IDCODE = %x\n", idcode);
	if (status)
		return status;

	dev_dbg(drvdata->dev, "Desync...\n");
	printk("Desync...\n");
	status = hwicap_command_desync(drvdata);
	if (status)
		return status;

	dev_dbg(drvdata->dev, "Reset...\n");
	printk("Reset...\n");
	drvdata->config->reset(drvdata);

	return 0;
}

/*
 * Probably can get rid of a bunch of stuff from here?
 */
static int hwicap_setup(struct device *dev, //__devinit
		const struct resource *regs_res,
		const struct hwicap_driver_config *config,
		const struct config_registers *config_regs)
{
	//dev_t devt;
	//struct hwicap_drvdata *drvdata = NULL;
	int retval = 0;

	dev_info(dev, "ll-accel icap port driver\n");

	//devt = MKDEV(XHWICAP_MAJOR, XHWICAP_MINOR + id);

	drvdata = kzalloc(sizeof(struct hwicap_drvdata), GFP_KERNEL);
	if (!drvdata) {
		dev_err(dev, "Couldn't allocate device private record\n");
		retval = -ENOMEM;
		goto failed0;
	}
	dev_set_drvdata(dev, (void *)drvdata);

	if (!regs_res) {
		dev_err(dev, "Couldn't get registers resource\n");
		retval = -EFAULT;
		goto failed1;
	}

	drvdata->mem_start = regs_res->start;
	drvdata->mem_end = regs_res->end;
	drvdata->mem_size = regs_res->end - regs_res->start + 1;

	if (!request_mem_region(drvdata->mem_start,
					drvdata->mem_size, DRIVER_NAME)) {
		dev_err(dev, "Couldn't lock memory region at %Lx\n",
			(unsigned long long) regs_res->start);
		retval = -EBUSY;
		goto failed1;
	}

	//drvdata->devt = devt;
	drvdata->dev = dev;
	drvdata->base_address = ioremap(drvdata->mem_start, drvdata->mem_size);
	if (!drvdata->base_address) {
		dev_err(dev, "ioremap() failed\n");
		goto failed2;
	}

	drvdata->config = config;
	drvdata->config_regs = config_regs;

	mutex_init(&drvdata->sem);
	drvdata->is_open = 0;

	dev_info(dev, "ioremap %llx to %p with size %llx\n",
		 (unsigned long long) drvdata->mem_start,
		 drvdata->base_address,
		 (unsigned long long) drvdata->mem_size);

	//cdev_init(&drvdata->cdev, &hwicap_fops);
	//drvdata->cdev.owner = THIS_MODULE;
	//retval = cdev_add(&drvdata->cdev, devt, 1);
	//if (retval) {
	//	dev_err(dev, "cdev_add() failed\n");
	//	goto failed3;
	//}

	//device_create(icap_class, dev, devt, NULL, "%s%d", DRIVER_NAME, id);

	return 0;		/* success */

 //failed3:
 //	iounmap(drvdata->base_address);

 failed2:
	release_mem_region(regs_res->start, drvdata->mem_size);

 failed1:
	kfree(drvdata);

 failed0:
	//mutex_lock(&icap_sem);
	//probed_devices[id] = 0;
	//mutex_unlock(&icap_sem);

	return retval;
}

/*****************************************************************************
 * DMA Functions
 *****************************************************************************/

/*
 * xll_ex_DmaSend
 * "transmit" the indicated buffer to the LL Example core.
 */

// Add here to target specific accelerator
// want a single Dma engine shared between all accelerators
// need to make sure this has a mutex for dma structure

static int
xll_ex_DmaSend (void *buff, size_t buff_len, struct ll_accel_dev *ll_accel_dev)
{

#ifdef HWTIME
	tb_data[HWTIME_DMA_TX_SETUP] = get_tbl();
#endif

    XLlDma_Bd *bd_ptr;
    dma_addr_t phy_addr;
    int        result;

		// prevent multiple accelerators modifying dma channel at once
		//mutex_lock(&dma->mutex);		

    //spin_lock_irqsave(&dma->lock, dma->lock_flags);
    result = XLlDma_BdRingAlloc(&ll_accel_dev->dma->Dma.TxBdRing, 1, &bd_ptr);
    

    if (result != XST_SUCCESS) {
        //if (llex_debug) {
            printk(KERN_ERR
                   "%s %s: Unable to allocate TX BdRing\n",
                   DRIVER_NAME, __FUNCTION__);
        //}
        return result;
    }
    
    /*
     * Get the physical address of the buffer.
     */
    //end = get_tbl();
    //printk("Time to alloc ring = %d\n", end-start);
    //start = get_tbl();

    phy_addr = (u32) dma_map_single(ll_dev, buff, buff_len, DMA_TO_DEVICE);

		//printk("Map single complete\n");

    //end = get_tbl();
    // printk("Time to flush cache = %d\n", end-start);
    //start = get_tbl();

		/* Setup decriptor fields */
    XLlDma_mBdSetBufAddr(bd_ptr, phy_addr);
    XLlDma_mBdSetLength(bd_ptr, buff_len);
    XLlDma_mBdSetId(bd_ptr, buff);
    XLlDma_mBdSetStsCtrl(bd_ptr, XLLDMA_BD_STSCTRL_SOP_MASK |
                                 XLLDMA_BD_STSCTRL_EOP_MASK |
                                 XLLDMA_BD_STSCTRL_IOE_MASK); // added this

    // Here, set APP1 field according to which accelerator this transfer should 
		// go to

		printk("Sending %d bytes to Accel %d\n", buff_len, MINOR((ll_accel_dev->cdev).dev));

		XLlDma_mBdWrite(bd_ptr, XLLDMA_BD_USR1_OFFSET, MINOR((ll_accel_dev->cdev).dev));
    XLlDma_mBdWrite(bd_ptr, XLLDMA_BD_USR2_OFFSET, 0x02);
		XLlDma_mBdWrite(bd_ptr, XLLDMA_BD_USR3_OFFSET, 0x03);
		XLlDma_mBdWrite(bd_ptr, XLLDMA_BD_USR4_OFFSET, 0x04);

		//printk("%s: About to Enqueue\n",DRIVER_NAME);
    //end = get_tbl();
    //printk("Time up to enqueue = %d\n", end-start);
    //end = get_tbl();    

    //unsigned int status = 0; 

    // For testing now, disable ints
    //XLlDma_mBdRingIntDisable(&dma->Dma.TxBdRing,
    //                         XLLDMA_CR_IRQ_ALL_EN_MASK);

    //status = XLlDma_mReadReg(ll_accel_dev->dma->Dma.TxBdRing.ChanBase,XLLDMA_SR_OFFSET);
    //printk("Status Before Enqueue = %u", status);

    //tx_poll_time = get_tbl();

    /* Enqueue to HW */
    result = XLlDma_BdRingToHw(&ll_accel_dev->dma->Dma.TxBdRing, 1, bd_ptr);
    //spin_unlock_irqrestore(&dma->lock, dma->lock_flags);



    //status = XLlDma_mReadReg(ll_accel_dev->dma->Dma.TxBdRing.ChanBase,XLLDMA_SR_OFFSET);
    //printk("Status After Enqueue = %u", status);

    

    // wait for controller to complete transfer
    
    //do
    //{
    //  status = XLlDma_mReadReg(ll_accel_dev->dma->Dma.TxBdRing.ChanBase,XLLDMA_SR_OFFSET);
    //} while (status & XLLDMA_SR_COMPLETED_MASK & XLLDMA_SR_ENGINE_BUSY_MASK == 0);

    //status = XLlDma_mReadReg(ll_accel_dev->dma->Dma.TxBdRing.ChanBase,XLLDMA_SR_OFFSET);
    //printk("Status After Polling = %u", status);

    //tx_poll_time = get_tbl() - tx_poll_time;
  

#ifdef HWTIME
    //asm volatile("isync");
		//asm volatile("eieio");
		tb_data[HWTIME_MEM2ACC] = get_tbl();
		tb_data[HWTIME_DMA_TX_SETUP] = tb_data[HWTIME_MEM2ACC] - tb_data[HWTIME_DMA_TX_SETUP];
#endif

     // re-enable DMA interrupts
    //XLlDma_mBdRingIntEnable(&dma->Dma.TxBdRing, XLLDMA_CR_IRQ_ALL_EN_MASK);

		//tx_cycles = get_tbl();
    //tx = get_tb() - tx;
    //printk("Check Success\n");

    if (result != XST_SUCCESS) {
        kfree(buff);
        XLlDma_mBdSetId(bd_ptr, NULL);
        //ll_accel_dev->errors++;
        printk(KERN_ERR
               "%s: could not send commit TX buffer descriptor (%d).\n",
               DRIVER_NAME, result);

        return XST_FAILURE;
    }

    ll_accel_dev->tx_buffers++;
    ll_accel_dev->tx_bytes += buff_len;

		//printk("%s: Finished DMA Send\n",DRIVER_NAME);
	
		//mutex_unlock(&dma->mutex);

    return XST_SUCCESS;
}


/*****************************************************************************
 * /proc File Operations
 *****************************************************************************/

static void *ll_accel_proc_seq_start (struct seq_file *s, loff_t *pos)
{
    //if (*pos == 0) {
		if (*pos >= ll_accel_nr_devs)
        return NULL; 

    return ll_accel_devices + *pos;
}

static void *ll_accel_proc_seq_next (struct seq_file *s, void *v, loff_t *pos)
{
    (*pos)++;

    if (*pos >= ll_accel_nr_devs)
			return NULL;

		return ll_accel_devices + *pos;
}

static void ll_accel_proc_seq_stop (struct seq_file *s, void *v)
{
}

/*
 * llex_proc_seq_show:
 * Produces the data displayed for a /proc read operation
 */
static int ll_accel_proc_seq_show (struct seq_file *s, void *v)
{
    struct ll_accel_dev *dev;

    dev = v;
    mutex_lock(&dev->mutex);

		//seq_printf(s,"\nNumber of Accelerators: %d", ll_accel_nr_devs);
		seq_printf(s,"\nAccelerator %d Stats", MINOR((dev->cdev).dev));
		seq_printf(s,"\nOpens:\t\t%d", dev->opens);
		seq_printf(s,"\nCloses:\t\t%d", dev->closes);
    seq_printf(s,"\nReads:\t\t%d", dev->reads);
    seq_printf(s,"\nWrites:\t\t%d", dev->writes);
    seq_printf(s,"\nTX Poll Time:\t\t%u", tx_poll_time);
		//seq_printf(s,"\nLast Tx Cycles:\t\t%u", tx_cycles);
#ifdef HWTIME
		seq_printf(s,"\nWrite Total Cycles:\t\t%u", tb_data[HWTIME_WRITE_TOTAL]);
		seq_printf(s,"\nWrite U2K Cycles:\t\t%u", tb_data[HWTIME_U2K]);
		seq_printf(s,"\nWrite DMA Tx Setup Cycles:\t\t%u", tb_data[HWTIME_DMA_TX_SETUP]);
		seq_printf(s,"\nWrite DMA Tx Cycles:\t\t%u", tb_data[HWTIME_MEM2ACC]);
		seq_printf(s,"\nRead Total Cycles:\t\t%u", tb_data[HWTIME_READ_TOTAL]);
		seq_printf(s,"\nRead Accel Exec Wait Cycles:\t\t%u", tb_data[HWTIME_ACCEL_DONE]);
		seq_printf(s,"\nRead DMA Rx Cycles:\t\t%u", tb_data[HWTIME_ACC2MEM]);
		seq_printf(s,"\nRead DMA Rx Setup Cycles:\t\t%u", tb_data[HWTIME_DMA_RX_SETUP]);	
		seq_printf(s,"\nRead K2U Cycles:\t\t%u", tb_data[HWTIME_K2U]);	

    seq_printf(s,"\nICAP Total Cycles:\t\t%u", tb_data[HWTIME_ICAP_TOTAL]);	
    seq_printf(s,"\nICAP MEM2ICAP Cycles:\t\t%u", tb_data[HWTIME_MEM2ICAP]);	

    // HW timing stats
    int tx_sof = in_be32(plb->mapaddr + 0x010);
    int tx_eof = in_be32(plb->mapaddr + 0x014);
    int rx_sof = in_be32(plb->mapaddr + 0x018);
    int rx_eof = in_be32(plb->mapaddr + 0x01C);

    seq_printf(s,"\nTX SOF:\t\t%u", tx_sof);
    seq_printf(s,"\nTX EOF:\t\t%u", tx_eof);
    seq_printf(s,"\nRX SOF:\t\t%u", rx_sof);
    seq_printf(s,"\nRX EOF:\t\t%u", rx_eof);
    seq_printf(s,"\nTX Packet Time:\t\t%u", tx_eof-tx_sof);
    seq_printf(s,"\nRX Packet Time:\t\t%u", rx_eof-rx_sof);

    seq_printf(s,"\nReg0:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP1_REG));
    seq_printf(s,"\nReg1:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP2_REG));
	  seq_printf(s,"\nReg2:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP3_REG));
    seq_printf(s,"\nReg3:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP4_REG));
    // tx_int, rx_int, done_int;
/*
    seq_printf(s,"\nTX Int Time:\t\t%u", tx_int);
		seq_printf(s,"\nAccel Done Int Time:\t\t%u", done_int);	
		seq_printf(s,"\nRX Int Time:\t\t%u", rx_int);	
    seq_printf(s,"\nDone Int PLB Time:\t\t%u", done_plb);	
    seq_printf(s,"\nDone HW PLB Time:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP4_REG));	
    
    seq_printf(s,"\nOpens:\t\t%u", dev->opens);
*/
/*
		seq_printf(s,"\nRx Accel2Mem Cycles\t\t%u", tb_data[HWTIME_ACC2MEM]);
		seq_printf(s,"\nDmaSend Cycles:\t\t%u", tb_data[HWTIME_DMA_SETUP]);
		seq_printf(s,"\nRead K2U:\t\t%u", tb_data[HWTIME_K2U]);
		seq_printf(s,"\nAccel Done Time:\t\t%u", tb_data[HWTIME_ACCEL_DONE]);
*/
#endif
/*
		seq_printf(s,"\nLast Rx Cycles:\t\t%u", (rx_done - in_be32(plb->mapaddr + LL_ACCEL_APP4_REG))*4);
    seq_printf(s,"\nRX Ints:\t\t%u", rx_ints);
    seq_printf(s,"\nRx Time Done:\t\t%u", rx_done);
    seq_printf(s,"\nRx Time Start:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP4_REG));
		seq_printf(s,"\nRx Time EOF:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP5_REG));
		seq_printf(s,"\nRx Time Diff:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP5_REG) - in_be32(plb->mapaddr + LL_ACCEL_APP4_REG));
    seq_printf(s,"\nPLB Read Cycles:\t\t%u", plb_cycles*4); //convert from 100MHz to match TB
    seq_printf(s,"\nTB Read Cycles:\t\t%u", tb_cycles);
		seq_printf(s,"\nFifo0 Count:\t%d", in_be32(plb->mapaddr + LL_ACCEL_FIFO1_CNT_REG));
		seq_printf(s,"\nFifo1 Count:\t%d", in_be32(plb->mapaddr + LL_ACCEL_FIFO2_CNT_REG));
		seq_printf(s,"\nApp1:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP1_REG));
		seq_printf(s,"\nApp2:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP2_REG));
		seq_printf(s,"\nApp3:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP3_REG));
		seq_printf(s,"\nApp4:\t\t%u", in_be32(plb->mapaddr + LL_ACCEL_APP4_REG));
		seq_printf(s,"\nDMA Address:\t%x", dev->dma->dma_addr);
		seq_printf(s,"\nDMA Errors:\t%u", dma->errors);
		seq_printf(s,"\nSOP:\t%u", rx_sop);
		seq_printf(s,"\nEOP:\t%u", rx_eop);
		seq_printf(s,"\nComplete:\t%u", rx_complete);
		seq_printf(s,"\nEOP-SOP:\t%u", rx_eop-rx_sop);
		seq_printf(s,"\nComplete-SOP:\t%u", (rx_complete-rx_sop));
		seq_printf(s,"\nRight After Enqueue:\t%u", after_dma_send);
		seq_printf(s,"\nTX Int Time:\t%u", tb_data[HWTIME_WRITE_DONE]);
*/
    seq_printf(s,"\n");

/*
    seq_printf(s,"\nBuffer Descriptors: 0x%08x (Virtual 0x%08x)", 
               dev->desc_physaddr,
               (unsigned int) dev->desc_virtaddr);

    seq_printf(s,"\n");
*/

    mutex_unlock(&dev->mutex);
    return 0;
}

/*
 * /proc SEQ operations
 */
static struct seq_operations ll_accel_proc_seq_ops = {
        .start = ll_accel_proc_seq_start,
        .next  = ll_accel_proc_seq_next,
        .stop  = ll_accel_proc_seq_stop,
        .show  = ll_accel_proc_seq_show
};

/*
 * The open() operation sets up the sequence operators.
 */
static int ll_accel_proc_open(struct inode *inode, struct file *file)
{
        return seq_open(file, &ll_accel_proc_seq_ops);
}

/*
 * Create a set of file operations for our proc file.
 * only open() is provided locally.
 */
static struct file_operations ll_accel_proc_ops = {
        .owner   = THIS_MODULE,
        .open    = ll_accel_proc_open,
        .read    = seq_read,
        .llseek  = seq_lseek,
        .release = seq_release
};

/*****************************************************************************
 * File Operations
 *****************************************************************************/

/*
 * Open
 *
 * This driver handles all accelerators in the system based on their minor
 * numbers. Each minor number corresponds to a reconfigurable module slot
 * where a accelerator can be configured. The open operation checks if the
 * requested accelerator slot is available and takes the appropriate action.
 */

int ll_accel_open(struct inode *inode, struct file *filp)
{
	struct ll_accel_dev *dev;
	int accel_minor, retval;

	dev = container_of(inode->i_cdev, struct ll_accel_dev, cdev);
	filp->private_data = dev;
	
	// need a mutex here since modifying dev structure
	mutex_lock(&dev->mutex);
	
	accel_minor = MINOR((dev->cdev).dev);
	retval = 0;

	//printk("Opening ll_accel Minor #: %d\n", accel_minor);
	//printk("ioctl command: %d\n", LL_ACCEL_IOCSBITSTREAM);

	// accelerator requested corresponds to minor number

	/*
   * Check if requested accelerator is free
   */
	switch (filp->f_flags & O_ACCMODE) {
  	case O_RDONLY:
    	if (dev->readers) {
      	retval = -EBUSY;
        goto out;
      } else {
            dev->readers++;
            //ll_accel_devices[accel_minor]->read_off = 0;
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
            //dev->read_off = 0;
        }
    }

    dev->opens++;

out:
    mutex_unlock(&dev->mutex);
    return retval; 
}

/*
 * Close
 *
 * Update device statistics that change when the file descriptor is closed
 */

int ll_accel_release(struct inode *inode, struct file *filp)
{
	struct ll_accel_dev *dev = filp->private_data;
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
 * Write
 * A userspace write to the device file. Send the data to the LL core by DMA
 */

// write should block until write is finished and data is in fifo
// should also prevent other processes from modifying dma stuff
ssize_t ll_accel_write(struct file *filp, const char __user *buf,
                    	 size_t count, loff_t *f_pos)
{

#ifdef HWTIME
	tb_data[HWTIME_WRITE_TOTAL] = get_tbl();
#endif

	struct ll_accel_dev *dev = filp->private_data;
  ssize_t retval = 0;
  void   *buffer;
  unsigned long time_done;


	mutex_lock(&dev->mutex);

	//printk("%s: Entering Write\n",DRIVER_NAME);
	dev->writes++;
	
	if (count < LL_EX_MIN_BUF_SIZE) {
      count = LL_EX_MIN_BUF_SIZE;
  }
  count = min(count, (size_t)LL_EX_BUF_SIZE);


#ifdef HWTIME
	tb_data[HWTIME_U2K] = get_tbl();
#endif

  buffer = kmalloc(count + 1, GFP_KERNEL);
  if (buffer == NULL) {
  	retval = -ENOMEM;
    goto out;
  }
  memset(buffer, 0, LL_EX_MIN_BUF_SIZE);

	if (copy_from_user(buffer, buf, count)) {
  	retval = -EFAULT;
    goto out;
  }
                  

#ifdef HWTIME
	tb_data[HWTIME_U2K] = get_tbl() - tb_data[HWTIME_U2K];
  tb_data[HWTIME_DMA_TX_SETUP] = get_tbl();
#endif

	mutex_lock(&dma->write_mutex);
	retval = xll_ex_DmaSend(buffer, count, dev);
	

	if (retval != XST_SUCCESS) {
  	printk(KERN_ERR "%s: write op failed (%d)\n",
           DRIVER_NAME, retval);
    retval = -ERESTARTSYS;
  } else {
  	retval = count;
  }
  *f_pos += count;

  //printk("Waiting in write\n");

	// block process until we have Tx and BD cleanup completes
	if(wait_event_interruptible(dev->write_wait_queue, 
			 dev->write_done != 0) != 0) {
		  // if interrupt not handled, die gracefully
      printk("Write wait interrupted by signal - dying...\n");
      return -ERESTARTSYS;
  }
	// reset ready flag
  dev->write_done = 0;

  mutex_unlock(&dma->write_mutex);

	out:

  mutex_unlock(&dev->mutex);

#ifdef HWTIME
	tb_data[HWTIME_WRITE_TOTAL] = get_tbl() - tb_data[HWTIME_WRITE_TOTAL];
#endif

  //printk("Write done\n");

	return retval;
}

/*
 * ll_accel_read:
 * A userspace read of the device file.  Copy one of the receive 
 * buffers to userspace and remove it from the list.
 */

ssize_t ll_accel_read(struct file *filp, char __user *buf, size_t count,
                   loff_t *f_pos)
{

	#ifdef HWTIME
			tb_data[HWTIME_READ_TOTAL] = get_tbl();
	#endif

	struct ll_accel_dev *dev = filp->private_data;
  ssize_t retval = 0;
  ssize_t copybytes;
  struct llex_rx_buff *rx_buff;
  int err;
	unsigned int control;
  unsigned int accel_minor;

  //unsigned long start, end; 
  //plb_cycles = in_be32(plb->mapaddr + LL_ACCEL_APP3_REG);

  mutex_lock(&dev->mutex);

/*
  if (llex_debug) {
  	printk(KERN_INFO "\n%s: START: f_pos %lld  count %d\n",
           __FILE__, *f_pos, count);
  }
*/

  dev->reads++;

	//start = get_tb();
	//printk("READ: waiting for acclerator\n");

	// block process until accelerator is done processing
	if(wait_event_interruptible(dev->wait_done, 
			 dev->accel_done != 0) != 0) {
		  // if interrupt not handled, die gracefully
      printk("Wait accel done interrupted by signal - dying...\n");
      return -ERESTARTSYS;
  }
	// reset done flag
  dev->accel_done = 0;

#ifdef HWTIME
	tb_data[HWTIME_ACCEL_DONE] = get_tbl() - tb_data[HWTIME_READ_TOTAL];
#endif

  accel_minor = MINOR((dev->cdev).dev);
  //printk("About to tell HW to send up results for accel %u\n", accel_minor);

  mutex_lock(&dma->read_mutex);

	// Tell HW to send results up, set Msb, leave accel 0 for now
	control = 0x80000000;
  control |= accel_minor;
	asm volatile("sync");
	out_be32(plb->mapaddr + LL_ACCEL_APP1_REG, control);
	asm volatile("sync");

#ifdef HWTIME
	tb_data[HWTIME_ACC2MEM] = get_tbl();
#endif

	// block process until we have something in the rx_buffer_list
	if(wait_event_interruptible(dev->wait_queue, 
			 dev->read_ready != 0) != 0) {
		  // if interrupt not handled, die gracefully
      printk("Read wait interrupted by signal - dying...\n");
      return -ERESTARTSYS;
  }
	// reset ready flag
  dev->read_ready = 0;

  //mutex_unlock(&plb->mutex);

  //printk("READ about to copy data\n");

	/*
   * Ensure that the RX Bottom-Half IRQ handler doesn't modify rx_buffer_list
   * while we are looking at it here.
   */
  tasklet_disable(&ExDmaRecvBH);

  mutex_unlock(&dma->read_mutex);

#ifdef HWTIME
	tb_data[HWTIME_K2U] = get_tbl();
	tb_data[HWTIME_DMA_RX_SETUP] = tb_data[HWTIME_K2U] - tb_data[HWTIME_DMA_RX_SETUP];
#endif

  /*
   * Anything received from the LL Example core? (old code, non-blocking)
   */
	//printk("About to do while loop\n");

  //if (list_empty(&dev->rx_buffer_list)) {
  //	goto out;
  //}

	while (!list_empty(&dev->rx_buffer_list)) {

  	rx_buff = list_entry(dev->rx_buffer_list.next,
                     	   struct llex_rx_buff, list);

 	 /*
  	* How many bytes to copy -- the lesser of the entire DMA buffer or
   	* available user buffer size.
   	*/
  	copybytes = min(rx_buff->data_len - dev->read_off, count);

    //printk("Copying %u bytes", copybytes);

  	/*
  	 * Copy this buffer to user space.
  	 */
  	err = copy_to_user(buf, rx_buff->data + dev->read_off, copybytes);
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
      	dev->read_off += copybytes;
/*
  	if (llex_debug) {
    	printk(KERN_INFO
             "\n%s: NOFIT: copybytes %d count %d data_len %d \n",
             __FILE__, copybytes, count, rx_buff->data_len);
    }
*/
 	 }

  	/*
   	 * If the entire DMA buffer has been copied, free it.
   	 * With the presently chosen buffer size (1K) it is expected that this
   	 * should happen every time.
   	 */
  	if ((dev->read_off == 0) ||
      	(dev->read_off == rx_buff->data_len)) {
      	 dev->read_off = 0;
      	 list_del(&rx_buff->list);
       	kfree(rx_buff);
  	}

    if (list_empty(&dev->rx_buffer_list)) {
  	  goto out;
    }
	} // while



	//printk("READ done\n");
/*
  if (llex_debug) {
      printk(KERN_INFO "\n%s: END: count %d read_off %d retval %d\n",
             __FILE__, count, ll_ex_dev->read_off, retval);
  }
*/

  out:

	#ifdef HWTIME
		tb_data[HWTIME_K2U] = get_tbl() - tb_data[HWTIME_K2U];
	#endif

  tasklet_enable(&ExDmaRecvBH);

  mutex_unlock(&dev->mutex);
  
	#ifdef HWTIME
			tb_data[HWTIME_READ_TOTAL] = get_tbl() - tb_data[HWTIME_READ_TOTAL];
	#endif

  return retval;
}

/*
 * ioctl() implementation
 *
 * ioctl calls are used for reconfiguring an accelerator slot. Once a user 
 * process has successfully opened a device, it can reconfigure the device
 * by passing in a partial bitstream. The bitstream must be for the correct
 * accelerator slot, otherwise another operating accelerator could be 
 * overwritten. This verification must be performed in userspace before the 
 * reconfigure ioctl call is made. In the future, this could be handled in 
 * the driver by looking at the frames being reconfigured in the bitstream 
 * data and verifying that it is targeting the correct accelerator. An even
 * better solution would be to support bitstream relocation, then a single
 * partial bitstream file could be targeted to any accelerator and there
 * would be no possibility of overwriting another operating accelerator.
 *
 */

int ll_accel_ioctl(struct inode *inode, struct file *filp,
                 unsigned int cmd, unsigned long arg)
{

	#ifdef HWTIME
		tb_data[HWTIME_ICAP_TOTAL] = get_tbl();
	#endif

	int err = 0;
	int retval = 0;
	ssize_t written = 0;
  //int index = 0;
  int i, status;
	ssize_t left, len;
  char *buffer;
  unsigned int *words;
  u32 *kbuf;
	unsigned long time; 

  bitstream_t bitstream; //changed from null (fix?)
    
  struct ll_accel_dev *dev = filp->private_data;
  unsigned int accel_minor = MINOR((dev->cdev).dev);

	/*
	 * extract the type and number bitfields, and don't decode
	 * wrong cmds: return ENOTTY (inappropriate ioctl) before access_ok()
	 */
	if (_IOC_TYPE(cmd) != LL_ACCEL_IOC_MAGIC) return -ENOTTY;
	if (_IOC_NR(cmd) > LL_ACCEL_IOC_MAXNR) return -ENOTTY;

	/*
	 * the direction is a bitmask, and VERIFY_WRITE catches R/W
	 * transfers. `Type' is user-oriented, while
	 * access_ok is kernel-oriented, so the concept of "read" and
	 * "write" is reversed
	 */
	if (_IOC_DIR(cmd) & _IOC_READ)
		err = !access_ok(VERIFY_WRITE, (void __user *)arg, _IOC_SIZE(cmd));
	else if (_IOC_DIR(cmd) & _IOC_WRITE)
		err =  !access_ok(VERIFY_READ, (void __user *)arg, _IOC_SIZE(cmd));
	if (err) return -EFAULT;

	switch(cmd) {
        
	  case LL_ACCEL_IOCSBITSTREAM: /* Set: arg points to the value */
			//if (! capable (CAP_SYS_ADMIN))
			//	return -EPERM;

			// only allow a single accelerator in here at a time
			//status = mutex_lock_interruptible(&drvdata->sem);
			//if (status) return status;

			//printk("LL_ACCEL_IOCSBITSTREAM ioctl()\n");

      #ifdef HWTIME
        tb_data[HWTIME_MEM2ICAP] = get_tbl();
	    #endif

      err = copy_from_user(&bitstream, (bitstream_t __user *)arg, sizeof(bitstream_t));
	    if (err) {
        printk("copy_from_user not copied = %d\n", err);
  	    retval = -EFAULT;
        goto out;
      }

      //printk("Bitstream size = %d\n", bitstream.size);
/*
      buffer = (char *)kmalloc(bitstream.size, GFP_KERNEL);
      if (buffer == NULL) {
        printk("Could not kmalloc\n");
  	    retval = -ENOMEM;
        goto out;
      }

      printk("Data Pointer = %x\n", bitstream.data);

      err = copy_from_user(buffer, bitstream.data, bitstream.size);
	    if (err) {
        printk("copy_from_user not copied = %d\n", err);
  	    retval = -EFAULT;
        goto out;
      }
*/
			//printk("Copied User Buffer\n");
/*  
      words = (unsigned int *)bitstream.data;

			for (i=0; i<(bitstream.size>>2); i++) {
        //printk("Word [%d] = %x\n", i, words[i]);
				status = drvdata->config->set_configuration(drvdata, &words[i], 1);
				if (status) printk("Problem in set_configuration\n");
			}

			printk("Completed for loop\n");
*/

			//time = get_tb();
		
			left = bitstream.size;
			left += drvdata->write_buffer_in_use;

			if (left < 4) {
			  printk("Error: left < 4\n");
				status = 0;
				goto out;
			}
      
			kbuf = (u32 *) __get_free_page(GFP_KERNEL);
	    if (!kbuf) {
		    printk("Error: Could not get free page\n");
		    status = -ENOMEM;
		    goto out;
	    }

      //Hold reset for fifos and accelerator about to be reconfigured 
      //printk("sending %u\n", 1 << accel_minor);
      //out_be32(plb->mapaddr + LL_ACCEL_APP2_REG, 1 << accel_minor);
      //out_be32(plb->mapaddr + LL_ACCEL_APP2_REG, 0xFFFFFFFF);

			while (left > 3) {

				len = left;

				//printk("left = %d\n", left);

				if (len > PAGE_SIZE) len = PAGE_SIZE;
				len &= ~3;

				if (drvdata->write_buffer_in_use) {
					memcpy(kbuf, drvdata->write_buffer,
					drvdata->write_buffer_in_use);
					if (copy_from_user(
			  		(((char *)kbuf) + drvdata->write_buffer_in_use),
			    	bitstream.data + written,
			    	len - (drvdata->write_buffer_in_use))) {
						printk("Error: could not copy_from_user 1\n");
						free_page((unsigned long)kbuf);
						status = -EFAULT;
						goto out;
					}
				} else {
					//printk("Got in else\n");
					err = copy_from_user(kbuf, bitstream.data + written, len);
					if (err) {
						printk("Written = %d, Len = %d\n", written, len);
						printk("copy_from_user not copied = %d\n", err);
						printk("Error: could not copy_from_user 2\n");
						free_page((unsigned long)kbuf);
						printk("Past free page\n");
						status = -EFAULT;
						goto out;
					}
				}

				for (i=0; i<len>>2; i++) {
					//status = drvdata->config->set_configuration(drvdata, kbuf, len >> 2);
					status = drvdata->config->set_configuration(drvdata, &kbuf[i], 1);
					if (status) {
						free_page((unsigned long)kbuf);
						printk("Error: set_configuration error\n");
						status = -EFAULT;
						goto out;
					}
				} // for
				if (drvdata->write_buffer_in_use) {
					len -= drvdata->write_buffer_in_use;
					left -= drvdata->write_buffer_in_use;
					drvdata->write_buffer_in_use = 0;
				}
				written += len;
				left -= len;
			} // while

			if ((left > 0) && (left < 4)) {
				if (!copy_from_user(drvdata->write_buffer,
					bitstream.data + written, left)) {
					drvdata->write_buffer_in_use = left;
					written += left;
					left = 0;
				}
			}

			free_page((unsigned long)kbuf);
			status = 0;

      #ifdef HWTIME
        tb_data[HWTIME_MEM2ICAP] = get_tbl() - tb_data[HWTIME_MEM2ICAP];
	    #endif

			out:
			//printk("Made it to out\n");
			//mutex_unlock(&drvdata->sem);
			//printk("Made it past sem\n");

      //out:
      //printk("Made it to out\n");

      //Clear reset for fifos and accelerator about to be reconfigured 
      out_be32(plb->mapaddr + LL_ACCEL_APP2_REG, 0xFFFFFFFF);
      out_be32(plb->mapaddr + LL_ACCEL_APP2_REG, 0);

			//time = get_tb() - time;
			//printk("Reconfigure Time = %ld Cycles\n", time);

			break;

	  default:  /* redundant, as cmd was checked against MAXNR */
		  return -ENOTTY;
	}

	#ifdef HWTIME
		tb_data[HWTIME_ICAP_TOTAL] = get_tbl() - tb_data[HWTIME_ICAP_TOTAL];
	#endif

	return status; // was retval
}

/*
 * File operations
 */

struct file_operations ll_accel_fops = {
	.owner =    THIS_MODULE,
	.read =     ll_accel_read,
	.write =    ll_accel_write,
	.ioctl =    ll_accel_ioctl,
	.open =     ll_accel_open,
	.release =  ll_accel_release,
};


/*****************************************************************************
 * Setup
 *****************************************************************************/

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
static void ll_accel_DmaSetupRecvBuffers(struct dma_channel *dma)
{
  int free_bd_count;
  int num_buffs;
  u32 new_buff_physaddr;
  XLlDma_Bd *BdPtr, *BdCurPtr;
  int result;

  free_bd_count = XLlDma_mBdRingGetFreeCnt(&dma->Dma.RxBdRing);

  result = XLlDma_BdRingAlloc(&dma->Dma.RxBdRing, free_bd_count, &BdPtr);
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
                                   XLLDMA_BD_STSCTRL_EOP_MASK |
                                   XLLDMA_BD_STSCTRL_IOE_MASK); //added descriptor processed

    BdCurPtr = XLlDma_mBdRingNext(&dma->Dma.RxBdRing, BdCurPtr);
  }

  /* enqueue RxBD with the attached buffers such that it is
   * ready for frame reception */
  result = XLlDma_BdRingToHw(&dma->Dma.RxBdRing, num_buffs, BdPtr);

  if (result != XST_SUCCESS) {
  	printk(KERN_ERR
           "%s: (DmaSetupRecvBuffers) BdRingToHw unsuccessful (%d)\n",
           DRIVER_NAME, result);
    BdCurPtr = BdPtr;
    while (num_buffs > 0) {
    	XLlDma_mBdSetId(BdCurPtr, NULL);
      BdCurPtr = XLlDma_mBdRingNext(&dma->Dma.RxBdRing,
                 BdCurPtr);
      num_buffs--;
    }
    return;
  }
}

/*
 * descriptor_init:
 * Allocate and set up RX/TX DMA descriptors.
 */
static int descriptor_init (struct dma_channel *dma) 
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
  dma->desc_virtaddr = kmalloc(dftsize, GFP_KERNEL);
  if (dma->desc_virtaddr == 0) {
   	printk(KERN_ERR "%s: Unable to allocate descriptors\n", DRIVER_NAME);
    return -ENOMEM;
  }

	/*
   * The physical address is what the DMA engine needs to use.
   */
  dma->desc_physaddr = (dma_addr_t)virt_to_phys(dma->desc_virtaddr);

  /* calc size of send and recv descriptor space */
  recvsize = XLlDma_mBdRingMemCalc(ALIGNMENT_BD, XLL_RECV_BD_CNT);
  sendsize = XLlDma_mBdRingMemCalc(ALIGNMENT_BD, XLL_SEND_BD_CNT);

  recvpoolptr = dma->desc_virtaddr;
  recvpoolphy = (void *) dma->desc_physaddr;
  sendpoolptr = (void *) ((u32) dma->desc_virtaddr + recvsize);
  sendpoolphy = (void *) ((u32) dma->desc_physaddr + recvsize);

  result = XLlDma_BdRingCreate(&dma->Dma.RxBdRing, (u32) recvpoolphy,
                     					(u32) recvpoolptr, ALIGNMENT_BD,
                     					XLL_RECV_BD_CNT);
  if (result != XST_SUCCESS)
  {
  	printk(KERN_ERR "%s: DMA Ring Create (RECV). Error: %d\n",
           DRIVER_NAME, result);
    return -EIO;
  }

	result = XLlDma_BdRingCreate(&dma->Dma.TxBdRing, (u32) sendpoolphy,
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

  ll_accel_DmaSetupRecvBuffers(dma);

	return 0;
}


/*****************************************************************************
 * Interrupt Handlers
 *****************************************************************************/

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
	u32 accel = 0;

	//printk("%s: Entering Tx Tasklet\n", DRIVER_NAME);

  result = XST_SUCCESS;
  dma_tx_int_mask = XLLDMA_CR_IRQ_ALL_EN_MASK;

  //spin_lock_irqsave(&dma->lock, dma->lock_flags);

  bd_processed_save = 0;
  while ((bd_processed =
        XLlDma_BdRingFromHw(&dma->Dma.TxBdRing, XLL_SEND_BD_CNT,
                    &BdPtr)) > 0)
  {

  	bd_processed_save = bd_processed;
    BdCurPtr = BdPtr;
    do {
    	len = XLlDma_mBdGetLength(BdCurPtr);

			accel = XLlDma_mBdRead(BdCurPtr, XLLDMA_BD_USR1_OFFSET);
	
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

			// Notify write() that BD has been released, so can stop blocking
			ll_accel_devices[accel].write_done = 1;
			// wake up wait queue
  		wake_up_interruptible(&(ll_accel_devices[accel].write_wait_queue));

      BdCurPtr = XLlDma_mBdRingNext(&dma->Dma.TxBdRing,
                           BdCurPtr);
      bd_processed--;
    } while (bd_processed > 0);

    result = XLlDma_BdRingFree(&dma->Dma.TxBdRing,
                       bd_processed_save, BdPtr);
    if (result != XST_SUCCESS) {
    	printk(KERN_ERR
             "%s: XLlDma: BdRingFree() error %d.\n",
             DRIVER_NAME, result);
      return;
    }
		
  }

	//printk("%s: Exiting Tx Tasklet\n", DRIVER_NAME);

  XLlDma_mBdRingIntEnable(&dma->Dma.TxBdRing, dma_tx_int_mask);
  //spin_unlock_irqrestore(&dma->lock, dma->lock_flags);
}

/*
 * DMA receive interrupt handler Bottom Half
 * Received buffers are removed from the descriptor ring and added to 
 * rx_buffer_list for later processing.
 */
static void DmaRecvHandlerBH(unsigned long p)
{
  u32                  buff_phys_addr;
	u32                  len, accel;
  struct llex_rx_buff *rx_buff;
  int                  result;
  XLlDma_Bd           *BdPtr, *BdCurPtr;
  unsigned int         bd_processed, bd_processed_saved;
  int                  dma_rx_int_mask;



  dma_rx_int_mask = XLLDMA_CR_IRQ_ALL_EN_MASK;

  //spin_lock_irqsave(&dma->lock, dma->lock_flags);
  if ((bd_processed =
       XLlDma_BdRingFromHw(&dma->Dma.RxBdRing, XLL_RECV_BD_CNT,
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

			//printk("%s: RX Packet Length: %d\n", DRIVER_NAME, len);

			// here we get the accelerator the packet is for
			accel = XLlDma_mBdRead(BdCurPtr, XLLDMA_BD_USR3_OFFSET);

			//printk("%s: RX Packet Accel: %d\n", DRIVER_NAME, accel);

      /* get pointer to buffer structure */
      rx_buff = (void *)
      XLlDma_mBdGetId(BdCurPtr);

      /* get and free up dma handle used by the buffer */
      buff_phys_addr =(dma_addr_t)XLlDma_mBdGetBufAddr(BdCurPtr);
      /*
       * Invalidate the data cache for this buffer.
       */
      dma_unmap_single(ll_dev, buff_phys_addr,
                       LL_EX_BUF_SIZE,
                       DMA_FROM_DEVICE);
      rx_buff->data_len = len;

      /* reset ID */
      XLlDma_mBdSetId(BdCurPtr, NULL);

      //ll_ex_dev->rx_buffers++;
      //ll_ex_dev->rx_bytes += len;

      /*
       * Add this buffer to the received list for later processing in
       * ll_accel_read().
       */

			// Add to appropriate accelerator's rx list
      list_add_tail(&rx_buff->list, &ll_accel_devices[accel].rx_buffer_list);

			// set ready flag
  		ll_accel_devices[accel].read_ready = 1;
			// wake up wait queue
  		wake_up_interruptible(&(ll_accel_devices[accel].wait_queue));
  
      BdCurPtr =
                XLlDma_mBdRingNext(&dma->Dma.RxBdRing,
                           BdCurPtr);
      bd_processed--;
    } while (bd_processed > 0);

    /* give the descriptor back to the driver */
    result = XLlDma_BdRingFree(&dma->Dma.RxBdRing,
                       bd_processed_saved, BdPtr);
    if (result != XST_SUCCESS) {
        printk(KERN_ERR
               "%s: XLlDma: BdRingFree unsuccessful (%d)\n",
               DRIVER_NAME, result);
        return;
    }

    ll_accel_DmaSetupRecvBuffers(dma);
  }
  XLlDma_mBdRingIntEnable(&dma->Dma.RxBdRing, dma_rx_int_mask);

  //spin_unlock_irqrestore(&dma->lock, dma->lock_flags);
}


// dev_id is specified in setup and forwarded here on interrupt
static irqreturn_t ll_accel_dma_tx_interrupt(int irq, void *dev_id)
{
	u32 irq_status;
  struct dma_channel *dma = dev_id;

/*
#ifdef HWTIME
	tb_data[HWTIME_MEM2ACC] = get_tbl() - tb_data[HWTIME_MEM2ACC];
  tx_int = get_tbl();
#endif
*/

	//tb_data[HWTIME_WRITE_DONE] = get_tbl();
	//tx_cycles = get_tbl() - tx_cycles;

	//asm volatile("sync");
	printk("%s: TX Interrupt Enter\n", DRIVER_NAME);


  dma->tx_irq++;
  //spin_lock_irqsave(&dma->lock, dma->lock_flags);
	irq_status = XLlDma_mBdRingGetIrq(&(dma->Dma.TxBdRing));

  XLlDma_mBdRingAckIrq(&(dma->Dma.TxBdRing), irq_status);
  //spin_unlock_irqrestore(&dma->lock, dma->lock_flags);

  if ((irq_status & XLLDMA_IRQ_ALL_ERR_MASK)) {
  	XLlDma_Reset(&dma->Dma);
    dma->errors++;
    return IRQ_HANDLED;
  }

  //if ((irq_status & (XLLDMA_IRQ_DELAY_MASK | XLLDMA_IRQ_COALESCE_MASK))) {

	//want only coalesce interrupt, delay timer not necessary since threshold is 1 packet
	if ((irq_status & (XLLDMA_IRQ_COALESCE_MASK))) {
    
    //spin_lock_irqsave(&dma->lock, dma->lock_flags);
  	XLlDma_mBdRingIntDisable(&dma->Dma.TxBdRing,
                             XLLDMA_CR_IRQ_ALL_EN_MASK);

    //spin_unlock_irqrestore(&dma->lock, dma->lock_flags);      
		//printk("%s: Scheduling tasklet\n", DRIVER_NAME);		
		// TX Interrupt notifying that DMA Controller has completed Tx?
  	#ifdef HWTIME
	    tb_data[HWTIME_MEM2ACC] = get_tbl() - tb_data[HWTIME_MEM2ACC];
      tx_int = get_tbl();
    #endif

    tasklet_schedule(&ExDmaSendBH);
  }
 

	//printk("%s: Exiting TX Interrupt\n", DRIVER_NAME);
  //printk("Tx Cycles = %ld\n", tx_cycles);	
  return IRQ_HANDLED;
}

/*
 * xllex_dma_rx_interrupt:
 * DMA receive interrupt handler (data from LL Example core)
 */
static irqreturn_t ll_accel_dma_rx_interrupt(int irq, void *dev_id)
{
	
  //printk("GOT RX Int from HW\n");
	u32 irq_status;
  struct dma_channel *dma = dev_id;

/*
#ifdef HWTIME
	tb_data[HWTIME_DMA_RX_SETUP] = get_tbl();
	tb_data[HWTIME_ACC2MEM] = tb_data[HWTIME_DMA_RX_SETUP] - tb_data[HWTIME_ACC2MEM];
  rx_int = get_tbl();
#endif
*/

	//printk("%s: RX Interrupt Enter\n", DRIVER_NAME);

	//? not sure about this?
  //dma->rx_irq = in_be32(plb->mapaddr + LL_ACCEL_APP2_REG)*4;

  //spin_lock_irqsave(&dma->lock, dma->lock_flags);
  irq_status = XLlDma_mBdRingGetIrq(&dma->Dma.RxBdRing);

  XLlDma_mBdRingAckIrq(&dma->Dma.RxBdRing, irq_status);

	// make sure we are getting a coalesce mask
	//spin_unlock_irqrestore(&dma->lock, dma->lock_flags); 

  if ((irq_status & XLLDMA_IRQ_ALL_ERR_MASK)) {
  	XLlDma_Reset(&dma->Dma);
    dma->errors++;
    return IRQ_HANDLED;
  }

  if ((irq_status & (/*XLLDMA_IRQ_DELAY_MASK |*/ XLLDMA_IRQ_COALESCE_MASK))) {

				//rx_complete = get_tbl();
				// read counter for time finished
				//rx_done = in_be32(plb->mapaddr + LL_ACCEL_APP3_REG);
				//asm("eieio");
        #ifdef HWTIME
        	tb_data[HWTIME_DMA_RX_SETUP] = get_tbl();
        	tb_data[HWTIME_ACC2MEM] = tb_data[HWTIME_DMA_RX_SETUP] - tb_data[HWTIME_ACC2MEM];
          rx_int = get_tbl();
        #endif

				rx_ints++;
      
      
      //spin_lock_irqsave(&dma->lock, dma->lock_flags);
      XLlDma_mBdRingIntDisable(&dma->Dma.RxBdRing,
                               XLLDMA_CR_IRQ_ALL_EN_MASK);

      //spin_unlock_irqrestore(&dma->lock, dma->lock_flags);   
 
      tasklet_schedule(&ExDmaRecvBH);
  }



	//printk("%s: RX Interrupt Exit\n", DRIVER_NAME);

  return IRQ_HANDLED;
}

////
// @name		plb_irq_handler
// @description Interrupt handler registered with IRQ line when applicable. 
//              Called when interrupt arrives. Wakes up wait queue and sets
//							ready flag.
// @param		irq - Interrupt request line number
// @param   dev_id - device local data structure
// @param		pt_regs - irrelevant structure
// @return	completion status handled if not interrupted by other kernel ops
////
irqreturn_t plb_irq_handler(int irq, void *dev_id, struct pt_regs *regs){
  // get local data
	struct plb_info *my_dev = dev_id;
	//printk("ll_accel GOT Interrupt from PLB HW\n");
	//unsigned int status = in_be32(my_dev->mapaddr + INTR_DISR_OFFSET);

	// HWTIME_ACCEL_DONE
#ifdef HWTIME
	tb_data[HWTIME_ACCEL_DONE] = get_tbl();
  done_int = get_tbl();
  //done_plb = in_be32(plb->mapaddr + LL_ACCEL_APP3_REG);
#endif
	int accel, i, bit;
  unsigned int status = in_be32(my_dev->mapaddr + INTR_IPISR_OFFSET);
	unsigned int r = 0;
	printk("Status Register = 0x%x\n", status);
  out_be32(my_dev->mapaddr + INTR_IPISR_OFFSET, status);

	// Get accelerator number from interrupt status
	// Need to calculate log2 of status field, will work up to 15 accelerators
	accel = status;
	// just support 0 for now
	//accel >>=1;

	//printk("Accel = %u\n", accel);

  // Go through all set bits and notify appropriate accelerator
  for (i=0; i<LL_ACCEL_NR_DEVS; i++)
  {
    bit = 1 << i;
    if ((accel & bit) == bit)
    {
      //printk("bit = %d, & = %d\n", bit, accel & bit);
      printk("Accelerator %d done\n", i);
      // Notify accelerator that interrupt was received
	    ll_accel_devices[i].accel_done = 1;
	    wake_up_interruptible(&(ll_accel_devices[i].wait_done));
    }
  }
	
	//printk("Wake interruptible\n");

	// set ready flag
  //my_dev->read_ready = 1;
	// wake up wait queue
  //wake_up_interruptible(&(my_dev->wait_queue));
  return IRQ_HANDLED;
}

////
// @name		enable_interrupts
// @description Interfaces with interrupt logic in hardware to turn on 
//              interrupt generation.
// @param		base_addr - base virtual address of hardware from which offsets can
//                      be used
////
void enable_plb_interrupts(void* base_addr){
  unsigned buffer;
  
  // clear FIFO device and IP interrupts
  buffer = ioread32(base_addr + INTR_IPISR_OFFSET);
  iowrite32(buffer, base_addr + INTR_IPISR_OFFSET);
  buffer = ioread32(base_addr + INTR_DISR_OFFSET);
  iowrite32(buffer, base_addr + INTR_DISR_OFFSET);
  
  // enable all interrupts
  buffer = swab32(0x0000000F); //was 1, mult 0xFF
  iowrite32(buffer, base_addr + INTR_IPIER_OFFSET);
  //buffer = swab32(0x00000067);
  //iowrite32(buffer, base_addr + INTR_DIER_OFFSET);
  buffer = swab32(0x80000000);
  iowrite32(buffer, base_addr + INTR_DGIER_OFFSET);  
  
}

/*****************************************************************************
 * Open Firmware Stuff
 *****************************************************************************/

// Device ID table:
// Used to match devices to driver. Device analog specified in .DTS file

static struct of_device_id ll_accel_of_match[] = {
  { .compatible = "xlnx,ll-accel-1.00.a", },
	{ .compatible = "xlnx,ll-accel-read-control-1.00.a", },
	{ .compatible = "xlnx,xps-hwicap-1.00.a", .data = &fifo_icap_config },
  { /* end of list */ },
};

// Register match table with device
MODULE_DEVICE_TABLE(of, ll_accel_of_match);

/*
 * of_probe
 *
 * This function is called when a match in the dts file is found in the device
 * ID table. This driver looks for two separate entries in the dts, one for
 * the ll-accel device with DMA channel references and one for the Xilinx 
 * HWICAP IP as added from XPS. Because of this, it is not necessary modify
 * the dts file produced by XPS except to add a llink-connected tag in the 
 * ll-accel description.
 *
 */

static int __devinit 
ll_accel_of_probe(struct of_device *op, const struct of_device_id *match)
{
	int result, i, err;
	dev_t dev = 0;
	const phandle *llink_connected_handle;
	u32   dma_tx_int_mask, dma_rx_int_mask;
	struct resource r_mem, r_irq;
	struct device_node *dma_of_node;
	struct proc_dir_entry *proc_entry;
	unsigned buffer;

	printk("Name: %s\n", op->node->name);

	result = 0;
	
	//See if we are dealing with hwicap or ll-accel
	if (strstr(op->node->name, "ll-accel") != NULL) {
	//if (strcmp(op->node->name, "ll-accel") == 0) {

		
		

  	// for now save device in global variable for dma map/unmap calls
  	ll_dev = &op->dev;

  	dev_dbg(&op->dev, "Probing LocalLink Accelerator\n");
  	//printk("Device Name: %s\nType: %s\n", match->name, match->type);
  		
   	// Extract information from dts file


  	/*
     * Which Local Link DMA engine is this core connected to?
     */

    llink_connected_handle =
          of_get_property(op->node, "llink-connected", NULL);
    if (llink_connected_handle == NULL) {
    	printk(KERN_ERR "%s: no Locallink connection found.\n", DRIVER_NAME);
      return -ENODEV;
    }

  	dma_of_node = of_find_node_by_phandle(*llink_connected_handle);
    if (dma_of_node == NULL) {
    	printk(KERN_ERR "%s: no DMA controller found.\n", DRIVER_NAME);
      return -ENODEV;
    }

  	// Get major and minor numbers 

  	// static device id specified
  	if (ll_accel_major) {
  		dev = MKDEV(ll_accel_major, ll_accel_minor);
  		result = register_chrdev_region(dev, ll_accel_nr_devs, "ll_accel");
  	// dynamic device id
  	} else {
  		result = alloc_chrdev_region(&dev, ll_accel_minor, ll_accel_nr_devs,
  						 "ll_accel");
  		ll_accel_major = MAJOR(dev);
  	}
  	if (result < 0) {
  		printk(KERN_WARNING "%s: can't get major %d\n", DRIVER_NAME, 
  					 ll_accel_major);
  		return result;
  	}

    // Allocate devices
    ll_accel_devices = 
  	kmalloc(ll_accel_nr_devs * sizeof(struct ll_accel_dev), GFP_KERNEL);
  	if (!ll_accel_devices) {
  		return -ENOMEM;
  		//goto fail;  /* Make this more graceful */
  	}
  	memset(ll_accel_devices, 0, ll_accel_nr_devs * sizeof(struct ll_accel_dev));

  	// Setup shared DMA channel
  	dma = kmalloc(sizeof(struct dma_channel), GFP_KERNEL);
  	if (!dma) {
  		result = -ENOMEM;
  		goto fail1;  /* Make this more graceful */
  	}
  	memset(dma, 0, sizeof(struct dma_channel));
  	//INIT_LIST_HEAD(&dma->rx_buffer_list);
  	mutex_init(&dma->mutex);

  	// Setup plb info
  	plb = kmalloc(sizeof(struct plb_info), GFP_KERNEL);
  	if (!plb) {
  		result = -ENOMEM;
  		goto fail2;  /* Make this more graceful */
  	}
  	memset(plb, 0, sizeof(struct plb_info));

  	/*
     * What is the physical address of PLB slave interface for registers
     */

    err = of_address_to_resource(op->node, 0, &r_mem);
    if (err) {
    	dev_warn(&op->dev, "invalid address\n");
      result = err;
  		goto fail3;
  		//return err;
    }	

  	plb->physaddr = r_mem.start;
    plb->addrsize = r_mem.end - r_mem.start + 1;

		/*
  	 * Memory Map LL_EXAMPLE core to a virtual address
     */
  	plb->mapaddr = ioremap(plb->physaddr, plb->addrsize);
    printk("%s: mapped to 0x%08x.\n", DRIVER_NAME, (u32)plb->mapaddr);	

		// reset
		buffer = swab32(RESET_MASK); // 0x0A000000
  	iowrite32(buffer, (plb->mapaddr + SOFT_RST_OFFSET));

		// Map physical to virtual IRQ if available
  	plb->virq = of_irq_to_resource(op->node, 0, &r_irq);
  	if(plb->virq == NO_IRQ){
    	printk("llaccel plb: No Interrupts\n");
  	}
  	else{
    	printk("\tll_accel plb IRQ successfully mapped to %d\n", plb->virq);
  	}

		// IRQ handler request if interrupts used
  	if(plb->virq != NO_IRQ){
    	result = request_irq(plb->virq, plb_irq_handler,0,DRIVER_NAME, plb);
			// If result != 0, failed to get access to interrupt line
    	if(result){
      	printk(KERN_INFO "short: can't get assigned irq %d\n", plb->virq);
    	}
			// otherwise enable interrupts in hardware
    	else{
      	enable_plb_interrupts(plb->mapaddr);
    	}
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
      	dma->dma_addr = *dcrreg_property;
      } 
  		else {
      	printk(KERN_ERR "%s: Unable to determine DMA controller address.\n",
               DRIVER_NAME);
  			result = -ENODEV;
        goto fail3;
    	}
  	} 
  	else {

    	/*
       * Address of memory mapped DMA controller (MPMC).
       */

      dma->dma_addr = r_mem.start;
    }

  	/* DMA RX and TX IRQs */

    err = of_irq_to_resource(dma_of_node, 0, &r_irq);
    if (err == NO_IRQ) {
    	printk(KERN_ERR "%s: First DMA IRQ not found.\n", DRIVER_NAME);
  		result = err;
      goto fail3;
    }
    dma->dma_rx_irq = r_irq.start;

    err = of_irq_to_resource(dma_of_node, 1, &r_irq);
    if (err == NO_IRQ) {
    	printk(KERN_ERR "%s: Second DMA IRQ not found.\n", DRIVER_NAME);
      result = err;
  		goto fail3;
    }
    dma->dma_tx_irq = r_irq.start;

  	/*
     * Allocate DMA interrupts and register driver interrupt handler.
     */
    printk(KERN_INFO
           "%s: allocating interrupt %d for dma tx.\n",
           DRIVER_NAME, dma->dma_tx_irq);
    err = request_irq(dma->dma_tx_irq,
                      &ll_accel_dma_tx_interrupt, 0, "ll_accel_dma_tx_int", dma);
    if (err) {
    	printk(KERN_ERR
             "%s: could not allocate interrupt %d (%d).\n",
             DRIVER_NAME, dma->dma_tx_irq, err);
      goto fail3;
   	}

    printk(KERN_INFO
           "%s: allocating interrupt %d for dma rx.\n",
           DRIVER_NAME, dma->dma_rx_irq);
    err = request_irq(dma->dma_rx_irq,
                      &ll_accel_dma_rx_interrupt, 0, "ll_accel_dma_rx_int", dma);
    if (err) {
    	printk(KERN_ERR
             "%s: could not allocate interrupt %d.\n",
             DRIVER_NAME, dma->dma_rx_irq);
      goto fail3;
   	}

  	

  	// Setup DMA stuff
    printk("%s: DMA DCR address: 0x%0x\n", DRIVER_NAME, dma->dma_addr);
  	XLlDma_Initialize(&dma->Dma, dma->dma_addr);

  	/*
     * Initialize the LLDMA descriptor ring.
     */

  	err = descriptor_init(dma);
    if (err) {
    	printk(KERN_ERR
             "%s: Descriptor init failed (%d).\n",
             DRIVER_NAME, err);
      err = -EIO;
      goto fail3;
    }

  	/*
     * set the packet threshold and wait bound for both TX/RX directions
     */
    //dma_tx_int_mask = XLLDMA_CR_IRQ_ALL_EN_MASK;
    dma_tx_int_mask = XLLDMA_CR_IRQ_EN_MASK | XLLDMA_CR_IRQ_ERROR_EN_MASK | XLLDMA_CR_IRQ_COALESCE_EN_MASK;
    err = XLlDma_BdRingSetCoalesce(&dma->Dma.TxBdRing,
          DFT_TX_THRESHOLD, DFT_TX_WAITBOUND);
    if (err != XST_SUCCESS)
    {
    	printk(KERN_ERR
             "%s: could not set SEND pkt threshold/waitbound, ERROR %d",
             DRIVER_NAME, err);
    }
    XLlDma_mBdRingIntEnable(&dma->Dma.TxBdRing, dma_tx_int_mask);

    //dma_rx_int_mask = XLLDMA_CR_IRQ_ALL_EN_MASK;
    dma_rx_int_mask = XLLDMA_CR_IRQ_EN_MASK | XLLDMA_CR_IRQ_ERROR_EN_MASK | XLLDMA_CR_IRQ_COALESCE_EN_MASK;
    err = XLlDma_BdRingSetCoalesce(&dma->Dma.RxBdRing,
          DFT_RX_THRESHOLD, DFT_RX_WAITBOUND);
    if (err != XST_SUCCESS)
    {
    	printk(KERN_ERR
             "%s: Could not set RECV pkt threshold/waitbound ERROR %d",
             DRIVER_NAME, err);
    }
    XLlDma_mBdRingIntEnable(&dma->Dma.RxBdRing, dma_rx_int_mask);

  	if (XLlDma_BdRingStart(&dma->Dma.TxBdRing) == XST_FAILURE) {
    	printk(KERN_ERR "%s: XLlTemac: could not start dma tx channel\n",
             DRIVER_NAME);
      err = -EIO;
      goto fail3;
    }
    if (XLlDma_BdRingStart(&dma->Dma.RxBdRing) == XST_FAILURE) {
    	printk(KERN_ERR "%s: XLlTemac: could not start dma rx channel\n",
             DRIVER_NAME);
      err = -EIO;
      goto fail3;
    }

  	// create sysfs class
  	ll_accel_class = class_create(THIS_MODULE, "rit_config");

    // Initialize lock for DMA operations
    //spin_lock_init(&dma->lock);
    mutex_init(&dma->read_mutex);
    mutex_init(&dma->write_mutex);

  	// Setup devices
    for (i = 0; i < ll_accel_nr_devs; i++) {
  		int err, devno = MKDEV(ll_accel_major, ll_accel_minor + i);
  		INIT_LIST_HEAD(&ll_accel_devices[i].rx_buffer_list);
  		mutex_init(&ll_accel_devices[i].mutex);
  		cdev_init(&ll_accel_devices[i].cdev, &ll_accel_fops);
  		ll_accel_devices[i].cdev.owner = THIS_MODULE;
  		ll_accel_devices[i].cdev.ops = &ll_accel_fops;
  		ll_accel_devices[i].dma = dma;
  		// Initialize Wait Queue and read_ready flags for RX interrupt operation
    	init_waitqueue_head(&(ll_accel_devices[i].wait_queue));
    	ll_accel_devices[i].read_ready = 0;
			// Initialize done wait queue
    	init_waitqueue_head(&(ll_accel_devices[i].wait_done));
    	ll_accel_devices[i].accel_done = 0;
			// Initialize Wait Queue for TX interrupt operation
			init_waitqueue_head(&(ll_accel_devices[i].write_wait_queue));
    	ll_accel_devices[i].write_done = 0;
  		err = cdev_add (&ll_accel_devices[i].cdev, devno, 1);
  		/* Fail gracefully if need be */
  		if (err) {
  			printk(KERN_NOTICE "Error %d adding ll_accel%d", err, i);
        goto fail3;
      }
  		// create file in /dev for each accelerator
  		device_create(ll_accel_class, &op->dev, devno, NULL, "%s%d", 
  									DRIVER_NAME, i);
  	}	

  	// Setup /proc
  	proc_entry = create_proc_entry("driver/ll_accel_drvr", 0, NULL);
    if (proc_entry) {
    	proc_entry->proc_fops = &ll_accel_proc_ops;
    }

  	dev_dbg(&op->dev, "Successfully completed probe\n");
  	return 0;

  	fail3:
  	kfree(plb);
  	fail2:
  	kfree(dma);
  	fail1:
  	kfree(ll_accel_devices);

  } // if ll-accel
  else {
    printk("ll-accel found HWICAP!\n");

    const struct hwicap_driver_config *config = match->data;
	  const struct config_registers *regs;
    struct resource res;
    int rc, status;

		// Need to still make sure drvdata stuff is ok

    rc = of_address_to_resource(op->node, 0, &res);
	  if (rc) {
		  dev_err(&op->dev, "invalid address\n");
		  return rc;
	  }

    // only support virtex-5, ignore family field
    regs = &v5_config_registers;

    status = hwicap_setup(&op->dev, &res, config, regs);
		if (status) return status;

		status = mutex_lock_interruptible(&drvdata->sem);
		if (status) goto error;

		if (drvdata->is_open) {
			status = -EBUSY;
			goto error;
		}

		status = hwicap_initialize_hwicap();
		if (status) {
			dev_err(drvdata->dev, "Failed to open file");
			goto error;
		}

		drvdata->write_buffer_in_use = 0;
		drvdata->read_buffer_in_use = 0;
		drvdata->is_open = 1;

		status = 0;

 	error:
		mutex_unlock(&drvdata->sem);
		return status;
  }

	skip:
  
	return result;
}


// Remove 
//

static int __devexit ll_accel_of_remove(struct of_device *dev)
{
		int i;
	  // cleanup ll_accel and hwicap stuff
  
		// ll-accel
		if (strcmp(dev->node->name, "ll-accel") == 0) {
			tasklet_kill(&ExDmaSendBH);
    	tasklet_kill(&ExDmaRecvBH);
    	remove_proc_entry("driver/ll_accel_drvr", NULL);
			
			for (i = 0; i < ll_accel_nr_devs; i++) {
				cdev_del(&ll_accel_devices[i]);
				//device_destroy(ll_accel_class, drvdata->devt);				
			}

      if (plb->mapaddr) {
      	iounmap(plb->mapaddr);
      }

      //kfree(ll_ex_dev);

			//free_irq(dma->dma_rx_irq, ll_ex_dev);
      //free_irq(dma->dma_tx_irq, ll_ex_dev);

		}
		// hwicap
		else {
			if (!drvdata) return 0;
			iounmap(drvdata->base_address);
			release_mem_region(drvdata->mem_start, drvdata->mem_size);
			kfree(drvdata);
			dev_set_drvdata(dev, NULL);
		}

    return 0;
}

// Driver specification structure:
// Ties probe and remove functions to driver operation

static struct of_platform_driver ll_accel_of_driver = {
  .owner        = THIS_MODULE,
  .name					= DRIVER_NAME,
  .match_table	= ll_accel_of_match,
  .probe				= ll_accel_of_probe,
  .remove				= __devexit_p(ll_accel_of_remove),
};

/*****************************************************************************
 * Driver Entry Point
 *****************************************************************************/

static int __init ll_accel_init(void)
{
    int status;
    status = of_register_platform_driver(&ll_accel_of_driver);
    return status;
}

static void __exit ll_accel_cleanup(void)
{
		printk("Driver Cleanup called\n");
	
		//put this stuff in appropriate function
		//class_destroy(ll_accel_class);
		// free memory allocated in ll_accel_init
		
    of_unregister_platform_driver(&ll_accel_of_driver);
}

module_init(ll_accel_init);
module_exit(ll_accel_cleanup);
module_param(ll_accel_major, int, S_IRUGO);
module_param(ll_accel_minor, int, S_IRUGO);
module_param(ll_accel_nr_devs, int, S_IRUGO);

MODULE_AUTHOR("Nick Palladino");
MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
MODULE_LICENSE("GPL");
