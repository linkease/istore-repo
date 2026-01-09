
for arch in `ls bin/packages | grep -v '^\.' | grep -v '^all$'`; do
    rsync --progress --exclude='Packages' --exclude='Packages.*' -a bin/packages/$arch $REPO_DEST/
    rsync -a --del bin/packages/$arch/nas $REPO_DEST/$arch/
done
rsync --progress --exclude='Packages' --exclude='Packages.*' -a bin/packages/all/nas_luci $REPO_DEST/all/
rsync -a --del bin/packages/all/nas_luci $REPO_DEST/all/

for conf in `find -H bin/packages/all -maxdepth 1 -type f -name '*.conf'`; do
    rsync -a $conf $REPO_DEST/all/
done
