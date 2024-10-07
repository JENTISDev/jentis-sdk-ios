#!/bin/sh

#  GenerateFramework.sh
#  JentisSDK
#
#  Created by Alexandre Oliveira on 07/10/2024.
#  

#!/bin/bash

# variables
FRAMEWORK_NAME="JentisSDK"
SCHEME_NAME="JentisSDK"
BUILD_DIR="./build"
XCFRAMEWORK_DIR="./${FRAMEWORK_NAME}.xcframework"

# Clean previous build artifacts
rm -rf "${BUILD_DIR}"
rm -rf "${XCFRAMEWORK_DIR}"

# Build for iOS devices
xcodebuild archive \
  -scheme "${SCHEME_NAME}" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "${BUILD_DIR}/iOS" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS simulator
xcodebuild archive \
  -scheme "${SCHEME_NAME}" \
  -configuration Release \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "${BUILD_DIR}/iOSSimulator" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES


# Create the XCFramework
xcodebuild -create-xcframework \
  -framework "${BUILD_DIR}/iOS.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
  -framework "${BUILD_DIR}/iOSSimulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
  -output "${XCFRAMEWORK_DIR}"

echo "XCFramework created at ${XCFRAMEWORK_DIR}"
