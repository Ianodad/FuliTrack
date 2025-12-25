import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Period type: 'Monthly' or 'Year'
  String _periodType = 'Monthly';

  // Selected month and year for navigation
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(fulizaSummaryProvider);
    final events = ref.watch(fulizaProvider).events;
    final isLoading = ref.watch(fulizaProvider).isLoading;
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
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildUsageTank(),
                        const SizedBox(height: 24),
                        _buildPeriodTypeSelector(),
                        const SizedBox(height: 12),
                        _buildPeriodNavigator(),
                        const SizedBox(height: 24),
                        _buildGraph(events),
                        const SizedBox(height: 24),
                        _buildSummaryCards(summary, events),
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
                  border: Border.all(color: Colors.white, width: 2),
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
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.slate700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildLimitHistoryItem(date: 'Dec 2024', limit: currentLimit, isCurrent: true),
                  _buildLimitHistoryItem(date: 'Nov 2024', limit: currentLimit * 0.9, isCurrent: false),
                  _buildLimitHistoryItem(date: 'Oct 2024', limit: currentLimit * 0.85, isCurrent: false),
                  _buildLimitHistoryItem(date: 'Sep 2024', limit: currentLimit * 0.8, isCurrent: false),
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
        border: isCurrent ? Border.all(color: AppTheme.teal500.withOpacity(0.3)) : null,
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

  /// Period type selector (Monthly / Year)
  Widget _buildPeriodTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.slate200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: ['Monthly', 'Year'].map((type) {
            final isSelected = _periodType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _periodType = type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
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
                    type.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
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

  /// Period navigator with arrows to go back/forward
  Widget _buildPeriodNavigator() {
    final now = DateTime.now();
    final isCurrentPeriod = _periodType == 'Monthly'
        ? (_selectedMonth == now.month && _selectedYear == now.year)
        : (_selectedYear == now.year);

    // Format the display text
    String periodText;
    if (_periodType == 'Monthly') {
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      periodText = '${monthNames[_selectedMonth - 1]} $_selectedYear';
    } else {
      periodText = '$_selectedYear';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.slate900,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            _buildNavButton(
              icon: Icons.chevron_left_rounded,
              onTap: _goToPreviousPeriod,
            ),

            // Period display with tap to show picker
            Expanded(
              child: GestureDetector(
                onTap: () => _showPeriodPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        periodText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isCurrentPeriod) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.teal500.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NOW',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.teal400,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppTheme.slate400,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Next button (disabled if current period)
            _buildNavButton(
              icon: Icons.chevron_right_rounded,
              onTap: isCurrentPeriod ? null : _goToNextPeriod,
              disabled: isCurrentPeriod,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: disabled ? Colors.transparent : AppTheme.slate800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
          color: disabled ? AppTheme.slate700 : AppTheme.slate300,
        ),
      ),
    );
  }

  void _goToPreviousPeriod() {
    setState(() {
      if (_periodType == 'Monthly') {
        if (_selectedMonth == 1) {
          _selectedMonth = 12;
          _selectedYear--;
        } else {
          _selectedMonth--;
        }
      } else {
        _selectedYear--;
      }
    });
  }

  void _goToNextPeriod() {
    final now = DateTime.now();
    setState(() {
      if (_periodType == 'Monthly') {
        if (_selectedMonth == 12) {
          if (_selectedYear < now.year) {
            _selectedMonth = 1;
            _selectedYear++;
          }
        } else {
          if (_selectedYear < now.year || _selectedMonth < now.month) {
            _selectedMonth++;
          }
        }
      } else {
        if (_selectedYear < now.year) {
          _selectedYear++;
        }
      }
    });
  }

  void _showPeriodPicker(BuildContext context) {
    final now = DateTime.now();
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: AppTheme.slate900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.slate700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _periodType == 'Monthly' ? 'SELECT MONTH' : 'SELECT YEAR',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppTheme.slate400),
                    ),
                  ],
                ),
              ),

              if (_periodType == 'Monthly') ...[
                // Year selector for monthly view
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setSheetState(() => _selectedYear--);
                        },
                        icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.slate300),
                      ),
                      Text(
                        '$_selectedYear',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: _selectedYear < now.year
                            ? () {
                                setSheetState(() => _selectedYear++);
                              }
                            : null,
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: _selectedYear < now.year ? AppTheme.slate300 : AppTheme.slate700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Month grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = month == _selectedMonth && _selectedYear == _selectedYear;
                      final isFuture = _selectedYear == now.year && month > now.month;
                      final isCurrent = month == now.month && _selectedYear == now.year;

                      return GestureDetector(
                        onTap: isFuture
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedMonth = month;
                                });
                                setSheetState(() {});
                                Navigator.pop(context);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.teal500
                                : isFuture
                                    ? AppTheme.slate800.withOpacity(0.3)
                                    : AppTheme.slate800,
                            borderRadius: BorderRadius.circular(16),
                            border: isCurrent && !isSelected
                                ? Border.all(color: AppTheme.teal500.withOpacity(0.5), width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              monthNames[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isFuture
                                    ? AppTheme.slate600
                                    : isSelected
                                        ? Colors.white
                                        : AppTheme.slate300,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Year list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: 5, // Show last 5 years
                    itemBuilder: (context, index) {
                      final year = now.year - index;
                      final isSelected = year == _selectedYear;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedYear = year;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.teal500 : AppTheme.slate800,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '$year',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : AppTheme.slate300,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraph(List<FulizaEvent> events) {
    final chartData = _calculateChartData(events);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FuliGraph(data: chartData),
    );
  }

  List<FuliGraphData> _calculateChartData(List<FulizaEvent> events) {
    final data = <FuliGraphData>[];

    if (_periodType == 'Monthly') {
      // Selected month broken into 4 weeks
      final monthStart = DateTime(_selectedYear, _selectedMonth, 1);
      final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;

      for (int week = 1; week <= 4; week++) {
        final weekStart = monthStart.add(Duration(days: (week - 1) * 7));
        final weekEnd = week == 4
            ? DateTime(_selectedYear, _selectedMonth, daysInMonth, 23, 59, 59)
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
    } else {
      // Selected year broken into 12 months
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

      for (int i = 0; i < 12; i++) {
        final monthStart = DateTime(_selectedYear, i + 1, 1);
        final monthEnd = DateTime(_selectedYear, i + 2, 0, 23, 59, 59);

        final monthEvents = events.where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(monthStart) &&
            !e.date.isAfter(monthEnd));
        final total = monthEvents.fold<double>(0, (sum, e) => sum + e.amount);

        data.add(FuliGraphData(
          label: monthNames[i],
          value: total,
        ));
      }
    }

    return data;
  }

  Widget _buildSummaryCards(FulizaSummary summary, List<FulizaEvent> events) {
    final currencyFormat = NumberFormat.currency(symbol: 'Ksh ', decimalDigits: 2);
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Calculate period-specific totals
    final periodInterest = _calculatePeriodInterest(events);
    final periodRepaid = _calculatePeriodRepaid(events);

    // Format subtitle based on period
    final subtitleText = _periodType == 'Monthly'
        ? '${monthNames[_selectedMonth - 1]} $_selectedYear'
        : '$_selectedYear';

    final repaidLabel = _periodType == 'Monthly' ? 'REPAID' : 'REPAID YEAR';

    // Calculate comparison
    final comparison = _calculateInterestComparison(events);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'INTEREST PAID',
              amount: currencyFormat.format(periodInterest),
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
              amount: currencyFormat.format(periodRepaid),
              subtitle: 'View logs',
              icon: Icons.arrow_forward,
              iconColor: AppTheme.slate400,
            ),
          ),
        ],
      ),
    );
  }

  double _calculatePeriodInterest(List<FulizaEvent> events) {
    DateTime start;
    DateTime end;

    if (_periodType == 'Monthly') {
      start = DateTime(_selectedYear, _selectedMonth, 1);
      end = DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
    } else {
      start = DateTime(_selectedYear, 1, 1);
      end = DateTime(_selectedYear, 12, 31, 23, 59, 59);
    }

    return events
        .where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(start) &&
            !e.date.isAfter(end))
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  double _calculatePeriodRepaid(List<FulizaEvent> events) {
    DateTime start;
    DateTime end;

    if (_periodType == 'Monthly') {
      start = DateTime(_selectedYear, _selectedMonth, 1);
      end = DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
    } else {
      start = DateTime(_selectedYear, 1, 1);
      end = DateTime(_selectedYear, 12, 31, 23, 59, 59);
    }

    return events
        .where((e) =>
            e.type == FulizaEventType.repayment &&
            !e.date.isBefore(start) &&
            !e.date.isAfter(end))
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  _InterestComparison _calculateInterestComparison(List<FulizaEvent> events) {
    DateTime currentStart;
    DateTime currentEnd;
    DateTime previousStart;
    DateTime previousEnd;

    if (_periodType == 'Monthly') {
      currentStart = DateTime(_selectedYear, _selectedMonth, 1);
      currentEnd = DateTime(_selectedYear, _selectedMonth + 1, 0, 23, 59, 59);
      // Previous month
      final prevMonth = _selectedMonth == 1 ? 12 : _selectedMonth - 1;
      final prevYear = _selectedMonth == 1 ? _selectedYear - 1 : _selectedYear;
      previousStart = DateTime(prevYear, prevMonth, 1);
      previousEnd = DateTime(prevYear, prevMonth + 1, 0, 23, 59, 59);
    } else {
      currentStart = DateTime(_selectedYear, 1, 1);
      currentEnd = DateTime(_selectedYear, 12, 31, 23, 59, 59);
      previousStart = DateTime(_selectedYear - 1, 1, 1);
      previousEnd = DateTime(_selectedYear - 1, 12, 31, 23, 59, 59);
    }

    final currentInterest = events
        .where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(currentStart) &&
            !e.date.isAfter(currentEnd))
        .fold<double>(0, (sum, e) => sum + e.amount);

    final previousInterest = events
        .where((e) =>
            e.type == FulizaEventType.interest &&
            !e.date.isBefore(previousStart) &&
            !e.date.isAfter(previousEnd))
        .fold<double>(0, (sum, e) => sum + e.amount);

    if (previousInterest == 0) {
      if (currentInterest == 0) {
        return _InterestComparison(trend: 'No change', isDown: true);
      }
      return _InterestComparison(trend: 'New', isDown: false);
    }

    final percentChange = ((currentInterest - previousInterest) / previousInterest * 100).abs();
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

class _InterestComparison {
  final String? trend;
  final bool isDown;

  _InterestComparison({
    required this.trend,
    required this.isDown,
  });
}
