#!/bin/bash

# https://github.com/mapbox/mapbox-navigation-ios/blob/master/scripts/wcarthage.sh
applyXcode12Workaround() {
    echo "Applying Xcode 12 workaround..."

    echo "Cleanup Carthage temporary items"
    for i in {1..1000}; do
        dir_name="${TMPDIR}TemporaryItems/(A Document Being Saved By carthage ${i})"
        [ -e "${dir_name}" ] && rm -rf "${dir_name}" || true
    done
    
    xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
    trap 'rm -f "${xcconfig}"' INT TERM HUP EXIT
    
    # For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
    # the build will fail on lipo due to duplicate architectures.
    echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
    echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

    export XCODE_XCCONFIG_FILE="${xcconfig}"
    echo "Workaround applied. xcconfig here: ${XCODE_XCCONFIG_FILE}"
}
