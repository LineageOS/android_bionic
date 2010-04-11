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
#ifndef _IPT_TTL_H
#define _IPT_TTL_H

enum {
 IPT_TTL_EQ = 0,
 IPT_TTL_NE,
 IPT_TTL_LT,
 IPT_TTL_GT,
};

struct ipt_ttl_info {
 u_int8_t mode;
 u_int8_t ttl;
};

#endif
