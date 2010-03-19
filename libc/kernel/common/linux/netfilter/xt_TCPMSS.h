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
#ifndef _XT_TCPMSS_H
#define _XT_TCPMSS_H

#include <linux/types.h>

struct xt_tcpmss_info {
 __u16 mss;
};

#define XT_TCPMSS_CLAMP_PMTU 0xffff

#endif
