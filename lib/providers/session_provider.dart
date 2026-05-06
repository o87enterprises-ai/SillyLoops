import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sample_provider.dart';

class SessionData {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<List<Map<String, dynamic>?>> banks;
  final double bpm;

  SessionData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.banks,
    required this.bpm,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'banks': banks,
        'bpm': bpm,
      };

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      banks: (json['banks'] as List).map((bank) {
        return (bank as List).map((sample) {
          return sample != null ? Map<String, dynamic>.from(sample) : null;
        }).toList();
      }).toList(),
      bpm: (json['bpm'] as num?)?.toDouble() ?? 120.0,
    );
  }
}

class SessionProvider extends ChangeNotifier {
  List<SessionData> _sessions = [];
  bool _isLoading = false;

  List<SessionData> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('saved_sessions') ?? [];
      _sessions = sessionsJson
          .map((s) => SessionData.fromJson(jsonDecode(s)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSession(String name, SampleProvider sampleProvider, double bpm) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final List<List<Map<String, dynamic>?>> banksData = sampleProvider.samples.map((bank) {
      return bank.map((sample) {
        if (sample == null) return null;
        return {
          'name': sample.name,
          'path': sample.path,
          'isLoop': sample.isLoop,
          'volume': sample.volume,
        };
      }).toList();
    }).toList();

    final newSession = SessionData(
      id: id,
      name: name,
      createdAt: DateTime.now(),
      banks: banksData,
      bpm: bpm,
    );

    _sessions.insert(0, newSession);
    await _persistSessions();
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await _persistSessions();
    notifyListeners();
  }

  Future<void> _persistSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _sessions.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList('saved_sessions', sessionsJson);
    } catch (e) {
      debugPrint('Error persisting sessions: $e');
    }
  }

  void loadSessionIntoApp(SessionData session, SampleProvider sampleProvider) {
    for (int bankIdx = 0; bankIdx < session.banks.length; bankIdx++) {
      for (int padIdx = 0; padIdx < session.banks[bankIdx].length; padIdx++) {
        final sampleData = session.banks[bankIdx][padIdx];
        if (sampleData != null) {
          sampleProvider.setSample(
            bankIdx,
            padIdx,
            SampleData(
              name: sampleData['name'],
              path: sampleData['path'],
              isLoop: sampleData['isLoop'] ?? false,
              volume: (sampleData['volume'] as num?)?.toDouble() ?? 1.0,
            ),
          );
        } else {
          sampleProvider.clearSample(bankIdx, padIdx);
        }
      }
    }
  }
}
