#!/bin/bash

set -e

base_dir=$(dirname "$0")
cd "$base_dir"

echo ""
echo ""
echo "Building Pods project..."
set -o pipefail && xcodebuild -workspace "Pods Project/AnimatableStackView.xcworkspace" -scheme "AnimatableStackView-Example" -configuration "Release" -sdk iphonesimulator | xcpretty

echo -e "\nBuilding Carthage project..."
set -o pipefail && xcodebuild -project "Carthage Project/AnimatableStackView.xcodeproj" -sdk iphonesimulator -target "Example" | xcpretty

echo -e "\nBuilding with Carthage..."
carthage build --no-skip-current --cache-builds

echo -e "\nPerforming tests..."
set -o pipefail && xcodebuild -project "Carthage Project/AnimatableStackView.xcodeproj" -sdk iphonesimulator -scheme "Example" -destination "platform=iOS Simulator,name=iPhone SE,OS=12.4" test | xcpretty

echo ""
echo "SUCCESS!"
echo ""
echo ""
