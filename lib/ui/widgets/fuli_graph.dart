import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// FuliGraph Component:
/// An SVG-style custom line chart that renders data points as a smooth Bezier curve.
/// Features interactive tap-able data points with animated tooltips.
class FuliGraph extends StatefulWidget {
  final List<FuliGraphData> data;
  final Function(int index, FuliGraphData data)? onPointTap;

  const FuliGraph({
    super.key,
    required this.data,
    this.onPointTap,
  });

  @override
  State<FuliGraph> createState() => _FuliGraphState();
}

class _FuliGraphState extends State<FuliGraph> with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  OverlayEntry? _tooltipOverlay;
  final GlobalKey _graphKey = GlobalKey();
  late AnimationController _tooltipController;
  late Animation<double> _tooltipAnimation;

  @override
  void initState() {
    super.initState();
    _tooltipController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _tooltipAnimation = CurvedAnimation(
      parent: _tooltipController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    _tooltipController.dispose();
    super.dispose();
  }

  void _hideTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  void _showTooltip(int index, Offset position) {
    _hideTooltip();

    final data = widget.data[index];
    final RenderBox? renderBox = _graphKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final globalPosition = renderBox.localToGlobal(position);

    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: globalPosition.dx - 50,
        top: globalPosition.dy - 60,
        child: AnimatedBuilder(
          animation: _tooltipAnimation,
          builder: (context, child) => Transform.scale(
            scale: _tooltipAnimation.value,
            child: Opacity(
              opacity: _tooltipAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.slate800,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.label,
                        style: const TextStyle(
                          color: AppTheme.slate400,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ksh ${data.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_tooltipOverlay!);
    _tooltipController.forward(from: 0);
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.data.isEmpty) return;

    // Calculate which point was tapped
    final RenderBox renderBox = _graphKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;
    final size = renderBox.size;

    final padding = 40.0;
    final graphWidth = size.width - 2 * padding;

    // Find nearest point
    int? nearestIndex;
    double nearestDistance = double.infinity;

    for (var i = 0; i < widget.data.length; i++) {
      final pointX = padding + (i * graphWidth) / (widget.data.length - 1);
      final distance = (localPosition.dx - pointX).abs();

      if (distance < nearestDistance && distance < 30) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    if (nearestIndex != null) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _selectedIndex = nearestIndex;
      });

      // Calculate point position for tooltip
      final maxValue = widget.data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
      final graphHeight = size.height - 2 * padding - 24; // Account for labels
      final pointX = padding + (nearestIndex * graphWidth) / (widget.data.length - 1);
      final pointY = size.height - padding - 24 - (widget.data[nearestIndex].value / maxValue) * graphHeight;

      _showTooltip(nearestIndex, Offset(pointX, pointY));

      widget.onPointTap?.call(nearestIndex, widget.data[nearestIndex]);
    }
  }

  void _onTapUp(TapUpDetails details) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _selectedIndex = null;
        });
        _hideTooltip();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      key: _graphKey,
      decoration: BoxDecoration(
        color: AppTheme.slate900,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          size: const Size(double.infinity, 150),
          painter: _GraphPainter(
            data: widget.data,
            selectedIndex: _selectedIndex,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.slate900,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class FuliGraphData {
  final String label;
  final double value;

  const FuliGraphData({
    required this.label,
    required this.value,
  });
}

class _GraphPainter extends CustomPainter {
  final List<FuliGraphData> data;
  final int? selectedIndex;

  _GraphPainter({
    required this.data,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final hasData = maxValue > 0;

    final leftPadding = 50.0; // More space for Y-axis labels
    final rightPadding = 20.0;
    final topPadding = 20.0;
    final bottomPadding = 30.0;
    final graphWidth = size.width - leftPadding - rightPadding;
    final graphHeight = size.height - topPadding - bottomPadding;

    // Draw Y-axis labels and grid lines (use a default max for empty data)
    final displayMaxValue = hasData ? maxValue : 1000.0; // Default scale when no data
    _drawYAxis(canvas, size, displayMaxValue, leftPadding, topPadding, graphHeight);

    // Calculate points - if no data, all points are at the baseline (y = 0)
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = leftPadding + (i * graphWidth) / (data.length - 1);
      final y = hasData
          ? size.height - bottomPadding - (data[i].value / maxValue) * graphHeight
          : size.height - bottomPadding; // All points at baseline when no data
      points.add(Offset(x, y));
    }

    if (hasData) {
      // Create gradient for fill area
      final areaPath = Path();
      areaPath.moveTo(points.first.dx, size.height - bottomPadding);
      areaPath.lineTo(points.first.dx, points.first.dy);

      // Draw smooth curve using cubic bezier
      for (var i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final cp1x = p1.dx + (p2.dx - p1.dx) / 2;

        areaPath.cubicTo(
          cp1x,
          p1.dy,
          cp1x,
          p2.dy,
          p2.dx,
          p2.dy,
        );
      }

      areaPath.lineTo(points.last.dx, size.height - bottomPadding);
      areaPath.close();

      // Fill gradient
      final fillGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.teal500.withOpacity(0.3),
          AppTheme.teal500.withOpacity(0),
        ],
      );

      final fillPaint = Paint()
        ..shader = fillGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );

      canvas.drawPath(areaPath, fillPaint);

      // Draw line
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);

      for (var i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final cp1x = p1.dx + (p2.dx - p1.dx) / 2;

        linePath.cubicTo(
          cp1x,
          p1.dy,
          cp1x,
          p2.dy,
          p2.dx,
          p2.dy,
        );
      }

      // Line gradient
      final lineGradient = LinearGradient(
        colors: [AppTheme.teal400, AppTheme.amber500],
      );

      final linePaint = Paint()
        ..shader = lineGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      // Add glow effect
      final glowPaint = Paint()
        ..shader = lineGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawPath(linePath, glowPaint);
      canvas.drawPath(linePath, linePaint);
    } else {
      // Draw a flat baseline when there's no data
      final baselinePaint = Paint()
        ..color = AppTheme.slate600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(leftPadding, size.height - bottomPadding),
        Offset(size.width - rightPadding, size.height - bottomPadding),
        baselinePaint,
      );
    }

    // Draw data points (always show them)
    for (var i = 0; i < points.length; i++) {
      final isSelected = selectedIndex == i;
      final point = points[i];

      if (hasData) {
        // Outer glow for selected point
        if (isSelected) {
          final glowPaint = Paint()
            ..color = AppTheme.teal400.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawCircle(point, 16, glowPaint);
        }

        // White outer ring
        final outerPaint = Paint()
          ..color = isSelected ? AppTheme.teal400 : Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, isSelected ? 8 : 5, outerPaint);

        // Inner dot
        final innerPaint = Paint()
          ..color = isSelected ? Colors.white : AppTheme.slate900
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, isSelected ? 4 : 2.5, innerPaint);
      } else {
        // Show hollow circles at baseline when no data
        final outerPaint = Paint()
          ..color = AppTheme.textSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(point, 5, outerPaint);

        // Small filled center
        final innerPaint = Paint()
          ..color = AppTheme.slate600
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 2, innerPaint);
      }
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < data.length; i++) {
      final isSelected = selectedIndex == i;
      textPainter.text = TextSpan(
        text: data[i].label,
        style: TextStyle(
          color: isSelected ? AppTheme.teal400 : AppTheme.textSecondary,
          fontSize: isSelected ? 10 : 9,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          size.height - 15,
        ),
      );
    }
  }

  void _drawYAxis(Canvas canvas, Size size, double maxValue, double leftPadding, double topPadding, double graphHeight) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Draw 3 Y-axis labels: 0, mid, max
    final yValues = [0.0, maxValue / 2, maxValue];
    final yPositions = [
      size.height - 30, // Bottom (0)
      topPadding + graphHeight / 2, // Middle
      topPadding, // Top (max)
    ];

    for (var i = 0; i < yValues.length; i++) {
      final value = yValues[i];
      final yPos = yPositions[i];

      // Format the value (use K for thousands)
      String label;
      if (value >= 1000) {
        label = '${(value / 1000).toStringAsFixed(1)}K';
      } else {
        label = value.toStringAsFixed(0);
      }

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 8, yPos - textPainter.height / 2),
      );

      // Draw subtle grid line
      final linePaint = Paint()
        ..color = AppTheme.slate700.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(leftPadding, yPos),
        Offset(size.width - 20, yPos),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.selectedIndex != selectedIndex;
  }
}
