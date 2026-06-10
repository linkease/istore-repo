TOPDIR:=${CURDIR}

export PATH:=$(TOPDIR)/staging_dir/host/bin:$(PATH)

include rules.mk

FEEDS_AVAILABLE:=${INDEX_FEEDS}

ARCH_PACKAGES:=${INDEX_ARCH}
PACKAGE_SUBDIRS:=$(foreach FEED,$(FEEDS_AVAILABLE),$(OUTPUT_DIR)/packages/$(ARCH_PACKAGES)/$(FEED))
APKS_SUBDIRS:=$(foreach FEED,$(FEEDS_AVAILABLE),$(OUTPUT_DIR)/apks/$(ARCH_PACKAGES)/$(FEED))

curdir:=package
$(curdir)/index: FORCE
	@echo Generating package index for $(ARCH_PACKAGES)...
	@for d in $(PACKAGE_SUBDIRS); do ( \
		mkdir -p $$d; \
		cd $$d || exit 0; \
		$(SCRIPT_DIR)/ipkg-make-index.sh . 2>&1 > Packages.manifest; \
		grep -vE '^(Maintainer|LicenseFiles|Source|SourceName|Require|SourceDateEpoch)' Packages.manifest > Packages; \
		case "$$(((64 + $$(stat -L -c%s Packages)) % 128))" in 110|111) \
			$(call ERROR_MESSAGE,WARNING: Applying padding in $$d/Packages to workaround usign SHA-512 bug!); \
			{ echo ""; echo ""; } >> Packages;; \
		esac; \
		gzip -9nc Packages > Packages.gz; \
		[ -s $(BUILD_KEY) ] || exit 0; \
		$(STAGING_DIR_HOST)/bin/usign -S -m Packages -s $(BUILD_KEY); \
	); done

$(curdir)/mkndx: FORCE
	[ -s $(BUILD_KEY_APK_SEC) ]
	@echo Generating apk index for $(ARCH_PACKAGES)...
	@for d in $(APKS_SUBDIRS); do ( \
		set -e; \
		mkdir -p $$d; \
		cd $$d || exit 0; \
		ls *.apk >/dev/null 2>&1 || exit 0; \
		$(STAGING_DIR_HOST)/bin/apk mkndx \
			--root $(TOPDIR) \
			--keys-dir $(TOPDIR) \
			--allow-untrusted \
			--sign $(BUILD_KEY_APK_SEC) \
			--output packages.adb \
			*.apk; \
	); done
