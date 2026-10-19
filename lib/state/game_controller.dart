import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import '../domain/game_settings.dart';
import '../engine/game_engine.dart';
import '../storage/game_repository.dart';
import '../storage/save_migrator.dart';

class SpinPresentation {
  const SpinPresentation({
    required this.wheel,
    required this.selectedIndex,
    required this.sequence,
  });

  final WheelPool wheel;
  final int selectedIndex;
  final int sequence;
}

class SecondaryRingRunSummary {
  const SecondaryRingRunSummary({
    required this.acquiredRings,
    required this.completed,
    this.pausedReason,
  });

  final List<SoulRing> acquiredRings;
  final bool completed;
  final String? pausedReason;
}

class GameController extends ChangeNotifier {
  GameController({
    required this.engine,
    required this.repository,
    this.spinDuration = const Duration(milliseconds: 2400),
    this.fastSpinDuration = const Duration(milliseconds: 420),
  });

  final GameEngine engine;
  final GameRepository repository;
  final Duration spinDuration;
  final Duration fastSpinDuration;

  GameState? _state;
  List<GameState> _archives = <GameState>[];
  SpinPresentation? _lastSpin;
  bool _isSpinning = false;
  bool _spinLocked = false;
  int _spinSequence = 0;
  bool _fastMode = false;
  bool _autoEventsPaused = false;
  bool _isCompletingSecondaryRings = false;
  GameSettings _settings = const GameSettings();

  GameState? get state => _state;
  List<GameState> get archives => List<GameState>.unmodifiable(_archives);
  SpinPresentation? get lastSpin => _lastSpin;
  bool get isSpinning => _isSpinning;
  bool get isJudging => _spinLocked;
  bool get fastMode => _fastMode;
  bool get autoEventsPaused => _autoEventsPaused;
  bool get isCompletingSecondaryRings => _isCompletingSecondaryRings;
  GameSettings get settings => _settings;
  bool get canContinue => _state != null && !(_state?.isFinished ?? true);
  bool get canCompleteSecondaryRings {
    final activeState = _state;
    if (activeState == null || activeState.isFinished || _spinLocked) {
      return false;
    }
    final character = activeState.character;
    return character.hasTwinMartialSouls &&
        character.soulRings.length >= 9 &&
        character.secondarySoulRings.length < 9 &&
        const <String>{
          'ringTarget',
          'ringMethod',
          'ringCandidate',
          'ringOutcome',
          'soulSpiritCandidate',
          'soulSpiritOutcome',
          'soulSpiritGrant',
          'soulBoneDrop',
          'soulBoneSlot',
          'soulBoneOutcome',
        }.contains(activeState.currentPoolId);
  }

  Future<void> load() async {
    _state = await repository.loadCurrent();
    _archives = await repository.loadArchives();
    final settingsRepository = repository;
    if (settingsRepository is GameSettingsRepository) {
      _settings = await (settingsRepository as GameSettingsRepository)
          .loadSettings();
    }
    _fastMode = _settings.fastMode;
    final loadedState = _state;
    if (loadedState != null && loadedState.isFinished) {
      await _archiveFinishedState(loadedState);
    }
    notifyListeners();
  }

  Future<void> startNew([String? seed]) async {
    _state = engine.newLife(seed ?? _newSeed());
    _lastSpin = null;
    _autoEventsPaused = false;
    await repository.saveCurrent(_state!);
    notifyListeners();
  }

  Future<void> abandonCurrentLife() async {
    await _finishCurrentLife(
      title: '命运中断',
      description: '你主动结束了这段尚未走完的人生，已有经历被保存在档案中。',
      effect: '未完人生已归档',
    );
  }

  Future<void> endCurrentLife() async {
    await _finishCurrentLife(
      title: '主动结束',
      description: '你决定在此为这段人生落下句点，所有已发生的经历已经写入档案。',
      effect: '本次人生已主动结束并归档',
    );
  }

  Future<void> _finishCurrentLife({
    required String title,
    required String description,
    required String effect,
  }) async {
    final activeState = _state;
    if (activeState == null || activeState.isFinished || _spinLocked) return;
    final abandoned = activeState.copy()
      ..isFinished = true
      ..ending = title
      ..currentPoolId = null
      ..character.status = LifeStatus.ended
      ..latestTitle = title
      ..latestResult = description
      ..latestEffects = <String>[effect];
    abandoned.timeline.add(
      TimelineEntry(
        age: abandoned.character.age,
        stage: '结局',
        title: title,
        description: abandoned.latestResult!,
        effects: <String>[effect],
      ),
    );
    _state = abandoned;
    await _archiveFinishedState(abandoned);
    notifyListeners();
  }

