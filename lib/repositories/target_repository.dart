import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/target_ibadah.dart';

class TargetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  static const String _webPrefKey = 'web_target_ibadah';

  Future<int> insertTarget(TargetIbadah target) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<TargetIbadah> all = listJson.map((m) => TargetIbadah.fromMap(m)).toList();
      
      final int newId = DateTime.now().millisecondsSinceEpoch;
      final newTarget = target.copyWith(id: newId);
      all.add(newTarget);
      
      await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
      return newId;
    }

    final db = await _dbHelper.database;
    return await db.insert('target_ibadah', target.toMap());
  }

  Future<List<TargetIbadah>> getTargetByTanggal(String tanggal) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<TargetIbadah> all = listJson.map((m) => TargetIbadah.fromMap(m)).toList();
      return all.where((t) => t.tanggal == tanggal).toList();
    }

    final db = await _dbHelper.database;
    final maps = await db.query(
      'target_ibadah',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
    );
    return maps.map((map) => TargetIbadah.fromMap(map)).toList();
  }

  Future<int> updateProgress(int id, int progress) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<TargetIbadah> all = listJson.map((m) => TargetIbadah.fromMap(m)).toList();
      
      final idx = all.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final target = all[idx];
        final isSelesai = progress >= target.targetHarian ? 1 : 0;
        all[idx] = target.copyWith(progress: progress, isSelesai: isSelesai);
        await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
        return 1;
      }
      return 0;
    }

    final db = await _dbHelper.database;
    final maps = await db.query('target_ibadah', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final tHarian = maps.first['target_harian'] as int;
      final isSelesai = progress >= tHarian ? 1 : 0;
      return await db.update(
        'target_ibadah',
        {'progress': progress, 'is_selesai': isSelesai},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }

  Future<int> updateTarget(TargetIbadah target) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<TargetIbadah> all = listJson.map((m) => TargetIbadah.fromMap(m)).toList();
      
      final idx = all.indexWhere((t) => t.id == target.id);
      if (idx != -1) {
        all[idx] = target;
        await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
        return 1;
      }
      return 0;
    }

    final db = await _dbHelper.database;
    return await db.update(
      'target_ibadah',
      target.toMap(),
      where: 'id = ?',
      whereArgs: [target.id],
    );
  }

  Future<int> deleteTarget(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<TargetIbadah> all = listJson.map((m) => TargetIbadah.fromMap(m)).toList();
      
      all.removeWhere((t) => t.id == id);
      await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
      return 1;
    }

    final db = await _dbHelper.database;
    return await db.delete(
      'target_ibadah',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
