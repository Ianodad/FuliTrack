import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Onboarding screen with premium dark theme design
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Track Fuliza. Control the Cost.',
      body:
          'FuliTrack analyzes your M-PESA SMS to show exactly how much interest you\'re paying in real-time.',
      icon: Icons.battery_charging_full_rounded,
    ),
    _OnboardingSlide(
      title: '100% Private. 100% Offline.',
      body:
          'We never upload your data. Your M-PESA messages are processed locally on your device.',
      icon: Icons.lock_outline_rounded,
    ),
    _OnboardingSlide(
      title: 'Build Habits. Earn Rewards.',
      body:
          'Reduce your dependency, lower your interest costs, and unlock premium badges.',
      icon: Icons.emoji_events_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastSlide = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.slate950,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
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
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: AppTheme.teal500.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(
                                    color: AppTheme.teal500.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  slide.icon,
                                  size: 80,
                                  color: _getIconColor(index),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.slate400,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Progress indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isActive ? 40 : 8,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.teal500 : AppTheme.slate800,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.teal600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: AppTheme.teal900.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLastSlide ? 'START SAVING' : 'NEXT STEP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2,
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

  Color _getIconColor(int index) {
    switch (index) {
      case 0:
        return AppTheme.teal500;
      case 1:
        return AppTheme.teal400;
      case 2:
        return AppTheme.amber500;
      default:
        return AppTheme.teal500;
    }
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
