# Router Feature - Test Plan

## Overview
This document outlines all tests for the go_router-based navigation system. The router handles authentication redirects, deep link handling for OAuth, tab navigation with state preservation via StatefulShellRoute, and custom page transitions.

---

## Test Coverage Summary

| Test Level | File | Test Groups | Total Tests |
|------------|------|-------------|-------------|
| **Unit - Auth Notifier** | `auth_notifier_test.dart` | 4 | 12 |
| **Unit - Routes** | `routes_test.dart` | 2 | 8 |
| **Unit - Router Redirects** | `router_redirect_test.dart` | 3 | 10 |
| **Widget - MainShell** | `main_shell_test.dart` | 3 | 9 |
| **Widget - Error Page** | `error_page_test.dart` | 2 | 4 |
| **Integration - Auth Flow** | `auth_flow_test.dart` | 2 | 6 |
| **Integration - Navigation** | `navigation_flow_test.dart` | 4 | 12 |
| **Total** | **7 files** | **20 groups** | **61 tests** |

---

## Running All Router Tests

### Quick Run with Test Runners (Recommended)

Use the convenient test runner files in `test/runners/router/`:

```bash
# Quick tests - fastest
flutter test test/runners/router/quick_test.dart

# Unit tests - comprehensive unit tests
flutter test test/runners/router/unit_test.dart

# All tests - everything including integration
flutter test test/runners/router/all_test.dart
```

**In your IDE**: Open any of these files and click the ▶️ Run button next to `main()`!

### Run by Tags

All router tests are tagged with `@Tags(['router'])`:

```bash
# Run all router tests
flutter test --tags router

# Run with coverage
flutter test --tags router --coverage

# Run specific sub-tag
flutter test --tags auth_notifier
flutter test --tags router_redirect
```

---

## 1. Unit Tests

### 1.1 AuthNotifier Tests (`auth_notifier_test.dart`)

Tests for the `AuthNotifier` class that manages authentication state for router redirects.

| Test Group | Test Name | Description |
|------------|-----------|-------------|
| **Initialization** | `should initialize with unauthenticated state when no session` | Verifies initial state when user has no Supabase session |
| **Initialization** | `should initialize with authenticated state when session exists` | Verifies initial state when user has active session |
| **Initialization** | `should handle Supabase unavailable gracefully` | Verifies fallback when Supabase fails to initialize |
| **Auth State Changes** | `should notify listeners on sign in` | Verifies notifyListeners called when user signs in |
| **Auth State Changes** | `should notify listeners on sign out` | Verifies notifyListeners called when user signs out |
| **Auth State Changes** | `should not notify on token refresh` | Verifies no notification for token refresh events |
| **Auth State Changes** | `should handle signedIn event when already authenticated` | Verifies no navigation on duplicate signedIn events |
| **Error Handling** | `should handle auth errors gracefully` | Verifies error logging without crash |
| **Error Handling** | `should sign out on permanent auth failures (401/403)` | Verifies auto sign-out on auth rejection |
| **Onboarding** | `should track onboarding completion state` | Verifies hasCompletedOnboarding property |
| **Onboarding** | `should notify listeners when onboarding completed` | Verifies notifyListeners on completeOnboarding() |
| **Dispose** | `should cancel auth subscription on dispose` | Verifies cleanup of stream subscription |

### 1.2 Routes Tests (`routes_test.dart`)

Tests for route path constants and path generation functions.

