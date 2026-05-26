import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_assesment2/db/database_helper.dart';
import 'package:flutter_assesment2/models/sholat_tracker.dart';
import 'package:flutter_assesment2/models/target_ibadah.dart';

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
        isSelesai: false,
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
      expect(fromMap.isSelesai, false);
    });

    test('DatabaseHelper should instantiate correctly', () {
      expect(DatabaseHelper.instance, isNotNull);
    });
  });
}
