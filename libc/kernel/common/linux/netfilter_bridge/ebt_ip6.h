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
#ifndef __LINUX_BRIDGE_EBT_IP6_H
#define __LINUX_BRIDGE_EBT_IP6_H

#define EBT_IP6_SOURCE 0x01
#define EBT_IP6_DEST 0x02
#define EBT_IP6_TCLASS 0x04
#define EBT_IP6_PROTO 0x08
#define EBT_IP6_SPORT 0x10
#define EBT_IP6_DPORT 0x20
#define EBT_IP6_MASK (EBT_IP6_SOURCE | EBT_IP6_DEST | EBT_IP6_TCLASS |  EBT_IP6_PROTO | EBT_IP6_SPORT | EBT_IP6_DPORT)
#define EBT_IP6_MATCH "ip6"

struct ebt_ip6_info {
 struct in6_addr saddr;
 struct in6_addr daddr;
 struct in6_addr smsk;
 struct in6_addr dmsk;
 uint8_t tclass;
 uint8_t protocol;
 uint8_t bitmask;
 uint8_t invflags;
 uint16_t sport[2];
 uint16_t dport[2];
};

#endif
