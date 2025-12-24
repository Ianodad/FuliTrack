import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// FuliGraph Component:
/// An SVG-style custom line chart that renders data points as a smooth Bezier curve.
class FuliGraph extends StatelessWidget {
  final List<FuliGraphData> data;

  const FuliGraph({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.slate900,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: CustomPaint(
        size: const Size(double.infinity, 150),
        painter: _GraphPainter(data: data),
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
      child: Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: AppTheme.slate500,
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

  _GraphPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return;

    final padding = 40.0;
    final graphWidth = size.width - 2 * padding;
    final graphHeight = size.height - 2 * padding;

    // Calculate points
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = padding + (i * graphWidth) / (data.length - 1);
      final y = size.height -
          padding -
          (data[i].value / maxValue) * graphHeight;
      points.add(Offset(x, y));
    }

    // Create gradient for fill area
    final areaPath = Path();
    areaPath.moveTo(points.first.dx, size.height - padding);
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

    areaPath.lineTo(points.last.dx, size.height - padding);
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

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < data.length; i++) {
      textPainter.text = TextSpan(
        text: data[i].label,
        style: const TextStyle(
          color: AppTheme.slate500,
          fontSize: 9,
          fontWeight: FontWeight.bold,
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

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
