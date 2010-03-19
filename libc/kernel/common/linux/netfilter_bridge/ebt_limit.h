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
#ifndef __LINUX_BRIDGE_EBT_LIMIT_H
#define __LINUX_BRIDGE_EBT_LIMIT_H

#define EBT_LIMIT_MATCH "limit"

#define EBT_LIMIT_SCALE 10000

struct ebt_limit_info {
 u_int32_t avg;
 u_int32_t burst;

 unsigned long prev;
 u_int32_t credit;
 u_int32_t credit_cap, cost;
};

#endif
