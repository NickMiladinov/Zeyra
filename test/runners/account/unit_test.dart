@Tags(['account'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../features/account/logic/account_notifier_test.dart'
    as account_notifier_tests;

void main() {
  group('[Account] Unit Tests', () {
    account_notifier_tests.main();
  });
}
