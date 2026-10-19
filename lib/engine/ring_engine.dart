import 'dart:math' as math;

import '../data/ring_data.dart';
import '../data/soul_beast_data.dart';
import '../domain/models.dart';
import 'seeded_random.dart';

RingColor ringColorForYears(int years) {
  if (years < 100) return RingColor.white;
  if (years < 1000) return RingColor.yellow;
  if (years < 10000) return RingColor.purple;
  if (years < 100000) return RingColor.black;
  if (years < 1000000) return RingColor.red;
  return RingColor.gold;
}

class RingYearRange {
  const RingYearRange(this.lower, this.upper);

  final int lower;
  final int upper;
}

const List<RingYearRange> _baseRingRanges = <RingYearRange>[
  RingYearRange(320, 480),
  RingYearRange(650, 950),
  RingYearRange(2400, 3600),
  RingYearRange(5600, 8500),
  RingYearRange(10000, 15000),
  RingYearRange(19000, 28000),
  RingYearRange(45000, 62000),
  RingYearRange(62000, 85000),
  RingYearRange(90000, 130000),
];

RingYearRange ringYearRangeFor(
  Character character,
  int ringNumber,
  String source, {
  bool invitationMode = false,
}) {
  final index = (ringNumber - 1).clamp(0, _baseRingRanges.length - 1);
  final special = _specialRingRange(source);
  final base = special ?? _baseRingRanges[index];
  final affinity = special == null
      ? (soulBeastProfileForName(source)?.affinity ??
                ringSourceAffinity[source] ??
                100) /
            100
      : 1.0;
  // 能力会拓宽可遇见魂环的范围，但增长幅度低于真正的承受上限，
  // 避免“遇见更高年限”与“更能承受”完全互相抵消。
  final discoveryMultiplier = math.sqrt(_ringAbilityMultiplier(character));
  final invitationMultiplier = invitationMode && special == null
      ? _invitationRingMultiplier(ringNumber)
      : 1.0;
  final multiplier = affinity * discoveryMultiplier * invitationMultiplier;
  final minimum = special?.lower ?? (ringNumber >= 5 ? 10000 : 10);
  final maximum = invitationMode ? 2000000 : 1000000;
  final lower = (base.lower * multiplier).round().clamp(minimum, maximum);
  final upper = (base.upper * multiplier).round().clamp(lower, maximum);
  return RingYearRange(lower, upper);
}

int ringSafetyUpperFor(
  Character character,
  int ringNumber,
  String source, {
  bool invitationMode = false,
}) {
  final index = (ringNumber - 1).clamp(0, _baseRingRanges.length - 1);
  final special = _specialRingRange(source);
  final baseline = (special ?? _baseRingRanges[index]).upper;
  final invitationMultiplier = invitationMode && special == null
      ? _invitationRingMultiplier(ringNumber)
      : 1.0;
  return (baseline * _ringAbilityMultiplier(character) * invitationMultiplier)
      .round()
      .clamp(1, 10000000);
}

double _invitationRingMultiplier(int ringNumber) =>
    8 + (ringNumber - 1).clamp(0, 8) * .5;

RingYearRange? _specialRingRange(String source) {
  final profile = soulBeastProfileForName(source);
  if (profile?.specialYearsLower != null &&
      profile?.specialYearsUpper != null) {
    return RingYearRange(
      profile!.specialYearsLower!,
      profile.specialYearsUpper!,
    );
  }
  return switch (source) {
    '神赐魂环' => const RingYearRange(800000, 1000000),
    '自愿献祭的魂兽' => const RingYearRange(100000, 350000),
    '凶兽本源魂环' => const RingYearRange(250000, 750000),
    '生命古树之灵' => const RingYearRange(120000, 600000),
    _ => null,
  };
}

double _ringAbilityMultiplier(Character character) {
  final constitution = switch (character.constitution) {
    '虚弱' => .8,
    '健康' => 1.05,
    '优秀' => 1.15,
    '天赋异禀' => 1.3,
    '怪物体质' => 1.5,
    _ => 1.0,
  };
  final spirit = switch (character.spirit) {
    '迟钝' => .85,
    '敏锐' => 1.05,
    '优秀' => 1.15,
    '精神天才' => 1.3,
    '特殊精神体质' => 1.45,
    _ => 1.0,
  };
  final talent = switch (character.talent) {
    '无魂师天赋' => .7,
    '微弱' => .85,
    '良好' => 1.05,
    '优秀' => 1.12,
    '顶尖' => 1.2,
    '绝世' => 1.32,
    '妖孽' => 1.45,
    '神级潜质' => 1.6,
    '未知变异' => 1.15,
    _ => 1.0,
  };
  final capacity = 1 + character.ringCapacityBonus / 100;
  return constitution * spirit * talent * capacity;
}

