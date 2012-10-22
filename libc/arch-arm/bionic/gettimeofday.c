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

#include <string.h>
#include <stdint.h>
#include <sys/time.h>
#include <machine/cpu-features.h>
#include <machine/kernel_user_helper.h>

int gettimeofday(struct timeval *tv, struct timezone *tz)
{
	unsigned prelock, postlock;

	/*
	 * Check if the offset in the kernel user helper page has
	 * the flag set appropriately to show that this feature is
	 * enabled in the kernel.  If not, default to the original
	 * gettimeofday system call.
	 */
	if (__kuser_gtod_feature != __kuser_gtod_feature_flag)
		return gettimeofday_syscall(tv, tz);

	if (tv) {
		struct gtod_t dgtod;
		uint32_t nscount, cycleoffset;
		uint64_t cycle_delta;
		uint32_t tmp = 0;

		do {
			prelock = __kuser_gtod_seqnum;

			dgtod.cycle_last = __kuser_gtod_cycle_last;
			dgtod.mask = __kuser_gtod_mask;
			dgtod.mult = __kuser_gtod_mult;
			dgtod.shift = __kuser_gtod_shift;
			dgtod.tv_sec = __kuser_gtod_tv_sec;
			dgtod.tv_nsec = __kuser_gtod_tv_nsec;

			cycleoffset = __kuser_gtod_offset;
			cycleoffset += __kuser_gtod_cycle_base;
			nscount = *(uint32_t *)cycleoffset;

			postlock = __kuser_gtod_seqnum;
		} while (prelock != postlock);

		cycle_delta = (nscount - dgtod.cycle_last) & dgtod.mask;
		dgtod.tv_nsec += (cycle_delta * dgtod.mult) >> dgtod.shift;
		while (dgtod.tv_nsec >= NSEC_PER_SEC) {
			dgtod.tv_sec += 1;
			dgtod.tv_nsec -= NSEC_PER_SEC;
		}

		tv->tv_sec = dgtod.tv_sec;
		asm("   movw   %[tmp], #0x4dd3\n\t"
		    "   movt   %[tmp], #0x1062\n\t"
		    "   umull  %[tmp], %[x], %[y], %[tmp]\n\t"
		    "   lsr    %[x], %[x], #6\n\t" :
			[x] "=r" (tv->tv_usec) :
			[y] "r" (dgtod.tv_nsec), [tmp] "r" (tmp)
			: );
	}

	if (tz) {
		do {
			prelock = __kuser_gtod_seqnum;
			tz->tz_minuteswest = __kuser_gtod_tz_minw;
			tz->tz_dsttime = __kuser_gtod_tz_dst;
			postlock = __kuser_gtod_seqnum;
		} while (prelock != postlock);
	}

	return 0;
}
