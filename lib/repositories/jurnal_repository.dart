import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/jurnal_harian.dart';

class JurnalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _webPrefKey = 'web_jurnal_harian';

  Future<int> insertJurnal(JurnalHarian jurnal) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<JurnalHarian> all = listJson.map((m) => JurnalHarian.fromMap(m)).toList();

      final int newId = DateTime.now().millisecondsSinceEpoch;
      final newJurnal = jurnal.copyWith(id: newId);
      all.add(newJurnal);

      await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
      return newId;
    }

    final db = await _dbHelper.database;
    return await db.insert('jurnal_harian', jurnal.toMap());
  }

  Future<List<JurnalHarian>> getAllJurnal() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      return listJson.map((m) => JurnalHarian.fromMap(m)).toList();
    }

    final db = await _dbHelper.database;
    final maps = await db.query('jurnal_harian', orderBy: 'tanggal DESC, id DESC');
    return maps.map((map) => JurnalHarian.fromMap(map)).toList();
  }

  Future<List<JurnalHarian>> getJurnalByTanggal(String tanggal) async {
    if (kIsWeb) {
      final all = await getAllJurnal();
      return all.where((j) => j.tanggal == tanggal).toList();
    }

    final db = await _dbHelper.database;
    final maps = await db.query(
      'jurnal_harian',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'id DESC',
    );
    return maps.map((map) => JurnalHarian.fromMap(map)).toList();
  }

  Future<int> updateJurnal(JurnalHarian jurnal) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<JurnalHarian> all = listJson.map((m) => JurnalHarian.fromMap(m)).toList();

      final idx = all.indexWhere((t) => t.id == jurnal.id);
      if (idx != -1) {
        all[idx] = jurnal;
        await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
        return 1;
      }
      return 0;
    }

    final db = await _dbHelper.database;
    return await db.update(
      'jurnal_harian',
      jurnal.toMap(),
      where: 'id = ?',
      whereArgs: [jurnal.id],
    );
  }

  Future<int> deleteJurnal(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<JurnalHarian> all = listJson.map((m) => JurnalHarian.fromMap(m)).toList();

      all.removeWhere((t) => t.id == id);
      await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
      return 1;
    }

    final db = await _dbHelper.database;
    return await db.delete(
      'jurnal_harian',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
