import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/account_service.dart';

class MockAccountService extends Mock implements AccountService {}

class FakeAccountIdentityBuilder {
  static AccountIdentity google({
    String userId = 'user_1',
    String email = 'user@example.com',
  }) {
    return AccountIdentity(userId: userId, email: email, provider: 'google');
  }

  static AccountIdentity apple({
    String userId = 'user_2',
    String email = 'apple@example.com',
  }) {
    return AccountIdentity(userId: userId, email: email, provider: 'apple');
  }
}
