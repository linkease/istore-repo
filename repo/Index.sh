
for arch in `ls bin/packages | grep -v '^\.' | grep -v '^all$'`; do
    [ -d bin/packages/$arch ] || continue
    INDEX_ARCH=$arch INDEX_FEEDS=nas make -f repo/Index.mk package/index || exit 1
done
INDEX_ARCH=all INDEX_FEEDS=nas_luci make -f repo/Index.mk package/index || exit 1

for arch in `ls bin/apks | grep -v '^\.' | grep -v '^all$'`; do
    [ -d bin/apks/$arch ] || continue
    INDEX_ARCH=$arch INDEX_FEEDS=nas make -f repo/Index.mk package/mkndx || exit 1
done
INDEX_ARCH=all INDEX_FEEDS=nas_luci make -f repo/Index.mk package/mkndx || exit 1
