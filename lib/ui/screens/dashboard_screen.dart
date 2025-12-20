import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Main dashboard screen showing Fuliza summary
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<MonthlyData>? _monthlyData;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    final db = ref.read(databaseServiceProvider);
    final aggregation = AggregationService(db);
    final data = await aggregation.getMonthlyTrend(months: 6);
    if (mounted) {
      setState(() => _monthlyData = data);
    }
  }

  Future<void> _onSync() async {
    final notifier = ref.read(fulizaProvider.notifier);
    final count = await notifier.syncFromSms();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count > 0
              ? 'Synced $count Fuliza transactions'
              : 'No new transactions found'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadChartData();
    }
  }

  Future<void> _showCustomDatePicker() async {
    final now = DateTime.now();
    final initialStart = DateTime(now.year, now.month - 1, 1);

    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(start: initialStart, end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      ref.read(fulizaProvider.notifier).setCustomDateRange(
            range.start,
            range.end,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fulizaProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FuliTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: state.isLoading ? null : _onSync,
            tooltip: 'Sync SMS',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(fulizaProvider.notifier).loadData();
          await _loadChartData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips
              const SizedBox(height: 8),
              DateFilterChips(
                currentFilter: state.currentFilter,
                onFilterChanged: (filter) {
                  ref.read(fulizaProvider.notifier).setFilter(filter);
                  _loadChartData();
                },
                onCustomDateTap: _showCustomDatePicker,
              ),

              const SizedBox(height: 16),

              // Summary cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Main summary row
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Total Borrowed',
                            value: state.summary.totalLoaned,
                            icon: Icons.arrow_circle_down,
                            color: AppTheme.loanColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Interest Paid',
                            value: state.summary.totalInterest,
                            icon: Icons.trending_up,
                            color: AppTheme.interestColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Secondary row
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Total Repaid',
                            value: state.summary.totalRepaid,
                            icon: Icons.arrow_circle_up,
                            color: AppTheme.repaymentColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Outstanding',
                            value: state.summary.outstandingBalance,
                            icon: Icons.account_balance_wallet,
                            color: state.summary.outstandingBalance > 0
                                ? AppTheme.errorRed
                                : AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Insights section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildInsights(state.summary),

              // Charts section
              if (settings.showCharts && _monthlyData != null) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Interest Trend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          InterestTrendChart(data: _monthlyData!),
                          const SizedBox(height: 8),
                          ChartLegend(
                            items: [
                              LegendItem(
                                label: 'Interest',
                                color: AppTheme.interestColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Loans vs Repayments',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          LoanRepaymentChart(data: _monthlyData!),
                          const SizedBox(height: 8),
                          ChartLegend(
                            items: [
                              LegendItem(
                                label: 'Borrowed',
                                color: AppTheme.loanColor,
                              ),
                              LegendItem(
                                label: 'Repaid',
                                color: AppTheme.repaymentColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Recent transactions
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${state.events.length} total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildTransactionList(state.events.take(10).toList()),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsights(FulizaSummary summary) {
    final insights = InsightGenerator.generateInsights(summary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: insights.take(3).map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InsightCard(
              message: insight.message,
              icon: insight.icon,
              color: insight.getColor(context),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(List<FulizaEvent> events) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _onSync,
                icon: const Icon(Icons.sync),
                label: const Text('Sync SMS'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _TransactionTile(event: event);
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final FulizaEvent event;

  const _TransactionTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;
    String label;

    switch (event.type) {
      case FulizaEventType.loan:
        icon = Icons.arrow_circle_down;
        color = AppTheme.loanColor;
        label = 'Fuliza Loan';
        break;
      case FulizaEventType.interest:
        icon = Icons.percent;
        color = AppTheme.interestColor;
        label = 'Interest Charged';
        break;
      case FulizaEventType.repayment:
        icon = Icons.arrow_circle_up;
        color = AppTheme.repaymentColor;
        label = 'Repayment';
        break;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(label),
      subtitle: Text(
        '${FuliDateUtils.formatDate(event.date)} • ${event.reference}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        '${event.type == FulizaEventType.repayment ? '+' : '-'}${CurrencyUtils.formatKsh(event.amount)}',
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
