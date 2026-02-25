@Tags(['account'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../features/account/logic/account_notifier_test.dart'
    as account_notifier_tests;
import '../../integration/user_flows/account/account_lifecycle_flow_test.dart'
    as account_integration_tests;

void main() {
  group('[Account] All Tests', () {
    account_notifier_tests.main();
    account_integration_tests.main();
  });
}
