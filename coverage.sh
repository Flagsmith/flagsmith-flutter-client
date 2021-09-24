#!/bin/sh
flutter test --coverage -j 12
lcov --remove coverage/lcov.info 'lib/src/core/self_signed_adapter.dart' -o coverage/new_lcov.info
genhtml coverage/new_lcov.info -o coverage/html
flutter pub run test_coverage_badge
open coverage/html/index.html