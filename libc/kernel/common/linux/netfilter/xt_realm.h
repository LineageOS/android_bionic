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
#ifndef _XT_REALM_H
#define _XT_REALM_H

#include <linux/types.h>

struct xt_realm_info {
 __u32 id;
 __u32 mask;
 __u8 invert;
};

#endif
