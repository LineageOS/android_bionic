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
#ifndef _XT_U32_H
#define _XT_U32_H 1

enum xt_u32_ops {
 XT_U32_AND,
 XT_U32_LEFTSH,
 XT_U32_RIGHTSH,
 XT_U32_AT,
};

struct xt_u32_location_element {
 u_int32_t number;
 u_int8_t nextop;
};

struct xt_u32_value_element {
 u_int32_t min;
 u_int32_t max;
};

#define XT_U32_MAXSIZE 10

struct xt_u32_test {
 struct xt_u32_location_element location[XT_U32_MAXSIZE+1];
 struct xt_u32_value_element value[XT_U32_MAXSIZE+1];
 u_int8_t nnums;
 u_int8_t nvalues;
};

struct xt_u32 {
 struct xt_u32_test tests[XT_U32_MAXSIZE+1];
 u_int8_t ntests;
 u_int8_t invert;
};

#endif
