import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/usage_tank.dart';
import '../widgets/fuli_graph.dart';
import '../widgets/premium_widgets.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

/// Dashboard screen with premium dark theme and UsageTank
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(fulizaSummaryProvider);
    final events = ref.watch(fulizaProvider).events;
    final isLoading = ref.watch(fulizaProvider).isLoading;
    final currentFilter = ref.watch(fulizaFilterProvider);

    final selectedPeriod = switch (currentFilter) {
      DateFilter.thisWeek => 'All',
      DateFilter.thisMonth => 'Monthly',
      DateFilter.thisYear => 'Year',
      DateFilter.allTime => 'All',
      DateFilter.custom => 'All',
    };

    final totalEventCount = ref.watch(fulizaProvider).totalEventCount;
    final showEmptyState = totalEventCount == 0;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: isLoading
            ? const DashboardSkeleton()
            : showEmptyState
                ? _buildEmptyState(context)
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),

                        const SizedBox(height: 24),

                        // Usage Tank
                        _buildUsageTank(),

                        const SizedBox(height: 24),

                        // Period Selector
                        _buildPeriodSelector(selectedPeriod),

                        const SizedBox(height: 24),

                        // Graph
                        _buildGraph(events, selectedPeriod),

                        const SizedBox(height: 24),

                        // Summary Cards
                        _buildSummaryCards(summary, selectedPeriod, events),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FULITRACK',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.slate900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'LIVE PULSE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.teal600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.slate100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: AppTheme.slate600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'FT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTank() {
    final currentLimit = ref.watch(fulizaLimitProvider);
    final summary = ref.watch(fulizaSummaryProvider);

    final limit = currentLimit?.limit ?? 5000.0;
    final spent = summary.outstandingBalance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: UsageTank(
        spent: spent,
        limit: limit,
        onTap: () => _showLimitHistorySheet(context, limit),
      ),
    );
  }

  void _showLimitHistorySheet(BuildContext context, double currentLimit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: AppTheme.slate900,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.slate700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LIMIT HISTORY',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current: Ksh ${currentLimit.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.teal400,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.slate400),
                  ),
                ],
              ),
            ),
            // Limit history list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildLimitHistoryItem(
                    date: 'Dec 2024',
                    limit: currentLimit,
                    isCurrent: true,
                  ),
                  _buildLimitHistoryItem(
                    date: 'Nov 2024',
                    limit: currentLimit * 0.9,
                    isCurrent: false,
                  ),
                  _buildLimitHistoryItem(
                    date: 'Oct 2024',
                    limit: currentLimit * 0.85,
                    isCurrent: false,
                  ),
                  _buildLimitHistoryItem(
                    date: 'Sep 2024',
                    limit: currentLimit * 0.8,
                    isCurrent: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitHistoryItem({
    required String date,
    required double limit,
    required bool isCurrent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.teal500.withOpacity(0.1) : AppTheme.slate800,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: AppTheme.teal500.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCurrent ? AppTheme.teal400 : AppTheme.slate600,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? Colors.white : AppTheme.slate400,
                ),
              ),
            ],
          ),
          Text(
            'Ksh ${limit.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isCurrent ? AppTheme.teal400 : AppTheme.slate300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(String selectedPeriod) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.slate200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: ['All', 'Monthly', 'Year'].map((period) {
            final isSelected = selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final filter = period == 'Monthly'
                      ? DateFilter.thisMonth
                      : period == 'Year'
                          ? DateFilter.thisYear
                          : DateFilter.allTime;
                  ref.read(fulizaProvider.notifier).setFilter(filter);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.primaryTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    period.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: isSelected ? Colors.white : AppTheme.slate400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGraph(List<FulizaEvent> events, String selectedPeriod) {
    // Calculate chart data based on events
    final chartData = _calculateChartData(events, selectedPeriod);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FuliGraph(data: chartData),
    );
  }

  List<FuliGraphData> _calculateChartData(
    List<FulizaEvent> events,
    String selectedPeriod,
  ) {
    final now = DateTime.now();
    final data = <FuliGraphData>[];

    if (selectedPeriod == 'Monthly') {
      // Current month broken into 4 weeks
      final monthStart = DateTime(now.year, now.month, 1);

      for (int week = 1; week <= 4; week++) {
        final weekStart = monthStart.add(Duration(days: (week - 1) * 7));
        final weekEnd = week == 4
            ? DateTime(now.year, now.month + 1, 0, 23, 59, 59) // End of month
            : monthStart.add(Duration(days: week * 7 - 1, hours: 23, minutes: 59, seconds: 59));

        final weekEvents = events.where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(weekStart) &&
            !e.date.isAfter(weekEnd));
        final total = weekEvents.fold<double>(0, (sum, e) => sum + e.amount);

        data.add(FuliGraphData(
          label: 'W$week',
          value: total,
        ));
      }
    } else if (selectedPeriod == 'Year') {
      // Current year broken into 12 months
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

      for (int i = 0; i < 12; i++) {
        final monthStart = DateTime(now.year, i + 1, 1);
        final monthEnd = DateTime(now.year, i + 2, 0, 23, 59, 59);

        final monthEvents = events.where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(monthStart) &&
            !e.date.isAfter(monthEnd));
        final total = monthEvents.fold<double>(0, (sum, e) => sum + e.amount);

        data.add(FuliGraphData(
          label: months[i],
          value: total,
        ));
      }
    } else {
      // All time - show last 6 months for context
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

      for (int i = 5; i >= 0; i--) {
        final targetMonth = DateTime(now.year, now.month - i, 1);
        final monthStart = DateTime(targetMonth.year, targetMonth.month, 1);
        final monthEnd = DateTime(targetMonth.year, targetMonth.month + 1, 0, 23, 59, 59);

        final monthEvents = events.where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(monthStart) &&
            !e.date.isAfter(monthEnd));
        final total = monthEvents.fold<double>(0, (sum, e) => sum + e.amount);

        data.add(FuliGraphData(
          label: months[targetMonth.month - 1],
          value: total,
        ));
      }
    }

    return data;
  }

  Widget _buildSummaryCards(
    FulizaSummary summary,
    String selectedPeriod,
    List<FulizaEvent> events,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: 'Ksh ', decimalDigits: 2);

    // Format subtitle and repaid label based on period
    final subtitleText = switch (selectedPeriod) {
      'Monthly' => 'This Month',
      'Year' => 'This Year',
      _ => 'All time',
    };

    final repaidLabel = switch (selectedPeriod) {
      'Monthly' => 'REPAID MONTH',
      'Year' => 'REPAID YEAR',
      _ => 'REPAID ALL',
    };

    // Calculate interest comparison
    final comparison = _calculateInterestComparison(events, selectedPeriod);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'INTEREST PAID',
                  amount: currencyFormat.format(summary.totalInterest),
                  subtitle: subtitleText,
                  icon: comparison.isDown ? Icons.trending_down : Icons.trending_up,
                  iconColor: AppTheme.amber600,
                  trend: comparison.trend,
                  trendColor: comparison.isDown ? AppTheme.teal600 : AppTheme.red500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  label: repaidLabel,
                  amount: currencyFormat.format(summary.totalRepaid),
                  subtitle: 'View logs',
                  icon: Icons.arrow_forward,
                  iconColor: AppTheme.slate400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Calculate interest comparison between current and previous period
  _InterestComparison _calculateInterestComparison(
    List<FulizaEvent> events,
    String selectedPeriod,
  ) {
    // For "All" period, don't show comparison
    if (selectedPeriod == 'All') {
      return _InterestComparison(trend: null, isDown: true);
    }

    final now = DateTime.now();
    DateTime currentStart;
    DateTime currentEnd;
    DateTime previousStart;
    DateTime previousEnd;

    switch (selectedPeriod) {
      case 'Monthly':
        // Current month
        currentStart = DateTime(now.year, now.month, 1);
        currentEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        // Previous month
        previousStart = DateTime(now.year, now.month - 1, 1);
        previousEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case 'Year':
        // Current year
        currentStart = DateTime(now.year, 1, 1);
        currentEnd = DateTime(now.year, 12, 31, 23, 59, 59);
        // Previous year
        previousStart = DateTime(now.year - 1, 1, 1);
        previousEnd = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        break;
      default:
        return _InterestComparison(trend: null, isDown: true);
    }

    // Calculate current period interest
    final currentInterest = events
        .where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(currentStart) &&
            !e.date.isAfter(currentEnd))
        .fold<double>(0, (sum, e) => sum + e.amount);

    // Calculate previous period interest
    final previousInterest = events
        .where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(previousStart) &&
            !e.date.isAfter(previousEnd))
        .fold<double>(0, (sum, e) => sum + e.amount);

    // Calculate percentage change
    if (previousInterest == 0) {
      if (currentInterest == 0) {
        return _InterestComparison(trend: 'No change', isDown: true);
      }
      return _InterestComparison(trend: 'New', isDown: false);
    }

    final percentChange =
        ((currentInterest - previousInterest) / previousInterest * 100).abs();
    final isDown = currentInterest <= previousInterest;

    return _InterestComparison(
      trend: '${percentChange.toStringAsFixed(0)}% ${isDown ? 'Down' : 'Up'}',
      isDown: isDown,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.teal50,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 60,
                color: AppTheme.teal600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Fuliza Data Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'FuliTrack will automatically scan your M-PESA SMS messages to track Fuliza transactions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.slate500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final notifier = ref.read(fulizaProvider.notifier);
                await notifier.syncFromSms();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Scan SMS Messages'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String? trend;
  final Color? trendColor;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trend,
    this.trendColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TappableCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.slate100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.slate400,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (trend != null) ...[
                  Icon(icon, size: 10, color: trendColor),
                  const SizedBox(width: 4),
                  Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                ] else ...[
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(icon, size: 10, color: iconColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for interest comparison result
class _InterestComparison {
  final String? trend;
  final bool isDown;

  _InterestComparison({
    required this.trend,
    required this.isDown,
  });
}
