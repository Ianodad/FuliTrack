import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Onboarding screen with 3 slides explaining app purpose
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Track Fuliza. Reduce the cost.',
      body: 'FuliTrack shows how much Fuliza really costs you using your M-PESA SMS.',
      icon: Icons.dashboard_outlined,
    ),
    _OnboardingSlide(
      title: 'Your data stays on your phone',
      body: 'We never upload your messages. Everything works offline and privately.',
      icon: Icons.lock_outline,
    ),
    _OnboardingSlide(
      title: 'Reduce Fuliza. Earn rewards.',
      body: 'Cut your Fuliza usage and unlock achievement badges as you save.',
      icon: Icons.emoji_events_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLastSlide = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              // Content
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with pulsing animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.95, end: 1.0),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: AppTheme.teal50,
                                  borderRadius: BorderRadius.circular(80),
                                ),
                                child: Icon(
                                  slide.icon,
                                  size: 80,
                                  color: AppTheme.teal600,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.body,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.slate500,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 32 : 8,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryTeal : AppTheme.slate200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastSlide) {
                      widget.onComplete();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLastSlide ? 'Get Started' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _OnboardingSlide {
  final String title;
  final String body;
  final IconData icon;

  _OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
  });
}
