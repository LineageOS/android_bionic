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
#ifndef __LINUX_BRIDGE_EBT_NFLOG_H
#define __LINUX_BRIDGE_EBT_NFLOG_H

#define EBT_NFLOG_MASK 0x0

#define EBT_NFLOG_PREFIX_SIZE 64
#define EBT_NFLOG_WATCHER "nflog"

#define EBT_NFLOG_DEFAULT_GROUP 0x1
#define EBT_NFLOG_DEFAULT_THRESHOLD 1

struct ebt_nflog_info {
 u_int32_t len;
 u_int16_t group;
 u_int16_t threshold;
 u_int16_t flags;
 u_int16_t pad;
 char prefix[EBT_NFLOG_PREFIX_SIZE];
};

#endif