| Test Group | Test Name | Description |
|------------|-----------|-------------|
| **Path Constants** | `AuthRoutes should have correct paths` | Verifies /auth and /onboarding paths |
| **Path Constants** | `MainRoutes should have correct paths` | Verifies /main/* tab paths |
| **Path Constants** | `ToolRoutes should have correct paths` | Verifies /main/tools/* paths |
| **Path Constants** | `MoreRoutes should have correct paths` | Verifies /main/more/* paths |
| **Path Generation** | `bumpDiaryEditPath should generate correct path` | Verifies week parameter in path |
| **Path Generation** | `contractionSessionDetailPath should generate correct path` | Verifies session ID in path |
| **Route Segments** | `RouteSegments should have correct values` | Verifies relative path segments |
| **Route Segments** | `RouteSegments should work with path parameters` | Verifies :week and :id placeholders |

### 1.3 Router Redirect Tests (`router_redirect_test.dart`)

Tests for the router redirect logic that handles authentication guards.

| Test Group | Test Name | Description |
|------------|-----------|-------------|
| **Unauthenticated** | `should redirect to /auth when not logged in and accessing main` | Guards protected routes |
| **Unauthenticated** | `should redirect to /auth when not logged in and accessing tools` | Guards nested routes |
| **Unauthenticated** | `should allow access to /auth when not logged in` | No redirect on auth page |
| **Authenticated** | `should redirect to /main/today when logged in and on /auth` | Post-login redirect |
| **Authenticated** | `should allow access to main routes when logged in` | No redirect on protected routes |
| **Authenticated** | `should allow access to nested routes when logged in` | Deep link support |
| **Edge Cases** | `should handle root path redirect` | Redirect / based on auth state |
| **Edge Cases** | `should preserve query parameters on redirect` | OAuth callback handling |
| **Edge Cases** | `should return null when no redirect needed` | No unnecessary redirects |
| **Onboarding** | `should redirect to onboarding for new users (future)` | Placeholder for onboarding flow |

---

## 2. Widget Tests

### 2.1 MainShell Tests (`main_shell_test.dart`)

Tests for the `MainShell` widget that provides bottom navigation and tracker banners.

| Test Group | Test Name | Description |
|------------|-----------|-------------|
| **Rendering** | `should render bottom navigation bar` | Verifies AppBottomNavBar presence |
| **Rendering** | `should render child navigation shell` | Verifies StatefulNavigationShell child |
| **Rendering** | `should show tracker banner when active session` | Verifies kick/contraction banner |
| **Tab Navigation** | `should call goBranch on tab tap` | Verifies tab switching |
| **Tab Navigation** | `should go to initial location when tapping current tab` | Verifies pop-to-root behavior |
| **Tab Navigation** | `should highlight correct tab based on currentIndex` | Verifies visual selection |
| **Banner Interaction** | `should navigate to active session on banner tap` | Verifies context.push call |
| **Banner Interaction** | `should hide banner before navigation` | Verifies banner provider update |
| **Banner Animation** | `should animate banner entrance/exit` | Verifies slide/fade animations |

### 2.2 Error Page Tests (`error_page_test.dart`)

Tests for the `ErrorPage` widget displayed on routing errors.

| Test Group | Test Name | Description |
|------------|-----------|-------------|
| **Rendering** | `should display error icon` | Verifies error visual indicator |
| **Rendering** | `should display page not found message` | Verifies user-friendly text |
| **Navigation** | `should navigate to home on button tap` | Verifies context.go call |
| **Navigation** | `should use correct home route` | Verifies MainRoutes.today path |

---

## 3. Integration Tests

### 3.1 Auth Flow Tests (`auth_flow_test.dart`)

End-to-end tests for authentication navigation flow.

| Test Group | Test Name | Description |
|------------|-----------|-------------|
| **Sign In Flow** | `should navigate to main screen after successful OAuth sign in` | Full sign-in journey |
| **Sign In Flow** | `should stay on auth screen on sign in failure` | Error handling |
| **Sign In Flow** | `should handle OAuth deep link callback` | Deep link processing |
| **Sign Out Flow** | `should navigate to auth screen after sign out` | Full sign-out journey |
| **Sign Out Flow** | `should clear auth state on sign out` | State cleanup verification |
| **Sign Out Flow** | `should handle sign out from any screen` | Deep screen sign-out |

### 3.2 Navigation Flow Tests (`navigation_flow_test.dart`)

End-to-end tests for navigation between screens.

| Test Group | Test Name | Description |
|------------|-----------|-------------|
| **Tab Navigation** | `should navigate between tabs` | Basic tab switching |
| **Tab Navigation** | `should preserve tab state on switch` | IndexedStack preservation |
| **Tab Navigation** | `should return to tab root on same-tab tap` | Pop-to-root behavior |
| **Nested Navigation** | `should navigate to tool screens` | Push to nested routes |
| **Nested Navigation** | `should navigate back from tool screens` | Pop navigation |
| **Nested Navigation** | `should preserve nested state across tabs` | State preservation |
| **Custom Transitions** | `should use slide-up for active sessions` | Animation verification |
| **Custom Transitions** | `should use slide-right for edit screens` | Animation verification |
| **Deep Links** | `should handle direct deep link to tool` | URL-based navigation |
| **Deep Links** | `should handle deep link with parameters` | Path parameter parsing |
| **Back Navigation** | `should pop correctly from nested routes` | Back button behavior |
| **Back Navigation** | `should handle system back button` | Android back handling |

---

## 4. Test Utilities

### 4.1 Mocks and Fakes

```dart
// test/mocks/router/mock_auth_notifier.dart
class MockAuthNotifier extends Mock implements AuthNotifier {}

// test/mocks/router/mock_supabase_auth.dart  
class MockSupabaseAuth extends Mock implements GoTrueClient {}

// test/mocks/router/fake_navigation_shell.dart
class FakeNavigationShell extends Fake implements StatefulNavigationShell {
  int _currentIndex = 0;
  @override
  int get currentIndex => _currentIndex;
  
  void setIndex(int index) => _currentIndex = index;
}
```

### 4.2 Test Helpers

```dart
// test/harness/router_test_helpers.dart
GoRouter createTestRouter({
  bool isAuthenticated = false,
  bool hasCompletedOnboarding = true,
}) {
  // Returns configured test router
}

Widget wrapWithRouter(Widget child, GoRouter router) {
  return ProviderScope(
    overrides: [
      appRouterProvider.overrideWithValue(router),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}
```

---

## 5. Test Tags

All router tests use the following tags for selective execution:

- `@Tags(['router'])` - All router tests
- `@Tags(['router', 'auth_notifier'])` - AuthNotifier unit tests
- `@Tags(['router', 'routes'])` - Routes unit tests
- `@Tags(['router', 'redirect'])` - Redirect logic tests
- `@Tags(['router', 'widget'])` - Widget tests
- `@Tags(['router', 'integration'])` - Integration tests

---

## 6. Coverage Requirements

| Category | Target | Notes |
|----------|--------|-------|
| AuthNotifier | 90%+ | Critical for auth flow |
| Routes | 100% | Simple constants |
| Redirect Logic | 95%+ | Security-critical |
| MainShell | 85%+ | Complex widget |
| Error Page | 90%+ | Simple widget |
| Integration | 80%+ | E2E coverage |

---

## 7. Implementation Notes

### Files to Create

```
test/
├── features/
│   └── router/
│       ├── auth_notifier_test.dart
│       ├── routes_test.dart
│       ├── router_redirect_test.dart
│       ├── main_shell_test.dart
│       ├── error_page_test.dart
│       └── integration/
│           ├── auth_flow_test.dart
│           └── navigation_flow_test.dart
├── mocks/
│   └── router/
│       ├── mock_auth_notifier.dart
│       ├── mock_supabase_auth.dart
│       └── fake_navigation_shell.dart
├── harness/
│   └── router_test_helpers.dart
└── runners/
    └── router/
        ├── quick_test.dart
        ├── unit_test.dart
        └── all_test.dart
```

### Dependencies

Tests require:
- `mocktail` for mocking
- `flutter_test` for widget testing
- Custom test harness for router setup