RingColor ringColorForSource(String source, int years) =>
    soulBeastProfileForName(source)?.specialColor ??
    switch (source) {
      '神赐魂环' => RingColor.gold,
      '凶兽本源魂环' => RingColor.orangeGold,
      '生命古树之灵' => RingColor.greenGold,
      _ => ringColorForYears(years),
    };

double specialRingChanceFor({
  required int ringNumber,
  required int years,
  bool invitationMode = false,
}) {
  final ringProgress = (ringNumber - 1).clamp(0, 8) * .018;
  final yearBonus = switch (years) {
    >= 1000000 => .12,
    >= 100000 => .08,
    >= 10000 => .05,
    >= 1000 => .025,
    _ => 0.0,
  };
  return (.025 + ringProgress + yearBonus + (invitationMode ? .18 : 0)).clamp(
    .025,
    invitationMode ? .55 : .28,
  );
}

List<RingColor> specialRingPaletteFor({
  required int ringNumber,
  required int years,
}) {
  final colors = <RingColor>[
    RingColor.green,
    RingColor.moonWhite,
    RingColor.redBrown,
  ];
  if (ringNumber >= 3 || years >= 1000) {
    colors.addAll(const <RingColor>[
      RingColor.cyan,
      RingColor.emerald,
      RingColor.silverViolet,
    ]);
  }
  if (ringNumber >= 5 || years >= 10000) {
    colors.addAll(const <RingColor>[
      RingColor.roseGold,
      RingColor.orangeGold,
      RingColor.greenGold,
      RingColor.blueGold,
    ]);
  }
  if (ringNumber >= 8 || years >= 100000) {
    colors.addAll(const <RingColor>[RingColor.crimsonGold, RingColor.rainbow]);
  }
  return List<RingColor>.unmodifiable(colors);
}

bool _hasFixedSpecialColor(String source) =>
    soulBeastProfileForName(source)?.specialColor != null ||
    source == '神赐魂环' ||
    source == '凶兽本源魂环' ||
    source == '生命古树之灵';

class RingEngine {
  const RingEngine();

  SoulRing createRing({
    required Character character,
    required String source,
    required SeededRandom random,
    bool invitationMode = false,
    int? ringNumber,
  }) {
    final resolvedRingNumber = ringNumber ?? character.soulRings.length + 1;
    final range = ringYearRangeFor(
      character,
      resolvedRingNumber,
      source,
      invitationMode: invitationMode,
    );
    var safeYears = range.lower + random.nextInt(range.upper - range.lower + 1);
    if (invitationMode && safeYears % 10000 == 0) {
      safeYears = safeYears < range.upper ? safeYears + 1 : safeYears - 1;
    }
    final names =
        skillNamesBySoulType[character.martialSoul] ??
        const <String>['魂力震荡', '命运回响', '灵息加护'];
    final baseSkill = names[random.nextInt(names.length)];
    final sourceTrait = _sourceTrait(source);
    final tier = _yearTier(safeYears);
    final skill = '$baseSkill·$sourceTrait$tier';
    var color = ringColorForSource(source, safeYears);
    final colorRandom = SeededRandom.fromSeed(
      '${random.state}|special-ring|$source|$safeYears|$resolvedRingNumber',
    );
    if (!_hasFixedSpecialColor(source) &&
        colorRandom.nextDouble() <
            specialRingChanceFor(
              ringNumber: resolvedRingNumber,
              years: safeYears,
              invitationMode: invitationMode,
            )) {
      final palette = specialRingPaletteFor(
        ringNumber: resolvedRingNumber,
        years: safeYears,
      );
      color = palette[colorRandom.nextInt(palette.length)];
    }

    return SoulRing(
      color: color,
      years: safeYears,
      source: source,
      skillName: skill,
      description:
          '$source 的$sourceTrait特性融入${character.martialSoul ?? '当前武魂'}，化作“$skill”。',
    );
  }
}

String _sourceTrait(String source) {
  final configuredTrait = soulBeastProfileForName(source)?.trait;
  if (configuredTrait != null) return configuredTrait;
  if (source.contains('雷') || source.contains('龙')) return '雷霆';
  if (source.contains('藤') || source.contains('树')) return '生命';
  if (source.contains('梦') || source.contains('幻')) return '幻境';
  if (source.contains('狼') || source.contains('影')) return '幽影';
  if (source.contains('献祭')) return '献祭';
  if (source.contains('本源')) return '本源';
  if (source.contains('神赐')) return '神赐';
  if (source.contains('龟')) return '守御';
  if (source.contains('鸟') || source.contains('火')) return '烈焰';
  return '灵息';
}

String _yearTier(int years) => switch (years) {
  < 1000 => '初鸣',
  < 10000 => '千锻',
  < 100000 => '万象',
  < 1000000 => '十万劫',
  _ => '百万神辉',
};
