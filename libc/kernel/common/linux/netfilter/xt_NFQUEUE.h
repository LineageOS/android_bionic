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
#ifndef _XT_NFQ_TARGET_H
#define _XT_NFQ_TARGET_H

#include <linux/types.h>

struct xt_NFQ_info {
 __u16 queuenum;
};

struct xt_NFQ_info_v1 {
 __u16 queuenum;
 __u16 queues_total;
};

#endif
