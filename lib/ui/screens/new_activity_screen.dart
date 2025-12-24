import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Activity screen with premium design and transaction list
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'LOG HISTORY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.slate900,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Filters
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: ['All', 'Loan', 'Repayment', 'Interest'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedFilter != filter) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedFilter = filter);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryTeal
                                : AppTheme.slate100,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppTheme.primaryTeal.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          '${filter}s'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.slate400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Transaction List
            Expanded(
              child: () {
                final filtered = _filterEvents(events);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppTheme.slate300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: AppTheme.slate400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
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

            // Bottom padding for floating nav
            const SizedBox(height: 100),
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
    final currencyFormat =
        NumberFormat.currency(symbol: 'Ksh ', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    final isLoan = event.type == FulizaEventType.loan;
    final isRepayment = event.type == FulizaEventType.repayment;

    Color iconBg;
    Color iconColor;
    IconData icon;

    if (isLoan) {
      iconBg = AppTheme.amber50;
      iconColor = AppTheme.secondaryAmber;
      icon = Icons.arrow_downward_rounded;
    } else if (isRepayment) {
      iconBg = AppTheme.teal50;
      iconColor = AppTheme.teal600;
      icon = Icons.arrow_upward_rounded;
    } else {
      iconBg = AppTheme.amber50;
      iconColor = AppTheme.secondaryAmber;
      icon = Icons.percent_rounded;
    }

    return TappableCard(
      onTap: onTap,
      scaleFactor: 0.98,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(16),
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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.slate800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              currencyFormat.format(event.amount),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
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
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate400,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (isLoan && event.amount > 0)
                              Text(
                                'Interest: ${currencyFormat.format(event.amount * 0.01)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.amber500,
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
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.slate300,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.slate50,
                border: Border(
                  top: BorderSide(color: AppTheme.slate100),
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'REFERENCE: ${event.reference}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.slate400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Copy reference
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Reference copied'),
                              backgroundColor: AppTheme.slate800,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'COPY REF',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.teal600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: Text(
                      '"${event.rawSms.length > 150 ? event.rawSms.substring(0, 150) + '...' : event.rawSms}"',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.slate500,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
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
  }
}