  void setFastMode(bool enabled) {
    if (_fastMode == enabled) return;
    _fastMode = enabled;
    _settings = _settings.copyWith(fastMode: enabled);
    final settingsRepository = repository;
    if (settingsRepository is GameSettingsRepository) {
      (settingsRepository as GameSettingsRepository).saveSettings(_settings);
    }
    notifyListeners();
  }

  Future<void> updateSettings(GameSettings settings) async {
    _settings = settings;
    _fastMode = settings.fastMode;
    final settingsRepository = repository;
    if (settingsRepository is GameSettingsRepository) {
      await (settingsRepository as GameSettingsRepository).saveSettings(
        settings,
      );
    }
    notifyListeners();
  }

  void pauseAutoEvents() {
    if (!_spinLocked) return;
    _autoEventsPaused = true;
    notifyListeners();
  }

  Future<void> resumeAutoEvents() async {
    _autoEventsPaused = false;
    notifyListeners();
    await spin();
  }

  Future<bool> unlockInvitation(String code) async {
    final activeState = _state;
    if (_spinLocked ||
        code.trim() != '239698' ||
        activeState == null ||
        activeState.isFinished) {
      return false;
    }
    if (!activeState.invitationMode) {
      final next = activeState.copy()..invitationMode = true;
      _state = next;
      await repository.saveCurrent(next);
      notifyListeners();
    }
    return true;
  }

  Future<void> continueSavedLife() async {
    _state = await repository.loadCurrent();
    _lastSpin = null;
    notifyListeners();
  }

  Future<void> spin() async {
    final activeState = _state;
    if (activeState == null || activeState.isFinished || _spinLocked) return;
    _spinLocked = true;
    try {
      await _spinOnce();

      while (_shouldContinueLifeEvents()) {
        await Future<void>.delayed(Duration.zero);
        await _spinOnce();
      }
    } finally {
      _spinLocked = false;
      if (_isSpinning) {
        _isSpinning = false;
        notifyListeners();
      }
    }
  }

  Future<SecondaryRingRunSummary> completeSecondaryRings() async {
    if (!canCompleteSecondaryRings) {
      return const SecondaryRingRunSummary(
        acquiredRings: <SoulRing>[],
        completed: false,
        pausedReason: '当前不在第二武魂连续附环阶段',
      );
    }
    _spinLocked = true;
    _isCompletingSecondaryRings = true;
    final acquired = <SoulRing>[];
    String? pausedReason;
    try {
      for (var step = 0; step < 80; step++) {
        final before = _state!.character.secondarySoulRings.length;
        await _spinOnce(skipPresentation: true);
        final activeState = _state!;
        final after = activeState.character.secondarySoulRings.length;
        if (after > before) {
          acquired.addAll(
            activeState.character.secondarySoulRings.sublist(before),
          );
        }
        if (activeState.isFinished) {
          pausedReason = '人生已经结束';
          break;
        }
        if (activeState.character.status == LifeStatus.injured ||
            (activeState.latestTitle?.contains('失败') ?? false) ||
            (activeState.latestTitle?.contains('反噬') ?? false) ||
            (activeState.latestTitle?.contains('重伤') ?? false)) {
          pausedReason = '出现高风险结果，已暂停连续附环';
          break;
        }
        if (activeState.character.secondarySoulRings.length >= 9 &&
            !const <String>{
              'soulBoneDrop',
              'soulBoneSlot',
              'soulBoneOutcome',
            }.contains(activeState.currentPoolId)) {
          break;
        }
      }
    } finally {
      _isCompletingSecondaryRings = false;
      _spinLocked = false;
      if (_isSpinning) _isSpinning = false;
      notifyListeners();
    }
    final completed = (_state?.character.secondarySoulRings.length ?? 0) >= 9;
    return SecondaryRingRunSummary(
      acquiredRings: List<SoulRing>.unmodifiable(acquired),
      completed: completed,
      pausedReason: pausedReason,
    );
  }

  bool _shouldContinueLifeEvents() {
    final state = _state;
    return !_autoEventsPaused &&
        state != null &&
        !state.isFinished &&
        state.currentPoolId == 'life' &&
        state.pendingLifeEvents > 0;
  }

  Duration presentationDurationFor(WheelPool wheel) {
    if (_settings.skipAnimations || _isCompletingSecondaryRings) {
      return Duration.zero;
    }
    final isMajorStage = <String>{
      'ringMethod',
      'ringTarget',
      'ringCandidate',
      'ringOutcome',
      'soulSpiritCandidate',
      'soulSpiritOutcome',
      'soulSpiritGrant',
      'soulBoneDrop',
      'soulBoneSlot',
      'soulBoneOutcome',
      'encounterOutcome',
      'eraMilestone',
      'beastMilestone',
      'godhoodEvent',
      'godhoodTrial',
      'godhoodOutcome',
      'ending',
    }.contains(wheel.id);
    return _fastMode && !isMajorStage ? fastSpinDuration : spinDuration;
  }

