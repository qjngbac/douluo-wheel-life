import '../domain/models.dart';
import 'combat_loadout_engine.dart';
import 'life_identity_engine.dart';
import 'soul_bone_quality.dart';
import 'soul_spirit_growth.dart';
import 'technology_asset_engine.dart';

const Set<RingColor> _standardRingColors = <RingColor>{
  RingColor.white,
  RingColor.yellow,
  RingColor.purple,
  RingColor.black,
  RingColor.red,
  RingColor.gold,
};

class RareRingDiscovery {
  const RareRingDiscovery({
    required this.color,
    required this.source,
    required this.maximumYears,
    required this.firstLifeTitle,
    required this.firstLifeSeed,
  });

  final RingColor color;
  final String source;
  final int maximumYears;
  final String firstLifeTitle;
  final String firstLifeSeed;
}

class ArchiveRecord {
  const ArchiveRecord({
    required this.label,
    required this.value,
    required this.lifeTitle,
    required this.lifeSeed,
  });

  final String label;
  final int value;
  final String lifeTitle;
  final String lifeSeed;
}

class CrossLifeDiscovery {
  const CrossLifeDiscovery({
    required this.name,
    required this.firstLifeTitle,
    required this.firstLifeSeed,
    required this.highestQuality,
    required this.highestQualityLabel,
    required this.occurrenceCount,
    required this.lifeTitles,
  });

  final String name;
  final String firstLifeTitle;
  final String firstLifeSeed;
  final int highestQuality;
  final String highestQualityLabel;
  final int occurrenceCount;
  final List<String> lifeTitles;
}

class AchievementDiscovery {
  const AchievementDiscovery({
    required this.name,
    required this.unlocked,
    required this.lifeTitles,
  });

  final String name;
  final bool unlocked;
  final List<String> lifeTitles;
}

class ArchiveCollectionSummary {
  const ArchiveCollectionSummary({
    required this.rareRings,
    required this.soulBoneDiscoveries,
    required this.soulSpiritDiscoveries,
    required this.technologyDiscoveries,
    required this.achievements,
    this.strongestRing,
    this.highestSoulPower,
    this.highestBeastYears,
    this.mostAllies,
    this.largestClan,
    this.rarestBeastPath,
    this.strongestSoulBone,
    this.highestCombatLoadout,
    this.richestResources,
  });

  final List<RareRingDiscovery> rareRings;
  final List<CrossLifeDiscovery> soulBoneDiscoveries;
  final List<CrossLifeDiscovery> soulSpiritDiscoveries;
  final List<CrossLifeDiscovery> technologyDiscoveries;
  final List<AchievementDiscovery> achievements;
  final ArchiveRecord? strongestRing;
  final ArchiveRecord? highestSoulPower;
  final ArchiveRecord? highestBeastYears;
  final ArchiveRecord? mostAllies;
  final ArchiveRecord? largestClan;
  final ArchiveRecord? rarestBeastPath;
  final ArchiveRecord? strongestSoulBone;
  final ArchiveRecord? highestCombatLoadout;
  final ArchiveRecord? richestResources;
}

