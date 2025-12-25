import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// UsageTank Component:
/// Visualizes the ratio of used credit vs available limit.
/// Uses a "liquid tank" metaphor with color-coded risk alerts (Teal vs Red).
/// Features a subtle wave animation inside the liquid.
class UsageTank extends StatefulWidget {
  final double spent;
  final double limit;
  final VoidCallback? onTap;

  const UsageTank({
    super.key,
    required this.spent,
    required this.limit,
    this.onTap,
  });

  @override
  State<UsageTank> createState() => _UsageTankState();
}

class _UsageTankState extends State<UsageTank>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _waveController;
  late Animation<double> _fillAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Wave animation controller - runs continuously
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _fillAnimation = Tween<double>(
      begin: 0,
      end: _percentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(UsageTank oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spent != widget.spent || oldWidget.limit != widget.limit) {
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: _percentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _waveController.dispose();
    super.dispose();
  }

  double get _percentage =>
      widget.limit > 0 ? (widget.spent / widget.limit * 100).clamp(0, 100) : 0;

  bool get _isHigh => _percentage > 70;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? () {
        HapticFeedback.lightImpact();
        widget.onTap!();
      } : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.slate900,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            // Glow backdrop
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (_isHigh ? AppTheme.red500 : AppTheme.teal500)
                          .withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Row(
              children: [
                // Vertical tank
                _buildTank(),
                const SizedBox(width: 24),

                // Info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LIMIT UTILIZATION',
                            style: AppTheme.labelUppercase.copyWith(
                              color: AppTheme.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                          if (widget.onTap != null)
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Ksh ${_formatNumber(widget.spent)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ ${_formatNumber(widget.limit)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: _fillAnimation,
                        builder: (context, child) => Text(
                          '${_fillAnimation.value.toStringAsFixed(0)}% of your limit used',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isHigh ? AppTheme.amber500 : AppTheme.teal400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status badge with View History hint
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.slate800,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 12,
                                  color:
                                      _isHigh ? AppTheme.amber500 : AppTheme.teal400,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'STATUS: ${_isHigh ? 'HIGH RISK' : 'OPTIMAL'}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.onTap != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.teal500.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 10,
                                    color: AppTheme.teal400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'HISTORY',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.teal400,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTank() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fillAnimation, _waveController]),
      builder: (context, child) {
        final fillHeight = _fillAnimation.value / 100;

        return Container(
          width: 64,
          height: 128,
          decoration: BoxDecoration(
            color: AppTheme.slate800,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.slate700,
              width: 4,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background
                Container(
                  color: AppTheme.slate800,
                ),

                // Fill with wave animation
                SizedBox(
                  height: (128 - 16) * fillHeight,
                  child: CustomPaint(
                    painter: _WavePainter(
                      wavePhase: _waveController.value,
                      isHigh: _isHigh,
                    ),
                    child: Container(),
                  ),
                ),

                // Pulse highlight at top of liquid
                if (fillHeight > 0.05)
                  Positioned(
                    bottom: (128 - 16) * fillHeight - 8,
                    left: 4,
                    right: 4,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) => Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25 * _pulseAnimation.value),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// Custom painter for the wave animation inside the tank
class _WavePainter extends CustomPainter {
  final double wavePhase;
  final bool isHigh;

  _WavePainter({
    required this.wavePhase,
    required this.isHigh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0) return;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: isHigh
            ? [AppTheme.red600, AppTheme.amber500]
            : [AppTheme.teal600, AppTheme.emerald400],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    // Start at bottom left
    path.moveTo(0, size.height);

    // Draw wave at the top
    final waveHeight = 4.0;
    final waveCount = 2.0;

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;
      final waveY = math.sin((normalizedX * waveCount * 2 * math.pi) + (wavePhase * 2 * math.pi)) * waveHeight;

      if (x == 0) {
        path.lineTo(x, waveY);
      } else {
        path.lineTo(x, waveY);
      }
    }

    // Complete the path
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw a second, slightly offset wave for more depth
    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: isHigh
            ? [AppTheme.red600.withOpacity(0.5), AppTheme.amber500.withOpacity(0.5)]
            : [AppTheme.teal600.withOpacity(0.5), AppTheme.emerald400.withOpacity(0.5)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path();
    path2.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;
      final waveY = math.sin((normalizedX * waveCount * 2 * math.pi) + (wavePhase * 2 * math.pi) + math.pi * 0.5) * (waveHeight * 0.6) + 2;

      if (x == 0) {
        path2.lineTo(x, waveY);
      } else {
        path2.lineTo(x, waveY);
      }
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase || oldDelegate.isHigh != isHigh;
  }
}
