library;

import 'package:flutter_test/flutter_test.dart';

import '../shared/widgets/app_card_test.dart' as app_card_test;
import '../shared/widgets/app_jit_tooltip_test.dart' as app_jit_tooltip_test;

void main() {
  group('All Widget Tests', () {
    app_card_test.main();
    app_jit_tooltip_test.main();
  });
}

