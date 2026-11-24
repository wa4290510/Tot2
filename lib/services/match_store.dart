import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match.dart';

class MatchStore extends ChangeNotifier {
  static const _historyKey = 'match_history';
  final List<MatchRecord> _history = [];
  List<MatchRecord> get history => List.unmodifiable(_history);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? const [];
    _history
      ..clear()
      ..addAll(raw.map((item) => MatchRecord.fromJson(jsonDecode(item) as Map<String, dynamic>)));
    notifyListeners();
  }

  Future<void> add(MatchRecord record) async {
    _history.insert(0, record);
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _history.removeWhere((record) => record.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> update(MatchRecord record) async {
    final index = _history.indexWhere((item) => item.id == record.id);
    if (index == -1) return;
    _history[index] = record;
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _history.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyKey,
      _history.map((record) => jsonEncode(record.toJson())).toList(),
    );
  }
}
