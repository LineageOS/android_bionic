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
#ifndef __LINUX_BRIDGE_EBT_MARK_T_H
#define __LINUX_BRIDGE_EBT_MARK_T_H

#define MARK_SET_VALUE (0xfffffff0)
#define MARK_OR_VALUE (0xffffffe0)
#define MARK_AND_VALUE (0xffffffd0)
#define MARK_XOR_VALUE (0xffffffc0)

struct ebt_mark_t_info {
 unsigned long mark;

 int target;
};
#define EBT_MARK_TARGET "mark"

#endif
