import '../domain/models.dart';
import 'soul_bone_quality.dart';

class CombatLoadout {
  const CombatLoadout({
    required this.offense,
    required this.defense,
    required this.control,
    required this.mobility,
    required this.recovery,
    required this.technology,
    required this.reasons,
  });

  final int offense;
  final int defense;
  final int control;
  final int mobility;
  final int recovery;
  final int technology;
  final List<String> reasons;

  int get overall =>
      offense + defense + control + mobility + recovery + technology;
}

class CombatBuildProfile {
  const CombatBuildProfile({
    required this.title,
    required this.strengths,
    required this.synergies,
    required this.risks,
  });

  final String title;
  final List<String> strengths;
  final List<String> synergies;
  final List<String> risks;
}

CombatBuildProfile combatBuildProfile(Character character) {
  final loadout = combatLoadout(character);
  final dimensions = <({String name, int value})>[
    (name: '强攻', value: loadout.offense),
    (name: '防御', value: loadout.defense),
    (name: '控制', value: loadout.control),
    (name: '机动', value: loadout.mobility),
    (name: '恢复', value: loadout.recovery),
    (name: '科技', value: loadout.technology),
  ]..sort((left, right) => right.value.compareTo(left.value));
  final strongest = dimensions.first;
  final second = dimensions[1];
  final weakest = dimensions.last;
  final synergies = <String>[
    ...loadout.reasons,
    ...character.tags.where(
      (tag) =>
          tag.startsWith('武魂融合技：') ||
          tag.startsWith('组合魂技：') ||
          tag.startsWith('双武魂组合：'),
    ),
  ];
  if (synergies.isEmpty) synergies.add('当前主要依靠基础魂力与单体魂技衔接');
  return CombatBuildProfile(
    title: '${strongest.name}主核·${second.name}辅助',
    strengths: <String>[
      '${strongest.name}${strongest.value}，是当前最稳定的胜负手段',
      '${second.name}${second.value}，支撑主核能力循环',
    ],
    synergies: List<String>.unmodifiable(synergies.toSet()),
    risks: <String>[
      '${weakest.name}${weakest.value}，面对针对性对手时可能成为短板',
      if (character.injuryTurns > 0)
        '当前伤势会同时削弱持久与容错'
      else if (character.technologyAssets.any(
        (asset) => asset.equipped && asset.integrity < 45,
      ))
        '低完整度科技装备可能在高强度战斗中失效'
      else
        '尚无致命冲突，但需防备对手针对最弱维度',
    ],
  );
}

CombatLoadout combatLoadout(Character character) {
  var offense = character.route == RouteType.soulBeast
      ? character.beastYears ~/ 8000
      : character.soulPower ~/ 4;
  var defense = character.route == RouteType.soulBeast
      ? character.beastBloodlinePower ~/ 4
      : character.soulPower ~/ 7;
  var control = character.spirit?.contains('优秀') ?? false ? 8 : 2;
  var mobility = 2;
  var recovery = 2;
  var technology =
      character.soulEngineerLevel * 2 + character.starCommandLevel * 3;
  final reasons = <String>[];

  for (final ring in <SoulRing>[
    ...character.soulRings,
    ...character.secondarySoulRings,
  ]) {
    final tier = ring.years >= 100000
        ? 6
        : ring.years >= 10000
        ? 4
        : ring.years >= 1000
        ? 3
        : 2;
    offense += tier;
    final text = '${ring.source}${ring.skillName}${ring.description}';
    if (_containsAny(text, const <String>['控制', '精神', '幻', '迟滞', '束缚'])) {
      control += tier;
    }
    if (_containsAny(text, const <String>['速度', '飞', '跃', '瞬', '风'])) {
      mobility += tier;
    }
    if (_containsAny(text, const <String>['恢复', '生命', '治疗', '守护'])) {
      recovery += tier;
    }
  }

  for (final bone in character.soulBones) {
    final value = (soulBoneQualityScore(bone, character) / 55).round().clamp(
      1,
      35,
    );
    switch (bone.slot) {
      case SoulBoneSlot.head:
        control += value;
      case SoulBoneSlot.torso:
        defense += value;
        recovery += value ~/ 3;
      case SoulBoneSlot.leftArm:
      case SoulBoneSlot.rightArm:
        offense += value;
      case SoulBoneSlot.leftLeg:
      case SoulBoneSlot.rightLeg:
        mobility += value;
      case SoulBoneSlot.external:
        offense += value ~/ 2;
        mobility += value ~/ 2;
        defense += value ~/ 3;
    }
  }

  for (final spirit in character.soulSpirits) {
    final value = (spirit.bond / 12 + spirit.years.clamp(0, 1000000) / 30000)
        .round()
        .clamp(1, 35);
    final text = '${spirit.species}${spirit.skillName}${spirit.description}';
    if (_containsAny(text, const <String>['精神', '梦', '幻', '控制', '时间'])) {
      control += value;
    }
    if (_containsAny(text, const <String>['生命', '守护', '恢复', '治疗', '涅槃'])) {
      recovery += value;
    }
    if (_containsAny(text, const <String>['风', '空间', '飞', '瞬'])) {
      mobility += value;
    }
    offense += value ~/ 2;
  }

  final armor = _rankValue(character.battleArmorStage);
  defense += armor * 5;
  offense += armor * 3;
  final mecha = _rankValue(character.mechaRank);
  defense += mecha * 3;
  mobility += mecha * 4;
  technology += mecha * 4;

  for (final asset in character.technologyAssets) {
    if (!asset.equipped || asset.memorial || asset.integrity <= 0) continue;
    final health = asset.integrity.clamp(0, 100) / 100;
    final value = (_rankValue(asset.rank) * 3 * health).round().clamp(0, 30);
    technology += value;
    final text = '${asset.name}${asset.rank}${asset.description}';
    if (_containsAny(text, const <String>['炮', '攻击', '火力', '弩', '核心'])) {
      offense += value;
    }
    if (_containsAny(text, const <String>['盾', '防御', '装甲'])) defense += value;
    if (_containsAny(text, const <String>['飞', '战机', '舰', '空间'])) {
      mobility += value;
    }
  }

  for (final set in activeSoulBoneSetBonuses(character)) {
    offense += set.offense;
    defense += set.defense;
    control += set.control;
    recovery += set.recovery;
    reasons.add('魂骨套装“${set.name}”${set.pieceCount}件共鸣');
  }
  if (character.battleArmorStage != null) {
    reasons.add('${character.battleArmorStage}提供攻防增幅');
  }
  if (character.mechaRank != null) {
    reasons.add('${character.mechaRank}提供机动与科技增幅');
  }
  if (character.soulSpirits.isNotEmpty) reasons.add('魂灵羁绊参与控制与恢复判定');

  return CombatLoadout(
    offense: offense.clamp(0, 300),
    defense: defense.clamp(0, 300),
    control: control.clamp(0, 300),
    mobility: mobility.clamp(0, 300),
    recovery: recovery.clamp(0, 300),
    technology: technology.clamp(0, 300),
    reasons: reasons,
  );
}

