import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../providers/providers.dart';

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
    final summary = ref.watch(currentMonthSummaryProvider);

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: SingleChildScrollView(
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
              summary.when(
                data: (data) => _buildSummaryCards(data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildSummaryCards(null),
              ),

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
                          onTap: () => setState(() => _selectedPeriod = period),
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
              summary.when(
                data: (data) => _buildInsightCard(data),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

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

  Widget _buildSummaryCards(dynamic data) {
    final currencyFormat = NumberFormat.currency(symbol: 'Ksh ', decimalDigits: 2);

    final fulizaUsed = data?.totalLoans ?? 1812.51;
    final interestPaid = data?.totalInterest ?? 18.14;
    final outstanding = data?.currentBalance ?? 145.30;

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

  Widget _buildInsightCard(dynamic data) {
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
              child: const Icon(
                Icons.trending_down,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You paid Ksh 18.14 in Fuliza interest this month.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.teal100,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "That's 32% less than last month 🎉",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart() {
    // Mock data for the chart
    final heights = [0.4, 0.7, 0.45, 0.9, 0.3, 0.6, 0.2];

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
                height: 96 * height,
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
