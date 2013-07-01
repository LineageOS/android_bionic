$(call libc-add-cpu-variant-src,MEMCPY,arch-arm/krait/bionic/memcpy.S)
$(call libc-add-cpu-variant-src,MEMSET,arch-arm/krait/bionic/memset.S)
$(call libc-add-cpu-variant-src,STRCMP,arch-arm/krait/bionic/strcmp.S)
$(call libc-add-cpu-variant-src,MEMMOVE,arch-arm/krait/bionic/memmove.S)
# Use cortex-a15 version of strlen.
$(call libc-add-cpu-variant-src,STRLEN,arch-arm/cortex-a15/bionic/strlen.S)

#include bionic/libc/arch-arm/generic/generic.mk
