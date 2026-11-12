import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pet.dart';
import '../models/reminder.dart';

/// Persistência local (SQLite) para animais e lembretes.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  /// Incrementado em cada escrita. Os ecrãs ouvem este valor e recarregam os dados.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static const _dbName = 'petcare.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get _database async {
    final existing = _db;
    if (existing != null) return existing;

    final path = join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
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
      },
    );
    return _db!;
  }

  // ---------------- Animais (CRUD) ----------------

  Future<List<Pet>> getPets() async {
    final db = await _database;
    final rows = await db.query('pets', orderBy: 'name COLLATE NOCASE');
    return rows.map(Pet.fromMap).toList();
  }

  Future<void> insertPet(Pet pet) async {
    final db = await _database;
    await db.insert('pets', pet.toMap());
    _notify();
  }

  Future<void> updatePet(Pet pet) async {
    final db = await _database;
    await db.update('pets', pet.toMap(), where: 'id = ?', whereArgs: [pet.id]);
    _notify();
  }

  /// Remove o animal e, por cascata, os seus lembretes.
  Future<void> deletePet(int id) async {
    final db = await _database;
    await db.delete('pets', where: 'id = ?', whereArgs: [id]);
    _notify();
  }

  // ---------------- Lembretes (CRUD) ----------------

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
  Future<List<Reminder>> getRemindersBetween(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _database;
    final rows = await db.rawQuery(
      '$_reminderSelect WHERE r.date_time >= ? AND r.date_time < ? '
      'ORDER BY r.date_time ASC',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return rows.map(Reminder.fromMap).toList();
  }

  Future<void> insertReminder(Reminder reminder) async {
    final db = await _database;
    await db.insert('reminders', reminder.toMap());
    _notify();
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

  void _notify() => changes.value++;
}
