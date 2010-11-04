/*
 * Copyright (C) 2010 The Android Open Source Project
 * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
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

#include <mntent.h>

#define MNTENT_LENGTH_MAX 400    //Buffer size for one record in mount entry file

static struct mntent *mnt = NULL;
char mntent_buf[MNTENT_LENGTH_MAX];    //Buffer to hold a record in mount entry file

struct mntent* getmntent(FILE* f)
{
    int index = 0, i = 0, flag = 1;
    char ch;
    char *temp;
    //Keeping count so that we don't over run the buffer size
    int count = MNTENT_LENGTH_MAX;

    if(mnt == NULL)
        if(!(mnt = (struct mntent *)malloc(sizeof(struct mntent))))
            return NULL;

    mnt->mnt_fsname = mntent_buf;

    if(f->_read(f->_cookie, &ch, 1) != 1)
        return NULL;

    // There are exactly 6 columns per record and so
    // we are checking value of index against 6 here.
    while(ch && (index < 6) && count) {
        switch(index) {
            case 0:
                //Storing mounted device.
                if(ch != ' ') {
                    mnt->mnt_fsname[i++] = ch;
                }
                else {
                    mnt->mnt_fsname[i++] = '\0';
                    mnt->mnt_dir =  &(mnt->mnt_fsname[i]);
                    i = 0;
                    index++;
                }
                count--;
                break;
            case 1:
                //Storing mount point.
                if(ch != ' ') {
                    mnt->mnt_dir[i++] = ch;
                }
                else {
                    mnt->mnt_dir[i++] = '\0';
                    mnt->mnt_type =  &(mnt->mnt_dir[i]);
                    i = 0;
                    index++;
                }
                count--;
                break;
            case 2:
                //Storing file system type.
                if(ch != ' ') {
                    mnt->mnt_type[i++] = ch;
                }
                else {
                    mnt->mnt_type[i++] = '\0';
                    mnt->mnt_opts =  &(mnt->mnt_type[i]);
                    i = 0;
                    index++;
                }
                count--;
                break;
            case 3:
                //Storing mount options.
                if(ch != ' ') {
                    mnt->mnt_opts[i++] = ch;
                }
                else {
                    mnt->mnt_opts[i++] = '\0';
                    temp =  &(mnt->mnt_opts[i]);
                    i = 0;
                    index++;
                }
                count--;
                break;
            case 4:
                //Dummy value to match the format of /etc/mtab
                if(ch != ' ') {
                    temp[i++] = ch;
                }
                else {
                    temp[i++] = '\0';
                    mnt->mnt_freq = atoi(temp);
                    temp = &(temp[i]);
                    i = 0;
                    index++;
                }
                count--;
                break;
            case 5:
                //Dummy value to match the format of /etc/mtab
                if(ch != '\n') {
                    temp[i++] = ch;
                }
                else {
                    temp[i++] = '\0';
                    mnt->mnt_passno = atoi(temp);
                    temp = &(temp[i]);
                    i = 0;
                    index++;
                    flag = 0;
                }
                count--;
                break;
        }
        if (flag)
            f->_read(f->_cookie, &ch, 1);
    }
    if(!count && flag)
        return NULL;

    return mnt;
}

FILE* setmntent(const char *filename, const char *type)
{
    return fopen(filename,  type);
}

int endmntent(FILE* f)
{
    if(mnt) {
        free(mnt);
        mnt = NULL;
    }
    f->_close(f);
    return 1;
}
