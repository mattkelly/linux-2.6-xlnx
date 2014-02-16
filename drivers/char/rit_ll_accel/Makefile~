#
# Makefile for RIT DMA & PDR driver
#

EXTRA_CFLAGS	+= -Idrivers/xilinx_common -Iarch/ppc/platforms/4xx/xparameters -DXHI_FAMILY=XHI_DEV_FAMILY_V5

obj-$(CONFIG_RIT_LL_ACCEL) := ll_accel.o fifo_icap.o

#obj-$(CONFIG_RIT_LL_ACCEL) += ll_accel_m.o 
#ll_accel_m-y := ll_accel.o fifo_icap.o

