import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

/// Permission screen for requesting SMS access
class PermissionScreen extends StatelessWidget {
  final VoidCallback onGranted;

  const PermissionScreen({super.key, required this.onGranted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              // Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.teal100.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        const Icon(
                          Icons.message_outlined,
                          size: 96,
                          color: AppTheme.teal100,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 48,
                              color: AppTheme.teal600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Allow SMS access',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.slate500,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'FuliTrack reads only M-PESA messages to calculate Fuliza usage.\n\n',
                          ),
                          TextSpan(
                            text: 'Your data never leaves your phone.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.slate700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.teal100,
                              decorationThickness: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _requestPermission(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Allow SMS Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        // Show info dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Why SMS Access?'),
                            content: const Text(
                              'FuliTrack needs to read M-PESA SMS messages to automatically track your Fuliza loans, interest charges, and repayments.\n\n'
                              'Your data is processed entirely on your device and never sent to any server. The app works completely offline.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Learn more',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.slate500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermission(BuildContext context) async {
    final status = await Permission.sms.request();

    if (!context.mounted) return;

    if (status.isGranted) {
      onGranted();
    } else if (status.isDenied) {
      // Show dialog explaining why permission is needed
      final shouldRetry = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('SMS Permission Required'),
          content: const Text(
            'FuliTrack needs access to your SMS messages to automatically '
            'track Fuliza transactions from M-PESA. We only read Fuliza-related '
            'messages and never send any data to servers.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Skip for now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Try again'),
            ),
          ],
        ),
      );

      if (shouldRetry == true && context.mounted) {
        await _requestPermission(context);
      } else {
        onGranted();
      }
    } else if (status.isPermanentlyDenied) {
      // Open app settings
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'SMS permission was denied. Please enable it in app settings '
            'to automatically track Fuliza transactions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      onGranted();
    }
  }
}
