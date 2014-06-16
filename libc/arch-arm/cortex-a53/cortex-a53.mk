$(call libc-add-cpu-variant-src,MEMMOVE,arch-arm/krait/bionic/memmove.S)
$(call libc-add-cpu-variant-src,BCOPY,)

include bionic/libc/arch-arm/cortex-a15/cortex-a15.mk
