/*
 * Copyright (C) 2011 The Android Open Source Project
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

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/param.h>

#include <sys/gmon.h>
#include <sys/mman.h>
#include <asm/sigcontext.h>
#include <asm/ucontext.h>

#include <libaprof.h>
#include <libaprof_impl.h>

static const int binMappedSize = 4;
static const char *anonymousDLinfoName =  "<anonymous>";
static bool aprofInited = false;
static bool aprofJniMode = false;
static unsigned aprofJniCounter = 0;
static int control = APROF_OFF;
#ifdef APROF_STATIC
    extern char *__progname;
#endif

/* SO_MAX from linker */
#define SO_MAX 192
/* +4 for linker, executable, and kernel space */
#define ELFINFO_MAX (SO_MAX + 4)

static const char *aprof_basename(const char *str);
static bool suffixWith(const char *str, const char *suffix);

namespace {
class ELFInfo {
    public:
        bool isContain(uintptr_t addr);
        void mcount(uintptr_t frompc, uintptr_t selfpc);
        void sampler(uintptr_t pc);
        void writeJniMode();
        void writeBins(int fd);
        void writeEdge(int fd);

        uint32_t countEdge();

        static ELFInfo *findContain(uintptr_t addr, bool jniMode);
        static ELFInfo *create(const Dl_info &info, size_t size, bool jniMode);
        static ELFInfo *createByAddress(uintptr_t addr, bool jniMode);
        static void getByAddress(uintptr_t addr);
        static void writeAll();
        static void writeAllJni();
        static void writeEdges(int fd);

        static void dump();
    private:
        void init(const Dl_info &info, size_t size, bool jniMode);

        const char *mName;
        uintptr_t mBase;
        size_t mSize;
        uint32_t mBinSize;
        uint16_t *mBins;

        size_t mFromssize;
        uint16_t *mFroms;

        struct tostruct *mTos;
        size_t mTolimit;
        size_t mTossize;
        bool mJniMode;

        ELFInfo *mNext;

        static const char *getExecutableName();
        static ELFInfo *head;
        static ELFInfo *tail;
        static ELFInfo pool[ELFINFO_MAX];
        static int poolIdx;
};
}

ELFInfo *ELFInfo::head = NULL;
ELFInfo *ELFInfo::tail = NULL;
ELFInfo ELFInfo::pool[ELFINFO_MAX];
int ELFInfo::poolIdx = 0;

static bool isExecutable(const char *name) {
    /* Only linker and executable are start with '/',
     * however linker we are already trade as libdl. */
    return (name[0] == '/' || !suffixWith(name, ".so"));
}

ELFInfo *ELFInfo::findContain(uintptr_t addr, bool jniMode)
{
    for (ELFInfo *info = head;info;info = info->mNext) {
        if (info->isContain(addr)) {
            return info;
        }
    }
    return createByAddress(addr, jniMode);
}

ELFInfo *ELFInfo::create(const Dl_info &dlinfo, size_t size, bool jniMode)
{
    ELFInfo *newInfo = &pool[poolIdx++];
    newInfo->init(dlinfo, size, jniMode);
    if (head == NULL) {
        head = tail = newInfo;
    } else {
        tail->mNext = newInfo;
        tail = tail->mNext;
    }
    return newInfo;
}

const char *ELFInfo::getExecutableName(){
    for (ELFInfo *info = head;info;info = info->mNext) {
        if (isExecutable(info->mName)) {
            return aprof_basename(info->mName);
        }
    }
    return "out";
}

