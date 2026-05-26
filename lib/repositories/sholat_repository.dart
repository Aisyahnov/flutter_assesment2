import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/sholat_tracker.dart';

class SholatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  static const List<String> _daftarWaktu = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
  static const String _webPrefKey = 'web_sholat_tracker';

  Future<int> insertSholat(SholatTracker sholat) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '{}';
      final Map<String, dynamic> data = json.decode(dataStr);
      
      final date = sholat.tanggal;
      final List<dynamic> listJson = data[date] ?? [];
      final List<SholatTracker> list = listJson.map((m) => SholatTracker.fromMap(m)).toList();
      
      final int newId = DateTime.now().millisecondsSinceEpoch;
      final newSholat = sholat.copyWith(id: newId);
      list.add(newSholat);
      
      data[date] = list.map((t) => t.toMap()).toList();
      await prefs.setString(_webPrefKey, json.encode(data));
      return newId;
    }

    final db = await _dbHelper.database;
    return await db.insert('sholat_tracker', sholat.toMap());
  }

  Future<List<SholatTracker>> getSholatByTanggal(String tanggal) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '{}';
      final Map<String, dynamic> data = json.decode(dataStr);
      
      if (data.containsKey(tanggal)) {
        final List<dynamic> listJson = data[tanggal];
        return listJson.map((m) => SholatTracker.fromMap(m)).toList();
      }
      return [];
    }

    final db = await _dbHelper.database;
    final maps = await db.query(
      'sholat_tracker',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
    );
    
    return maps.map((map) => SholatTracker.fromMap(map)).toList();
  }

  Future<int> updateSholat(SholatTracker sholat) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '{}';
      final Map<String, dynamic> data = json.decode(dataStr);
      
      if (data.containsKey(sholat.tanggal)) {
        final List<dynamic> listJson = data[sholat.tanggal];
        final List<SholatTracker> list = listJson.map((m) => SholatTracker.fromMap(m)).toList();
        final idx = list.indexWhere((t) => t.id == sholat.id || t.waktu == sholat.waktu);
        if (idx != -1) {
          list[idx] = sholat;
          data[sholat.tanggal] = list.map((t) => t.toMap()).toList();
          await prefs.setString(_webPrefKey, json.encode(data));
          return 1;
        }
      }
      return 0;
    }

    final db = await _dbHelper.database;
    return await db.update(
      'sholat_tracker',
      sholat.toMap(),
      where: 'id = ?',
      whereArgs: [sholat.id],
    );
  }

  Future<int> deleteSholat(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '{}';
      final Map<String, dynamic> data = json.decode(dataStr);
      
      bool deleted = false;
      data.forEach((key, value) {
        final List<dynamic> listJson = value;
        final List<SholatTracker> list = listJson.map((m) => SholatTracker.fromMap(m)).toList();
        final idx = list.indexWhere((t) => t.id == id);
        if (idx != -1) {
          list.removeAt(idx);
          data[key] = list.map((t) => t.toMap()).toList();
          deleted = true;
        }
      });
      if (deleted) {
        await prefs.setString(_webPrefKey, json.encode(data));
        return 1;
      }
      return 0;
    }

    final db = await _dbHelper.database;
    return await db.delete(
      'sholat_tracker',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
