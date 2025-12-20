import 'package:intl/intl.dart';

/// Types of Fuliza events that can be parsed from M-PESA SMS
enum FulizaEventType {
  loan,
  interest,
  repayment,
}

/// Represents a single Fuliza transaction event
class FulizaEvent {
  final int? id;
  final FulizaEventType type;
  final double amount;
  final DateTime date;
  final String reference;
  final String rawSms;
  final String periodKey; // e.g., "2024-W18" or "2024-05"
  final DateTime? dueDate;
  final double? outstandingBalance;

  FulizaEvent({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.reference,
    required this.rawSms,
    required this.periodKey,
    this.dueDate,
    this.outstandingBalance,
  });

  /// Generate period key for weekly aggregation (ISO week)
  static String generateWeeklyKey(DateTime date) {
    final weekNumber = _getIsoWeekNumber(date);
    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Generate period key for monthly aggregation
  static String generateMonthlyKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  /// Generate period key for yearly aggregation
  static String generateYearlyKey(DateTime date) {
    return date.year.toString();
  }

  static int _getIsoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final weekday = date.weekday;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'reference': reference,
      'raw_sms': rawSms,
      'period_key': periodKey,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'outstanding_balance': outstandingBalance,
    };
  }

  /// Create from database Map
  factory FulizaEvent.fromMap(Map<String, dynamic> map) {
    return FulizaEvent(
      id: map['id'] as int?,
      type: FulizaEventType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      reference: map['reference'] as String,
      rawSms: map['raw_sms'] as String,
      periodKey: map['period_key'] as String,
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
          : null,
      outstandingBalance: map['outstanding_balance'] != null
          ? (map['outstanding_balance'] as num).toDouble()
          : null,
    );
  }

  FulizaEvent copyWith({
    int? id,
    FulizaEventType? type,
    double? amount,
    DateTime? date,
    String? reference,
    String? rawSms,
    String? periodKey,
    DateTime? dueDate,
    double? outstandingBalance,
  }) {
    return FulizaEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      rawSms: rawSms ?? this.rawSms,
      periodKey: periodKey ?? this.periodKey,
      dueDate: dueDate ?? this.dueDate,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
    );
  }

  @override
  String toString() {
    return 'FulizaEvent(id: $id, type: $type, amount: $amount, date: $date, reference: $reference)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FulizaEvent &&
        other.reference == reference &&
        other.type == type &&
        other.amount == amount;
  }

  @override
  int get hashCode => reference.hashCode ^ type.hashCode ^ amount.hashCode;
}
