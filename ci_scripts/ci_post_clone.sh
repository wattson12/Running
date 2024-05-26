#!/bin/sh

# skip macro validation on CI
echo "Skipping macro validation"
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

echo "Setting environment variable for IS_TESTFLIGHT_BUILD"
plutil -replace IS_TESTFLIGHT_BUILD -string $IS_TESTFLIGHT_BUILD Running/Info.plist

plutil -p Running/Info.plist