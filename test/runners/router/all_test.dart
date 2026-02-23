@Tags(['router'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'quick_test.dart' as router_quick_tests;
import '../../integration/user_flows/router/critical_auth_routing_flow_test.dart'
    as router_integration_tests;

void main() {
  group('[Router] All Tests', () {
    group('1. Quick', () {
      router_quick_tests.main();
    });

    group('2. Integration', () {
      router_integration_tests.main();
    });
  });
}

