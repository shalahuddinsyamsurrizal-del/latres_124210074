import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = join(await getDatabasesPath(), 'rick_morty_explorer.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<bool> register(String username, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'username': username.trim(),
        'password_hash': _hashPassword(password),
      });
      return true;
    } catch (_) {
      return false; // username sudah digunakan atau insert gagal
    }
  }

  Future<bool> login(String username, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username.trim(), _hashPassword(password)],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
