import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';

class LocalSettingsDatabase {
  static Database? _database;
  static final LocalSettingsDatabase instance = LocalSettingsDatabase._();

  LocalSettingsDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();

    final path = join(await getDatabasesPath(), 'fuggipizza_v1.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE local_settings(id INTEGER PRIMARY KEY, serverAddress TEXT, serverPort INTEGER)',
        );
      },
    );
  }

  Future<void> insertLocalSettings(LocalSettings settings) async {
    final db = await database;
    await db.insert(
      'local_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<LocalSettings?> getLocalSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('local_settings');

    if (maps.isNotEmpty) {
      return LocalSettings.fromMap(maps.first);
    } else {
      return null;
    }
  }
}

class LocalSettings {
  final int id;
  final String serverAddress;
  final int serverPort;

  LocalSettings({
    required this.id,
    required this.serverAddress,
    required this.serverPort,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverAddress': serverAddress,
      'serverPort': serverPort,
    };
  }

  factory LocalSettings.fromMap(Map<String, dynamic> map) {
    return LocalSettings(
      id: map['id'],
      serverAddress: map['serverAddress'],
      serverPort: map['serverPort'],
    );
  }
}
