# Tooltip Feature Test Plan

## Overview
Tests for the just-in-time (JIT) tooltip system that shows contextual help to users.

## Components

### 1. TooltipPreferencesService (`core/services/tooltip_preferences_service.dart`)
Low-level service for persisting tooltip shown states.

### 2. TooltipProvider (`shared/providers/tooltip_provider.dart`)
Riverpod provider for managing tooltip state.

### 3. AppJitTooltip Widget (`shared/widgets/app_jit_tooltip.dart`)
Reusable overlay widget for displaying tooltips with highlighted areas.

---

## Test Groups

### [Tooltip] TooltipNotifier

#### Initial State
- [ ] should start with isLoaded = false
- [ ] should load tooltip states from SharedPreferences
- [ ] should set isLoaded = true after loading

#### shouldShow()
- [ ] should return false when condition is not met
- [ ] should return false when tooltip has been shown before
- [ ] should return true when condition is met and tooltip not shown
- [ ] should return false when state is not loaded

#### dismissTooltip()
- [ ] should persist true to SharedPreferences
- [ ] should update state to mark tooltip as shown
- [ ] should cause shouldShow to return false after dismissal

#### Persistence
- [ ] should persist across notifier instances
- [ ] should load all known tooltip IDs on startup

---

### [Widget] AppJitTooltip

#### Rendering
- [ ] should display tooltip card with message
- [ ] should display title when provided
- [ ] should not display title when not provided
- [ ] should display close button

#### Positioning
- [ ] should position tooltip below target when in upper part of screen
- [ ] should position tooltip above target when in lower part of screen
- [ ] should calculate target rect from GlobalKey

#### Interactions
- [ ] should call onDismiss when close button tapped
- [ ] should call onDismiss when background tapped
- [ ] should dismiss overlay when close button tapped

#### Configuration
- [ ] should use default highlightBorderRadius when not specified
- [ ] should use custom highlightBorderRadius when specified

---

### [Widget] JitTooltipConfig

#### Defaults
- [ ] should have default position of TooltipPosition.below
- [ ] should have default highlightPadding of EdgeInsets.zero
- [ ] should have default highlightBorderRadius of AppEffects.radiusLG

---

## Integration Tests

### Kick Counter Tooltip Flow
- [ ] should show first session tooltip after recording first session
- [ ] should show graph unlocked tooltip after 7 valid sessions
- [ ] should not show tooltip if already dismissed
- [ ] should show tooltips sequentially if multiple are queued

---

## Files

| Test File | Component |
|-----------|-----------|
| `test/shared/providers/tooltip_provider_test.dart` | TooltipNotifier |
| `test/shared/widgets/app_jit_tooltip_test.dart` | AppJitTooltip |

---

## Coverage Requirements
- Unit tests: >85% coverage on tooltip_provider.dart
- Widget tests: Core rendering and interaction paths covered
