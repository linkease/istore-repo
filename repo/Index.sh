
for arch in `ls bin/packages | grep -v '^\.' | grep -v '^all$'`; do
    INDEX_ARCH=$arch INDEX_FEEDS=nas make -f repo/Index.mk package/index || exit 1
done
INDEX_ARCH=all INDEX_FEEDS=nas_luci make -f repo/Index.mk package/index || exit 1
