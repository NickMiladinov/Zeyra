import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';

/// Application icon system.
/// 
/// Centralizes icon usage and ensures consistent styling across the app.
/// Uses Material Symbols for comprehensive icon support with fill, weight, and style variants.
/// Also supports custom SVG icons for brand-specific imagery.
class AppIcons {
  // Prevent instantiation
  AppIcons._();
  
  // ============================================================================
  // CUSTOM ICON PATHS
  // ============================================================================
  
  /// Path to custom baby feet SVG icon
  static const String _babyFeetSvgPath = 'assets/icons/baby_feet.svg';
  static const String _babyFeetFilledSvgPath = 'assets/icons/baby_feet_filled.svg';
  static const String _babyFootSvgPath = 'assets/icons/baby_foot.svg';

  // ============================================================================
  // ICON CONFIGURATION
  // ============================================================================
  
  /// Default icon color (inactive state)
  static const Color defaultColor = AppColors.backgroundGrey500;
  
  /// Active icon color
  static const Color activeColor = AppColors.primary;
  
  /// Default icon weight (light)
  static const double defaultWeight = 300.0;
  
  /// Default icon fill (outlined)
  static const double defaultFill = 0.0;
  
  /// Active icon fill (filled)
  static const double activeFill = 1.0;
  
  /// Default optical size
  static const double defaultOpticalSize = 24.0;

  // ============================================================================
  // ICON BUILDER METHODS
  // ============================================================================
  
  /// Create a default icon (rounded, weight 300, outlined, grey)
  static Icon icon(
    IconData iconData, {
    double? size,
    Color? color,
    double? weight,
    double? fill,
    double? grade,
    double? opticalSize,
  }) {
    return Icon(
      iconData,
      size: size ?? AppSpacing.iconMD,
      color: color ?? defaultColor,
      weight: weight ?? defaultWeight,
      fill: fill ?? defaultFill,
      grade: grade,
      opticalSize: opticalSize ?? (size ?? defaultOpticalSize),
    );
  }
  
  /// Create an active icon (rounded, weight 300, filled, primary color)
  static Icon active(
    IconData iconData, {
    double? size,
    double? weight,
  }) {
    return Icon(
      iconData,
      size: size ?? AppSpacing.iconMD,
      color: activeColor,
      weight: weight ?? defaultWeight,
      fill: activeFill,
      opticalSize: size ?? defaultOpticalSize,
    );
  }
  
  /// Create a small icon
  static Icon small(
    IconData iconData, {
    Color? color,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: AppSpacing.iconSM,
      color: color,
      weight: weight,
      fill: fill,
    );
  }
  
  /// Create a large icon
  static Icon large(
    IconData iconData, {
    Color? color,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: AppSpacing.iconLG,
      color: color,
      weight: weight,
      fill: fill,
    );
  }
  
  /// Create an extra large icon
  static Icon extraLarge(
    IconData iconData, {
    Color? color,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: AppSpacing.iconXL,
      color: color,
      weight: weight,
      fill: fill,
    );
  }
  
  /// Create a primary colored icon (outlined)
  static Icon primary(
    IconData iconData, {
    double? size,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: size,
      color: AppColors.primary,
      weight: weight,
      fill: fill,
    );
  }
  
  /// Create a secondary colored icon
  static Icon secondary(
    IconData iconData, {
    double? size,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: size,
      color: AppColors.secondary,
      weight: weight,
      fill: fill,
    );
  }
  
  /// Create a white/light icon (for dark backgrounds like AppBar)
  static Icon light(
    IconData iconData, {
    double? size,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: size,
      color: AppColors.white,
      weight: weight,
      fill: fill,
    );
  }
  
  /// Create an error icon
  static Icon error(
    IconData iconData, {
    double? size,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: size,
      color: AppColors.error,
      weight: weight,
      fill: fill,
    );
  }
  
  /// Create a success icon
  static Icon success(
    IconData iconData, {
    double? size,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: size,
      color: AppColors.success,
      weight: weight,
      fill: fill,
    );
  }
  
  /// Create a warning icon
  static Icon warning(
    IconData iconData, {
    double? size,
    double? weight,
    double? fill,
  }) {
    return icon(
      iconData,
      size: size,
      color: AppColors.warning,
      weight: weight,
      fill: fill,
    );
  }

  // ============================================================================
  // CUSTOM SVG ICON METHODS
  // ============================================================================
  
