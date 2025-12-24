import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// UsageTank Component:
/// Visualizes the ratio of used credit vs available limit.
/// Uses a "liquid tank" metaphor with color-coded risk alerts (Teal vs Red).
class UsageTank extends StatefulWidget {
  final double spent;
  final double limit;

  const UsageTank({
    super.key,
    required this.spent,
    required this.limit,
  });

  @override
  State<UsageTank> createState() => _UsageTankState();
}

class _UsageTankState extends State<UsageTank>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

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
    super.dispose();
  }

  double get _percentage =>
      widget.limit > 0 ? (widget.spent / widget.limit * 100).clamp(0, 100) : 0;

  bool get _isHigh => _percentage > 70;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    Text(
                      'LIMIT UTILIZATION',
                      style: AppTheme.labelUppercase.copyWith(
                        color: AppTheme.slate500,
                        letterSpacing: 2,
                      ),
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
                            color: AppTheme.slate500,
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

                    // Status badge
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
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTank() {
    return AnimatedBuilder(
      animation: _fillAnimation,
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

                // Fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: (128 - 16) * fillHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: _isHigh
                          ? [AppTheme.red600, AppTheme.amber500]
                          : [AppTheme.teal600, AppTheme.emerald400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Pulse highlight at top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) => Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(0.2 * _pulseAnimation.value),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
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