void ELFInfo::init(const Dl_info &info, size_t size, bool jniMode)
{
    mName = info.dli_fname;
    mBase = (uintptr_t)info.dli_fbase;
    mSize = size;
    mBinSize = size / binMappedSize;
    mBins = NULL;
    mJniMode =jniMode;
    mNext = NULL;

    /* Allocate mBins  */
    void *addr;
    addr = mmap((void *)0, mBinSize * sizeof(uint16_t),
                PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, (off_t)0);
    if (addr == MAP_FAILED) {
        goto mapfailed;
    }
    mBins = (uint16_t *)addr;

    mFromssize = mSize / HASHFRACTION;
    mTolimit = mSize * ARCDENSITY / 100;
    if (mTolimit < MINARCS) {
        mTolimit = MINARCS;
    } else if (mTolimit > MAXARCS) {
        mTolimit = MAXARCS;
    }
    mTossize = mTolimit * sizeof(struct tostruct);

    addr = mmap((void *)0, mFromssize,  PROT_READ|PROT_WRITE,
                MAP_ANON|MAP_PRIVATE, -1, (off_t)0);
    if (addr == MAP_FAILED) {
        goto mapfailed;
    }
    mFroms = (uint16_t*)addr;

    addr = mmap((void *)0, mTossize,  PROT_READ|PROT_WRITE,
                MAP_ANON|MAP_PRIVATE, -1, (off_t)0);
    if (addr == MAP_FAILED) {
        goto mapfailed;
    }
    mTos = (struct tostruct*)addr;
    mTos[0].link = 0;

    return;
mapfailed:
    if (mBins != NULL) {
        munmap(mBins, mBinSize * sizeof(uint16_t));
        mBins = NULL;
    }
    if (mFroms != NULL) {
        munmap(mFroms, mFromssize);
        mFroms = NULL;
    }
    if (mTos != NULL) {
        munmap(mTos, mTossize);
        mTos = NULL;
    }

    ERROR("Out of memory !!!!!\n");
}

bool ELFInfo::isContain(uintptr_t addr)
{
    if (addr >= mBase && addr < mBase +mSize) {
        return true;
    } else {
        return false;
    }
}


static bool suffixWith(const char *str, const char *suffix)
{
    size_t len = strlen(str);
    size_t suffixLen = strlen(suffix);
    if (len < suffixLen) return false;
    return strcmp(str + len - suffixLen, suffix) == 0;
}

static const int BUFFER_SIZE = PATH_MAX+256;
ELFInfo *ELFInfo::createByAddress(uintptr_t addr, bool jniMode)
{
    Dl_info info;
    ELFInfo *elfInfo = NULL;
    bool isAnonymous = false;
#ifndef APROF_STATIC
    if (dladdr((void*)addr, &info)) {
        DEBUG("dladdr = %s %p\n", info.dli_fname, info.dli_fbase);
    } else {
        DEBUG("PC %p in Anonymous memory space\n", (void*)addr);
        isAnonymous = true;
    }
#else
    info.dli_fname = __progname;
    info.dli_fbase = 0;
#endif
    FILE *fd = fopen("/proc/self/maps", "r");
    if (fd == NULL) {
        ERROR("Can't open /proc/self/maps!\n");
        return NULL;
    }

    char buf[BUFFER_SIZE];
    char path[PATH_MAX];
    unsigned long begin, end;
    char permission[5];
    long dummy;
    while( fgets(buf, BUFFER_SIZE, fd) ) {
        sscanf(buf, "%lx-%lx %4c %lx %lx:%lx %ld %s\n",
              &begin, &end, &permission[0], &dummy,
              &dummy, &dummy, &dummy, path);
        permission[4] = '\0';
        if (addr >= begin && addr < end) {
            if (permission[2] != 'x') {
                ERROR("PC in non-executable region!?\n");
            }
            DEBUG("%lx-%lx %s %s\n", begin, end, permission, path);
            if (isAnonymous) {
                if (suffixWith(path, "linker")) {
                    /* Most of situation is calling the dl* functions
                     * if the PC is in linker */
                    info.dli_fname = "libdl.so";
                } else {
                    info.dli_fname = anonymousDLinfoName;
                }
                info.dli_fbase = (void *)begin;
            } else {
                if (!suffixWith(path, info.dli_fname)) {
#ifdef APROF_STATIC
                    info.dli_fname = anonymousDLinfoName;
                    info.dli_fbase = (void *)begin;
#else
                    ERROR("Find the wrong dl info ?\n");
#endif
                }
                if (info.dli_fbase == 0) {
                    /* Hanlde for non-PIE */
                    info.dli_fbase = (void *)begin;
                }
            }
            elfInfo = create(info, (size_t)(end - begin), jniMode);
            break;
        }
    }
    fclose(fd);
    return elfInfo;
}

