import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps widgets for testing with necessary providers and MaterialApp.
/// Use this to wrap widgets in widget tests to provide the required context.

class TestAppWrapper extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestAppWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

