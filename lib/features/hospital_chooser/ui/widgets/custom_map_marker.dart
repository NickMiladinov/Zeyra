import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';

/// Utility class for creating custom map markers.
class CustomMapMarker {
  CustomMapMarker._();

  /// Cache for generated marker icons.
  static BitmapDescriptor? _defaultMarker;
  static BitmapDescriptor? _selectedMarker;
  static BitmapDescriptor? _shortlistedMarker;
  static final Map<int, BitmapDescriptor> _clusterMarkerCache = {};

  /// Get the default hospital marker (coral with white plus).
  static Future<BitmapDescriptor> getDefaultMarker() async {
    _defaultMarker ??= await _createMarker(
      backgroundColor: AppColors.primary, // Coral/peach color
      iconColor: Colors.white,
      markerSymbol: _MarkerSymbol.plus,
    );
    return _defaultMarker!;
  }

  /// Get the selected hospital marker (highlighted).
  static Future<BitmapDescriptor> getSelectedMarker() async {
    _selectedMarker ??= await _createMarker(
      backgroundColor: AppColors.primary, // Teal when selected
      iconColor: Colors.white,
      markerSymbol: _MarkerSymbol.plus,
    );
    return _selectedMarker!;
  }

  /// Get the shortlisted hospital marker (coral with white heart).
  static Future<BitmapDescriptor> getShortlistedMarker() async {
    _shortlistedMarker ??= await _createMarker(
      backgroundColor: AppColors.primary,
      iconColor: Colors.white,
      markerSymbol: _MarkerSymbol.heart,
    );
    return _shortlistedMarker!;
  }

  /// Create a custom marker with the given colors.
  static Future<BitmapDescriptor> _createMarker({
    required Color backgroundColor,
    required Color iconColor,
    required _MarkerSymbol markerSymbol,
  }) async {
    // Marker dimensions - smaller for better map visibility
    const double width = 48;
    const double height = 60;
    const double pinWidth = 36;
    const double pinHeight = 36;
    const double pointerHeight = 8;
    const double topInset = 3;
    const double iconSize = 16;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Center position
    const double centerX = width / 2;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final shadowPath = _buildPinPath(
      centerX: centerX + 1,
      topY: topInset,
      bodyWidth: pinWidth,
      bodyHeight: pinHeight,
      tipY: topInset + pinHeight + pointerHeight + 1,
    );
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw the main pin body (circle)
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final pinPath = _buildPinPath(
      centerX: centerX,
      topY: topInset,
      bodyWidth: pinWidth,
      bodyHeight: pinHeight,
      tipY: topInset + pinHeight + pointerHeight,
    );
    canvas.drawPath(pinPath, paint);

    final pinCenterY = topInset + (pinHeight / 2);

    if (markerSymbol == _MarkerSymbol.plus) {
      final iconPaint = Paint()
        ..color = iconColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      // Horizontal line of plus
      canvas.drawLine(
        Offset(centerX - iconSize / 2, pinCenterY),
        Offset(centerX + iconSize / 2, pinCenterY),
        iconPaint,
      );

      // Vertical line of plus
      canvas.drawLine(
        Offset(centerX, pinCenterY - iconSize / 2),
        Offset(centerX, pinCenterY + iconSize / 2),
        iconPaint,
      );
    } else {
      // Render the real icon glyph so marker iconography matches app UI icons.
      final heartIcon = AppIcons.favorite;
      final heartTextPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(heartIcon.codePoint),
          style: TextStyle(
            color: iconColor,
            fontSize: 20,
            fontFamily: heartIcon.fontFamily,
            package: heartIcon.fontPackage,
            // Material Symbols variable font settings for filled heart.
            fontVariations: const [
              ui.FontVariation('FILL', 1),
              ui.FontVariation('wght', 400),
              ui.FontVariation('opsz', 24),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      heartTextPainter.paint(
        canvas,
        Offset(
          centerX - heartTextPainter.width / 2,
          pinCenterY - heartTextPainter.height / 2,
        ),
      );
    }

    // Convert to image
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
  }

  /// Build a smooth map-pin silhouette similar to Material map pin shape.
  static Path _buildPinPath({
    required double centerX,
    required double topY,
    required double bodyWidth,
    required double bodyHeight,
    required double tipY,
  }) {
    final halfWidth = bodyWidth / 2;
    final leftX = centerX - halfWidth;
    final rightX = centerX + halfWidth;
    final centerY = topY + (bodyHeight / 2);
    final bottomShoulderY = topY + bodyHeight * 0.74;

    return Path()
      ..moveTo(centerX, topY)
      // Top circular dome (left half)
      ..cubicTo(
        centerX - halfWidth,
        topY,
        leftX,
        centerY - halfWidth * 0.35,
        leftX,
        centerY,
      )
      // Left side tapering into tip
      ..cubicTo(
        leftX,
        bottomShoulderY,
        centerX - halfWidth * 0.45,
        tipY - bodyHeight * 0.22,
        centerX,
        tipY,
      )
      // Right side tapering from tip
      ..cubicTo(
        centerX + halfWidth * 0.45,
        tipY - bodyHeight * 0.22,
        rightX,
        bottomShoulderY,
        rightX,
        centerY,
      )
      // Top circular dome (right half)
      ..cubicTo(
        rightX,
        centerY - halfWidth * 0.35,
        centerX + halfWidth,
        topY,
        centerX,
        topY,
      )
      ..close();
  }

  /// Get a cluster marker with the count displayed.
  static Future<BitmapDescriptor> getClusterMarker(int count) async {
    // Return cached if available
    if (_clusterMarkerCache.containsKey(count)) {
      return _clusterMarkerCache[count]!;
    }
    
    final marker = await _createClusterMarker(count);
    _clusterMarkerCache[count] = marker;
    return marker;
  }

  /// Create a cluster marker showing the count.
  static Future<BitmapDescriptor> _createClusterMarker(int count) async {
    const double size = 48;
    
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      const Offset(size / 2 + 1, size / 2 + 1),
      size / 2 - 4,
      shadowPaint,
    );
    
    // Draw circle background
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 4,
      paint,
    );
    
    // Draw count text
    final textPainter = TextPainter(
      text: TextSpan(
        text: count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );
    
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (bytes == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
    
    return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
  }

  /// Clear the marker cache (useful for theme changes).
  static void clearCache() {
    _defaultMarker = null;
    _selectedMarker = null;
    _shortlistedMarker = null;
    _clusterMarkerCache.clear();
  }
}

enum _MarkerSymbol { plus, heart }