void ELFInfo::dump()
{
    for (ELFInfo *info = ELFInfo::head;info;info = info->mNext) {
        DEBUG("ELFInfo = {\n"
              "  name = %s,\n"
              "  base = %p,\n"
              "  size = %zd,\n"
              "}\n",
              info->mName,
              (void*)info->mBase,
              info->mSize);
    }
}

void ELFInfo::mcount(uintptr_t frompc, uintptr_t selfpc)
{
    uintptr_t frompcOffset = frompc - mBase;
    uint16_t *frompcIndex =
        &mFroms[frompcOffset / (HASHFRACTION * sizeof(*mFroms))];
    size_t toindex = *frompcIndex;
    struct tostruct *top, *prevtop;
    if (toindex == 0) {
        /*
         *  first time traversing this arc
         */
        toindex = ++mTos[0].link;
        if (toindex >= mTolimit)
            /* halt further profiling */
            goto overflow;

        *frompcIndex = toindex;
        top = &mTos[toindex];
        top->selfpc = selfpc;
        top->count = 1;
        top->link = 0;
        return;
    }

    top = &mTos[toindex];
    if (top->selfpc == selfpc) {
        /*
         * arc at front of chain; usual case.
         */
        top->count++;
        return;
    }

    /*
     * have to go looking down chain for it.
     * top points to what we are looking at,
     * prevtop points to previous top.
     * we know it is not at the head of the chain.
     */
    for (; /* goto done */; ) {
        if (top->link == 0) {
            /*
             * top is end of the chain and none of the chain
             * had top->selfpc == selfpc.
             * so we allocate a new tostruct
             * and link it to the head of the chain.
             */
            toindex = ++mTos[0].link;
            if (toindex >= mTolimit)
                goto overflow;

            top = &mTos[toindex];
            top->selfpc = selfpc;
            top->count = 1;
            top->link = *frompcIndex;
            *frompcIndex = toindex;
            return;
        }
        /*
         * otherwise, check the next arc on the chain.
         */
        prevtop = top;
        top = &mTos[top->link];
        if (top->selfpc == selfpc) {
            /*
             * there it is.
             * increment its count
             * move it to the head of the chain.
             */
            top->count++;
            toindex = prevtop->link;
            prevtop->link = top->link;
            top->link = *frompcIndex;
            *frompcIndex = toindex;
            return;
        }
    }
    return;

overflow:
    ERROR("overflow @ %s\n", mName);
    return;
}

void ELFInfo::sampler(uintptr_t pc)
{
    if (aprofJniMode && !mJniMode) {
        return;
    }
    size_t i = ((uintptr_t)pc - (uintptr_t)mBase) / binMappedSize;
    if (i < mBinSize) {
        mBins[i]++;
    } else {
        ERROR("out of range %u (bin size : %u)\n", i, mBinSize);
    }
}

static void writeHeader(int fd) {
    const char aprof_tag[] = APROF_TAG;
    uint32_t aprof_version = APROF_VERSION;
    uint32_t sample_rate = PROFRATE;
    uint32_t pointer_size = sizeof(uintptr_t);
    /* Write aprof profiling file header. */
    write(fd, aprof_tag, APROF_TAG_LENGTH);
    write(fd, &aprof_version, sizeof(uint32_t));
    write(fd, &sample_rate, sizeof(uint32_t));
    write(fd, &pointer_size, sizeof(uint32_t));
}

static int openFile(const char *filename)
{
    int fd;
    const char defaultPath[] = "/mnt/sdcard/";
    const char suffix[] = ".aprof";
    char output[PATH_MAX] = "";
    size_t maxlen, envlen;
    const char* env;
    env = getenv("APROF_OUTPUT");
    if (env == NULL) {
      env = getenv("EXTERNAL_STORAGE");
    }
    if (env) {
        envlen = strlen(env);
        maxlen = PATH_MAX - (sizeof(suffix) + envlen +
                              1 /* for '/' */ + 1 /* for '\0' */);
        strcpy(output, env);
        strcat(output, "/");
    } else {
        maxlen = PATH_MAX - (sizeof(suffix) + sizeof(defaultPath) + 1);
        strcpy(output, defaultPath);
    }
    strncat(output, filename, maxlen);
    strcat(output, suffix);

    fd = open(output, O_CREAT|O_TRUNC|O_WRONLY, 0664);
    DEBUG("aprof : open %s fd = %d\n", output, fd);
    return fd;
}

