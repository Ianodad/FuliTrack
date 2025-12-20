import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Filter chip row for date filtering
class DateFilterChips extends StatelessWidget {
  final DateFilter currentFilter;
  final ValueChanged<DateFilter> onFilterChanged;
  final VoidCallback? onCustomDateTap;

  const DateFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.onCustomDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'This Week',
            isSelected: currentFilter == DateFilter.thisWeek,
            onTap: () => onFilterChanged(DateFilter.thisWeek),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Month',
            isSelected: currentFilter == DateFilter.thisMonth,
            onTap: () => onFilterChanged(DateFilter.thisMonth),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Year',
            isSelected: currentFilter == DateFilter.thisYear,
            onTap: () => onFilterChanged(DateFilter.thisYear),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'All Time',
            isSelected: currentFilter == DateFilter.allTime,
            onTap: () => onFilterChanged(DateFilter.allTime),
          ),
          if (onCustomDateTap != null) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Custom',
              isSelected: currentFilter == DateFilter.custom,
              onTap: onCustomDateTap!,
              icon: Icons.calendar_month,
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }
}
