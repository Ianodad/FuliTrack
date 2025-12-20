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

  // Pattern 1: Fuliza loan with interest
  // "SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. Interest charged Ksh 14.44. Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24."
  static final RegExp _loanWithInterestPattern = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.\s*Fuliza M-PESA amount is Ksh\s*([\d,]+\.?\d*)\.\s*Interest charged Ksh\s*([\d,]+\.?\d*)\.\s*Total Fuliza M-PESA outstanding amount is Ksh\s*([\d,]+\.?\d*)\s*due on\s*(\d{2}/\d{2}/\d{2})',
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
    return lowerMessage.contains('fuliza') &&
        (lowerMessage.contains('m-pesa') || lowerMessage.contains('mpesa'));
  }

  /// Parse an SMS message and extract Fuliza events
  static SmsParseResult parse(String message, DateTime smsDate) {
    // First check if this is a Fuliza message
    if (!isFulizaMessage(message)) {
      return SmsParseResult.notFuliza();
    }

    final events = <FulizaEvent>[];
    final cleanMessage = _cleanMessage(message);

    // Try to match loan with interest pattern
    final loanMatch = _loanWithInterestPattern.firstMatch(cleanMessage);
    if (loanMatch != null) {
      final reference = loanMatch.group(1)!;
      final loanAmount = _parseAmount(loanMatch.group(2)!);
      final interestAmount = _parseAmount(loanMatch.group(3)!);
      final outstandingAmount = _parseAmount(loanMatch.group(4)!);
      final dueDate = _parseDate(loanMatch.group(5)!);
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
    final fullRepayMatch = _fullRepaymentPattern.firstMatch(cleanMessage);
    if (fullRepayMatch != null) {
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
    final partialRepayMatch = _partialRepaymentPattern.firstMatch(cleanMessage);
    if (partialRepayMatch != null) {
      final reference = partialRepayMatch.group(1)!;
      final repaymentAmount = _parseAmount(partialRepayMatch.group(2)!);
      final outstandingAmount = partialRepayMatch.group(3) != null
          ? _parseAmount(partialRepayMatch.group(3)!)
          : null;
      final dueDate = partialRepayMatch.group(4) != null
          ? _parseDate(partialRepayMatch.group(4)!)
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

  /// Parse date string in DD/MM/YY format
  static DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        var year = int.parse(parts[2]);
        // Convert 2-digit year to 4-digit
        if (year < 100) {
          year += 2000;
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
