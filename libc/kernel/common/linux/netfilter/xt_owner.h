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
#ifndef _XT_OWNER_MATCH_H
#define _XT_OWNER_MATCH_H

#include <linux/types.h>

enum {
 XT_OWNER_UID = 1 << 0,
 XT_OWNER_GID = 1 << 1,
 XT_OWNER_SOCKET = 1 << 2,
};

struct xt_owner_match_info {
 __u32 uid_min, uid_max;
 __u32 gid_min, gid_max;
 __u8 match, invert;
};

#endif
