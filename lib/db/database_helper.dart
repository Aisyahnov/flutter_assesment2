import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ibadahku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sholat_tracker (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal    TEXT    NOT NULL,
        waktu      TEXT    NOT NULL,
        status     TEXT    NOT NULL DEFAULT 'belum',
        catatan    TEXT,
        created_at TEXT    DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE target_ibadah (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_target   TEXT    NOT NULL,
        jenis         TEXT    NOT NULL,
        target_harian INTEGER NOT NULL,
        progress      INTEGER DEFAULT 0,
        satuan        TEXT    NOT NULL,
        tanggal       TEXT    NOT NULL,
        is_selesai    INTEGER DEFAULT 0,
        created_at    TEXT    DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE koleksi_doa (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        judul       TEXT NOT NULL,
        isi_doa     TEXT NOT NULL,
        terjemahan  TEXT,
        kategori    TEXT,
        is_favorit  INTEGER DEFAULT 0,
        created_at  TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE jurnal_harian (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal    TEXT NOT NULL,
        mood       TEXT,
        catatan    TEXT NOT NULL,
        syukur     TEXT,
        evaluasi   TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
}
