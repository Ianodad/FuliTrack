import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

/// Service for managing local SQLite database
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'fulitrack.db';
  static const int _dbVersion = 1;

  /// Get database instance (creates if not exists)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Fuliza events table
    await db.execute('''
      CREATE TABLE fuliza_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        reference TEXT NOT NULL UNIQUE,
        raw_sms TEXT NOT NULL,
        period_key TEXT NOT NULL,
        due_date INTEGER,
        outstanding_balance REAL
      )
    ''');

    // Fuliza rewards table
    await db.execute('''
      CREATE TABLE fuliza_rewards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        period TEXT NOT NULL,
        period_start INTEGER NOT NULL,
        awarded_at INTEGER NOT NULL,
        previous_value REAL NOT NULL,
        current_value REAL NOT NULL,
        comparison_type TEXT NOT NULL
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes for faster queries
    await db.execute(
      'CREATE INDEX idx_events_date ON fuliza_events(date)',
    );
    await db.execute(
      'CREATE INDEX idx_events_period_key ON fuliza_events(period_key)',
    );
    await db.execute(
      'CREATE INDEX idx_events_type ON fuliza_events(type)',
    );
    await db.execute(
      'CREATE INDEX idx_rewards_period_start ON fuliza_rewards(period_start)',
    );
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
    if (oldVersion < 2) {
      // Example: await db.execute('ALTER TABLE fuliza_events ADD COLUMN new_field TEXT');
    }
  }

  // ==================== Fuliza Events ====================

  /// Insert a new Fuliza event
  Future<int> insertEvent(FulizaEvent event) async {
    final db = await database;
    try {
      return await db.insert(
        'fuliza_events',
        event.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      // Likely duplicate reference
      return -1;
    }
  }

  /// Insert multiple events (batch)
  Future<void> insertEvents(List<FulizaEvent> events) async {
    final db = await database;
    final batch = db.batch();

    for (final event in events) {
      batch.insert(
        'fuliza_events',
        event.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all Fuliza events
  Future<List<FulizaEvent>> getAllEvents() async {
    final db = await database;
    final maps = await db.query(
      'fuliza_events',
      orderBy: 'date DESC',
    );
    return maps.map((map) => FulizaEvent.fromMap(map)).toList();
  }

  /// Get events by date range
  Future<List<FulizaEvent>> getEventsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      'fuliza_events',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => FulizaEvent.fromMap(map)).toList();
  }

  /// Get events by type
  Future<List<FulizaEvent>> getEventsByType(FulizaEventType type) async {
    final db = await database;
    final maps = await db.query(
      'fuliza_events',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'date DESC',
    );
    return maps.map((map) => FulizaEvent.fromMap(map)).toList();
  }

  /// Get events by period key
  Future<List<FulizaEvent>> getEventsByPeriodKey(String periodKey) async {
    final db = await database;
    final maps = await db.query(
      'fuliza_events',
      where: 'period_key = ?',
      whereArgs: [periodKey],
      orderBy: 'date DESC',
    );
    return maps.map((map) => FulizaEvent.fromMap(map)).toList();
  }

  /// Get event count
  Future<int> getEventCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM fuliza_events');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if reference exists (for avoiding duplicates)
  Future<bool> referenceExists(String reference) async {
    final db = await database;
    final result = await db.query(
      'fuliza_events',
      where: 'reference = ?',
      whereArgs: [reference],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Delete event by ID
  Future<int> deleteEvent(int id) async {
    final db = await database;
    return db.delete(
      'fuliza_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all events
  Future<int> deleteAllEvents() async {
    final db = await database;
    return db.delete('fuliza_events');
  }

  // ==================== Fuliza Rewards ====================

  /// Insert a new reward
  Future<int> insertReward(FulizaReward reward) async {
    final db = await database;
    return db.insert(
      'fuliza_rewards',
      reward.toMap()..remove('id'),
    );
  }

  /// Get all rewards
  Future<List<FulizaReward>> getAllRewards() async {
    final db = await database;
    final maps = await db.query(
      'fuliza_rewards',
      orderBy: 'awarded_at DESC',
    );
    return maps.map((map) => FulizaReward.fromMap(map)).toList();
  }

  /// Get rewards by period
  Future<List<FulizaReward>> getRewardsByPeriod(RewardPeriod period) async {
    final db = await database;
    final maps = await db.query(
      'fuliza_rewards',
      where: 'period = ?',
      whereArgs: [period.name],
      orderBy: 'awarded_at DESC',
    );
    return maps.map((map) => FulizaReward.fromMap(map)).toList();
  }

  /// Get recent rewards (last N)
  Future<List<FulizaReward>> getRecentRewards({int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'fuliza_rewards',
      orderBy: 'awarded_at DESC',
      limit: limit,
    );
    return maps.map((map) => FulizaReward.fromMap(map)).toList();
  }

  /// Delete all rewards
  Future<int> deleteAllRewards() async {
    final db = await database;
    return db.delete('fuliza_rewards');
  }

  // ==================== App Settings ====================

  /// Save a setting
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a setting
  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  /// Get all settings as map
  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final maps = await db.query('app_settings');
    return {
      for (final map in maps) map['key'] as String: map['value'] as String,
    };
  }

  // ==================== Summary Queries ====================

  /// Get summary for a date range
  Future<FulizaSummary> getSummary({
    DateTime? start,
    DateTime? end,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (start != null && end != null) {
      whereClause = 'WHERE date >= ? AND date <= ?';
      whereArgs = [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch];
    }

    // Get totals by type
    final loanResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total, COUNT(*) as count
      FROM fuliza_events
      $whereClause ${whereClause.isNotEmpty ? 'AND' : 'WHERE'} type = 'loan'
    ''', whereArgs.isNotEmpty ? [...whereArgs] : null);

    final interestResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fuliza_events
      $whereClause ${whereClause.isNotEmpty ? 'AND' : 'WHERE'} type = 'interest'
    ''', whereArgs.isNotEmpty ? [...whereArgs] : null);

    final repaymentResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fuliza_events
      $whereClause ${whereClause.isNotEmpty ? 'AND' : 'WHERE'} type = 'repayment'
    ''', whereArgs.isNotEmpty ? [...whereArgs] : null);

    final totalLoaned = (loanResult.first['total'] as num?)?.toDouble() ?? 0;
    final transactionCount = (loanResult.first['count'] as int?) ?? 0;
    final totalInterest =
        (interestResult.first['total'] as num?)?.toDouble() ?? 0;
    final totalRepaid =
        (repaymentResult.first['total'] as num?)?.toDouble() ?? 0;

    // Calculate outstanding balance
    final outstandingBalance = totalLoaned + totalInterest - totalRepaid;

    return FulizaSummary(
      totalLoaned: totalLoaned,
      totalInterest: totalInterest,
      totalRepaid: totalRepaid,
      outstandingBalance: outstandingBalance < 0 ? 0 : outstandingBalance,
      transactionCount: transactionCount,
      periodStart: start,
      periodEnd: end,
    );
  }

  /// Get summary by period key
  Future<FulizaSummary> getSummaryByPeriodKey(String periodKey) async {
    final db = await database;

    final loanResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total, COUNT(*) as count
      FROM fuliza_events
      WHERE period_key = ? AND type = 'loan'
    ''', [periodKey]);

    final interestResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fuliza_events
      WHERE period_key = ? AND type = 'interest'
    ''', [periodKey]);

    final repaymentResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fuliza_events
      WHERE period_key = ? AND type = 'repayment'
    ''', [periodKey]);

    final totalLoaned = (loanResult.first['total'] as num?)?.toDouble() ?? 0;
    final transactionCount = (loanResult.first['count'] as int?) ?? 0;
    final totalInterest =
        (interestResult.first['total'] as num?)?.toDouble() ?? 0;
    final totalRepaid =
        (repaymentResult.first['total'] as num?)?.toDouble() ?? 0;

    final outstandingBalance = totalLoaned + totalInterest - totalRepaid;

    return FulizaSummary(
      totalLoaned: totalLoaned,
      totalInterest: totalInterest,
      totalRepaid: totalRepaid,
      outstandingBalance: outstandingBalance < 0 ? 0 : outstandingBalance,
      transactionCount: transactionCount,
    );
  }

  // ==================== Data Management ====================

  /// Delete all data (full reset)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('fuliza_events');
    await db.delete('fuliza_rewards');
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Get database file size (approximate)
  Future<int> getDatabaseSize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    // This is a rough estimate
    final db = await database;
    final result = await db.rawQuery('PRAGMA page_count');
    final pageCount = Sqflite.firstIntValue(result) ?? 0;
    final pageSizeResult = await db.rawQuery('PRAGMA page_size');
    final pageSize = Sqflite.firstIntValue(pageSizeResult) ?? 4096;
    return pageCount * pageSize;
  }
}