static const char *aprof_basename(const char *str)
{
    const char *end = str + strlen(str);
    const char *itr = end-1;
    while (itr != str) {
        if (*itr == '/') {
            return itr+1;
        } else {
            itr--;
        }
    }
    return itr;
}

static bool startWith(const char *str, const char *prefix)
{
    while (*prefix != '\0' && *str != '\0') {
        if (*prefix != *str) return false;
        prefix++;
        str++;
    }
    if (*prefix == '\0') return true;
    else                 return false;
}

void ELFInfo::writeBins(int fd)
{
    /* Don't write out libaprof* and anonymous memory space */
    if (startWith(mName, "libaprof") || mName[0] == '<') {
        return;
    }
    uint32_t headerType;
    bool isExe;
#ifdef APROF_STATIC
    isExe = true;
#else
    isExe = isExecutable(mName);
#endif
    if (isExe) {
        headerType = APROF_EXECUTABLE_HISTOGRAM_HEADER;
    } else {
        headerType = APROF_HISTOGRAM_HEADER;
    }
    const char *name = NULL;
    if (isExe) {
        name = aprof_basename(mName);
    } else {
        name = mName;
    }
    write(fd, &headerType, sizeof(uint32_t));

    DEBUG("aprof : write %s bins...\n", mName);

    unsigned len = strlen(name);
    write(fd, &len, sizeof(len));
    write(fd, name, len);
    write(fd, &mBase, sizeof(mBase));
    write(fd, &mSize, sizeof(mSize));
    write(fd, &mBinSize, sizeof(mBinSize));
    write(fd, &binMappedSize, sizeof(uint32_t));
    if (mBins != NULL) {
        write(fd, mBins, mBinSize*sizeof(uint16_t));
    }
}

uint32_t ELFInfo::countEdge()
{
    uint32_t numEdges = 0;
    int fromindex, endfrom, toindex;

    endfrom = mFromssize / sizeof(*mFroms);
    for (fromindex = 0; fromindex < endfrom; fromindex++) {
        if (mFroms[fromindex] == 0)
            continue;
        for (toindex = mFroms[fromindex]; toindex != 0;
             toindex = mTos[toindex].link) {
            numEdges++;
        }
    }
    return numEdges;
}

void ELFInfo::writeEdge(int fd)
{
    int fromindex, endfrom, toindex;
    uintptr_t frompc;
    uintptr_t selfpc;
    uint32_t count;

    endfrom = mFromssize / sizeof(*mFroms);
    for (fromindex = 0; fromindex < endfrom; fromindex++) {
        if (mFroms[fromindex] == 0)
            continue;

        frompc = mBase + (fromindex * HASHFRACTION * sizeof(*mFroms));
        for (toindex = mFroms[fromindex]; toindex != 0;
             toindex = mTos[toindex].link) {
            selfpc = mTos[toindex].selfpc;
            count = mTos[toindex].count;
            DEBUG("%x->%x : %d\n", frompc, selfpc, count);
            write(fd, &frompc, sizeof(uintptr_t));
            write(fd, &selfpc, sizeof(uintptr_t));
            write(fd, &count, sizeof(uint32_t));
        }
    }

}

void ELFInfo::writeEdges(int fd)
{
    uint32_t headerType = APROF_CALL_GRAPH_HEADER;
    uint32_t numEdges = 0;
    for (ELFInfo *info = ELFInfo::head;info;info = info->mNext) {
        numEdges += info->countEdge();
    }
    write(fd, &headerType, sizeof(uint32_t));
    write(fd, &numEdges, sizeof(uint32_t));

    for (ELFInfo *info = ELFInfo::head;info;info = info->mNext) {
        info->writeEdge(fd);
    }
}

void ELFInfo::writeJniMode()
{
    int fd = openFile(mName);
    if (fd < 0) {
        ERROR("fail to open file for output\n");
        return;
    }
    writeHeader(fd);
    writeBins(fd);

    uint32_t headerType = APROF_CALL_GRAPH_HEADER;
    uint32_t numEdges = countEdge();

    write(fd, &headerType, sizeof(uint32_t));
    write(fd, &numEdges, sizeof(uint32_t));

    writeEdge(fd);

    close(fd);
}

