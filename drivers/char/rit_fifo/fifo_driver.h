///////////////////////////////////////////////////////////////////////////////
//
// File: fifo_driver.h
// Author: Jeremy Espenshade
// Date: April 29, 2009													
//																
// Description: Header for generic FIFO driver enabling 
//		interaction with custom hardware				
//              accelerators. Some includes may be			
//              extraneous. See fifo_driver.c for				
//		detailed function descriptions.					
//
// License: GPL	
///////////////////////////////////////////////////////////////////////////////

#define DEBUG

#include <linux/device.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/string.h>
#include <linux/mm.h>
#include <linux/fb.h>
#include <linux/init.h>
#include <linux/dma-mapping.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>
#include <linux/slab.h> 
#include <linux/fs.h> 
#include <linux/errno.h> 
#include <linux/types.h> 
#include <linux/proc_fs.h>
#include <linux/fcntl.h> 
#include <linux/ioport.h>
#include <asm/io.h>
#include <asm/dcr.h>
#include <asm/system.h>
#include <asm/uaccess.h>
#include <asm/prom.h>
#include <asm/byteorder.h>
#include <linux/semaphore.h>
#include <linux/cdev.h>
#include <linux/wait.h>
#include <linux/interrupt.h>

#include <asm/time.h> //get_tbl

// Generic FIFO Driver 
#define DRIVER_NAME         "plb_fifo"
#define DRIVER_DESCRIPTION  "Xilinx PLB FIFO HW Unit"
#define DRIVER_VERSION      "1.00a"

// Read FIFO Offsets
#define RDFIFO_RST_OFFSET (0x00000300)
#define RDFIFO_SR_OFFSET (RDFIFO_RST_OFFSET + 0x00000004)
#define RDFIFO_DATA_OFFSET (0x00000400)

// Read FIFO Masks
#define RDFIFO_EMPTY_MASK (0x80000000UL)
#define RDFIFO_AE_MASK (0x40000000UL)
#define RDFIFO_DL_MASK (0x20000000UL)
#define RDFIFO_SCL_MASK (0x10000000UL) 
#define RDFIFO_WIDTH_MASK (0x0E000000UL) 
#define RDFIFO_OCC_MASK (0x01FFFFFFUL) 

// Write FIFO Offsets 
#define WRFIFO_RST_OFFSET (0x00000500)
#define WRFIFO_SR_OFFSET (WRFIFO_RST_OFFSET + 0x00000004)
#define WRFIFO_DATA_OFFSET (0x00000600)

// Write FIFO Masks
#define WRFIFO_FULL_MASK (0x80000000UL)
#define WRFIFO_AF_MASK (0x40000000UL)
#define WRFIFO_DL_MASK (0x20000000UL)
#define WRFIFO_SCL_MASK (0x10000000UL) 
#define WRFIFO_WIDTH_MASK (0x0E000000UL) 
#define WRFIFO_DREP_MASK (0x01000000UL) 
#define WRFIFO_VAC_MASK (0x00FFFFFFUL) 

// Common Reset Mask
#define RESET_MASK (0x0000000A)

// Interrupt Generator Offsets
#define INTR_SPACE_OFFSET (0x00000200)
#define INTR_DISR_OFFSET  (INTR_SPACE_OFFSET + 0x00000000)
#define INTR_DIER_OFFSET  (INTR_SPACE_OFFSET + 0x00000008)
#define INTR_DGIER_OFFSET (INTR_SPACE_OFFSET + 0x0000001C)
#define INTR_IPISR_OFFSET (INTR_SPACE_OFFSET + 0x00000020)
#define INTR_IPIER_OFFSET (INTR_SPACE_OFFSET + 0x00000028)

// Software-controlled Reset Offset
#define SOFT_RST_OFFSET   (0x00000100)

// Read File Operation
ssize_t fifo_read(struct file *filp, char *buf, size_t count, loff_t *f_pos); 

// Write File Operation
ssize_t fifo_write(struct file *filp, const char *buf, size_t count, loff_t *f_pos); 

// Open File Operation
int fifo_open(struct inode *inode, struct file *filp); 

// Release File Operation
int fifo_release(struct inode *inode, struct file *filp);

// Enable interrupts on hardware accelerator
void enable_interrupts(void* base_addr);

// Interrupt handler
irqreturn_t fifo_irq_handler(int irq, void *dev_id, struct pt_regs *regs);
