/// Types of Fuliza limit records
enum FulizaLimitType {
  /// Official limit increase notification from Safaricom
  increase,
  /// Limit shown after full payment
  fullPayment,
  /// Limit shown after partial payment
  partialPayment,
  /// Initial opt-in limit
  optIn,
}

/// Represents a Fuliza limit record
class FulizaLimit {
  final int? id;
  final FulizaLimitType type;
  final double limit;
  final DateTime date;
  final String? transactionId;
  final String rawSms;
  final double? previousLimit; // For tracking increases

  FulizaLimit({
    this.id,
    required this.type,
    required this.limit,
    required this.date,
    this.transactionId,
    required this.rawSms,
    this.previousLimit,
  });

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'limit_amount': limit,
      'date': date.millisecondsSinceEpoch,
      'transaction_id': transactionId,
      'raw_sms': rawSms,
      'previous_limit': previousLimit,
    };
  }

  /// Create from database Map
  factory FulizaLimit.fromMap(Map<String, dynamic> map) {
    return FulizaLimit(
      id: map['id'] as int?,
      type: FulizaLimitType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FulizaLimitType.fullPayment,
      ),
      limit: (map['limit_amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      transactionId: map['transaction_id'] as String?,
      rawSms: map['raw_sms'] as String,
      previousLimit: map['previous_limit'] != null
          ? (map['previous_limit'] as num).toDouble()
          : null,
    );
  }

  FulizaLimit copyWith({
    int? id,
    FulizaLimitType? type,
    double? limit,
    DateTime? date,
    String? transactionId,
    String? rawSms,
    double? previousLimit,
  }) {
    return FulizaLimit(
      id: id ?? this.id,
      type: type ?? this.type,
      limit: limit ?? this.limit,
      date: date ?? this.date,
      transactionId: transactionId ?? this.transactionId,
      rawSms: rawSms ?? this.rawSms,
      previousLimit: previousLimit ?? this.previousLimit,
    );
  }

  /// Calculate increase amount from previous limit
  double get increaseAmount {
    if (previousLimit == null) return 0;
    return limit - previousLimit!;
  }

  /// Calculate increase percentage from previous limit
  double get increasePercentage {
    if (previousLimit == null || previousLimit == 0) return 0;
    return ((limit - previousLimit!) / previousLimit!) * 100;
  }

  @override
  String toString() {
    return 'FulizaLimit(id: $id, type: $type, limit: $limit, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FulizaLimit &&
        other.limit == limit &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day &&
        other.type == type;
  }

  @override
  int get hashCode => limit.hashCode ^ date.hashCode ^ type.hashCode;
}
