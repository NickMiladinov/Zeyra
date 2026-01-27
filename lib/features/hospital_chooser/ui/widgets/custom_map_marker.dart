import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/theme/app_colors.dart';

/// Utility class for creating custom map markers.
class CustomMapMarker {
  CustomMapMarker._();

  /// Cache for generated marker icons.
  static BitmapDescriptor? _defaultMarker;
  static BitmapDescriptor? _selectedMarker;
  static final Map<int, BitmapDescriptor> _clusterMarkerCache = {};

  /// Get the default hospital marker (coral with white plus).
  static Future<BitmapDescriptor> getDefaultMarker() async {
    _defaultMarker ??= await _createMarker(
      backgroundColor: AppColors.secondary, // Coral/peach color
      iconColor: Colors.white,
      isSelected: false,
    );
    return _defaultMarker!;
  }

  /// Get the selected hospital marker (highlighted).
  static Future<BitmapDescriptor> getSelectedMarker() async {
    _selectedMarker ??= await _createMarker(
      backgroundColor: AppColors.primary, // Teal when selected
      iconColor: Colors.white,
      isSelected: true,
    );
    return _selectedMarker!;
  }

  /// Create a custom marker with the given colors.
  static Future<BitmapDescriptor> _createMarker({
    required Color backgroundColor,
    required Color iconColor,
    required bool isSelected,
  }) async {
    // Marker dimensions - smaller for better map visibility
    const double width = 48;
    const double height = 60;
    const double pinWidth = 36;
    const double pinHeight = 36;
    const double pointerHeight = 12;
    const double iconSize = 16;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Center position
    const double centerX = width / 2;

    // Draw drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Shadow path (slightly offset)
    final shadowPath = Path();
    shadowPath.addOval(Rect.fromCenter(
      center: const Offset(centerX + 1, pinHeight / 2 + 2),
      width: pinWidth,
      height: pinHeight,
    ));
    // Shadow pointer
    shadowPath.moveTo(centerX - 8 + 1, pinHeight / 2 + pinHeight / 3);
    shadowPath.lineTo(centerX + 1, pinHeight + pointerHeight + 1);
    shadowPath.lineTo(centerX + 8 + 1, pinHeight / 2 + pinHeight / 3);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw the main pin body (circle)
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Pin circle
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(centerX, pinHeight / 2),
        width: pinWidth,
        height: pinHeight,
      ),
      paint,
    );

    // Draw the pointer triangle at the bottom
    final pointerPath = Path();
    pointerPath.moveTo(centerX - 8, pinHeight / 2 + pinHeight / 3);
    pointerPath.lineTo(centerX, pinHeight + pointerHeight);
    pointerPath.lineTo(centerX + 8, pinHeight / 2 + pinHeight / 3);
    pointerPath.close();
    canvas.drawPath(pointerPath, paint);

    // Draw the plus icon
    final iconPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Horizontal line of plus
    canvas.drawLine(
      Offset(centerX - iconSize / 2, pinHeight / 2),
      Offset(centerX + iconSize / 2, pinHeight / 2),
      iconPaint,
    );

    // Vertical line of plus
    canvas.drawLine(
      Offset(centerX, pinHeight / 2 - iconSize / 2),
      Offset(centerX, pinHeight / 2 + iconSize / 2),
      iconPaint,
    );

    // Convert to image
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
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
      ..color = AppColors.secondary
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
    _clusterMarkerCache.clear();
  }
}
