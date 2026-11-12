import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pet.dart';
import '../models/reminder.dart';
import '../models/weight_entry.dart';

/// Persistência local (SQLite) de animais, histórico de peso e lembretes.
///
/// [databasePath] permite usar outro ficheiro (ou `inMemoryDatabasePath` nos testes).
class DatabaseService {
  DatabaseService({String? databasePath}) : _customPath = databasePath;

  /// Instância partilhada pela app.
  static final DatabaseService instance = DatabaseService();

  /// Incrementado em cada escrita. Os ecrãs ouvem este valor e recarregam os dados.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static const dbName = 'petcare.db';
  static const dbVersion = 1;

  final String? _customPath;
  Future<Database>? _openFuture;

  Future<Database> get _database => _openFuture ??= _open();

  Future<Database> _open() async {
    final path = _customPath ?? join(await getDatabasesPath(), dbName);
    return openDatabase(
      path,
      version: dbVersion,
      onConfigure: (db) async {
        // Sem isto o SQLite ignora as chaves estrangeiras (e o ON DELETE CASCADE).
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createSchema,
    );
  }

  static Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight REAL NOT NULL,
        gender TEXT NOT NULL,
        medical_notes TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE weight_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        recorded_at INTEGER NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        date_time INTEGER NOT NULL,
        done INTEGER NOT NULL DEFAULT 0,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_reminders_date ON reminders (date_time)',
    );
  }

  /// Fecha a ligação (usado nos testes).
  Future<void> close() async {
    final future = _openFuture;
    _openFuture = null;
    if (future != null) {
      await (await future).close();
    }
  }

  void _notify() => changes.value++;

  // ---------------- Animais ----------------

  Future<List<Pet>> getPets() async {
    final db = await _database;
    final rows = await db.query('pets', orderBy: 'name COLLATE NOCASE');
    return rows.map(Pet.fromMap).toList();
  }

  /// Insere o animal e o primeiro registo do seu peso, numa única transação.
  Future<int> insertPet(Pet pet) async {
    final db = await _database;
    final id = await db.transaction<int>((txn) async {
      final id = await txn.insert('pets', pet.toMap());
      await txn.insert(
        'weight_log',
        WeightEntry(petId: id, weight: pet.weight, recordedAt: DateTime.now())
            .toMap(),
      );
      return id;
    });
    _notify();
    return id;
  }

  /// Atualiza o animal. Se o peso mudou, regista-o também no histórico.
  Future<void> updatePet(Pet pet) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.update('pets', pet.toMap(), where: 'id = ?', whereArgs: [pet.id]);

      final last = await txn.query(
        'weight_log',
        where: 'pet_id = ?',
        whereArgs: [pet.id],
        orderBy: 'recorded_at DESC',
        limit: 1,
      );
      final lastWeight = last.isEmpty ? null : (last.first['weight'] as num).toDouble();

      if (lastWeight != pet.weight) {
        await txn.insert(
          'weight_log',
          WeightEntry(
            petId: pet.id!,
            weight: pet.weight,
            recordedAt: DateTime.now(),
          ).toMap(),
        );
      }
    });
    _notify();
  }

  /// Remove o animal, e por cascata o histórico de peso e os lembretes.
  Future<void> deletePet(int id) async {
    final db = await _database;
    await db.delete('pets', where: 'id = ?', whereArgs: [id]);
    _notify();
  }

  // ---------------- Histórico de peso ----------------

  Future<List<WeightEntry>> getWeightHistory(int petId) async {
    final db = await _database;
    final rows = await db.query(
      'weight_log',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'recorded_at ASC',
    );
    return rows.map(WeightEntry.fromMap).toList();
  }

  /// Regista um novo peso e atualiza o peso atual do animal.
  Future<void> addWeight(int petId, double weight, {DateTime? at}) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.insert(
        'weight_log',
        WeightEntry(
          petId: petId,
          weight: weight,
          recordedAt: at ?? DateTime.now(),
        ).toMap(),
      );
      await txn.update(
        'pets',
        {'weight': weight},
        where: 'id = ?',
        whereArgs: [petId],
      );
    });
    _notify();
  }

  // ---------------- Lembretes ----------------

  static const _reminderSelect = '''
    SELECT r.*, p.name AS pet_name
    FROM reminders r
    LEFT JOIN pets p ON p.id = r.pet_id
  ''';

  Future<List<Reminder>> getReminders() async {
    final db = await _database;
    final rows = await db.rawQuery('$_reminderSelect ORDER BY r.date_time ASC');
    return rows.map(Reminder.fromMap).toList();
  }

  /// Lembretes com data em [start] (inclusive) até [end] (exclusive).
  Future<List<Reminder>> getRemindersBetween(DateTime start, DateTime end) async {
    final db = await _database;
    final rows = await db.rawQuery(
      '$_reminderSelect WHERE r.date_time >= ? AND r.date_time < ? '
      'ORDER BY r.date_time ASC',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return rows.map(Reminder.fromMap).toList();
  }

  /// Próximos lembretes por concluir a partir de [from].
  Future<List<Reminder>> getUpcomingReminders(DateTime from, {int limit = 3}) async {
    final db = await _database;
    final rows = await db.rawQuery(
      '$_reminderSelect WHERE r.done = 0 AND r.date_time >= ? '
      'ORDER BY r.date_time ASC LIMIT ?',
      [from.millisecondsSinceEpoch, limit],
    );
    return rows.map(Reminder.fromMap).toList();
  }

  Future<int> insertReminder(Reminder reminder) async {
    final db = await _database;
    final id = await db.insert('reminders', reminder.toMap());
    _notify();
    return id;
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await _database;
    await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
    _notify();
  }

  Future<void> setReminderDone(int id, bool done) async {
    final db = await _database;
    await db.update(
      'reminders',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify();
  }

  Future<void> deleteReminder(int id) async {
    final db = await _database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
    _notify();
  }
}
