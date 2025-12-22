import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Activity screen with transaction list and filters
class NewActivityScreen extends ConsumerStatefulWidget {
  const NewActivityScreen({super.key});

  @override
  ConsumerState<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends ConsumerState<NewActivityScreen> {
  String _selectedFilter = 'All';
  int? _expandedId;

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(fulizaProvider).events;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate800,
                ),
              ),
            ),

            // Filters
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['All', 'Loan', 'Repayment', 'Interest'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        '${filter}s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.slate500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryTeal,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryTeal : AppTheme.slate200,
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Transaction List
            Expanded(
              child: () {
                final filtered = _filterEvents(events);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: AppTheme.slate400),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final event = filtered[index];
                    return _TransactionCard(
                      event: event,
                      isExpanded: _expandedId == event.id,
                      onTap: () => setState(() {
                        _expandedId = _expandedId == event.id ? null : event.id;
                      }),
                    );
                  },
                );
              }(),
            ),
          ],
        ),
      ),
    );
  }

  List<FulizaEvent> _filterEvents(List<FulizaEvent> events) {
    if (_selectedFilter == 'All') return events;

    final filterType = _selectedFilter.toLowerCase();
    return events.where((event) => event.type.name == filterType).toList();
  }
}

class _TransactionCard extends StatelessWidget {
  final FulizaEvent event;
  final bool isExpanded;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.event,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Ksh ', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    final isLoan = event.type == FulizaEventType.loan;
    final isRepayment = event.type == FulizaEventType.repayment;
    final isInterest = event.type == FulizaEventType.interest;

    Color iconBg;
    Color iconColor;
    IconData icon;

    if (isLoan) {
      iconBg = AppTheme.amber50;
      iconColor = AppTheme.secondaryAmber;
      icon = Icons.arrow_downward;
    } else if (isRepayment) {
      iconBg = const Color(0xFFDCFCE7);
      iconColor = AppTheme.successGreen;
      icon = Icons.arrow_upward;
    } else {
      iconBg = AppTheme.amber50;
      iconColor = AppTheme.secondaryAmber;
      icon = Icons.percent;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate100),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              event.type.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate800,
                              ),
                            ),
                            Text(
                              currencyFormat.format(event.amount),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormat.format(event.date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.slate400,
                              ),
                            ),
                            if (isLoan && event.amount > 0)
                              Text(
                                'Interest: ${currencyFormat.format(event.amount * 0.01)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.secondaryAmber,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Expand icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.slate300,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(
                  top: BorderSide(color: AppTheme.slate50),
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REF: ${event.reference}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.slate500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.slate100),
                    ),
                    child: Text(
                      '"${event.rawSms.length > 150 ? event.rawSms.substring(0, 150) + '...' : event.rawSms}"',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.slate500,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