double combatOutcomeModifier(String optionId, CombatLoadout loadout) =>
    switch (optionId) {
      'encounter-crush' ||
      'encounter-kill' => 1 + loadout.offense / 140 + loadout.control / 260,
      'encounter-wound-opponent' ||
      'encounter-win' => 1 + loadout.offense / 220 + loadout.control / 300,
      'encounter-draw' => 1 + loadout.defense / 300,
      'encounter-escape' => 1 + loadout.mobility / 45 + loadout.control / 180,
      'encounter-defeat' =>
        1 / (1 + loadout.defense / 100 + loadout.control / 220),
      'encounter-heavy-injury' =>
        1 / (1 + loadout.defense / 65 + loadout.recovery / 80),
      'encounter-fall' =>
        1 /
            (1 +
                loadout.defense / 45 +
                loadout.mobility / 80 +
                loadout.recovery / 65),
      'cooperate-perfect' ||
      'cooperate-win' => 1 + loadout.control / 160 + loadout.technology / 180,
      'cooperate-rescue' => 1 + loadout.defense / 180 + loadout.recovery / 150,
      'cooperate-wounded' || 'cooperate-fall' =>
        1 / (1 + loadout.defense / 65 + loadout.recovery / 75),
      _ => 1,
    };

List<String> applyCombatWear(Character character, {required int severity}) {
  if (severity <= 0) return const <String>[];
  final effects = <String>[];
  if (character.soulBones.isNotEmpty) {
    character.soulBones = List<SoulBone>.from(character.soulBones);
    final index = character.soulBones.indexed
        .reduce(
          (left, right) =>
              left.$2.integrity <= right.$2.integrity ? left : right,
        )
        .$1;
    final bone = character.soulBones[index];
    final integrity = (bone.integrity - severity * 4).clamp(0, 100);
    character.soulBones[index] = bone.copyWith(integrity: integrity);
    effects.add('${bone.name}受损，完整度降至$integrity');
  }
  final activeAssets = character.technologyAssets
      .where(
        (asset) => asset.equipped && !asset.memorial && asset.integrity > 0,
      )
      .toList(growable: false);
  if (activeAssets.isNotEmpty) {
    character.technologyAssets = List<TechnologyAsset>.from(
      character.technologyAssets,
    );
    final target = activeAssets.reduce(
      (left, right) => left.integrity <= right.integrity ? left : right,
    );
    final index = character.technologyAssets.indexWhere(
      (asset) => asset.id == target.id,
    );
    final asset = character.technologyAssets[index];
    final integrity = (asset.integrity - severity * 5).clamp(0, 100);
    character.technologyAssets[index] = asset.copyWith(integrity: integrity);
    effects.add('${asset.name}受损，完整度降至$integrity');
  }
  return effects;
}

bool _containsAny(String text, Iterable<String> values) =>
    values.any(text.contains);

int _rankValue(String? rank) {
  if (rank == null) return 0;
  const levels = <String, int>{
    '一字': 1,
    '黄色': 1,
    '一级': 1,
    '二字': 2,
    '紫色': 2,
    '三级': 2,
    '四级': 2,
    '三字': 3,
    '黑色': 3,
    '五级': 3,
    '六级': 3,
    '四字': 4,
    '红级': 4,
    '七级': 4,
    '八级': 4,
    '星际': 5,
    '九级': 5,
    '旗舰': 5,
    '巡洋舰': 4,
    '突击舰': 3,
  };
  var value = 1;
  for (final entry in levels.entries) {
    if (rank.contains(entry.key) && entry.value > value) value = entry.value;
  }
  return value;
}