  /// Create a custom SVG icon widget
  static Widget svgIcon(
    String assetPath, {
    double? size,
    Color? color,
  }) {
    return SvgPicture.asset(
      assetPath,
      width: size ?? AppSpacing.iconMD,
      height: size ?? AppSpacing.iconMD,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
  
  /// Create a small SVG icon
  static Widget svgSmall(String assetPath, {Color? color}) {
    return svgIcon(assetPath, size: AppSpacing.iconSM, color: color);
  }
  
  /// Create a large SVG icon
  static Widget svgLarge(String assetPath, {Color? color}) {
    return svgIcon(assetPath, size: AppSpacing.iconLG, color: color);
  }
  
  /// Create an extra large SVG icon
  static Widget svgExtraLarge(String assetPath, {Color? color}) {
    return svgIcon(assetPath, size: AppSpacing.iconXL, color: color);
  }
  
  /// Create an active SVG icon (primary color)
  static Widget svgActive(String assetPath, {double? size}) {
    return svgIcon(assetPath, size: size, color: activeColor);
  }
  
  /// Create a primary colored SVG icon
  static Widget svgPrimary(String assetPath, {double? size}) {
    return svgIcon(assetPath, size: size, color: AppColors.primary);
  }
  
  /// Create a light/white SVG icon
  static Widget svgLight(String assetPath, {double? size}) {
    return svgIcon(assetPath, size: size, color: AppColors.white);
  }

  // ============================================================================
  // BABY ICON - Custom SVG (Outlined and Filled variants)
  // ============================================================================
  
  /// Baby feet icon (custom SVG) - default/inactive state (outlined)
  /// Use this for the inactive navigation state
  static Widget baby({double? size, Color? color}) {
    return svgIcon(_babyFeetSvgPath, size: size, color: color ?? defaultColor);
  }
  
  /// Baby feet icon (custom SVG) - active state (filled, primary color)
  /// Use this for the active navigation state
  static Widget babyActive({double? size}) {
    return svgIcon(_babyFeetFilledSvgPath, size: size, color: activeColor);
  }
  
  /// Baby feet icon (custom SVG) - small size
  static Widget babySmall({Color? color}) {
    return svgSmall(_babyFeetSvgPath, color: color ?? defaultColor);
  }
  
  /// Baby feet icon (custom SVG) - large size
  static Widget babyLarge({Color? color}) {
    return svgLarge(_babyFeetSvgPath, color: color ?? defaultColor);
  }
  
  /// Baby feet icon - filled variant with custom color
  static Widget babyFilled({double? size, Color? color}) {
    return svgIcon(_babyFeetFilledSvgPath, size: size, color: color ?? defaultColor);
  }

  static Widget babyFoot({double? size, Color? color}) {
    return svgIcon(_babyFootSvgPath, size: size, color: color ?? defaultColor);
  }

  // ============================================================================
  // COMMON APP ICONS (Material Symbols Rounded)
  // ============================================================================
  // Navigation icons
  static const IconData home = Symbols.home_rounded;
  static const IconData myHealth = Symbols.cardiology_rounded;
  // Note: baby icon is a custom SVG, use AppIcons.baby() or AppIcons.babyActive()
  static const IconData tools = Symbols.medical_services_rounded;
  static const IconData more = Symbols.more_horiz_rounded;
  static const IconData profile = Symbols.person_rounded;
  static const IconData settings = Symbols.settings_rounded;
  static const IconData back = Symbols.arrow_left_alt_rounded;
  static const IconData close = Symbols.close_rounded;
  
  // Action icons
  static const IconData add = Symbols.add_2_rounded;
  static const IconData remove = Symbols.remove_rounded;
  static const IconData edit = Symbols.edit_rounded;
  static const IconData stop = Symbols.stop_rounded;
  static const IconData pause = Symbols.pause_rounded;
  static const IconData play = Symbols.play_arrow_rounded;
  static const IconData delete = Symbols.delete_rounded;
  static const IconData undo = Symbols.undo_rounded;
  static const IconData refresh = Symbols.refresh_rounded;
  static const IconData share = Symbols.share_rounded;
  static const IconData link = Symbols.link_rounded;
  static const IconData wand = Symbols.wand_stars_rounded;
  static const IconData search = Symbols.search_rounded;
  static const IconData filter = Symbols.tune_rounded;
  static const IconData moreVertical = Symbols.more_vert_rounded;
  static const IconData overview = Symbols.format_list_bulleted_rounded;
  static const IconData newTab = Symbols.open_in_new_rounded;
  
  // Calendar & Time icons
  static const IconData today = Symbols.today_rounded;
  static const IconData calendar = Symbols.calendar_month_rounded;
  static const IconData schedule = Symbols.schedule_rounded;
  static const IconData event = Symbols.event_rounded;
  static const IconData history = Symbols.history_rounded;
  
  // File & Document icons
  static const IconData upload = Symbols.upload_rounded;
  static const IconData download = Symbols.download_rounded;
  static const IconData file = Symbols.description_rounded;
  static const IconData folder = Symbols.folder_rounded;
  static const IconData image = Symbols.image_rounded;
  static const IconData pdf = Symbols.picture_as_pdf_rounded;
  static const IconData qr = Symbols.qr_code_rounded;
  static const IconData camera = Symbols.photo_camera_rounded;
  static const IconData attachment = Symbols.attach_file_rounded;
  
  // Image Editing icons
  static const IconData cropFree = Symbols.crop_free_rounded;
  static const IconData cropSquare = Symbols.crop_square_rounded;
  static const IconData cropPortrait = Symbols.crop_portrait_rounded;
  static const IconData cropLandscape = Symbols.crop_landscape_rounded;
  static const IconData crop169 = Symbols.crop_16_9_rounded;
  static const IconData smartphone = Symbols.smartphone_rounded;
  static const IconData rotateLeft = Symbols.rotate_left_rounded;
  static const IconData rotateRight = Symbols.rotate_right_rounded;
  
  // Communication icons
  static const IconData chat = Symbols.chat_rounded;
  static const IconData send = Symbols.send_rounded;
  static const IconData notification = Symbols.notifications_rounded;
  static const IconData notificationEdit = Symbols.edit_notifications_rounded;
  static const IconData notificationActive = Symbols.notifications_active_rounded;
  static const IconData hint = Symbols.lightbulb_rounded;
  static const IconData email = Symbols.mail_rounded;
  static const IconData phone = Symbols.phone_rounded;
  
  // Status & Feedback icons
  static const IconData checkIcon = Symbols.check_rounded;
  static const IconData errorIcon = Symbols.error_rounded;
  static const IconData warningIcon = Symbols.warning_rounded;
  static const IconData infoIcon = Symbols.info_rounded;
  static const IconData help = Symbols.help_rounded;
  
  // Location icons
  static const IconData location = Symbols.location_on_rounded;
  static const IconData hospitalLocation = Symbols.add_location_rounded;
  static const IconData map = Symbols.map_rounded;
  static const IconData homePin = Symbols.home_pin_rounded;
  static const IconData heartPin = Symbols.map_pin_heart_rounded;
  
  // User & People icons
  static const IconData person = Symbols.person_rounded;
  
  // Favorites & Bookmarks
  static const IconData favorite = Symbols.favorite_rounded;
  static const IconData bookmark = Symbols.bookmark_rounded;
  static const IconData star = Symbols.kid_star_rounded;

  // Pregnancy & Health specific icons
  static const IconData medical = Symbols.medical_services_rounded;
  static const IconData doctor = Symbols.local_hospital_rounded;
  static const IconData medication = Symbols.pill_rounded;
  static const IconData vaccine = Symbols.vaccines_rounded;
  static const IconData bloodPressure = Symbols.blood_pressure_rounded;
  static const IconData temperature = Symbols.thermostat_rounded;
  static const IconData weight = Symbols.monitor_weight_gain_rounded;

  // Data & Analytics icons
  static const IconData chart = Symbols.monitoring_rounded;
  static const IconData trendUp = Symbols.trending_up_rounded;
  static const IconData trendDown = Symbols.trending_down_rounded;
  static const IconData analytics = Symbols.analytics_rounded;
  
  // Visibility & Privacy
  static const IconData visibility = Symbols.visibility_rounded;
  static const IconData visibilityOff = Symbols.visibility_off_rounded;
  static const IconData lock = Symbols.lock_rounded;
  static const IconData unlock = Symbols.lock_open_rounded;
  
  // Navigation arrows
  static const IconData arrowForward = Symbols.keyboard_arrow_right_rounded;
  static const IconData arrowBack = Symbols.keyboard_arrow_left_rounded;
  static const IconData arrowUp = Symbols.keyboard_arrow_up_rounded;
  static const IconData arrowDown = Symbols.keyboard_arrow_down_rounded;
  static const IconData expandAll = Symbols.expand_all_rounded;
  
  // App-specific custom icons
  static const IconData hospital = Symbols.local_hospital_rounded;
  static const IconData appointment = Symbols.event_available_rounded;
  static const IconData birthPlan = Symbols.assignment_rounded;
  static const IconData notes = Symbols.note_rounded;
  static const IconData prescription = Symbols.medication_liquid_rounded;
  static const IconData labResults = Symbols.science_rounded;
  static const IconData symptom = Symbols.healing_rounded;
  static const IconData mood = Symbols.sentiment_satisfied_rounded;
}

