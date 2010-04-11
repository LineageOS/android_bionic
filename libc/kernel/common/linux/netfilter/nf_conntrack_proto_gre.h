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
#ifndef _CONNTRACK_PROTO_GRE_H
#define _CONNTRACK_PROTO_GRE_H
#include <asm/byteorder.h>

#define GRE_VERSION_1701 0x0
#define GRE_VERSION_PPTP 0x1

#define GRE_PROTOCOL_PPTP 0x880B

#define GRE_FLAG_C 0x80
#define GRE_FLAG_R 0x40
#define GRE_FLAG_K 0x20
#define GRE_FLAG_S 0x10
#define GRE_FLAG_A 0x80

#define GRE_IS_C(f) ((f)&GRE_FLAG_C)
#define GRE_IS_R(f) ((f)&GRE_FLAG_R)
#define GRE_IS_K(f) ((f)&GRE_FLAG_K)
#define GRE_IS_S(f) ((f)&GRE_FLAG_S)
#define GRE_IS_A(f) ((f)&GRE_FLAG_A)

struct gre_hdr {
#ifdef __LITTLE_ENDIAN_BITFIELD
 __u16 rec:3,
 srr:1,
 seq:1,
 key:1,
 routing:1,
 csum:1,
 version:3,
 reserved:4,
 ack:1;
#elif defined(__BIG_ENDIAN_BITFIELD)
 __u16 csum:1,
 routing:1,
 key:1,
 seq:1,
 srr:1,
 rec:3,
 ack:1,
 reserved:4,
 version:3;
#else
#error "Adjust your <asm/byteorder.h> defines"
#endif
 __be16 protocol;
};

struct gre_hdr_pptp {
 __u8 flags;
 __u8 version;
 __be16 protocol;
 __be16 payload_len;
 __be16 call_id;
 __be32 seq;
 __be32 ack;

};

struct nf_ct_gre {
 unsigned int stream_timeout;
 unsigned int timeout;
};

#endif
