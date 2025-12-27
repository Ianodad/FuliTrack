import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

/// Manages unique notification IDs to prevent collisions
class NotificationIdManager {
  static const String _counterKey = 'notification_id_counter';
  static const String _mappingPrefix = 'notification_id_map_';

  /// Get next available notification ID
  static Future<int> getNextId() async {
    final prefs = await SharedPreferences.getInstance();
    final currentId = prefs.getInt(_counterKey) ?? 1000; // Start from 1000
    final nextId = currentId + 1;
    await prefs.setInt(_counterKey, nextId);
    AppLogger.d('Generated notification ID: $nextId');
    return nextId;
  }

  /// Get or create notification ID for a specific reference
  static Future<int> getIdForReference(String reference) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_mappingPrefix$reference';

    // Check if we already have an ID for this reference
    int? existingId = prefs.getInt(key);

    if (existingId != null) {
      AppLogger.d('Reusing notification ID $existingId for reference: $reference');
      return existingId;
    }

    // Generate new ID and store mapping
    final newId = await getNextId();
    await prefs.setInt(key, newId);
    AppLogger.d('Created new notification ID $newId for reference: $reference');
    return newId;
  }

  /// Clear notification ID mapping for a reference (when notification is no longer needed)
  static Future<void> clearIdForReference(String reference) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_mappingPrefix$reference';
    await prefs.remove(key);
    AppLogger.d('Cleared notification ID mapping for reference: $reference');
  }
}
