import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_assesment2/db/database_helper.dart';
import 'package:flutter_assesment2/models/sholat_tracker.dart';
import 'package:flutter_assesment2/models/target_ibadah.dart';
import 'package:flutter_assesment2/models/koleksi_doa.dart';
import 'package:flutter_assesment2/models/jurnal_harian.dart';

void main() {
  group('Model Tests', () {
    test('SholatTracker should map correctly', () {
      final tracker = SholatTracker(
        id: 1,
        tanggal: '2026-05-26',
        waktu: 'Subuh',
        status: 'selesai',
        catatan: 'Berjamaah',
      );

      final map = tracker.toMap();
      expect(map['id'], 1);
      expect(map['tanggal'], '2026-05-26');
      expect(map['waktu'], 'Subuh');
      expect(map['status'], 'selesai');
      expect(map['catatan'], 'Berjamaah');

      final fromMap = SholatTracker.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.tanggal, '2026-05-26');
      expect(fromMap.waktu, 'Subuh');
      expect(fromMap.status, 'selesai');
      expect(fromMap.catatan, 'Berjamaah');
    });

    test('TargetIbadah should map correctly', () {
      final target = TargetIbadah(
        id: 2,
        namaTarget: 'Membaca Quran',
        jenis: 'Sunnah',
        targetHarian: 10,
        progress: 5,
        satuan: 'Halaman',
        tanggal: '2026-05-26',
        isSelesai: 0,
      );

      final map = target.toMap();
      expect(map['id'], 2);
      expect(map['nama_target'], 'Membaca Quran');
      expect(map['jenis'], 'Sunnah');
      expect(map['target_harian'], 10);
      expect(map['progress'], 5);
      expect(map['satuan'], 'Halaman');
      expect(map['tanggal'], '2026-05-26');
      expect(map['is_selesai'], 0);

      final fromMap = TargetIbadah.fromMap(map);
      expect(fromMap.id, 2);
      expect(fromMap.namaTarget, 'Membaca Quran');
      expect(fromMap.jenis, 'Sunnah');
      expect(fromMap.targetHarian, 10);
      expect(fromMap.progress, 5);
      expect(fromMap.satuan, 'Halaman');
      expect(fromMap.tanggal, '2026-05-26');
      expect(fromMap.isSelesai, 0);
      expect(fromMap.isCompleted, false);
    });

    test('KoleksiDoa should map correctly', () {
      final doa = KoleksiDoa(
        id: 3,
        judul: 'Doa Sebelum Makan',
        isiDoa: 'Allahumma barik lana...',
        terjemahan: 'Ya Allah berkahilah...',
        kategori: 'Harian',
        isFavorit: 1,
      );

      final map = doa.toMap();
      expect(map['id'], 3);
      expect(map['judul'], 'Doa Sebelum Makan');
      expect(map['isi_doa'], 'Allahumma barik lana...');
      expect(map['terjemahan'], 'Ya Allah berkahilah...');
      expect(map['kategori'], 'Harian');
      expect(map['is_favorit'], 1);

      final fromMap = KoleksiDoa.fromMap(map);
      expect(fromMap.id, 3);
      expect(fromMap.judul, 'Doa Sebelum Makan');
      expect(fromMap.isiDoa, 'Allahumma barik lana...');
      expect(fromMap.terjemahan, 'Ya Allah berkahilah...');
      expect(fromMap.kategori, 'Harian');
      expect(fromMap.isFavorit, 1);
      expect(fromMap.isFavorite, true);
    });

    test('JurnalHarian should map correctly', () {
      final jurnal = JurnalHarian(
        id: 4,
        tanggal: '2026-05-26',
        mood: '😇',
        catatan: 'Sholat fardhu lengkap dan tilawah 2 lembar',
        syukur: 'Alhamdulillah sehat wal afiat',
        evaluasi: 'Kurang sholat sunnah rawatib',
      );

      final map = jurnal.toMap();
      expect(map['id'], 4);
      expect(map['tanggal'], '2026-05-26');
      expect(map['mood'], '😇');
      expect(map['catatan'], 'Sholat fardhu lengkap dan tilawah 2 lembar');
      expect(map['syukur'], 'Alhamdulillah sehat wal afiat');
      expect(map['evaluasi'], 'Kurang sholat sunnah rawatib');

      final fromMap = JurnalHarian.fromMap(map);
      expect(fromMap.id, 4);
      expect(fromMap.tanggal, '2026-05-26');
      expect(fromMap.mood, '😇');
      expect(fromMap.catatan, 'Sholat fardhu lengkap dan tilawah 2 lembar');
      expect(fromMap.syukur, 'Alhamdulillah sehat wal afiat');
      expect(fromMap.evaluasi, 'Kurang sholat sunnah rawatib');
    });

    test('DatabaseHelper should instantiate correctly', () {
      expect(DatabaseHelper.instance, isNotNull);
    });
  });
}
