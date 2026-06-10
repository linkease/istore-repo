find bin/packages/ \( -name 'Packages' -or -name 'Packages.*' \) -exec rm -f '{}' ';'
find bin/apks/ -name 'packages.adb' -exec rm -f '{}' ';'
