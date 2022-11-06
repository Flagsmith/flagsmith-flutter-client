#!/bin/sh
flutter test --coverage
lcov --remove coverage/lcov.info 'lib/src/extensions/self_signed_adapter.dart' 'lib/utils/l10n/*' -o coverage/lcov_trimed.info
genhtml coverage/lcov_trimed.info -o coverage/html
flutter pub run test_coverage_badge
open coverage/html/index.html