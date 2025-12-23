import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/models.dart';
import 'sms_parser.dart';

/// Service for accessing device SMS messages
class SmsService {
  final SmsQuery _query = SmsQuery();

  /// Check if SMS permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Request SMS permission from user
  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Get permission status with detailed info
  Future<PermissionStatus> getPermissionStatus() async {
    return Permission.sms.status;
  }

  /// Fetch all SMS messages from device
  Future<List<SmsMessage>> getAllSms() async {
    if (!await hasPermission()) {
      debugPrint('❌ SMS permission not granted');
      throw SmsPermissionException('SMS permission not granted');
    }

    try {
      debugPrint('📱 Reading all SMS messages...');
      final messages = await _query.getAllSms;
      debugPrint('✅ Found ${messages.length} total SMS messages');
      return messages;
    } catch (e) {
      debugPrint('❌ Failed to read SMS: $e');
      throw SmsReadException('Failed to read SMS: $e');
    }
  }

  /// Fetch SMS messages from M-PESA / Safaricom only
  Future<List<SmsMessage>> getMpesaSms() async {
    final allSms = await getAllSms();

    debugPrint('🔍 Filtering for M-PESA messages...');
    final mpesaMessages = allSms.where((sms) {
      final sender = (sms.address ?? '').toUpperCase();
      // M-PESA messages typically come from these senders
      return sender.contains('MPESA') ||
          sender.contains('M-PESA') ||
          sender.contains('SAFARICOM') ||
          sender == 'MPESA';
    }).toList();

    debugPrint('✅ Found ${mpesaMessages.length} M-PESA messages');

    // Print first few senders for debugging
    if (mpesaMessages.isNotEmpty) {
      final senders = mpesaMessages
          .take(5)
          .map((sms) => sms.address ?? 'Unknown')
          .toSet()
          .join(', ');
      debugPrint('📬 M-PESA senders: $senders');
    }

    return mpesaMessages;
  }

  /// Fetch and parse Fuliza-specific messages
  Future<List<FulizaEvent>> getFulizaEvents() async {
    debugPrint('\n🔎 Starting Fuliza event extraction...');
    final mpesaSms = await getMpesaSms();

    // Filter Fuliza messages
    int fulizaCount = 0;
    final smsDataList = <SmsData>[];

    for (final sms in mpesaSms) {
      final body = sms.body ?? '';
      if (SmsParser.isFulizaMessage(body)) {
        fulizaCount++;
        smsDataList.add(SmsData(
          body: body,
          date: sms.date ?? DateTime.now(),
          sender: sms.address,
        ));

        // Print first Fuliza message for debugging
        if (fulizaCount == 1) {
          debugPrint('📋 Sample Fuliza message:');
          debugPrint('   From: ${sms.address}');
          debugPrint('   Date: ${sms.date}');
          debugPrint('   Body: ${body.substring(0, body.length > 100 ? 100 : body.length)}...');
        }
      }
    }

    debugPrint('✅ Found $fulizaCount Fuliza messages');

    if (smsDataList.isEmpty) {
      debugPrint('⚠️  No Fuliza messages found to parse');
      return [];
    }

    debugPrint('🔄 Parsing Fuliza messages...');
    final events = SmsParser.parseMultiple(smsDataList);
    debugPrint('✅ Parsed ${events.length} Fuliza events');

    if (events.isNotEmpty) {
      debugPrint('📊 Event types:');
      final loans = events.where((e) => e.type == FulizaEventType.loan).length;
      final repayments = events.where((e) => e.type == FulizaEventType.repayment).length;
      final interests = events.where((e) => e.type == FulizaEventType.interest).length;
      debugPrint('   - Loans: $loans');
      debugPrint('   - Repayments: $repayments');
      debugPrint('   - Interest: $interests');
    }

    return events;
  }

  /// Get SMS count for debugging
  Future<int> getSmsCount() async {
    final messages = await getAllSms();
    return messages.length;
  }

  /// Get Fuliza SMS count for debugging
  Future<int> getFulizaSmsCount() async {
    final mpesaSms = await getMpesaSms();
    int count = 0;

    for (final sms in mpesaSms) {
      if (sms.body != null && SmsParser.isFulizaMessage(sms.body!)) {
        count++;
      }
    }

    return count;
  }

  /// Fetch and parse Fuliza limit messages
  Future<List<FulizaLimit>> getFulizaLimits() async {
    debugPrint('\n🔎 Starting Fuliza limit extraction...');
    final mpesaSms = await getMpesaSms();

    // Convert to SmsData for parsing
    final smsDataList = mpesaSms.map((sms) => SmsData(
      body: sms.body ?? '',
      date: sms.date ?? DateTime.now(),
      sender: sms.address,
    )).toList();

    // Parse limit messages
    final limits = FulizaLimitParser.parseMultiple(smsDataList);

    if (limits.isNotEmpty) {
      debugPrint('📊 Limit types:');
      final increases = limits.where((l) => l.type == FulizaLimitType.increase).length;
      final fullPayments = limits.where((l) => l.type == FulizaLimitType.fullPayment).length;
      final partialPayments = limits.where((l) => l.type == FulizaLimitType.partialPayment).length;
      debugPrint('   - Increases: $increases');
      debugPrint('   - Full Payments: $fullPayments');
      debugPrint('   - Partial Payments: $partialPayments');

      final latest = FulizaLimitParser.getLatestLimit(limits);
      if (latest != null) {
        debugPrint('💳 Current limit: Ksh ${latest.limit}');
      }
    }

    return limits;
  }
}

/// Exception thrown when SMS permission is not granted
class SmsPermissionException implements Exception {
  final String message;
  SmsPermissionException(this.message);

  @override
  String toString() => 'SmsPermissionException: $message';
}

/// Exception thrown when SMS reading fails
class SmsReadException implements Exception {
  final String message;
  SmsReadException(this.message);

  @override
  String toString() => 'SmsReadException: $message';
}