ArchiveCollectionSummary composeArchiveCollectionSummary(
  List<GameState> archives,
) {
  final rareRings = <String, RareRingDiscovery>{};
  for (final state in archives.reversed) {
    for (final ring in _allRings(state.character)) {
      if (_standardRingColors.contains(ring.color)) continue;
      final source = ring.source.trim().isEmpty ? '未知魂兽' : ring.source;
      final key = '${enumName(ring.color)}|$source';
      final existing = rareRings[key];
      rareRings[key] = RareRingDiscovery(
        color: ring.color,
        source: source,
        maximumYears: existing == null
            ? ring.years
            : (ring.years > existing.maximumYears
                  ? ring.years
                  : existing.maximumYears),
        firstLifeTitle: existing?.firstLifeTitle ?? state.ending ?? '未命名人生',
        firstLifeSeed: existing?.firstLifeSeed ?? state.seed,
      );
    }
  }
  final sortedRings = rareRings.values.toList()
    ..sort((a, b) => b.maximumYears.compareTo(a.maximumYears));
  final soulBoneDiscoveries = _collectDiscoveries(
    archives,
    itemsOf: (state) =>
        <SoulBone>[
          ...state.character.soulBones,
          ...state.character.spareSoulBones,
        ].map(
          (bone) => (
            name: bone.name,
            quality: soulBoneQualityScore(bone, state.character),
            label:
                '${bone.years}年 · ${soulBoneQualityScore(bone, state.character)}分 · ${soulBoneSlotName(bone.slot)}',
          ),
        ),
  );
  final soulSpiritDiscoveries = _collectDiscoveries(
    archives,
    itemsOf: (state) => state.character.soulSpirits.map((spirit) {
      final profile = soulSpiritGrowthProfile(spirit, state.character);
      final score = spirit.years ~/ 1000 + spirit.bond + profile.affinity;
      return (
        name: spirit.name,
        quality: score,
        label:
            '${spirit.quality} · ${profile.growthStage} · 契合${profile.affinity}',
      );
    }),
  );
  final technologyDiscoveries = _collectDiscoveries(
    archives,
    itemsOf: (state) => state.character.technologyAssets.map(
      (asset) => (
        name: asset.name,
        quality: technologyAssetQualityScore(asset),
        label:
            '${asset.rank} · +${asset.upgradeLevel} · ${technologyAssetStatus(asset)}',
      ),
    ),
  );
  const achievementNames = <String>[
    '九环人生',
    '逆天第一环',
    '六骨共鸣',
    '双生绝巅',
    '登临神界',
    '万兽共主',
    '魂导神匠',
  ];
  final achievementLives = <String, List<String>>{};
  for (final state in archives) {
    final lifeTitle = _lifeTitle(state);
    final unlocked = <String>{
      ...lifeAchievements(state.character),
      ...derivedLifeTitles(state.character),
    };
    for (final achievement in unlocked) {
      achievementLives.putIfAbsent(achievement, () => <String>[]);
      if (!achievementLives[achievement]!.contains(lifeTitle)) {
        achievementLives[achievement]!.add(lifeTitle);
      }
    }
  }

  final beastPathCounts = <String, int>{};
  for (final state in archives) {
    if (state.character.route != RouteType.soulBeast) continue;
    final path = state.character.beastPath;
    if (path == '尚未选择' || path.trim().isEmpty) continue;
    beastPathCounts[path] = (beastPathCounts[path] ?? 0) + 1;
  }
  final rarestPath = beastPathCounts.entries.toList()
    ..sort((a, b) {
      final byCount = a.value.compareTo(b.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });

  return ArchiveCollectionSummary(
    rareRings: List<RareRingDiscovery>.unmodifiable(sortedRings),
    soulBoneDiscoveries: soulBoneDiscoveries,
    soulSpiritDiscoveries: soulSpiritDiscoveries,
    technologyDiscoveries: technologyDiscoveries,
    achievements: <String>{...achievementNames, ...achievementLives.keys}
        .map(
          (name) => AchievementDiscovery(
            name: name,
            unlocked: achievementLives.containsKey(name),
            lifeTitles: List<String>.unmodifiable(
              achievementLives[name] ?? const <String>[],
            ),
          ),
        )
        .toList(growable: false),
    strongestRing: _maximumRecord(
      archives,
      label: '最强魂环',
      valueOf: (state) => _allRings(
        state.character,
      ).fold<int>(0, (best, ring) => ring.years > best ? ring.years : best),
    ),
    highestSoulPower: _maximumRecord(
      archives.where((state) => state.character.route != RouteType.soulBeast),
      label: '最高魂力',
      valueOf: (state) => state.character.soulPower,
    ),
    highestBeastYears: _maximumRecord(
      archives.where((state) => state.character.route == RouteType.soulBeast),
      label: '最高魂兽修为',
      valueOf: (state) => state.character.beastYears,
    ),
    mostAllies: _maximumRecord(
      archives,
      label: '最多盟友',
      valueOf: (state) => state.relationships
          .where(
            (relationship) => relationship.alive && relationship.trust >= 70,
          )
          .length,
    ),
    largestClan: _maximumRecord(
      archives.where((state) => state.character.route == RouteType.soulBeast),
      label: '最大族群',
      valueOf: (state) => state.character.beastClanPopulation,
    ),
    rarestBeastPath: rarestPath.isEmpty
        ? null
        : ArchiveRecord(
            label: '最稀有命途：${rarestPath.first.key}（${rarestPath.first.value}次）',
            value: rarestPath.first.value,
            lifeTitle:
                archives
                    .firstWhere(
                      (state) =>
                          state.character.route == RouteType.soulBeast &&
                          state.character.beastPath == rarestPath.first.key,
                    )
                    .ending ??
                '未命名人生',
            lifeSeed: archives
                .firstWhere(
                  (state) =>
                      state.character.route == RouteType.soulBeast &&
                      state.character.beastPath == rarestPath.first.key,
                )
                .seed,
          ),
    strongestSoulBone: _maximumRecord(
      archives,
      label: '最强魂骨',
      valueOf: (state) => state.character.soulBones.fold<int>(0, (best, bone) {
        final score = soulBoneQualityScore(bone, state.character);
        return score > best ? score : best;
      }),
    ),
    highestCombatLoadout: _maximumRecord(
      archives,
      label: '最高综合战力',
      valueOf: (state) => combatLoadout(state.character).overall,
    ),
    richestResources: _maximumRecord(
      archives,
      label: '最多成长资源',
      valueOf: (state) =>
          state.character.goldCoins + state.character.rareMetals * 10,
    ),
  );
}

List<CrossLifeDiscovery> _collectDiscoveries(
  List<GameState> archives, {
  required Iterable<({String name, int quality, String label})> Function(
    GameState state,
  )
  itemsOf,
}) {
  final builders = <String, _DiscoveryBuilder>{};
  for (final state in archives.reversed) {
    final title = _lifeTitle(state);
    for (final item in itemsOf(state)) {
      final builder = builders.putIfAbsent(
        item.name,
        () => _DiscoveryBuilder(
          name: item.name,
          firstLifeTitle: title,
          firstLifeSeed: state.seed,
          highestQuality: item.quality,
          highestQualityLabel: item.label,
        ),
      );
      builder.occurrenceCount++;
      if (!builder.lifeTitles.contains(title)) builder.lifeTitles.add(title);
      if (item.quality > builder.highestQuality) {
        builder
          ..highestQuality = item.quality
          ..highestQualityLabel = item.label;
      }
    }
  }
  final result = builders.values
      .map(
        (builder) => CrossLifeDiscovery(
          name: builder.name,
          firstLifeTitle: builder.firstLifeTitle,
          firstLifeSeed: builder.firstLifeSeed,
          highestQuality: builder.highestQuality,
          highestQualityLabel: builder.highestQualityLabel,
          occurrenceCount: builder.occurrenceCount,
          lifeTitles: List<String>.unmodifiable(builder.lifeTitles),
        ),
      )
      .toList();
  result.sort((left, right) {
    final byQuality = right.highestQuality.compareTo(left.highestQuality);
    return byQuality != 0 ? byQuality : left.name.compareTo(right.name);
  });
  return List<CrossLifeDiscovery>.unmodifiable(result);
}

class _DiscoveryBuilder {
  _DiscoveryBuilder({
    required this.name,
    required this.firstLifeTitle,
    required this.firstLifeSeed,
    required this.highestQuality,
    required this.highestQualityLabel,
  });

  final String name;
  final String firstLifeTitle;
  final String firstLifeSeed;
  int highestQuality;
  String highestQualityLabel;
  int occurrenceCount = 0;
  final List<String> lifeTitles = <String>[];
}

String _lifeTitle(GameState state) =>
    state.archiveAlias?.trim().isNotEmpty == true
    ? state.archiveAlias!.trim()
    : state.ending ?? displayLifeName(state.character);

List<SoulRing> _allRings(Character character) => <SoulRing>[
  ...character.soulRings,
  ...character.secondarySoulRings,
];

ArchiveRecord? _maximumRecord(
  Iterable<GameState> states, {
  required String label,
  required int Function(GameState state) valueOf,
}) {
  GameState? best;
  var value = -1;
  for (final state in states) {
    final candidate = valueOf(state);
    if (candidate <= value) continue;
    best = state;
    value = candidate;
  }
  if (best == null) return null;
  return ArchiveRecord(
    label: label,
    value: value,
    lifeTitle: best.ending ?? '未命名人生',
    lifeSeed: best.seed,
  );
}
