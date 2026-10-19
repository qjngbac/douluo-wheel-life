import '../domain/models.dart';
import '../domain/presentation_labels.dart';
import 'game_engine.dart';

class BalanceReport {
  const BalanceReport({
    required this.runs,
    required this.completed,
    required this.humanLives,
    required this.soulBeastLives,
    required this.deaths,
    required this.godhoods,
    required this.averageJudgements,
    required this.averageSoulRings,
    required this.maximumJudgements,
    required this.nineRingLives,
    required this.hundredLevelLives,
    required this.averageHumanEndingAge,
    required this.ringColorCounts,
    required this.endingCounts,
  });

  final int runs;
  final int completed;
  final int humanLives;
  final int soulBeastLives;
  final int deaths;
  final int godhoods;
  final double averageJudgements;
  final double averageSoulRings;
  final int maximumJudgements;
  final int nineRingLives;
  final int hundredLevelLives;
  final double averageHumanEndingAge;
  final Map<RingColor, int> ringColorCounts;
  final Map<String, int> endingCounts;
}

class SoulBeastBalanceReport {
  const SoulBeastBalanceReport({
    required this.runs,
    required this.completed,
    required this.deaths,
    required this.averageLifeEvents,
    required this.pathCounts,
    required this.endingCounts,
    required this.speciesCounts,
    required this.relationshipStanceCounts,
  });

  final int runs;
  final int completed;
  final int deaths;
  final double averageLifeEvents;
  final Map<String, int> pathCounts;
  final Map<String, int> endingCounts;
  final Map<String, int> speciesCounts;
  final Map<String, int> relationshipStanceCounts;

  double get deathRate => runs == 0 ? 0 : deaths / runs;
}

BalanceReport analyzeBalance(GameEngine engine, int runs) {
  if (runs < 1) throw ArgumentError.value(runs, 'runs', '必须大于 0');
  var completed = 0;
  var humans = 0;
  var beasts = 0;
  var deaths = 0;
  var godhoods = 0;
  var judgements = 0;
  var rings = 0;
  var maximumJudgements = 0;
  var nineRingLives = 0;
  var hundredLevelLives = 0;
  var humanEndingAgeTotal = 0;
  final ringColors = <RingColor, int>{};
  final endings = <String, int>{};

  for (var index = 0; index < runs; index++) {
    final state = engine.simulateToEnd('balance-v5-$index');
    if (state.isFinished) completed++;
    if (state.character.route == RouteType.human) {
      humans++;
      humanEndingAgeTotal += state.character.age;
    } else if (state.character.route == RouteType.soulBeast) {
      beasts++;
    }
    if (state.character.status == LifeStatus.dead) deaths++;
    if (state.character.godhood != null) godhoods++;
    if (state.character.soulRings.length >= 9) nineRingLives++;
    if (state.character.route == RouteType.human &&
        state.character.soulPower >= 100) {
      hundredLevelLives++;
    }
    judgements += state.timeline.length;
    if (state.timeline.length > maximumJudgements) {
      maximumJudgements = state.timeline.length;
    }
    rings += state.character.soulRings.length;
    for (final ring in state.character.soulRings) {
      ringColors[ring.color] = (ringColors[ring.color] ?? 0) + 1;
    }
    final ending = state.ending ?? '未命名结局';
    endings[ending] = (endings[ending] ?? 0) + 1;
  }

  return BalanceReport(
    runs: runs,
    completed: completed,
    humanLives: humans,
    soulBeastLives: beasts,
    deaths: deaths,
    godhoods: godhoods,
    averageJudgements: judgements / runs,
    averageSoulRings: rings / runs,
    maximumJudgements: maximumJudgements,
    nineRingLives: nineRingLives,
    hundredLevelLives: hundredLevelLives,
    averageHumanEndingAge: humans == 0 ? 0 : humanEndingAgeTotal / humans,
    ringColorCounts: Map<RingColor, int>.unmodifiable(ringColors),
    endingCounts: Map<String, int>.unmodifiable(endings),
  );
}

String _soulBeastEndingCategory(String? ending) {
  final value = ending ?? '未命名结局';
  return value.split('·').first.trim();
}

SoulBeastBalanceReport analyzeSoulBeastBalance(int runs) {
  if (runs < 1) throw ArgumentError.value(runs, 'runs', '必须大于 0');
  final engine = GameEngine(data: const GameData.forceSoulBeast());
  var completed = 0;
  var deaths = 0;
  var lifeEvents = 0;
  final paths = <String, int>{};
  final endings = <String, int>{};
  final species = <String, int>{};
  final relationshipStances = <String, int>{};
  for (var index = 0; index < runs; index++) {
    final state = engine.simulateToEnd('beast-balance-v7-$index');
    if (state.isFinished) completed++;
    if (state.character.status == LifeStatus.dead) deaths++;
    lifeEvents += state.lifeEventCount;
    final path = state.character.beastPath;
    final ending = _soulBeastEndingCategory(state.ending);
    final archetype = state.character.beastArchetype;
    paths[path] = (paths[path] ?? 0) + 1;
    endings[ending] = (endings[ending] ?? 0) + 1;
    species[archetype] = (species[archetype] ?? 0) + 1;
    for (final relationship in state.relationships) {
      final stance = playerFacingRelationshipStance(relationship);
      relationshipStances[stance] = (relationshipStances[stance] ?? 0) + 1;
    }
  }
  return SoulBeastBalanceReport(
    runs: runs,
    completed: completed,
    deaths: deaths,
    averageLifeEvents: lifeEvents / runs,
    pathCounts: Map<String, int>.unmodifiable(paths),
    endingCounts: Map<String, int>.unmodifiable(endings),
    speciesCounts: Map<String, int>.unmodifiable(species),
    relationshipStanceCounts: Map<String, int>.unmodifiable(
      relationshipStances,
    ),
  );
}
