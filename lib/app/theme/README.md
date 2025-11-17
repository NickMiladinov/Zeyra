# Zeyra App Theme System

This directory contains the complete design system for the Zeyra pregnancy health app.

## 📁 Files Overview

### `app_colors.dart`
Color palette including:
- Primary and secondary colors
- Neutral/grayscale colors
- Semantic colors (success, warning, error, info)
- App-specific colors (biomarkers, timeline, etc.)
- Overlay and utility colors

**How to use:**
```dart
import 'package:zeyra/app/theme/app_colors.dart';

Container(
  color: AppColors.primary,
  child: Text('Hello', style: TextStyle(color: AppColors.textPrimary)),
)
```

### `app_typography.dart`
Typography system including:
- Font families
- Display, headline, title styles
- Body and label styles
- App-specific text styles
- Utility methods for text style customization

**How to use:**
```dart
import 'package:zeyra/app/theme/app_typography.dart';

Text('Title', style: AppTypography.headlineLarge)
Text('Body', style: AppTypography.bodyMedium)
```

### `app_spacing.dart`
Spacing and sizing system including:
- Spacing scale (xs, sm, md, lg, xl, etc.)
- Semantic spacing (padding, margin, gap)
- Component sizes (buttons, inputs, icons)
- Layout dimensions
- Border widths and elevations

**How to use:**
```dart
import 'package:zeyra/app/theme/app_spacing.dart';

Padding(
  padding: EdgeInsets.all(AppSpacing.paddingMD),
  child: SizedBox(height: AppSpacing.buttonHeightMD),
)
```

### `app_effects.dart`
Visual effects system including:
- Border radius
- Box shadows
- Borders and border sides
- Gradients
- Blur effects
- Opacity levels
- Animation durations and curves
- Dividers

**How to use:**
```dart
import 'package:zeyra/app/theme/app_effects.dart';

Container(
  decoration: BoxDecoration(
    borderRadius: AppEffects.roundedLG,
    boxShadow: AppEffects.shadowMD,
  ),
)
```

### `app_theme.dart`
Main theme configuration that combines all theme elements into a Material 3 `ThemeData` object.

**How to use:**
```dart
import 'package:zeyra/app/theme/app_theme.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  // darkTheme: AppTheme.darkTheme, // When implemented
  home: MyHomePage(),
)
```

## 🎨 Importing Figma Styles

### Step 1: Export from Figma
1. Open your Figma design file
2. Select "Inspect" panel for any element
3. Copy color hex codes, font sizes, spacing values, etc.

### Step 2: Update Theme Files
Replace all `// TODO: Replace` comments with your Figma values:

#### Colors Example:
```dart
// Before:
static const Color primary = Color(0xFF008080); // TODO: Replace

// After (from Figma):
static const Color primary = Color(0xFF2D9CDB); // Figma: Blue/Primary
```

#### Typography Example:
```dart
// Before:
static TextStyle headlineLarge = const TextStyle(
  fontSize: 32, // TODO: Replace
  fontWeight: FontWeight.w700, // TODO: Replace
);

// After (from Figma):
static TextStyle headlineLarge = const TextStyle(
  fontSize: 28, // Figma: H1 / 28px
  fontWeight: FontWeight.w600, // Figma: Semi-bold
);
```

#### Spacing Example:
```dart
// Before:
static const double lg = 16.0; // TODO: Replace

// After (from Figma):
static const double lg = 20.0; // Figma: Spacing/Large
```

### Step 3: Update Font Family
1. Add custom fonts to `assets/fonts/` directory
2. Update `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: YourFontName
      fonts:
        - asset: assets/fonts/YourFont-Regular.ttf
        - asset: assets/fonts/YourFont-Bold.ttf
          weight: 700
```
3. Update `AppTypography.primaryFontFamily` to match

### Step 4: Test Your Theme
Update `lib/app/app.dart` to use the new theme:
```dart
import 'package:zeyra/app/theme/app_theme.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  ...
)
```

## 🔧 Best Practices

1. **Consistency**: Always use theme constants instead of hardcoded values
2. **Semantic naming**: Use descriptive names that reflect purpose, not appearance
3. **Scalability**: Add new values that follow the existing naming patterns
4. **Documentation**: Comment any app-specific values that might not be obvious
5. **Testing**: Test theme changes on different screen sizes and platforms

## 📚 Additional Resources

- [Material 3 Design System](https://m3.material.io/)
- [Flutter ThemeData Documentation](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [Figma to Flutter Guide](https://docs.flutter.dev/ui/design)

