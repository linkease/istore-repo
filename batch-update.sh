#!/bin/sh

update() {
    local dest=${1%%/}
    local src=${2%%/}
    local file
    local pkg
    local old
    ls "$src/" | grep '.ipk$' | while read; do
        file="$REPLY"
        [ -f "$dest/$file" ] && continue
        pkg=`tar -xOf "$src/$file" ./control.tar.gz | tar -xOz ./control | grep '^Package: ' | sed 's/^Package: \(.*\)$/\1/'`
        old=`cd "$dest"; ls ${pkg}_*.ipk 2>/dev/null | head -1`
        if [ -n "$old" ];then
            echo "remove old $pkg: $old"
            rm -f "$dest/$old"
        fi
        echo "copy new $pkg: $file"
        cp -a "$src/$file" "$dest/"
    done
}

usage() {
    cat <<-EOF >&2
Batch update ipks
Usage: $1 <DEST_DIR> <SRC_DIR>
EOF
}

[ -z "$1" -o -z "$2" ] && { usage $0; exit 1; }
[ -d "$1" -a -d "$2" ] || {
    echo "DEST_DIR ($1) or/and SRC_DIR ($2) does not exists"
    exit 1
}

update "$1" "$2"
