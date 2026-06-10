
# IPKs
for arch in `ls bin/packages | grep -v '^\.' | grep -v '^all$'`; do
    [ -d bin/packages/$arch ] || continue
    rsync --progress --exclude='Packages' --exclude='Packages.*' -a bin/packages/$arch $REPO_DEST/
    rsync -a --del bin/packages/$arch/nas $REPO_DEST/$arch/
done
rsync --progress --exclude='Packages' --exclude='Packages.*' -a bin/packages/all/nas_luci $REPO_DEST/all/
rsync -a --del bin/packages/all/nas_luci $REPO_DEST/all/

for conf in `find -H bin/packages/all -maxdepth 1 -type f -name '*.conf'`; do
    rsync -a $conf $REPO_DEST/all/
done

# APKs
for arch in `ls bin/apks | grep -v '^\.' | grep -v '^all$'`; do
    [ -d bin/apks/$arch ] || continue
    rsync --progress --exclude='packages.adb' -a bin/apks/$arch $REPO_DEST-apk/
    rsync --include="*/" --include='packages.adb' --exclude="*" -a bin/apks/$arch $REPO_DEST-apk/
    rsync -a --del bin/apks/$arch/nas $REPO_DEST-apk/$arch/
done
rsync --progress --exclude='packages.adb' -a bin/apks/all/nas_luci $REPO_DEST-apk/all/
rsync --include="*/" --include='packages.adb' --exclude="*" -a bin/apks/all/nas_luci $REPO_DEST-apk/all/
rsync -a --del bin/apks/all/nas_luci $REPO_DEST-apk/all/
