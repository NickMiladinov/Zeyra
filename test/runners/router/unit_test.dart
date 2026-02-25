@Tags(['router'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'quick_test.dart' as router_quick_tests;

void main() {
  group('[Router] Unit Tests', () {
    router_quick_tests.main();
  });
}

