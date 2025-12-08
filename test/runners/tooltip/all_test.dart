/// Runs all tooltip-related tests.
library;

import 'package:flutter_test/flutter_test.dart';

import '../../shared/providers/tooltip_provider_test.dart' as tooltip_provider_test;
import '../../shared/widgets/app_jit_tooltip_test.dart' as app_jit_tooltip_test;

void main() {
  group('All Tooltip Tests', () {
    tooltip_provider_test.main();
    app_jit_tooltip_test.main();
  });
}
