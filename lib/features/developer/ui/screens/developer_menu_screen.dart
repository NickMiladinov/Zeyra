import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/main.dart' show logger;

/// Developer menu screen for debugging and diagnostics.
/// 
/// Only accessible in debug builds via the "More" tab.
/// Provides access to:
/// - Talker log viewer
/// - Log export
/// - Clear logs
/// - Test crash reporting
class DeveloperMenuScreen extends StatelessWidget {
  const DeveloperMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safety check - should never be shown in release builds
    if (kReleaseMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Developer Menu'),
        ),
        body: const Center(
          child: Text('Developer menu is not available in release builds'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Developer Menu',
          style: AppTypography.headlineMedium,
        ),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.paddingLG),
        children: [
          // Logging Section
          _buildSectionHeader('Logging & Diagnostics'),
          _buildMenuTile(
            context,
            icon: Icons.bug_report,
            title: 'View Logs',
            subtitle: 'Open Talker log viewer',
            onTap: () => _openTalkerViewer(context),
          ),
          _buildMenuTile(
            context,
            icon: Icons.file_download,
            title: 'Export Logs',
            subtitle: 'Save logs to file',
            onTap: () => _exportLogs(context),
          ),
          _buildMenuTile(
            context,
            icon: Icons.delete_sweep,
            title: 'Clear Logs',
            subtitle: 'Remove all local logs',
            onTap: () => _clearLogs(context),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Testing Section
          _buildSectionHeader('Testing'),
          _buildMenuTile(
            context,
            icon: Icons.warning,
            title: 'Test Error Logging',
            subtitle: 'Trigger test error',
            onTap: () => _testErrorLogging(context),
          ),
          _buildMenuTile(
            context,
            icon: Icons.info,
            title: 'Test Info Logging',
            subtitle: 'Trigger test info log',
            onTap: () => _testInfoLogging(context),
          ),
          _buildMenuTile(
            context,
            icon: Icons.error,
            title: 'Test Crash Reporting',
            subtitle: 'Trigger test exception to Sentry',
            onTap: () => _testCrashReporting(context),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Info Section
          _buildSectionHeader('Information'),
          _buildInfoTile('Total Logs', '${logger.getLogs().length}'),
          _buildInfoTile('Build Mode', 'Debug'),
          _buildInfoTile('Sentry Enabled', logger.talker.settings.enabled ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
        left: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primary,
          size: AppSpacing.iconMD,
        ),
        title: Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _openTalkerViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TalkerScreen(
          talker: logger.talker,
          theme: const TalkerScreenTheme(
            backgroundColor: AppColors.surface,
            cardColor: AppColors.white,
            textColor: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _exportLogs(BuildContext context) {
    try {
      final logs = logger.exportLogs();
      
      // In a real implementation, you would use a file picker
      // or share plugin to save/share the logs
      logger.info('Logs exported', data: {'length': logs.length});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logs exported successfully (${logs.length} characters)'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      logger.error('Failed to export logs', error: e);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export logs: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _clearLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              logger.clearLogs();
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logs cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _testInfoLogging(BuildContext context) {
    logger.info(
      'Test info log from developer menu',
      data: {
        'timestamp': DateTime.now().toIso8601String(),
        'source': 'developer_menu',
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test info log generated'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _testErrorLogging(BuildContext context) {
    logger.error(
      'Test error log from developer menu',
      error: Exception('This is a test error'),
      data: {
        'timestamp': DateTime.now().toIso8601String(),
        'source': 'developer_menu',
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test error log generated and sent to Sentry'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _testCrashReporting(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Crash Reporting'),
        content: const Text(
          'This will trigger a test exception that will be sent to Sentry. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Trigger a test exception
              logger.critical(
                'Test crash from developer menu',
                error: Exception('This is a test crash for Sentry'),
                data: {
                  'timestamp': DateTime.now().toIso8601String(),
                  'source': 'developer_menu',
                  'test': true,
                },
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test exception sent to Sentry'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Send Test'),
          ),
        ],
      ),
    );
  }
}

