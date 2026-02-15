@Tags(['account'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/account_service.dart';
import 'package:zeyra/features/account/logic/account_notifier.dart';

import '../../../mocks/fake_data/account_fakes.dart';

void main() {
  group('[Account] AccountNotifier', () {
    late MockAccountService accountService;

    setUp(() {
      accountService = MockAccountService();
      // Default identity for constructor bootstrapping.
      when(
        () => accountService.getCurrentIdentity(),
      ).thenReturn(FakeAccountIdentityBuilder.google());
    });

    test('should load account identity on initialization', () {
      final notifier = AccountNotifier(accountService: accountService);

      expect(notifier.state.identity, isNotNull);
      expect(notifier.state.identity?.email, 'user@example.com');
      verify(() => accountService.getCurrentIdentity()).called(1);
    });

    test('should return true and clear identity when sign out succeeds', () async {
      when(() => accountService.signOut()).thenAnswer((_) async {});

      final notifier = AccountNotifier(accountService: accountService);
      final result = await notifier.signOut();

      expect(result, true);
      expect(notifier.state.isBusy, false);
      expect(notifier.state.identity, isNull);
      verify(() => accountService.signOut()).called(1);
    });

    test(
      'should return false and set error when account deletion fails',
      () async {
        when(
          () => accountService.deleteCurrentAccount(),
        ).thenThrow(const AccountServiceException('Delete failed'));

        final notifier = AccountNotifier(accountService: accountService);
        final result = await notifier.deleteAccount();

        expect(result, false);
        expect(notifier.state.isBusy, false);
        expect(notifier.state.error, 'Delete failed');
        verify(() => accountService.deleteCurrentAccount()).called(1);
      },
    );
  });
}
