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
      throw SmsPermissionException('SMS permission not granted');
    }

    try {
      final messages = await _query.getAllSms;
      return messages;
    } catch (e) {
      throw SmsReadException('Failed to read SMS: $e');
    }
  }

  /// Fetch SMS messages from M-PESA / Safaricom only
  Future<List<SmsMessage>> getMpesaSms() async {
    final allSms = await getAllSms();

    return allSms.where((sms) {
      final sender = (sms.address ?? '').toUpperCase();
      // M-PESA messages typically come from these senders
      return sender.contains('MPESA') ||
          sender.contains('M-PESA') ||
          sender.contains('SAFARICOM') ||
          sender == 'MPESA';
    }).toList();
  }

  /// Fetch and parse Fuliza-specific messages
  Future<List<FulizaEvent>> getFulizaEvents() async {
    final mpesaSms = await getMpesaSms();

    final smsDataList = mpesaSms.map((sms) {
      return SmsData(
        body: sms.body ?? '',
        date: sms.date ?? DateTime.now(),
        sender: sms.address,
      );
    }).toList();

    return SmsParser.parseMultiple(smsDataList);
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
