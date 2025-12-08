import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registers mock repositories and services for testing.
/// This file provides a centralized location for all mock dependencies
/// used across the test suite.

class MockDependencies {
  /// Returns a ProviderScope with all mock dependencies overridden.
  static ProviderScope createMockProviderScope({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        ...overrides,
      ],
      child: child,
    );
  }
}

