import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_analytics.dart';
import 'package:zeyra/domain/entities/kick_counter/kick_session.dart';
import 'package:zeyra/features/kick_counter/logic/kick_analytics_provider.dart';
import 'package:zeyra/shared/widgets/app_progress_unlock_banner.dart';

/// Widget displaying a bar graph of time to 10 movements.
/// 
/// Shows a progress unlock banner until there are 7 valid sessions.
/// Once unlocked, displays the last 7 valid sessions (sessions with >= 10 kicks) with:
/// - Bar chart showing duration in minutes
/// - Average line
/// - Outlier highlighting based on GRAPH-SPECIFIC safe range
/// 
/// The graph uses its own analytics calculation where all 7 displayed sessions
/// are evaluated against one safe range calculated from the 14 valid sessions
/// that occurred before the newest displayed session.
class KickDurationGraphCard extends ConsumerWidget {
  final List<KickSession> allSessions;
  
  /// Optional key to attach to the card container for tooltip highlighting.
  final GlobalKey? highlightKey;

  const KickDurationGraphCard({
    super.key,
    required this.allSessions,
    this.highlightKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get ALL valid sessions for counting progress
    final allValidSessions = allSessions
        .where((s) => s.kicks.length >= 10 && s.durationToTenthKick != null)
        .toList();
    
    // Take only the last 7 for display
    final validSessions = allValidSessions.take(7).toList();

    // Calculate graph-specific analytics
    // All 7 sessions are evaluated against one safe range from the 14 sessions
    // that occurred before the newest displayed session
    final (analytics, graphSessionAnalytics) = validSessions.isEmpty
        ? (
            const KickHistoryAnalytics(validSessionCount: 0),
            <KickSessionAnalytics>[],
          )
        : ref.read(kickAnalyticsProvider.notifier).calculateAnalyticsForGraph(
            validSessions,
            allSessions,
          );

    // Reverse to show oldest on left
    final displaySessions = validSessions.reversed.toList();
    final displayAnalytics = graphSessionAnalytics.reversed.toList();

    return Container(
      key: highlightKey, // Apply highlight key directly to the container
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        boxShadow: AppEffects.shadowXS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Your Baby\'s Pattern',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.gapXS),
          
          // Subtitle
          Text(
            'Time taken to feel 10 movements (in minutes)',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.gapMD),

          // Show unlock banner when < 7 valid sessions
          if (!analytics.hasEnoughDataForAnalytics)
            AppProgressUnlockBanner(
              currentCount: allValidSessions.length,
              requiredCount: KickHistoryAnalytics.minSessionsForAnalytics,
              messageTemplate:
                  'Record {remaining} more complete sessions (10+ movements) to see your baby\'s average pattern',
            ),
          
          // Only show graph when unlocked (>= 7 valid sessions)
          if (analytics.hasEnoughDataForAnalytics) ...[
            _buildLegend(),
            const SizedBox(height: AppSpacing.gapMD),
            _buildGraph(displaySessions, displayAnalytics, analytics),
          ],
        ],
      ),
    );
  }

  /// Build the legend showing "Your baby's typical range" and "Average"
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.gapMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Typical range legend - 50% width
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: CustomPaint(
                    size: const Size(AppSpacing.iconSM, AppSpacing.iconSM),
                    painter: _LegendBoxPainter(),
                  ),
                ),
                const SizedBox(width: AppSpacing.gapMD),
                Expanded(
                  child: Text(
                    'Safe range for your baby\'s pattern',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.gapMD),
          // Average legend - 50% width
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: CustomPaint(
                    size: const Size(AppSpacing.iconSM, AppSpacing.iconSM),
                    painter: _AverageLegendPainter(),
                  ),
                ),
                const SizedBox(width: AppSpacing.gapSM),
                Expanded(
                  child: Text(
                    'Average Time to 10 Movements',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Determine label alignment for the safe range line.
  /// 
  /// Positions the label on the left if rightmost bars would overlap with it,
  /// otherwise positions on the right for better visibility.
  Alignment _getSafeRangeLabelAlignment(List<double> durationsInMinutes, double thresholdInMinutes) {
    if (durationsInMinutes.isEmpty) return Alignment.topRight;
    
    // Check the last 2-3 bars (rightmost) to see if they're near the threshold
    final checkCount = durationsInMinutes.length >= 3 ? 3 : durationsInMinutes.length;
    final rightmostDurations = durationsInMinutes.sublist(durationsInMinutes.length - checkCount);
    
    // If any rightmost bar is at or above threshold (within 0.5 minutes), use left alignment
    for (final duration in rightmostDurations) {
      if ((duration - thresholdInMinutes).abs() <= 0.5 || duration >= thresholdInMinutes) {
        return Alignment.topLeft;
      }
    }
    
    return Alignment.topRight;
  }

  /// Round seconds to nearest minute for display labels
  int _roundToNearestMinute(int seconds) {
    if (seconds <= 0) return 1;
    return ((seconds + 30) / 60).floor().clamp(1, 999);
  }

  Widget _buildGraph(
    List<KickSession> displaySessions,
    List<KickSessionAnalytics> displayAnalytics,
    KickHistoryAnalytics analytics,
  ) {
    // Calculate durations in minutes (as decimals for accurate bar heights)
    // E.g., 189 seconds = 3.15 minutes (bar height), but label shows "3 min" (rounded)
    final durationsInMinutes = displaySessions.map((s) {
      final seconds = s.durationToTenthKick?.inSeconds ?? 0;
      return seconds > 0 ? seconds / 60.0 : 1.0;
    }).toList();
    
    final maxDuration = durationsInMinutes.reduce((a, b) => a > b ? a : b);
    
    // Threshold in minutes (decimal for line position), rounded for label
    final thresholdSeconds = analytics.upperThreshold?.inSeconds ?? 0;
    final thresholdInMinutes = thresholdSeconds > 0 ? thresholdSeconds / 60.0 : 1.0;
    final thresholdLabel = _roundToNearestMinute(thresholdSeconds);
    
    // Average in minutes (decimal for line position), rounded for reference
    final averageSeconds = analytics.averageDurationToTen?.inSeconds ?? 0;
    final averageInMinutes = averageSeconds > 0 ? averageSeconds / 60.0 : 1.0;
    
    // Add 15% padding to max for better visualization (room for labels above bars)
    final maxValue = maxDuration > thresholdInMinutes ? maxDuration : thresholdInMinutes;
    final maxY = (maxValue * 1.15).ceilToDouble();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: displaySessions.length <= 5 
              ? BarChartAlignment.start 
              : BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipMargin: 2, // Reduced space between label and bar
              getTooltipColor: (group) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Show rounded minutes label above bar
                final seconds = displaySessions[groupIndex].durationToTenthKick?.inSeconds ?? 0;
                final minutes = _roundToNearestMinute(seconds);
                return BarTooltipItem(
                  '$minutes',
                  AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            // Always show tooltips (labels above bars)
            handleBuiltInTouches: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < displaySessions.length) {
                    final session = displaySessions[value.toInt()];
                    final date = DateFormat('dd/MM').format(session.startTime);
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.paddingXS),
                      child: Text(
                        date,
                        style: AppTypography.labelSmall,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false), // Remove grid lines
          borderData: FlBorderData(show: false), // Remove borders
          barGroups: List.generate(
            displaySessions.length,
            (index) {
              final sessionAnalytic = displayAnalytics[index];
              
              // Use actual duration in minutes (decimal) for accurate bar height
              final barHeight = durationsInMinutes[index];
              
              // Determine bar color: 
              // - All bars are secondary (green) when < 7 sessions (no threshold available)
              // - Green (secondary) if below or at threshold (safe range)
              // - Coral/warning color if above threshold (outlier)
              Color barColor = AppColors.secondary;
              if (analytics.hasEnoughDataForAnalytics) {
                // Use outlier flag (which is based on upper threshold)
                if (sessionAnalytic.isOutlier) {
                  barColor = const Color(0xFFFFB5A0); // Light coral for outliers
                }
              }

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: barHeight,
                    color: barColor,
                    width: 28,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
                showingTooltipIndicators: [0], // Always show tooltip (label above bar)
              );
            },
          ),
          // Gradient area below the threshold line (safe/typical range)
          rangeAnnotations: analytics.hasEnoughDataForAnalytics && analytics.upperThreshold != null
              ? RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 0,
                      y2: thresholdInMinutes,
                      color: AppColors.secondary.withValues(alpha: 0.15),
                    ),
                  ],
                )
              : null,
          extraLinesData: analytics.hasEnoughDataForAnalytics && analytics.upperThreshold != null
              ? ExtraLinesData(
                  horizontalLines: [
                    // Average line (grey, in the middle of safe range)
                    if (analytics.averageDurationToTen != null)
                      HorizontalLine(
                        y: averageInMinutes,
                        color: AppColors.backgroundGrey500,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    // Upper threshold line (green, top of safe range)
                    // Position label on left if rightmost bars overlap, else right
                    HorizontalLine(
                      y: thresholdInMinutes,
                      color: AppColors.secondary,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: _getSafeRangeLabelAlignment(durationsInMinutes, thresholdInMinutes),
                        padding: _getSafeRangeLabelAlignment(durationsInMinutes, thresholdInMinutes) == Alignment.topRight
                            ? const EdgeInsets.only(right: AppSpacing.paddingSM, bottom: AppSpacing.paddingXS)
                            : const EdgeInsets.only(left: AppSpacing.paddingSM, bottom: AppSpacing.paddingXS),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          backgroundColor: AppColors.surface,
                        ),
                        labelResolver: (line) => 'Safe range: $thresholdLabel min',
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}

/// Custom painter for the legend box with dashed top border
class _LegendBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    // Draw filled box
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(AppEffects.radiusXS),
    );
    canvas.drawRRect(rect, paint);
    
    // Draw dashed line on top
    final dashedPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;
    
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth < size.width ? startX + dashWidth : size.width, 0),
        dashedPaint,
      );
      startX += dashWidth + dashSpace;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the average legend (dashed grey line)
class _AverageLegendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashedPaint = Paint()
      ..color = AppColors.backgroundGrey500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;
    final centerY = size.height *0.5;
    
    // Draw dashed line through the middle
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, centerY),
        Offset(startX + dashWidth < size.width ? startX + dashWidth : size.width, centerY),
        dashedPaint,
      );
      startX += dashWidth + dashSpace;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
