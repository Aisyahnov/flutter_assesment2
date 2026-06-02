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
    await _seedData(db);
  }

  Future<void> seedIfEmpty() async {
    final db = await database;
    final sholatCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sholat_tracker'));
    if (sholatCount == 0) {
      await _seedData(db);
    }
  }

  Future _seedData(Database db) async {
    // Dummy Doa
    final doaList = [
      ['Doa Sebelum Makan', 'اللَّهُمَّ بَارِكْ لَنَا فِيمَا رَزَقْتَنَا وَقِنَا عَذَابَ النَّارِ', 'Ya Allah, berkahilah kami dalam rezeki yang telah Engkau berikan kepada kami dan peliharalah kami dari siksa api neraka.'],
      ['Doa Sesudah Makan', 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ', 'Segala puji bagi Allah yang telah memberi kami makan dan minum serta menjadikan kami orang-orang muslim.'],
      ['Doa Sebelum Tidur', 'بِاسْمِكَ اللَّهُمَّ أَحْيَا وَأَمُوتُ', 'Dengan nama-Mu ya Allah, aku hidup dan aku mati.'],
      ['Doa Bangun Tidur', 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ', 'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami dan kepada-Nya lah kami kembali.'],
      ['Doa Masuk Kamar Mandi', 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ', 'Ya Allah, sesungguhnya aku berlindung kepada-Mu dari godaan syaitan laki-laki dan syaitan perempuan.'],
    ];

    for (var doa in doaList) {
      await db.insert('koleksi_doa', {
        'judul': doa[0],
        'isi_doa': doa[1],
        'terjemahan': doa[2],
        'kategori': 'Harian',
      });
    }

    // Dummy Target
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    final targetList = [
      ['Baca Al-Qur\'an', 'Ibadah', 5, 2, 'Halaman'],
      ['Sedekah', 'Sosial', 10000, 5000, 'Rupiah'],
      ['Sholawat', 'Dzikir', 1000, 500, 'Kali'],
      ['Hafalan Surat', 'Pendidikan', 1, 0, 'Surat'],
      ['Dzikir Pagi', 'Dzikir', 33, 33, 'Kali'],
    ];

    for (var target in targetList) {
      await db.insert('target_ibadah', {
        'nama_target': target[0],
        'jenis': target[1],
        'target_harian': target[2],
        'progress': target[3],
        'satuan': target[4],
        'tanggal': todayStr,
        'is_selesai': (target[3] as int) >= (target[2] as int) ? 1 : 0,
      });
    }

    // Dummy Jurnal
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      await db.insert('jurnal_harian', {
        'tanggal': dateStr,
        'mood': ['😀', '😐', '😌', '💪', '🙌'][i],
        'catatan': 'Hari ini adalah hari ke-${i + 1} yang sangat produktif. Terus semangat!',
        'syukur': 'Masih diberikan kesehatan dan kesempatan beribadah.',
        'evaluasi': 'Perlu meningkatkan kekhusyukan dalam sholat.',
      });
    }

    // Dummy Sholat
    final sholatWaktu = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    for (var waktu in sholatWaktu) {
      await db.insert('sholat_tracker', {
        'tanggal': todayStr,
        'waktu': waktu,
        'status': waktu == 'Subuh' || waktu == 'Dzuhur' ? 'selesai' : 'belum',
        'catatan': 'Alhamdulillah',
      });
    }
  }
}
