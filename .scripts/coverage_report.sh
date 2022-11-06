#!/bin/sh
# flutter test --coverage -j 12
lcov --remove ./coverage_report/lcov.info 'lib/src/core/self_signed_adapter.dart' -o ./coverage_report/new_lcov.info
genhtml ./coverage_report/new_lcov.info -o ./coverage_report/html
flutter pub run test_coverage_badge
open ./coverage_report/html/index.html