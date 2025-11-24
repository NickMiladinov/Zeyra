library;

import 'package:flutter_test/flutter_test.dart';

import '../shared/widgets/app_banner_test.dart' as app_banner_test;
import '../shared/widgets/app_card_test.dart' as app_card_test;
// Import other widget tests here as they are created

void main() {
  group('All Widget Tests', () {
    app_banner_test.main();
    app_card_test.main();
  });
}

