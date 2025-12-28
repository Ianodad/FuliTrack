import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

/// Animated splash screen with Lottie animation
class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({
    super.key,
    required this.onAnimationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            // TODO: Replace with actual animation file when ready
            // Lottie.asset(
            //   'assets/animations/fulitrack_splash.json',
            //   controller: _controller,
            //   onLoaded: (composition) {
            //     _controller
            //       ..duration = composition.duration
            //       ..forward().then((_) {
            //         // Wait a bit before transitioning
            //         Future.delayed(const Duration(milliseconds: 500), () {
            //           if (mounted) {
            //             widget.onAnimationComplete();
            //           }
            //         });
            //       });
            //   },
            // ),

            // Temporary: Static logo with fade-in until Lottie is ready
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 200,
                height: 200,
              ),
              onEnd: () {
                // Auto-proceed after 2 seconds
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    widget.onAnimationComplete();
                  }
                });
              },
            ),

            const SizedBox(height: 32),

            // App name with fade-in
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: const Text(
                'FuliTrack',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.slate900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on TweenAnimationBuilder {
  // Helper to add delay (not built-in, custom implementation)
  TweenAnimationBuilder delay(Duration duration) => this;
}
