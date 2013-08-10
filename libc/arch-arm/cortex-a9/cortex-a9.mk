$(call libc-add-cpu-variant-src,MEMCPY,arch-arm/cortex-a9/bionic/memcpy.S)
$(call libc-add-cpu-variant-src,MEMSET,arch-arm/cortex-a9/bionic/memset.S)
$(call libc-add-cpu-variant-src,STRCAT,arch-arm/cortex-a9/bionic/strcat.S)
$(call libc-add-cpu-variant-src,STRCMP,arch-arm/cortex-a9/bionic/strcmp.S)
ifeq ($(ARCH_ARM_HAVE_NEON),true)
$(call libc-add-cpu-variant-src,MEMMOVE,arch-arm/bionic/memmove.S)
else
$(call libc-add-cpu-variant-src,MEMMOVE,bionic/memmove.c.arm)
$(call libc-add-cpu-variant-src,BCOPY,string/bcopy.c.arm)
endif
$(call libc-add-cpu-variant-src,STRCPY,arch-arm/cortex-a9/bionic/strcpy.S)
$(call libc-add-cpu-variant-src,STRLEN,arch-arm/cortex-a9/bionic/strlen.S)

#include bionic/libc/arch-arm/generic/generic.mk
