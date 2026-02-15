# Account Feature - Test Plan

## Overview
Coverage plan for the Account feature (account hub, account details actions, and account operation logic).

**Created:** 2026-02-13  
**Status:** In progress

## Implemented Tests

| Level | File | Scope |
|---|---|---|
| Unit - Logic | `test/features/account/logic/account_notifier_test.dart` | Identity bootstrap, sign-out success, delete-account failure handling |

## Planned Follow-ups

- Add widget tests for:
  - account hub links/actions visibility
  - account details delete confirmation dialog behavior
- Add service tests for:
  - `AccountService.deleteCurrentAccount()` remote success/failure branches
  - local cleanup ordering (cache close, db file delete, key delete)

## How To Run

```bash
flutter test --tags account
flutter test test/runners/account/quick_test.dart
flutter test test/runners/account/unit_test.dart
flutter test test/runners/account/all_test.dart
```
