import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import '../domain/game_settings.dart';
import 'save_migrator.dart';

abstract class GameRepository {
  Future<GameState?> loadCurrent();
  Future<void> saveCurrent(GameState state);
  Future<void> clearCurrent();
  Future<List<GameState>> loadArchives();
  Future<void> saveArchive(GameState state);
  Future<void> replaceArchives(List<GameState> states);
}

abstract class GameSettingsRepository {
  Future<GameSettings> loadSettings();
  Future<void> saveSettings(GameSettings settings);
}

class SharedPreferencesGameRepository
    implements GameRepository, GameSettingsRepository {
  SharedPreferencesGameRepository(this._preferences);

  static const _currentKey = 'douluo.current.v1';
  static const _currentBackupKey = 'douluo.current.backup.v1';
  static const _archiveKey = 'douluo.archives.v1';
  static const _settingsKey = 'douluo.settings.v1';
  final SharedPreferences _preferences;

  static Future<SharedPreferencesGameRepository> create() async =>
      SharedPreferencesGameRepository(await SharedPreferences.getInstance());

  @override
  Future<void> clearCurrent() async {
    await _preferences.remove(_currentKey);
    await _preferences.remove(_currentBackupKey);
  }

  @override
  Future<List<GameState>> loadArchives() async {
    final raw = _preferences.getString(_archiveKey);
    if (raw == null) return <GameState>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<Object?>) return <GameState>[];
      final states = <GameState>[];
      for (final item in decoded.whereType<Map<Object?, Object?>>()) {
        try {
          states.add(
            migrateGameState(GameState.fromJson(_stringKeyedMap(item))),
          );
        } on FormatException {
          continue;
        } on TypeError {
          continue;
        }
      }
      final normalized = jsonEncode(
        states.map((item) => item.toJson()).toList(),
      );
      if (normalized != raw) {
        await _preferences.setString(_archiveKey, normalized);
      }
      return states;
    } on FormatException {
      return <GameState>[];
    } on TypeError {
      return <GameState>[];
    }
  }

  @override
  Future<GameState?> loadCurrent() async {
    final raw = _preferences.getString(_currentKey);
    final state = _decodeState(raw);
    if (state != null) {
      final normalized = jsonEncode(state.toJson());
      if (normalized != raw) {
        await _preferences.setString(_currentKey, normalized);
      }
      return state;
    }
    final backup = _decodeState(_preferences.getString(_currentBackupKey));
    if (backup == null) return null;
    await _preferences.setString(_currentKey, jsonEncode(backup.toJson()));
    return backup;
  }

  @override
  Future<void> saveArchive(GameState state) async {
    final archives = await loadArchives();
    archives.insert(0, state.copy());
    await replaceArchives(archives);
  }

  @override
  Future<void> replaceArchives(List<GameState> states) async {
    await _preferences.setString(
      _archiveKey,
      jsonEncode(states.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<void> saveCurrent(GameState state) async {
    final previous = _preferences.getString(_currentKey);
    if (_decodeState(previous) != null) {
      await _preferences.setString(_currentBackupKey, previous!);
    }
    await _preferences.setString(_currentKey, jsonEncode(state.toJson()));
  }

  @override
  Future<GameSettings> loadSettings() async {
    final raw = _preferences.getString(_settingsKey);
    if (raw == null) return const GameSettings();
    try {
      return GameSettings.fromJson(
        _stringKeyedMap(jsonDecode(raw) as Map<Object?, Object?>),
      );
    } on FormatException {
      return const GameSettings();
    } on TypeError {
      return const GameSettings();
    }
  }

  @override
  Future<void> saveSettings(GameSettings settings) async {
    await _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  GameState? _decodeState(String? raw) {
    if (raw == null) return null;
    try {
      return migrateGameState(
        GameState.fromJson(
          _stringKeyedMap(jsonDecode(raw) as Map<Object?, Object?>),
        ),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Map<String, Object?> _stringKeyedMap(Map<Object?, Object?> source) =>
      source.map((key, value) => MapEntry(key.toString(), value));
}
