/// Application spacing and sizing system.
class AppSpacing {
  // Prevent instantiation
  AppSpacing._();

  // ============================================================================
  // BASE SPACING UNIT
  // ============================================================================
  /// Base spacing unit
  static const double baseUnit = 4.0;

  // ============================================================================
  // SPACING SCALE
  // ============================================================================
  /// Extra small spacing (4pt)
  static const double xs = 4.0;
  
  /// Small spacing (8pt)
  static const double sm = 8.0;
  
  /// Medium spacing (12pt)
  static const double md = 12.0;
  
  /// Large spacing (16pt)
  static const double lg = 16.0;
  
  /// Extra large spacing (24pt)
  static const double xl = 24.0;
  
  /// 2X Extra large spacing (32pt)
  static const double xxl = 32.0;
  
  /// 3X Extra large spacing (48pt)
  static const double xxxl = 48.0;
  
  /// 4X Extra large spacing (64pt)
  static const double xxxxl = 64.0;

  // ============================================================================
  // SEMANTIC SPACING (Context-specific)
  // ============================================================================
  /// Padding inside components
  static const double paddingXS = xs;
  static const double paddingSM = sm;
  static const double paddingMD = md;
  static const double paddingLG = lg;
  static const double paddingXL = xl;
  static const double paddingXXL = xxl;
  static const double paddingXXXL = xxxl;
  
  /// Margin between components
  static const double marginXS = xs;
  static const double marginSM = sm;
  static const double marginMD = md;
  static const double marginLG = lg;
  static const double marginXL = xl;
  
  /// Gaps in flex layouts (Row, Column)
  static const double gapXS = xs;
  static const double gapSM = sm;
  static const double gapMD = md;
  static const double gapLG = lg;
  static const double gapXL = xl;

  // ============================================================================
  // LAYOUT SPACING
  // ============================================================================
  /// Screen edge padding
  static const double screenPadding = 24.0;
  
  /// Screen edge padding (horizontal)
  static const double screenPaddingHorizontal = 24.0;
  
  /// Screen edge padding (vertical)
  static const double screenPaddingVertical = 32.0;
  
  /// Content max width for tablets/desktop
  static const double contentMaxWidth = 600.0;
  
  /// Section spacing (between major sections)
  static const double sectionSpacing = 24.0;
  
  /// Card padding
  static const double cardPadding = 16.0;
  
  /// List item padding
  static const double listItemPadding = 16.0;

  // ============================================================================
  // COMPONENT SIZES
  // ============================================================================
  /// Button heights
  static const double buttonHeightSM = 32.0;
  static const double buttonHeightMD = 40.0;
  static const double buttonHeightLG = 48.0;
  static const double buttonHeightXL = 52.0;
  static const double buttonHeightXXL = 56.0;
  
  /// Input field heights
  static const double inputHeightSM = 40.0;
  static const double inputHeightMD = 48.0;
  static const double inputHeightLG = 56.0;
  
  /// Icon sizes
  static const double iconXXS = 16.0;
  static const double iconXS = 20.0;
  static const double iconSM = 24.0;
  static const double iconMD = 28.0;
  static const double iconLG = 32.0;
  static const double iconXL = 36.0;
  
  /// App bar height
  static const double appBarHeight = 56.0;
  
  /// Bottom navigation bar height (with comfortable padding)
  static const double bottomNavHeight = 80.0;
  
  /// Bottom navigation item height
  static const double bottomNavItemHeight = 48.0;
  
  /// Tab bar height
  static const double tabBarHeight = 56.0;
  
  /// FAB (Floating Action Button) size
  static const double fabSize = 56.0;
  static const double fabSizeMini = 48.0;

  // ============================================================================
  // APP-SPECIFIC SIZES
  // ============================================================================
  /// Add custom sizes specific to your pregnancy health app
  
  // Example: Biomarker card dimensions
  // static const double biomarkerCardWidth = 160.0;
  // static const double biomarkerCardHeight = 120.0;
  
  // Example: Timeline item spacing
  // static const double timelineItemSpacing = 24.0;
  
  // Example: Baby visualization container
  // static const double babyVisualizationSize = 200.0;

  // ============================================================================
  // BORDER WIDTHS
  // ============================================================================
  /// Border width for dividers and borders
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 4.0;

  // ============================================================================
  // ELEVATION (Shadows)
  // ============================================================================
  /// Shadow elevation levels
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 12.0;
}

