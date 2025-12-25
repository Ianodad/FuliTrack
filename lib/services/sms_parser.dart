import '../utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

/// Result of parsing an SMS message
class SmsParseResult {
  final List<FulizaEvent> events;
  final bool isFulizaMessage;
  final String? error;

  SmsParseResult({
    required this.events,
    required this.isFulizaMessage,
    this.error,
  });

  factory SmsParseResult.notFuliza() {
    return SmsParseResult(events: [], isFulizaMessage: false);
  }

  factory SmsParseResult.success(List<FulizaEvent> events) {
    return SmsParseResult(events: events, isFulizaMessage: true);
  }

  factory SmsParseResult.error(String message) {
    return SmsParseResult(events: [], isFulizaMessage: true, error: message);
  }
}

/// Service for parsing M-PESA Fuliza SMS messages
class SmsParser {
  // Regex patterns for different Fuliza SMS formats

  // Pattern 1: Fuliza loan with interest/access fee
  // "SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. Interest charged Ksh 14.44. Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24."
  // "TKBBB9V6KD Confirmed. Fuliza M-PESA amount is Ksh 39.00. Access Fee charged Ksh 0.39. Total Fuliza M-PESA outstanding amount is Ksh 5862.40 due on 08/12/25."
  // "TD58I1W15G Confirmed. Fuliza M-PESA amount is Ksh 1092.86. Interest charged Ksh 10.93. Total Fuliza M-PESA outstanding amount is Ksh 1103.79 due on 05/05Transaction cost, Ksh0.00."
  static final RegExp _loanWithInterestPattern = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.\s*Fuliza M-PESA amount is Ksh\s*([\d,]+\.?\d*)\.\s*(?:Interest|Access Fee) charged Ksh\s*([\d,]+\.?\d*)\.\s*Total Fuliza M-PESA outstanding amount is Ksh\s*([\d,]+\.?\d*)\s*due on\s*(\d{2}/\d{2}(?:/\d{2})?)',
    caseSensitive: false,
    multiLine: true,
  );

  // Pattern 2: Full repayment
  // "SD36YYPUQM Confirmed. Ksh 1689.12 from your M-PESA has been used to fully pay your outstanding Fuliza M-PESA. Available Fuliza M-PESA limit is Ksh 3000.00."
  static final RegExp _fullRepaymentPattern = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.\s*Ksh\s*([\d,]+\.?\d*)\s*from your M-PESA has been used to fully pay your outstanding Fuliza M-PESA',
    caseSensitive: false,
    multiLine: true,
  );

  // Pattern 3: Partial repayment
  // "SD38YVVQ1A Confirmed. Ksh 500.00 from your M-PESA has been used to partially pay your Fuliza M-PESA. Outstanding Fuliza M-PESA is Ksh 957.83 due on 03/05/24."
  static final RegExp _partialRepaymentPattern = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.\s*Ksh\s*([\d,]+\.?\d*)\s*from your M-PESA has been used to partially pay your (?:outstanding\s+)?Fuliza M-PESA\.\s*(?:Outstanding Fuliza M-PESA is Ksh\s*([\d,]+\.?\d*)\s*due on\s*(\d{2}/\d{2}/\d{2}))?',
    caseSensitive: false,
    multiLine: true,
  );

  // Pattern 4: Fuliza limit restored (informational, not a transaction)
  static final RegExp _limitRestoredPattern = RegExp(
    r'Available Fuliza M-PESA limit is Ksh\s*([\d,]+\.?\d*)',
    caseSensitive: false,
  );

  /// Check if a message is from M-PESA/Safaricom about Fuliza
  static bool isFulizaMessage(String message) {
    final lowerMessage = message.toLowerCase();

    // Must contain 'fuliza' and 'm-pesa'
    if (!lowerMessage.contains('fuliza')) return false;
    if (!lowerMessage.contains('m-pesa') && !lowerMessage.contains('mpesa')) {
      return false;
    }

    // Exclude promotional/informational messages that just mention Fuliza
    // These are NOT actual Fuliza transactions
    final exclusions = [
      'dial *234', // "Dial *234*0# to check your FULIZA LIMIT"
      'to register for fuliza', // "To register for Fuliza dial *234#"
      'opted into fuliza', // "you have successfully opted into Fuliza M-PESA"
      'opted out of fuliza', // "You have successfully Opted Out of Fuliza M-PESA"
      'withdraw your fuliza limit', // "Withdraw your Fuliza limit at any M-Pesa agent"
      'to use fuliza', // "To use Fuliza, transact normally"
      'available fuliza m-pesa limit ksh', // Just showing limit
      'insufficient funds', // Failed transactions
    ];

    for (final exclusion in exclusions) {
      if (lowerMessage.contains(exclusion)) {
        return false;
      }
    }

    // Must contain transaction-specific keywords
    final transactionKeywords = [
      'fuliza m-pesa amount is', // Loan transaction
      'to fully pay your outstanding fuliza', // Full repayment
      'to partially pay your', // Partial repayment
      'fuliza m-pesa outstanding amount', // Loan with outstanding
    ];

    return transactionKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Parse an SMS message and extract Fuliza events
  static SmsParseResult parse(String message, DateTime smsDate) {
    // First check if this is a Fuliza message
    if (!isFulizaMessage(message)) {
      return SmsParseResult.notFuliza();
    }

    AppLogger.d('Parsing Fuliza message...');
    final events = <FulizaEvent>[];
    final cleanMessage = _cleanMessage(message);

    // Try to match loan with interest pattern
    AppLogger.d('Trying loan pattern...');
    final loanMatch = _loanWithInterestPattern.firstMatch(cleanMessage);
    if (loanMatch != null) {
      AppLogger.d('Matched loan pattern!');
      final reference = loanMatch.group(1)!;
      final loanAmount = _parseAmount(loanMatch.group(2)!);
      final interestAmount = _parseAmount(loanMatch.group(3)!);
      final outstandingAmount = _parseAmount(loanMatch.group(4)!);
      final dueDate = _parseDate(loanMatch.group(5)!, smsDate);
      final periodKey = FulizaEvent.generateMonthlyKey(smsDate);

      // Add loan event
      events.add(FulizaEvent(
        type: FulizaEventType.loan,
        amount: loanAmount,
        date: smsDate,
        reference: reference,
        rawSms: message,
        periodKey: periodKey,
        dueDate: dueDate,
        outstandingBalance: outstandingAmount,
      ));

      // Add interest event
      events.add(FulizaEvent(
        type: FulizaEventType.interest,
        amount: interestAmount,
        date: smsDate,
        reference: '${reference}_INT',
        rawSms: message,
        periodKey: periodKey,
        dueDate: dueDate,
        outstandingBalance: outstandingAmount,
      ));

      return SmsParseResult.success(events);
    }

    // Try to match full repayment pattern
    AppLogger.d('Trying full repayment pattern...');
    final fullRepayMatch = _fullRepaymentPattern.firstMatch(cleanMessage);
    if (fullRepayMatch != null) {
      AppLogger.d('Matched full repayment pattern!');
      final reference = fullRepayMatch.group(1)!;
      final repaymentAmount = _parseAmount(fullRepayMatch.group(2)!);
      final periodKey = FulizaEvent.generateMonthlyKey(smsDate);

      events.add(FulizaEvent(
        type: FulizaEventType.repayment,
        amount: repaymentAmount,
        date: smsDate,
        reference: reference,
        rawSms: message,
        periodKey: periodKey,
        outstandingBalance: 0,
      ));

      return SmsParseResult.success(events);
    }

    // Try to match partial repayment pattern
    AppLogger.d('Trying partial repayment pattern...');
    final partialRepayMatch = _partialRepaymentPattern.firstMatch(cleanMessage);
    if (partialRepayMatch != null) {
      AppLogger.d('Matched partial repayment pattern!');
      final reference = partialRepayMatch.group(1)!;
      final repaymentAmount = _parseAmount(partialRepayMatch.group(2)!);
      final outstandingAmount = partialRepayMatch.group(3) != null
          ? _parseAmount(partialRepayMatch.group(3)!)
          : null;
      final dueDate = partialRepayMatch.group(4) != null
          ? _parseDate(partialRepayMatch.group(4)!, smsDate)
          : null;
      final periodKey = FulizaEvent.generateMonthlyKey(smsDate);

      events.add(FulizaEvent(
        type: FulizaEventType.repayment,
        amount: repaymentAmount,
        date: smsDate,
        reference: reference,
        rawSms: message,
        periodKey: periodKey,
        dueDate: dueDate,
        outstandingBalance: outstandingAmount,
      ));

      return SmsParseResult.success(events);
    }

    // Message contains Fuliza but couldn't parse it
    if (events.isEmpty) {
      AppLogger.d('No pattern matched!');
      AppLogger.d('Message (cleaned): $cleanMessage');
      return SmsParseResult.error('Could not parse Fuliza message format');
    }

    return SmsParseResult.success(events);
  }

  /// Clean up message (remove extra whitespace, normalize line breaks)
  static String _cleanMessage(String message) {
    return message
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
  }

  /// Parse amount string to double (handles comma formatting)
  static double _parseAmount(String amountStr) {
    final cleaned = amountStr.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Parse date string in DD/MM/YY or DD/MM format
  /// If year is missing, uses the year from smsDate
  static DateTime? _parseDate(String dateStr, [DateTime? smsDate]) {
    try {
      final parts = dateStr.split('/');
      if (parts.length >= 2) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        var year = smsDate?.year ?? DateTime.now().year;

        // If year is provided in the date string, use it
        if (parts.length == 3) {
          year = int.parse(parts[2]);
          // Convert 2-digit year to 4-digit
          if (year < 100) {
            year += 2000;
          }
        }

        return DateTime(year, month, day);
      }
    } catch (e) {
      // Return null on parse error
    }
    return null;
  }

  /// Parse multiple SMS messages and extract all Fuliza events
  static List<FulizaEvent> parseMultiple(List<SmsData> messages) {
    final allEvents = <FulizaEvent>[];
    final seenReferences = <String>{};

    for (final sms in messages) {
      final result = parse(sms.body, sms.date);
      if (result.isFulizaMessage && result.events.isNotEmpty) {
        for (final event in result.events) {
          // Avoid duplicates by checking reference
          if (!seenReferences.contains(event.reference)) {
            seenReferences.add(event.reference);
            allEvents.add(event);
          }
        }
      }
    }

    return allEvents;
  }
}

