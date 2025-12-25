import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'sms_parser.dart';

/// Service for accessing device SMS messages
class SmsService {
  final SmsQuery _query = SmsQuery();

  /// Check if SMS permission is granted
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.sms.status;
      return status.isGranted;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to check SMS permission', e, stackTrace);
      return false;
    }
  }

  /// Request SMS permission from user
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.sms.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to request SMS permission', e, stackTrace);
      return false;
    }
  }

  /// Get permission status with detailed info
  Future<PermissionStatus> getPermissionStatus() async {
    try {
      return await Permission.sms.status;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get SMS permission status', e, stackTrace);
      return PermissionStatus.denied;
    }
  }

  /// Fetch all SMS messages from device
  Future<List<SmsMessage>> getAllSms() async {
    if (!await hasPermission()) {
      AppLogger.e('SMS permission not granted');
      throw SmsPermissionException('SMS permission not granted');
    }

    try {
      AppLogger.d('Reading all SMS messages...');
      final messages = await _query.getAllSms;
      AppLogger.d('Found ${messages.length} total SMS messages');
      return messages;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to read SMS', e, stackTrace);
      throw SmsReadException('Failed to read SMS: $e');
    }
  }

  /// Fetch SMS messages from M-PESA / Safaricom only
  Future<List<SmsMessage>> getMpesaSms() async {
    try {
      final allSms = await getAllSms();

      AppLogger.d('Filtering for M-PESA messages...');
      final mpesaMessages = allSms.where((sms) {
        final sender = (sms.address ?? '').toUpperCase();
        // M-PESA messages typically come from these senders
        return sender.contains('MPESA') ||
            sender.contains('M-PESA') ||
            sender.contains('SAFARICOM') ||
            sender == 'MPESA';
      }).toList();

      AppLogger.d('Found ${mpesaMessages.length} M-PESA messages');

      if (mpesaMessages.isNotEmpty) {
        final senders = mpesaMessages
            .take(5)
            .map((sms) => sms.address ?? 'Unknown')
            .toSet()
            .join(', ');
        AppLogger.d('M-PESA senders: $senders');
      }

      return mpesaMessages;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get M-PESA messages', e, stackTrace);
      rethrow;
    }
  }

  /// Fetch and parse Fuliza-specific messages
  Future<List<FulizaEvent>> getFulizaEvents() async {
    try {
      AppLogger.d('Starting Fuliza event extraction...');
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

          // Log first Fuliza message for debugging
          if (fulizaCount == 1) {
            AppLogger.d('Sample Fuliza message from: ${sms.address}, Date: ${sms.date}');
          }
        }
      }

      AppLogger.d('Found $fulizaCount Fuliza messages');

      if (smsDataList.isEmpty) {
        AppLogger.w('No Fuliza messages found to parse');
        return [];
      }

      AppLogger.d('Parsing Fuliza messages...');
      final events = SmsParser.parseMultiple(smsDataList);
      AppLogger.d('Parsed ${events.length} Fuliza events');

      if (events.isNotEmpty) {
        final loans = events.where((e) => e.type == FulizaEventType.loan).length;
        final repayments = events.where((e) => e.type == FulizaEventType.repayment).length;
        final interests = events.where((e) => e.type == FulizaEventType.interest).length;
        AppLogger.d('Event types - Loans: $loans, Repayments: $repayments, Interest: $interests');
      }

      return events;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get Fuliza events', e, stackTrace);
      rethrow;
    }
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
    try {
      AppLogger.d('Starting Fuliza limit extraction...');
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
        final increases = limits.where((l) => l.type == FulizaLimitType.increase).length;
        final fullPayments = limits.where((l) => l.type == FulizaLimitType.fullPayment).length;
        final partialPayments = limits.where((l) => l.type == FulizaLimitType.partialPayment).length;
        AppLogger.d('Limit types - Increases: $increases, Full Payments: $fullPayments, Partial Payments: $partialPayments');

        final latest = FulizaLimitParser.getLatestLimit(limits);
        if (latest != null) {
          AppLogger.d('Current limit: Ksh ${latest.limit}');
        }
      }

      return limits;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get Fuliza limits', e, stackTrace);
      rethrow;
    }
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
