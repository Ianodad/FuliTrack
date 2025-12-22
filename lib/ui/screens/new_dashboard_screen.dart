import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

/// Dashboard screen with summary cards and insights
class NewDashboardScreen extends ConsumerStatefulWidget {
  const NewDashboardScreen({super.key});

  @override
  ConsumerState<NewDashboardScreen> createState() => _NewDashboardScreenState();
}

class _NewDashboardScreenState extends ConsumerState<NewDashboardScreen> {
  String _selectedPeriod = 'Month';

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(fulizaSummaryProvider);
    final events = ref.watch(fulizaProvider).events;
    final isLoading = ref.watch(fulizaProvider).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : events.isEmpty
                ? _buildEmptyState(context)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'FuliTrack',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.slate800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.teal50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'PRO-FREE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Summary Cards
                        _buildSummaryCards(summary),

              const SizedBox(height: 24),

              // Period Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.slate100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['Week', 'Month', 'Year'].map((period) {
                      final isSelected = _selectedPeriod == period;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedPeriod = period);
                            final filter = period == 'Week'
                                ? DateFilter.thisWeek
                                : period == 'Month'
                                    ? DateFilter.thisMonth
                                    : DateFilter.thisYear;
                            ref.read(fulizaProvider.notifier).setFilter(filter);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              period,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppTheme.primaryTeal : AppTheme.slate500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Insight Card
              _buildInsightCard(summary),

              const SizedBox(height: 24),

              // Mini Chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interest Over Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMiniChart(),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(FulizaSummary summary) {
    final currencyFormat = NumberFormat.currency(symbol: 'Ksh ', decimalDigits: 2);

    final fulizaUsed = summary.totalLoaned;
    final interestPaid = summary.totalInterest;
    final outstanding = summary.outstandingBalance;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _SummaryCard(
            label: 'Fuliza used',
            amount: currencyFormat.format(fulizaUsed),
            subtitle: 'This $_selectedPeriod',
            color: AppTheme.slate900,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            label: 'Interest paid',
            amount: currencyFormat.format(interestPaid),
            subtitle: 'Avoidable cost',
            color: AppTheme.secondaryAmber,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            label: 'Outstanding',
            amount: currencyFormat.format(outstanding),
            subtitle: 'Repay soon',
            color: AppTheme.errorRed,
            subtitleColor: AppTheme.errorRed,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(FulizaSummary summary) {
    // Don't show insight card if no data
    if (summary.totalInterest == 0 && summary.totalLoaned == 0) {
      return const SizedBox();
    }

    final currencyFormat = NumberFormat.currency(symbol: 'Ksh ', decimalDigits: 2);

    // Format the period text
    String periodText = 'this $_selectedPeriod'.toLowerCase();

    // Simple insight message based on available data
    String mainMessage;
    if (summary.totalInterest > 0) {
      mainMessage = 'You paid ${currencyFormat.format(summary.totalInterest)} in Fuliza interest $periodText.';
    } else {
      mainMessage = 'No Fuliza interest charged $periodText. Great job!';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.teal600, AppTheme.teal800],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                summary.totalInterest > 0 ? Icons.info_outline : Icons.celebration_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  if (summary.outstandingBalance > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.teal100,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Outstanding balance: ${currencyFormat.format(summary.outstandingBalance)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart() {
    final events = ref.watch(fulizaProvider).events;

    // Calculate interest by period (last 7 days/weeks depending on selection)
    final now = DateTime.now();
    final chartData = <double>[];
    final maxBars = 7;

    if (events.isEmpty) {
      // Show empty bars if no data
      for (int i = 0; i < maxBars; i++) {
        chartData.add(0);
      }
    } else {
      // Group events by day/week and calculate interest
      for (int i = maxBars - 1; i >= 0; i--) {
        DateTime periodStart;
        DateTime periodEnd;

        if (_selectedPeriod == 'Week') {
          // Last 7 weeks
          periodEnd = now.subtract(Duration(days: i * 7));
          periodStart = periodEnd.subtract(const Duration(days: 7));
        } else if (_selectedPeriod == 'Year') {
          // Last 7 months
          periodEnd = DateTime(now.year, now.month - i, 1);
          periodStart = DateTime(now.year, now.month - i - 1, 1);
        } else {
          // Last 7 days (default)
          periodEnd = DateTime(now.year, now.month, now.day - i);
          periodStart = periodEnd.subtract(const Duration(days: 1));
        }

        final periodEvents = events.where((event) {
          return event.date.isAfter(periodStart) &&
              event.date.isBefore(periodEnd.add(const Duration(days: 1))) &&
              event.type == FulizaEventType.interest;
        });

        final totalInterest = periodEvents.fold<double>(
          0,
          (sum, event) => sum + event.amount,
        );

        chartData.add(totalInterest);
      }
    }

    // Normalize heights (0 to 1)
    final maxValue = chartData.reduce((a, b) => a > b ? a : b);
    final heights = maxValue > 0
        ? chartData.map((value) => value / maxValue).toList()
        : chartData.map((value) => 0.2).toList();

    return Container(
      height: 128,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: heights.asMap().entries.map((entry) {
          final index = entry.key;
          final height = entry.value;
          final isLast = index == heights.length - 1;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500 + (index * 100)),
                height: height > 0 ? 96 * height : 4,
                decoration: BoxDecoration(
                  color: isLast ? AppTheme.teal600 : AppTheme.slate200,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final String subtitle;
  final Color color;
  final Color? subtitleColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.subtitle,
    required this.color,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.slate500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: subtitleColor ?? AppTheme.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
