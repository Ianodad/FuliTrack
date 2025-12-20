import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

/// Card for displaying insights and tips
class InsightCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const InsightCard({
    super.key,
    required this.message,
    this.icon = Icons.lightbulb_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      color: cardColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: cardColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generate insights from summary data
class InsightGenerator {
  static List<InsightData> generateInsights(FulizaSummary summary) {
    final insights = <InsightData>[];

    if (summary.transactionCount == 0) {
      insights.add(InsightData(
        message: 'No Fuliza usage recorded for this period. Keep it up!',
        icon: Icons.celebration,
        type: InsightType.positive,
      ));
      return insights;
    }

    // Interest insight
    if (summary.totalInterest > 0) {
      insights.add(InsightData(
        message:
            'You paid ${CurrencyUtils.formatKsh(summary.totalInterest)} in Fuliza interest this period',
        icon: Icons.trending_down,
        type: InsightType.info,
      ));
    }

    // Average interest per loan
    if (summary.averageInterestPerLoan > 0) {
      insights.add(InsightData(
        message:
            'Average interest per loan is ${CurrencyUtils.formatKsh(summary.averageInterestPerLoan)}',
        icon: Icons.calculate,
        type: InsightType.info,
      ));
    }

    // Interest rate insight
    if (summary.interestRate > 0) {
      insights.add(InsightData(
        message:
            'Your effective interest rate is ${summary.interestRate.toStringAsFixed(1)}%',
        icon: Icons.percent,
        type: summary.interestRate > 5 ? InsightType.warning : InsightType.info,
      ));
    }

    // Outstanding balance warning
    if (summary.outstandingBalance > 0) {
      insights.add(InsightData(
        message:
            'You have ${CurrencyUtils.formatKsh(summary.outstandingBalance)} outstanding Fuliza balance',
        icon: Icons.warning_amber,
        type: InsightType.warning,
      ));
    }

    // Fully paid
    if (summary.totalRepaid >= summary.totalLoaned + summary.totalInterest &&
        summary.transactionCount > 0) {
      insights.add(InsightData(
        message: 'Great job! You\'ve fully paid off your Fuliza for this period',
        icon: Icons.check_circle,
        type: InsightType.positive,
      ));
    }

    return insights;
  }
}

enum InsightType {
  positive,
  info,
  warning,
}

class InsightData {
  final String message;
  final IconData icon;
  final InsightType type;

  InsightData({
    required this.message,
    required this.icon,
    required this.type,
  });

  Color getColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case InsightType.positive:
        return Colors.green;
      case InsightType.info:
        return theme.colorScheme.primary;
      case InsightType.warning:
        return Colors.orange;
    }
  }
}
