import '../domain/models.dart';
import '../engine/seeded_random.dart';
import '../engine/soul_beast_archetype.dart';
import '../engine/twin_martial_soul_engine.dart';

GameState migrateGameState(GameState state) {
  var migrated = state.copy();

  if (state.contentVersion < 7 &&
      migrated.character.technologyAssets.isNotEmpty &&
      !migrated.character.technologyAssets.any((asset) => asset.equipped)) {
    final equippedTypes = <TechnologyType>{};
    migrated.character.technologyAssets = migrated.character.technologyAssets
        .map((asset) {
          final shouldEquip =
              !asset.memorial &&
              asset.integrity > 0 &&
              equippedTypes.add(asset.type);
          return asset.copyWith(equipped: shouldEquip);
        })
        .toList(growable: false);
  }

  if (const <String>{
        'v1',
        'v2',
        'v3',
        'v4',
        'v5',
      }.contains(state.dataVersion) &&
      migrated.character.route == RouteType.human &&
      migrated.character.lifeExpectancy == 0) {
    migrated.character.lifeExpectancy =
        88 + SeededRandom.fromSeed('${migrated.seed}:lifespan-v5').nextInt(31);
  }

  if (migrated.character.route == RouteType.soulBeast) {
    migrated.character.soulPower = 0;
    migrated.character.soulRings = <SoulRing>[];
    migrated.character.secondaryMartialSoul = null;
    migrated.character.secondarySoulRings = <SoulRing>[];
    if (migrated.character.lifeStartAge == 0) {
      migrated.character.lifeStartAge = migrated.character.age;
    }
    if (migrated.character.beastBloodlinePower == 0) {
      migrated.character.beastBloodlinePower =
          switch (migrated.character.family) {
            '王族血脉' => 75,
            '远古遗脉' => 60,
            '纯净血脉' => 45,
            '普通血脉' => 30,
            _ => 18,
          };
    }
    if (migrated.character.beastIntelligence == 0) {
      migrated.character.beastIntelligence =
          switch (migrated.character.beastYears) {
            >= 100000 => 65,
            >= 10000 => 48,
            >= 1000 => 30,
            >= 100 => 18,
            _ => 8,
          };
    }
    if (migrated.character.beastTerritory == 0) {
      migrated.character.beastTerritory = 12;
    }
    final archetype = soulBeastArchetypeFor(migrated.character.martialSoul);
    if (migrated.character.beastArchetype == '陆生兽族' &&
        archetype != SoulBeastArchetype.land) {
      migrated.character.beastArchetype = soulBeastArchetypeName(archetype);
    }
    if (migrated.character.beastHabitat == '未定栖息地' &&
        migrated.character.timeline != null) {
      migrated.character.beastHabitat = migrated.character.timeline!;
    }
    if (migrated.character.beastClanPopulation <= 1) {
      migrated.character.beastClanPopulation =
          1 + migrated.character.beastPrestige ~/ 5;
    }
    if (migrated.character.maximumHumanThreat <
        migrated.character.humanThreat) {
      migrated.character.maximumHumanThreat = migrated.character.humanThreat;
    }
  }

  if (migrated.character.route == RouteType.human &&
      migrated.character.martialSoul == '双生武魂' &&
      migrated.character.secondaryMartialSoul == null) {
    const concreteSouls = <String>[
      '青藤长弓',
      '影狼',
      '流火灯',
      '星纹罗盘',
      '回春铃',
      '明镜之眼',
      '苍雷龙印',
    ];
    final random = SeededRandom.fromSeed('${migrated.seed}:twin-souls');
    final primaryIndex = random.nextInt(concreteSouls.length);
    var secondaryIndex = random.nextInt(concreteSouls.length - 1);
    if (secondaryIndex >= primaryIndex) secondaryIndex++;
    migrated.character
      ..martialSoul = concreteSouls[primaryIndex]
      ..secondaryMartialSoul = concreteSouls[secondaryIndex];
    if (!migrated.character.tags.contains('双生武魂')) {
      migrated.character.tags.add('双生武魂');
    }
  }

  if (migrated.character.route == RouteType.human &&
      migrated.character.hasTwinMartialSouls) {
    applyTwinMartialSoulAwakening(migrated.character);
    unlockTwinMartialSoulFusion(migrated.character);
  }

  const godhoodStages = <String>{
    'godhoodEvent',
    'godhoodTrial',
    'godhoodOutcome',
  };
  if (!migrated.isFinished &&
      migrated.character.hasTwinMartialSouls &&
      (migrated.character.soulRings.length < 9 ||
          migrated.character.secondarySoulRings.length < 9) &&
      godhoodStages.contains(migrated.currentPoolId)) {
    migrated
      ..currentPoolId = 'ringTarget'
      ..pendingRing = null
      ..pendingHunt = null
      ..pendingRingTarget = null
      ..pendingGodPathId = null
      ..godTrialStep = 0
      ..godTrialScore = 0;
    migrated.character.tags.removeWhere((tag) => tag.startsWith('神途:'));
  }

  if (migrated.currentPoolId == 'cultivationGrowth' &&
      migrated.pendingYears == 0) {
    migrated.pendingYears = _recoverPendingYears(migrated.timeline);
  }

  if (migrated.dataVersion != currentDataVersion ||
      migrated.rngVersion != currentRngVersion ||
      migrated.contentVersion != currentContentVersion) {
    migrated = GameState.fromJson(<String, Object?>{
      ...migrated.toJson(),
      'dataVersion': currentDataVersion,
      'rngVersion': currentRngVersion,
      'contentVersion': currentContentVersion,
    });
  }
  return migrated;
}

int _recoverPendingYears(List<TimelineEntry> timeline) {
  final ageEffect = RegExp(r'^年龄 \+(\d+) 岁$');
  if (timeline.isEmpty) return 1;
  for (final effect in timeline.last.effects.reversed) {
    final match = ageEffect.firstMatch(effect);
    if (match != null) return int.parse(match.group(1)!).clamp(1, 1000000);
  }
  return 1;
}
