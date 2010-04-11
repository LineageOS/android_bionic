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
#ifndef _XT_DSCP_H
#define _XT_DSCP_H

#include <linux/types.h>

#define XT_DSCP_MASK 0xfc  
#define XT_DSCP_SHIFT 2
#define XT_DSCP_MAX 0x3f  

struct xt_dscp_info {
 __u8 dscp;
 __u8 invert;
};

struct xt_tos_match_info {
 __u8 tos_mask;
 __u8 tos_value;
 __u8 invert;
};

#endif
