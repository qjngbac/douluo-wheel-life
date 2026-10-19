import 'game_engine.dart';
import '../data/soul_beast_data.dart';
import '../domain/models.dart';

class ContentCoverageReport {
  const ContentCoverageReport({
    required this.runs,
    required this.eventCounts,
    required this.completedArcCounts,
    required this.soulBeastCandidateCounts,
    required this.godhoodPathCounts,
    required this.endingCounts,
    required this.unreachedEventIds,
  });

  final int runs;
  final Map<String, int> eventCounts;
  final Map<String, int> completedArcCounts;
  final Map<String, int> soulBeastCandidateCounts;
  final Map<String, int> godhoodPathCounts;
  final Map<String, int> endingCounts;
  final Set<String> unreachedEventIds;
}

class FirstRingCoverageReport {
  const FirstRingCoverageReport({
    required this.runs,
    required this.completedSamples,
    required this.candidateCounts,
    required this.habitatCounts,
    required this.rareCandidateAppearances,
    required this.totalCandidateAppearances,
  });

  final int runs;
  final int completedSamples;
  final Map<String, int> candidateCounts;
  final Map<String, int> habitatCounts;
  final int rareCandidateAppearances;
  final int totalCandidateAppearances;

  double get mostCommonShare {
    if (totalCandidateAppearances == 0 || candidateCounts.isEmpty) return 0;
    final maximum = candidateCounts.values.reduce((a, b) => a > b ? a : b);
    return maximum / totalCandidateAppearances;
  }
}

FirstRingCoverageReport analyzeFirstRingCoverage(int runs) {
  if (runs < 1) throw ArgumentError.value(runs, 'runs', '必须大于 0');
  final engine = GameEngine.production();
  const samples = <({String id, String name, String habitat, String soul})>[
    (id: 'ring-family', name: '家族帮助猎魂', habitat: '森林', soul: '青藤长弓'),
    (id: 'ring-team', name: '朋友组队', habitat: '湿地', soul: '玄水龟甲'),
    (id: 'ring-alone', name: '独自猎魂', habitat: '荒原', soul: '影狼'),
    (id: 'ring-chance', name: '意外遇见', habitat: '海域', soul: '潮汐海螺'),
    (id: 'ring-academy', name: '学院老师带队', habitat: '学院圈养', soul: '柔骨兔'),
    (id: 'ring-clue', name: '购买情报', habitat: '非法猎魂', soul: '幽冥灵猫'),
  ];
  var completed = 0;
  var rareAppearances = 0;
  var totalAppearances = 0;
  final candidates = <String, int>{};
  final habitats = <String, int>{};
  for (var index = 0; index < runs; index++) {
    final sample = samples[index % samples.length];
    final state = GameState(
      seed: 'first-ring-coverage-$index',
      randomState: index + 1,
      currentPoolId: 'ringCandidate',
      pendingRingTarget: MartialSoulSlot.primary,
      pendingHunt: HuntContext(
        methodId: sample.id,
        methodName: sample.name,
        riskMultiplier: 1,
        affinityMultiplier: 1,
        habitat: sample.habitat,
      ),
      character: Character(
        route: RouteType.human,
        age: 6,
        soulPower: 10,
        martialSoul: sample.soul,
      ),
    );
    final wheel = engine.currentWheel(state);
    if (wheel == null || wheel.options.isEmpty) continue;
    completed++;
    for (final option in wheel.options) {
      totalAppearances++;
      candidates[option.id] = (candidates[option.id] ?? 0) + 1;
      final profile = soulBeastProfileForId(option.id);
      if (profile == null) continue;
      if (profile.quality >= 2) rareAppearances++;
      for (final habitat in profile.habitats) {
        if (habitat == '通用') continue;
        habitats[habitat] = (habitats[habitat] ?? 0) + 1;
      }
    }
  }
  return FirstRingCoverageReport(
    runs: runs,
    completedSamples: completed,
    candidateCounts: Map<String, int>.unmodifiable(candidates),
    habitatCounts: Map<String, int>.unmodifiable(habitats),
    rareCandidateAppearances: rareAppearances,
    totalCandidateAppearances: totalAppearances,
  );
}

ContentCoverageReport analyzeContentCoverage(GameEngine engine, int runs) {
  if (runs < 1) throw ArgumentError.value(runs, 'runs', '必须大于 0');
  final eventCounts = <String, int>{};
  final arcCounts = <String, int>{};
  final candidateCounts = <String, int>{};
  final godhoodCounts = <String, int>{};
  final endingCounts = <String, int>{};
  final maximumArcStages = <String, int>{};
  for (final event in engine.data.events) {
    final arcId = event.arcId;
    if (arcId != null) {
      maximumArcStages[arcId] = event.arcStage > (maximumArcStages[arcId] ?? 0)
          ? event.arcStage
          : maximumArcStages[arcId]!;
    }
  }

  for (var index = 0; index < runs; index++) {
    var state = engine.newLife('coverage-v1-$index');
    for (var turn = 0; turn < 900 && !state.isFinished; turn++) {
      final wheel = engine.currentWheel(state);
      if (wheel?.id == 'ringCandidate') {
        for (final option in wheel!.options) {
          candidateCounts[option.id] = (candidateCounts[option.id] ?? 0) + 1;
        }
      }
      state = engine.advance(state);
    }
    for (final entry in state.eventCounts.entries) {
      eventCounts[entry.key] = (eventCounts[entry.key] ?? 0) + entry.value;
    }
    for (final entry in state.arcStages.entries) {
      if (entry.value >= (maximumArcStages[entry.key] ?? 999)) {
        arcCounts[entry.key] = (arcCounts[entry.key] ?? 0) + 1;
      }
    }
    for (final tag in state.character.tags.where(
      (tag) => tag.startsWith('神途:'),
    )) {
      godhoodCounts[tag] = (godhoodCounts[tag] ?? 0) + 1;
    }
    final ending = state.ending ?? '未命名结局';
    endingCounts[ending] = (endingCounts[ending] ?? 0) + 1;
  }
  final unreached = engine.data.events
      .map((event) => event.id)
      .where((id) => !eventCounts.containsKey(id))
      .toSet();
  return ContentCoverageReport(
    runs: runs,
    eventCounts: Map<String, int>.unmodifiable(eventCounts),
    completedArcCounts: Map<String, int>.unmodifiable(arcCounts),
    soulBeastCandidateCounts: Map<String, int>.unmodifiable(candidateCounts),
    godhoodPathCounts: Map<String, int>.unmodifiable(godhoodCounts),
    endingCounts: Map<String, int>.unmodifiable(endingCounts),
    unreachedEventIds: Set<String>.unmodifiable(unreached),
  );
}