  Future<void> _spinOnce({bool skipPresentation = false}) async {
    final activeState = _state;
    if (activeState == null || activeState.isFinished) return;
    final wheel = engine.currentWheel(activeState);
    if (wheel == null) return;

    final next = engine.advance(activeState);
    final selectedIndex = wheel.options.indexWhere(
      (option) => option.text == next.latestTitle,
    );
    _lastSpin = SpinPresentation(
      wheel: wheel,
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      sequence: ++_spinSequence,
    );
    _isSpinning = true;
    notifyListeners();

    await repository.saveCurrent(next);
    if (next.isFinished) {
      await _archiveFinishedState(next);
    }
    notifyListeners();

    final presentationDuration = skipPresentation
        ? Duration.zero
        : presentationDurationFor(wheel);
    if (presentationDuration > Duration.zero) {
      await Future<void>.delayed(presentationDuration);
    }
    _state = next;
    _isSpinning = false;
    notifyListeners();
  }

  String exportArchives() => jsonEncode(<String, Object?>{
    'format': 'douluo-life-archives',
    'version': 1,
    'archives': _archives.map((state) => state.toJson()).toList(),
  });

  Future<int> importArchives(String raw) async {
    final decoded = jsonDecode(raw);
    late final List<Object?> rawItems;
    if (decoded is List<Object?>) {
      rawItems = decoded;
    } else if (decoded is Map<Object?, Object?> &&
        decoded['archives'] is List<Object?>) {
      rawItems = decoded['archives']! as List<Object?>;
    } else {
      throw const FormatException('档案备份格式不正确');
    }
    final imported = <GameState>[];
    for (final item in rawItems.whereType<Map<Object?, Object?>>()) {
      try {
        final mapped = item.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        final state = migrateGameState(GameState.fromJson(mapped));
        if (state.isFinished) imported.add(state..invitationMode = false);
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    if (imported.isEmpty) throw const FormatException('备份中没有完整人生档案');
    final merged = <GameState>[..._archives];
    var added = 0;
    for (final state in imported) {
      if (merged.any((existing) => _sameArchive(existing, state))) continue;
      merged.add(state.copy());
      added++;
    }
    await repository.replaceArchives(merged);
    _archives = await repository.loadArchives();
    notifyListeners();
    return added;
  }

  Future<void> deleteArchive(GameState target) async {
    if (target.archiveLocked) return;
    final remaining = _archives
        .where((state) => !_sameArchive(state, target))
        .toList(growable: false);
    await repository.replaceArchives(remaining);
    _archives = await repository.loadArchives();
    notifyListeners();
  }

  Future<void> renameArchive(GameState target, String alias) =>
      _updateArchive(target, (state) {
        final normalized = alias.trim();
        state.archiveAlias = normalized.isEmpty ? null : normalized;
      });

  Future<void> setArchiveFavorite(GameState target, bool favorite) =>
      _updateArchive(target, (state) => state.archiveFavorite = favorite);

  Future<void> setArchiveLocked(GameState target, bool locked) =>
      _updateArchive(target, (state) => state.archiveLocked = locked);

  Future<void> _updateArchive(
    GameState target,
    void Function(GameState state) update,
  ) async {
    final index = _archives.indexWhere((state) => _sameArchive(state, target));
    if (index < 0) return;
    final next = _archives[index].copy();
    update(next);
    final replacements = <GameState>[..._archives]..[index] = next;
    await repository.replaceArchives(replacements);
    _archives = await repository.loadArchives();
    notifyListeners();
  }

  bool _sameArchive(GameState first, GameState second) {
    if (identical(first, second)) return true;
    if (first.seed != second.seed) return false;
    if (first.archiveAlias != second.archiveAlias) return false;
    if (first.archiveFavorite != second.archiveFavorite) return false;
    if (first.archiveLocked != second.archiveLocked) return false;
    if (first.lifeEventCount != second.lifeEventCount) return false;
    if (first.timeline.length != second.timeline.length) return false;
    if (first.ending != second.ending) return false;
    if (first.character.age != second.character.age) return false;
    if (first.randomState != second.randomState) return false;
    return jsonEncode(first.toJson()) == jsonEncode(second.toJson());
  }

  Future<void> _archiveFinishedState(GameState finished) async {
    final archived = finished.copy()..invitationMode = false;
    final alreadyArchived = _archives.any(
      (archive) => _sameArchive(archive, archived),
    );
    if (!alreadyArchived) {
      await repository.saveArchive(archived);
    }
    await repository.clearCurrent();
    _archives = await repository.loadArchives();
  }

  String _newSeed() =>
      'DL-${DateTime.now().microsecondsSinceEpoch.toRadixString(16).toUpperCase()}';
}
