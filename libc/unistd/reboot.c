/*
 * Copyright (C) 2008 The Android Open Source Project
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
#include <unistd.h>
#include <stdlib.h>
#include <sys/reboot.h>
#include <sys/wait.h>

static void do_preshutdown_cleanup_inner(void)
{
    pid_t bg_pid;
    bg_pid = fork();
    if (bg_pid < 0)
        return;
    if (bg_pid) {
        int ret_stat, i;
        if (bg_pid == waitpid(bg_pid, &ret_stat, WNOHANG))
            return;
        for (i = 0; i < 100; i++) {
            usleep(100000);
            if (bg_pid == waitpid(bg_pid, &ret_stat, WNOHANG))
                return;
        }
    } else {
        execl("/system/etc/preshutdown", "/system/etc/preshutdown", (char *)NULL);
        exit(255);
    }
}

void do_preshutdown_cleanup(void)
{
    do_preshutdown_cleanup_inner();
    sync();
}

int reboot (int  mode) 
{
    return __reboot( LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2, mode, NULL );
}
