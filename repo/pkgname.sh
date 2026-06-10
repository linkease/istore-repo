#!/bin/bash
file="$1"
if [ -z "$file" ]; then
	echo "Usage: $0 <.ipk or .apk file>" >&2
	exit 1
fi
if [ ! -s "$file" ]; then
	echo "File not found or empty: $file" >&2
	exit 1
fi

if [[ "$file" == *.ipk ]]; then
	{ tar -xOf "$file" ./control.tar.gz || tar -xOf "$file" control.tar.gz; } | tar -xOz ./control | grep '^Package: ' | head -1 | sed 's/^Package: \(.*\)$/\1/'
elif [[ "$file" == *.apk ]]; then
	./staging_dir/host/bin/apk adbdump --format json "$file" | jq -r .info.name
else
	echo "Unsupported file type: $file" >&2
	exit 1
fi
