#!/usr/bin/env bash
# Runs on the CI emulator: screen walkthrough with screenshots.
set -u
mkdir -p screenshots
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart > screenshots/drive.txt 2>&1
MAIN=$?
echo "main=$MAIN" > screenshots/status.txt
grep -E "Some tests|All tests|EXCEPTION|Expected|Actual" screenshots/drive.txt | head -30
[ $MAIN -eq 0 ]
