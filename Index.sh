INDEX_ARCH=aarch64_cortex-a53 INDEX_FEEDS=nas make -f Index.mk package/index || exit 1
INDEX_ARCH=x86_64 INDEX_FEEDS=nas make -f Index.mk package/index || exit 1
INDEX_ARCH=all INDEX_FEEDS=nas_luci make -f Index.mk package/index || exit 1
