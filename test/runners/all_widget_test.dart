library;

import 'package:flutter_test/flutter_test.dart';

import '../features/contraction_timer/ui/screens/contraction_session_detail_screen_test.dart'
    as contraction_session_detail_screen_test;
import '../features/contraction_timer/ui/screens/labour_overview_screen_test.dart'
    as labour_overview_screen_test;
import '../features/contraction_timer/ui/widgets/rule_511_progress_test.dart'
    as rule_511_progress_test;
import '../features/contraction_timer/ui/widgets/session_511_status_card_test.dart'
    as session_511_status_card_test;
import '../shared/widgets/app_banner_test.dart' as app_banner_test;
import '../shared/widgets/app_card_test.dart' as app_card_test;
import '../shared/widgets/app_jit_tooltip_test.dart' as app_jit_tooltip_test;
import '../shared/widgets/app_progress_unlock_banner_test.dart'
    as app_progress_unlock_banner_test;
// Import other widget tests here as they are created

void main() {
  group('All Widget Tests', () {
    // Shared widgets
    app_banner_test.main();
    app_card_test.main();
    app_progress_unlock_banner_test.main();
    app_jit_tooltip_test.main();

    // Contraction timer widgets
    rule_511_progress_test.main();
    session_511_status_card_test.main();
    labour_overview_screen_test.main();
    contraction_session_detail_screen_test.main();
  });
}

