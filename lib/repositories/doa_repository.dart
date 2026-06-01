import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/koleksi_doa.dart';

class DoaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _webPrefKey = 'web_koleksi_doa';

  Future<int> insertDoa(KoleksiDoa doa) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<KoleksiDoa> all = listJson.map((m) => KoleksiDoa.fromMap(m)).toList();

      final int newId = DateTime.now().millisecondsSinceEpoch;
      final newDoa = doa.copyWith(id: newId);
      all.add(newDoa);

      await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
      return newId;
    }

    final db = await _dbHelper.database;
    return await db.insert('koleksi_doa', doa.toMap());
  }

  Future<List<KoleksiDoa>> getAllDoa() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      return listJson.map((m) => KoleksiDoa.fromMap(m)).toList();
    }

    final db = await _dbHelper.database;
    final maps = await db.query('koleksi_doa', orderBy: 'id DESC');
    return maps.map((map) => KoleksiDoa.fromMap(map)).toList();
  }

  Future<List<KoleksiDoa>> getFavoritDoa() async {
    if (kIsWeb) {
      final all = await getAllDoa();
      return all.where((doa) => doa.isFavorite).toList();
    }

    final db = await _dbHelper.database;
    final maps = await db.query('koleksi_doa', where: 'is_favorit = 1', orderBy: 'id DESC');
    return maps.map((map) => KoleksiDoa.fromMap(map)).toList();
  }

  Future<int> updateDoa(KoleksiDoa doa) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<KoleksiDoa> all = listJson.map((m) => KoleksiDoa.fromMap(m)).toList();

      final idx = all.indexWhere((t) => t.id == doa.id);
      if (idx != -1) {
        all[idx] = doa;
        await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
        return 1;
      }
      return 0;
    }

    final db = await _dbHelper.database;
    return await db.update(
      'koleksi_doa',
      doa.toMap(),
      where: 'id = ?',
      whereArgs: [doa.id],
    );
  }

  Future<int> deleteDoa(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<KoleksiDoa> all = listJson.map((m) => KoleksiDoa.fromMap(m)).toList();

      all.removeWhere((t) => t.id == id);
      await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
      return 1;
    }

    final db = await _dbHelper.database;
    return await db.delete(
      'koleksi_doa',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorit(int id, bool isFavorit) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_webPrefKey) ?? '[]';
      final List<dynamic> listJson = json.decode(dataStr);
      final List<KoleksiDoa> all = listJson.map((m) => KoleksiDoa.fromMap(m)).toList();

      final idx = all.indexWhere((t) => t.id == id);
      if (idx != -1) {
        all[idx] = all[idx].copyWith(isFavorit: isFavorit ? 1 : 0);
        await prefs.setString(_webPrefKey, json.encode(all.map((t) => t.toMap()).toList()));
        return 1;
      }
      return 0;
    }

    final db = await _dbHelper.database;
    return await db.update(
      'koleksi_doa',
      {'is_favorit': isFavorit ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