/// Simple SMS data class for parsing
class SmsData {
  final String body;
  final DateTime date;
  final String? sender;

  SmsData({
    required this.body,
    required this.date,
    this.sender,
  });
}

/// Service for parsing Fuliza limit messages
class FulizaLimitParser {
  // Pattern 1: Limit increase notification from Safaricom
  // "Dear IAN, your Fuliza M-PESA limit is KSH 8000.00. Keep using M-PESA to grow your limit."
  static final RegExp _limitIncreasePattern = RegExp(
    r'Dear\s+\w+,\s+your\s+Fuliza\s+M-PESA\s+limit\s+is\s+KSH?\s*([\d,]+\.?\d*)\.\s*Keep\s+using\s+M-PESA\s+to\s+grow\s+your\s+limit',
    caseSensitive: false,
  );

  // Pattern 2: Limit shown after full payment
  // "TKTBBI22A Confirmed. Ksh 1432.10 from your M-PESA has been used to fully pay your outstanding Fuliza M-PESA. Available Fuliza M-PESA limit is Ksh 8000.00."
  static final RegExp _fullPaymentLimitPattern = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.\s*Ksh\s*([\d,]+\.?\d*)\s*from your M-PESA has been used to fully pay.*?(?:Available Fuliza M-PESA limit is|Your available Fuliza M-PESA limit is)\s*Ksh\s*([\d,]+\.?\d*)',
    caseSensitive: false,
    multiLine: true,
  );

  // Pattern 3: Limit shown after partial payment
  // "SFF9LYPELJ Confirmed. Ksh 2000.00 from your M-PESA has been used to partially pay your outstanding Fuliza M-PESA. Your available Fuliza M-PESA limit is Ksh 2856.17."
  static final RegExp _partialPaymentLimitPattern = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.\s*Ksh\s*([\d,]+\.?\d*)\s*from your M-PESA has been used to partially pay.*?(?:Available Fuliza M-PESA limit is|Your available Fuliza M-PESA limit is)\s*Ksh\s*([\d,]+\.?\d*)',
    caseSensitive: false,
    multiLine: true,
  );

  // Pattern 4: Opt-in message
  // "Dear IAN, you have successfully opted into Fuliza M-PESA. Enjoy limit of Ksh 0.00 at an Access fee of 1%..."
  static final RegExp _optInPattern = RegExp(
    r'Dear\s+(\w+),\s+you\s+have\s+successfully\s+opted\s+into\s+Fuliza\s+M-PESA\.\s+Enjoy\s+limit\s+of\s+Ksh\s*([\d,]+\.?\d*)',
    caseSensitive: false,
  );

  /// Check if a message is a Fuliza limit-related message
  static bool isLimitMessage(String message) {
    final lowerMessage = message.toLowerCase();
    if (!lowerMessage.contains('fuliza')) return false;

    return lowerMessage.contains('your fuliza m-pesa limit is') ||
        lowerMessage.contains('available fuliza m-pesa limit is') ||
        lowerMessage.contains('your available fuliza m-pesa limit is') ||
        lowerMessage.contains('opted into fuliza m-pesa');
  }

  /// Parse a single SMS message for limit information
  static FulizaLimit? parseLimit(String message, DateTime smsDate) {
    final cleanMessage = message
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();

    // Try limit increase notification pattern
    final increaseMatch = _limitIncreasePattern.firstMatch(cleanMessage);
    if (increaseMatch != null) {
      final limit = _parseAmount(increaseMatch.group(1)!);
      AppLogger.d('Matched limit increase: Ksh $limit');
      return FulizaLimit(
        type: FulizaLimitType.increase,
        limit: limit,
        date: smsDate,
        rawSms: message,
      );
    }

    // Try full payment limit pattern
    final fullPayMatch = _fullPaymentLimitPattern.firstMatch(cleanMessage);
    if (fullPayMatch != null) {
      final transactionId = fullPayMatch.group(1)!;
      final limit = _parseAmount(fullPayMatch.group(3)!);
      AppLogger.d('Matched full payment limit: Ksh $limit ($transactionId)');
      return FulizaLimit(
        type: FulizaLimitType.fullPayment,
        limit: limit,
        date: smsDate,
        transactionId: transactionId,
        rawSms: message,
      );
    }

    // Try partial payment limit pattern
    final partialPayMatch = _partialPaymentLimitPattern.firstMatch(cleanMessage);
    if (partialPayMatch != null) {
      final transactionId = partialPayMatch.group(1)!;
      final limit = _parseAmount(partialPayMatch.group(3)!);
      AppLogger.d('Matched partial payment limit: Ksh $limit ($transactionId)');
      return FulizaLimit(
        type: FulizaLimitType.partialPayment,
        limit: limit,
        date: smsDate,
        transactionId: transactionId,
        rawSms: message,
      );
    }

    // Try opt-in pattern
    final optInMatch = _optInPattern.firstMatch(cleanMessage);
    if (optInMatch != null) {
      final limit = _parseAmount(optInMatch.group(2)!);
      AppLogger.d('Matched opt-in limit: Ksh $limit');
      return FulizaLimit(
        type: FulizaLimitType.optIn,
        limit: limit,
        date: smsDate,
        rawSms: message,
      );
    }

    return null;
  }

  /// Parse multiple SMS messages and extract all limit records
  static List<FulizaLimit> parseMultiple(List<SmsData> messages) {
    final limits = <FulizaLimit>[];
    final seenLimits = <String>{};

    AppLogger.d('Parsing Fuliza limit messages...');
    int limitMessagesFound = 0;

    for (final sms in messages) {
      if (isLimitMessage(sms.body)) {
        limitMessagesFound++;
        final limit = parseLimit(sms.body, sms.date);
        if (limit != null) {
          // Create unique key to avoid duplicates
          final key = '${limit.limit}_${limit.date.year}${limit.date.month}${limit.date.day}_${limit.type.name}';
          if (!seenLimits.contains(key)) {
            seenLimits.add(key);
            limits.add(limit);
          }
        }
      }
    }

    AppLogger.d('Found $limitMessagesFound limit messages, parsed ${limits.length} unique limits');

    // Sort by date ascending to calculate previous limits
    limits.sort((a, b) => a.date.compareTo(b.date));

    // Calculate previous limits for increase type
    final processedLimits = <FulizaLimit>[];
    double? lastIncreaseLimit;

    for (final limit in limits) {
      if (limit.type == FulizaLimitType.increase) {
        if (lastIncreaseLimit != null && limit.limit > lastIncreaseLimit) {
          processedLimits.add(limit.copyWith(previousLimit: lastIncreaseLimit));
        } else {
          processedLimits.add(limit);
        }
        lastIncreaseLimit = limit.limit;
      } else {
        processedLimits.add(limit);
      }
    }

    return processedLimits;
  }

  /// Get the current (latest) Fuliza limit
  static FulizaLimit? getLatestLimit(List<FulizaLimit> limits) {
    if (limits.isEmpty) return null;

    // Sort by date descending and return the first one
    final sorted = List<FulizaLimit>.from(limits)
      ..sort((a, b) => b.date.compareTo(a.date));

    return sorted.first;
  }

  /// Get all limit increases (sorted chronologically)
  static List<FulizaLimit> getLimitIncreases(List<FulizaLimit> limits) {
    return limits
        .where((l) => l.type == FulizaLimitType.increase)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static double _parseAmount(String amountStr) {
    final cleaned = amountStr.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