void ELFInfo::writeAllJni() {
    for (ELFInfo *info = ELFInfo::head;info;info = info->mNext) {
        info->writeJniMode();
    }
}

void ELFInfo::writeAll()
{
    int fd;
    const char *env;
#ifdef APROF_STATIC
    const char *filename = __progname;
#else
    const char *filename = getExecutableName();
#endif
    env = getenv("APROF_OUTPUT_FILENAME");
    if (env) {
        filename = env;
    }
    fd = openFile(filename);
    if (fd < 0) {
        ERROR("fail to open file for output\n");
        return;
   }
    writeHeader(fd);

    for (ELFInfo *info = ELFInfo::head;info;info = info->mNext) {
        info->writeBins(fd);
    }

    writeEdges(fd);

    close(fd);
}


void aprof_mcount(uintptr_t frompc, uintptr_t selfpc)
{
    ELFInfo *info = ELFInfo::findContain(frompc, false);
    info->mcount(frompc, selfpc);
}

static void aprof_sampler (int sig __attribute__((unused)),
                           siginfo_t *sii __attribute__((unused)),
                           void *context)
{
    struct ucontext *uc = (struct ucontext*)context;
    uintptr_t pc;
#if defined(__arm__)
    pc = uc->uc_mcontext.arm_pc;
#elif defined(__mips__)
    pc = uc->uc_mcontext.sc_pc;
#elif defined(__i386__)
    pc = uc->uc_mcontext.eip;
#else
#error "Aprof not supported"
#endif
    ELFInfo *info = ELFInfo::findContain(pc, false);
    info->sampler(pc);
}

void aprof_init(void *module_address)
{
    struct sigaction sigact;
    struct itimerval timer;
    if (module_address != NULL) {
        if (aprofInited && aprofJniCounter == 0) {
            ERROR("aprof already start with non-jni mode!");
            return;
        }

        ELFInfo *info =
            ELFInfo::createByAddress((uintptr_t)module_address, true);
        aprofJniCounter++;
        if (aprofJniCounter != 1) {
            return;
        }
    }
    aprofInited = true;
    DEBUG("aprof : init\n");
    sigact.sa_sigaction =  &aprof_sampler;
    sigact.sa_flags = SA_RESTART | SA_SIGINFO;
    sigfillset(&sigact.sa_mask);

    if (sigaction(SIGPROF, &sigact, NULL) < 0) {
        ERROR("error on set sigaction");
        return;
    }

    timer.it_value.tv_sec = 0;
    timer.it_value.tv_usec = 1000000 / (PROFRATE);
    timer.it_interval = timer.it_value;
    if (setitimer(ITIMER_PROF, &timer, NULL) < 0) {
        ERROR("error on setitimer");
        return;
    }
}

void aprof_fini(void *module_address)
{
    if (module_address != NULL) {
        ELFInfo *info = ELFInfo::findContain((uintptr_t)module_address, false);
        info->writeJniMode();
        aprofJniCounter--;
        if (aprofJniCounter == 0) {
            /* Trun off aprof_sampler */
            sigaction(SIGPROF, NULL, NULL);
            setitimer(ITIMER_PROF, NULL, NULL);
        }
    } else {
        ELFInfo::writeAll();
    }
}

void aprof_control(int control)
{
    /* Do nothing if non-JNI mode*/
    if (!aprofJniCounter) return;
    if (control == APROF_OFF) {
        DEBUG("aprof : APROF_OFF\n");
        setitimer(ITIMER_PROF, NULL, NULL);
        ELFInfo::writeAllJni();
    } else {
        DEBUG("aprof : APROF_ON\n");
        struct itimerval timer;
        timer.it_value.tv_sec = 0;
        timer.it_value.tv_usec = 1000000 / (PROFRATE);
        timer.it_interval = timer.it_value;
        if (setitimer(ITIMER_PROF, &timer, NULL) < 0) {
            ERROR("aprof : error on setitimer");
            return;
        }
    }
}
