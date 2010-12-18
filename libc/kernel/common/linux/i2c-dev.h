/****************************************************************************
 ****************************************************************************
 ***
 ***   This header was automatically generated from a Linux kernel header
 ***   of the same name, to make information necessary for userspace to
 ***   call into the kernel available to libc.  It contains only constants,
 ***   structures, and macros generated from the original header, and thus,
 ***   contains no copyrightable information.
 ***
 ****************************************************************************
 ****************************************************************************/
#ifndef _LINUX_I2C_DEV_H
#define _LINUX_I2C_DEV_H

#include <linux/types.h>
#include <linux/compiler.h>

#define I2C_RETRIES 0x0701  
#define I2C_TIMEOUT 0x0702  

#define I2C_SLAVE 0x0703  
#define I2C_SLAVE_FORCE 0x0706  
#define I2C_TENBIT 0x0704  

#define I2C_FUNCS 0x0705  

#define I2C_RDWR 0x0707  

#define I2C_PEC 0x0708  
#define I2C_SMBUS 0x0720  

struct i2c_smbus_ioctl_data {
 __u8 read_write;
 __u8 command;
 __u32 size;
 union i2c_smbus_data __user *data;
};

struct i2c_rdwr_ioctl_data {
 struct i2c_msg __user *msgs;
 __u32 nmsgs;
};

#define I2C_RDRW_IOCTL_MAX_MSGS 42

#endif

