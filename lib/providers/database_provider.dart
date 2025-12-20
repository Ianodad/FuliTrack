import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';

/// Provider for database service (singleton)
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider for SMS service (singleton)
final smsServiceProvider = Provider<SmsService>((ref) {
  return SmsService();
});
