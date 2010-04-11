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
#ifndef __LINUX_BRIDGE_EBT_IP_H
#define __LINUX_BRIDGE_EBT_IP_H

#define EBT_IP_SOURCE 0x01
#define EBT_IP_DEST 0x02
#define EBT_IP_TOS 0x04
#define EBT_IP_PROTO 0x08
#define EBT_IP_SPORT 0x10
#define EBT_IP_DPORT 0x20
#define EBT_IP_MASK (EBT_IP_SOURCE | EBT_IP_DEST | EBT_IP_TOS | EBT_IP_PROTO |  EBT_IP_SPORT | EBT_IP_DPORT )
#define EBT_IP_MATCH "ip"

struct ebt_ip_info {
 __be32 saddr;
 __be32 daddr;
 __be32 smsk;
 __be32 dmsk;
 uint8_t tos;
 uint8_t protocol;
 uint8_t bitmask;
 uint8_t invflags;
 uint16_t sport[2];
 uint16_t dport[2];
};

#endif
