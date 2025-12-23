import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'database_provider.dart';

/// State for Fuliza data
class FulizaState {
  final List<FulizaEvent> events;
  final FulizaSummary summary;
  final bool isLoading;
  final String? error;
  final DateFilter currentFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  FulizaState({
    this.events = const [],
    FulizaSummary? summary,
    this.isLoading = false,
    this.error,
    this.currentFilter = DateFilter.thisMonth,
    this.customStartDate,
    this.customEndDate,
  }) : summary = summary ?? FulizaSummary.empty();

  FulizaState copyWith({
    List<FulizaEvent>? events,
    FulizaSummary? summary,
    bool? isLoading,
    String? error,
    DateFilter? currentFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return FulizaState(
      events: events ?? this.events,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}

/// Notifier for managing Fuliza state
class FulizaNotifier extends StateNotifier<FulizaState> {
  final DatabaseService _db;
  final SmsService _smsService;

  FulizaNotifier(this._db, this._smsService) : super(FulizaState()) {
    loadData();
  }

  /// Load initial data from database
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final (start, end) = _getDateRange(state.currentFilter);
      print('\n📊 Loading data with filter: ${state.currentFilter}');
      print('   Date range: $start to $end');

      final events = start != null && end != null
          ? await _db.getEventsByDateRange(start, end)
          : await _db.getAllEvents();
      final summary = await _db.getSummary(start: start, end: end);

      // Debug: Count events by type
      final loans = events.where((e) => e.type == FulizaEventType.loan).length;
      final interests = events.where((e) => e.type == FulizaEventType.interest).length;
      final repayments = events.where((e) => e.type == FulizaEventType.repayment).length;

      print('   📦 Loaded ${events.length} events:');
      print('      - Loans: $loans');
      print('      - Interests: $interests');
      print('      - Repayments: $repayments');
      print('   💰 Summary:');
      print('      - Total Loaned: ${summary.totalLoaned}');
      print('      - Total Interest: ${summary.totalInterest}');
      print('      - Total Repaid: ${summary.totalRepaid}');
      print('      - Outstanding: ${summary.outstandingBalance}');

      state = state.copyWith(
        events: events,
        summary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load data: $e',
      );
    }
  }

  /// Sync SMS messages from device
  Future<int> syncFromSms() async {
    print('\n========================================');
    print('🚀 STARTING SMS SYNC');
    print('========================================\n');

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check permission
      print('🔐 Checking SMS permission...');
      if (!await _smsService.hasPermission()) {
        print('⚠️  Permission not granted, requesting...');
        final granted = await _smsService.requestPermission();
        if (!granted) {
          print('❌ SMS permission denied by user');
          state = state.copyWith(
            isLoading: false,
            error: 'SMS permission denied',
          );
          return 0;
        }
        print('✅ Permission granted!');
      } else {
        print('✅ SMS permission already granted');
      }

      // Fetch and parse SMS
      print('\n📱 Fetching Fuliza events from SMS...');
      final events = await _smsService.getFulizaEvents();
      print('📦 Got ${events.length} events from SMS parser');

      if (events.isEmpty) {
        print('⚠️  No events to insert');
        state = state.copyWith(isLoading: false);
        return 0;
      }

      // Check how many events are already in database before insert
      final countBefore = await _db.getEventCount();
      print('📊 Events in database BEFORE insert: $countBefore');

      // Insert new events (duplicates are ignored)
      print('\n💾 Inserting ${events.length} events into database...');
      await _db.insertEvents(events);

      // Check count after insert
      final countAfter = await _db.getEventCount();
      print('📊 Events in database AFTER insert: $countAfter');
      print('   New events added: ${countAfter - countBefore}');

      // Reload data with current filter
      print('\n🔄 Reloading data with filter: ${state.currentFilter}');
      await loadData();

      // If current filter shows no events but database has events, switch to All Time
      if (state.events.isEmpty && countAfter > 0) {
        print('⚠️  Current filter shows 0 events but DB has $countAfter');
        print('🔄 Switching to All Time filter...');
        state = state.copyWith(currentFilter: DateFilter.allTime);
        await loadData();
      }

      // Log final state
      print('\n📋 Final state:');
      print('   Events in state: ${state.events.length}');
      print('   Summary - Loans: ${state.summary.totalLoaned}');
      print('   Summary - Interest: ${state.summary.totalInterest}');

      print('\n========================================');
      print('✅ SMS SYNC COMPLETED');
      print('   Parsed: ${events.length} events');
      print('   New: ${countAfter - countBefore} events');
      print('   Total in DB: $countAfter events');
      print('   Displayed: ${state.events.length} events (filtered by ${state.currentFilter})');
      print('========================================\n');

      return events.length;
    } catch (e, stackTrace) {
      print('\n========================================');
      print('❌ SMS SYNC FAILED');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('========================================\n');

      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sync SMS: $e',
      );
      return 0;
    }
  }

  /// Change date filter
  Future<void> setFilter(DateFilter filter) async {
    state = state.copyWith(currentFilter: filter);
    await loadData();
  }

  /// Set custom date range
  Future<void> setCustomDateRange(DateTime start, DateTime end) async {
    state = state.copyWith(
      currentFilter: DateFilter.custom,
      customStartDate: start,
      customEndDate: end,
    );
    await loadData();
  }

  /// Get date range for current filter
  (DateTime?, DateTime?) _getDateRange(DateFilter filter) {
    final now = DateTime.now();

    switch (filter) {
      case DateFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return (
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );

      case DateFilter.thisMonth:
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );

      case DateFilter.thisYear:
        return (
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31, 23, 59, 59),
        );

      case DateFilter.custom:
        if (state.customStartDate != null && state.customEndDate != null) {
          return (state.customStartDate, state.customEndDate);
        }
        return (null, null);

      case DateFilter.allTime:
        return (null, null);
    }
  }

  /// Delete all data
  Future<void> deleteAllData() async {
    state = state.copyWith(isLoading: true);
    await _db.deleteAllData();
    state = FulizaState();
  }

  /// Get event count
  Future<int> getEventCount() async {
    return _db.getEventCount();
  }
}

/// Provider for Fuliza state
final fulizaProvider = StateNotifierProvider<FulizaNotifier, FulizaState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final smsService = ref.watch(smsServiceProvider);
  return FulizaNotifier(db, smsService);
});

/// Provider for summary only (efficient for widgets that only need summary)
final fulizaSummaryProvider = Provider<FulizaSummary>((ref) {
  return ref.watch(fulizaProvider).summary;
});

/// Provider for loading state
final fulizaLoadingProvider = Provider<bool>((ref) {
  return ref.watch(fulizaProvider).isLoading;
});

/// Provider for current filter
final fulizaFilterProvider = Provider<DateFilter>((ref) {
  return ref.watch(fulizaProvider).currentFilter;
});
