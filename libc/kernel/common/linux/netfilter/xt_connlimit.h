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
#ifndef _XT_CONNLIMIT_H
#define _XT_CONNLIMIT_H

struct xt_connlimit_data;

struct xt_connlimit_info {
 union {
 union nf_inet_addr mask;
 union {
 __be32 v4_mask;
 __be32 v6_mask[4];
 };
 };
 unsigned int limit, inverse;

 struct xt_connlimit_data *data __attribute__((aligned(8)));
};

#endif
