import 'package:flutter_riverpod/legacy.dart'
    show StateNotifier, StateNotifierProvider;

import '../../../core/di/main_providers.dart';
import '../../../core/services/account_service.dart';

class AccountState {
  const AccountState({
    this.identity,
    this.isBusy = false,
    this.error,
  });

  final AccountIdentity? identity;
  final bool isBusy;
  final String? error;

  AccountState copyWith({
    AccountIdentity? identity,
    bool? isBusy,
    String? error,
  }) {
    return AccountState(
      identity: identity ?? this.identity,
      isBusy: isBusy ?? this.isBusy,
      error: error,
    );
  }
}

class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier({required AccountService accountService})
      : _accountService = accountService,
        super(const AccountState()) {
    refreshIdentity();
  }

  final AccountService _accountService;

  void refreshIdentity() {
    state = state.copyWith(identity: _accountService.getCurrentIdentity());
  }

  Future<bool> signOut() async {
    state = state.copyWith(isBusy: true, error: null);
    try {
      await _accountService.signOut();
      state = const AccountState(isBusy: false);
      return true;
    } on AccountServiceException catch (e) {
      state = state.copyWith(isBusy: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isBusy: false,
        error: 'Could not sign out. Please try again.',
      );
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isBusy: true, error: null);
    try {
      await _accountService.deleteCurrentAccount();
      state = const AccountState(isBusy: false);
      return true;
    } on AccountServiceException catch (e) {
      state = state.copyWith(isBusy: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isBusy: false,
        error: 'Could not delete account. Please try again.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, AccountState>((ref) {
      final accountService = ref.watch(accountServiceProvider);
      return AccountNotifier(accountService: accountService);
    });
