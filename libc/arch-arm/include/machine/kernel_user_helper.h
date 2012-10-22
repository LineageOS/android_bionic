/* Copyright (c) 2012, The Linux Foundation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *    * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above
 *     copyright notice, this list of conditions and the following
 *     disclaimer in the documentation and/or other materials provided
 *     with the distribution.
 *   * Neither the name of The Linux Foundation nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#ifndef _ARCH_ARM_KERNEL_USER_HELPER_H
#define _ARCH_ARM_KERNEL_USER_HELPER_H

extern int clock_gettime_syscall(int clk_id, struct timespec *tp);
extern int gettimeofday_syscall(struct timeval *tv, struct timezone *tz);

#define __kuser_gtod_base        (*(int32_t *)0xffff0f40)
#define __kuser_gtod_cycle_last  (*(int32_t *)0xffff0f40)
#define __kuser_gtod_mask        (*(int32_t *)0xffff0f48)
#define __kuser_gtod_mult        (*(int32_t *)0xffff0f50)
#define __kuser_gtod_shift       (*(int32_t *)0xffff0f54)
#define __kuser_gtod_tv_sec      (*(int32_t *)0xffff0f58)
#define __kuser_gtod_tv_nsec     (*(int32_t *)0xffff0f5c)

#define __kuser_gtod_seqnum      (*(int32_t *)0xffff0f28)
#define __kuser_gtod_offset      (*(int32_t *)0xffff0f30)
#define __kuser_gtod_cycle_base               0xfffef000
#define __kuser_gtod_feature     (*(int32_t *)0xffff0f34)
#define __kuser_gtod_feature_flag             0xffff0f20

#define __kuser_gtod_wtm_tv_sec  (*(int32_t *)0xffff0f38)
#define __kuser_gtod_wtm_tv_nsec (*(int32_t *)0xffff0f3c)

#define __kuser_gtod_timezone    (*(int32_t *)0xffff0f20)
#define __kuser_gtod_tz_minw     (*(int32_t *)0xffff0f20)
#define __kuser_gtod_tz_dst      (*(int32_t *)0xffff0f24)

struct gtod_t {
	uint64_t  cycle_last;
	uint64_t  mask;
	uint32_t  mult;
	uint32_t  shift;
	uint32_t  tv_sec;
	uint32_t  tv_nsec;
};

#define NSEC_PER_SEC	1000000000L

#endif
