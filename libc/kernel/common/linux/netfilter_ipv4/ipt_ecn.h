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
#ifndef _IPT_ECN_H
#define _IPT_ECN_H
#include <linux/netfilter/xt_dscp.h>

#define IPT_ECN_IP_MASK (~XT_DSCP_MASK)

#define IPT_ECN_OP_MATCH_IP 0x01
#define IPT_ECN_OP_MATCH_ECE 0x10
#define IPT_ECN_OP_MATCH_CWR 0x20

#define IPT_ECN_OP_MATCH_MASK 0xce

struct ipt_ecn_info {
 u_int8_t operation;
 u_int8_t invert;
 u_int8_t ip_ect;
 union {
 struct {
 u_int8_t ect;
 } tcp;
 } proto;
};

#endif
