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
#ifndef _IPT_SAME_H
#define _IPT_SAME_H

#define IPT_SAME_MAX_RANGE 10

#define IPT_SAME_NODST 0x01

struct ipt_same_info {
 unsigned char info;
 u_int32_t rangesize;
 u_int32_t ipnum;
 u_int32_t *iparray;

 struct nf_nat_range range[IPT_SAME_MAX_RANGE];
};

#endif
