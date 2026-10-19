import '../domain/models.dart';

class SoulSpiritGrowthProfile {
  const SoulSpiritGrowthProfile({
    required this.growthStage,
    required this.affinity,
    required this.evolutionRoutes,
    required this.reasons,
  });

  final String growthStage;
  final int affinity;
  final List<String> evolutionRoutes;
  final List<String> reasons;
}

SoulSpiritGrowthProfile soulSpiritGrowthProfile(
  SoulSpirit spirit,
  Character character,
) {
  final soul =
      '${character.martialSoul ?? ''}${character.secondaryMartialSoul ?? ''}';
  final spiritText =
      '${spirit.species}${spirit.skillName}${spirit.description}';
  var affinity = 25 + spirit.bond ~/ 2;
  final reasons = <String>['羁绊${spirit.bond}提供长期共鸣基础'];
  const groups = <List<String>>[
    <String>['精神', '瞳', '眼', '幻', '梦'],
    <String>['龙', '雷', '霆'],
    <String>['冰', '雪', '霜'],
    <String>['火', '焰', '凰'],
    <String>['草', '藤', '树', '生命'],
    <String>['海', '水', '潮', '鲸'],
    <String>['空间', '星', '时间'],
  ];
  if (groups.any(
    (group) => group.any(soul.contains) && group.any(spiritText.contains),
  )) {
    affinity += 22;
    reasons.add('武魂属性与魂灵本源契合');
  } else if (soul.isNotEmpty) {
    reasons.add('武魂与魂灵暂无显著属性共鸣');
  }
  if (character.soulEngineerLevel >= 5 || character.tags.contains('魂灵体系解锁')) {
    affinity += 12;
    reasons.add('科技体系稳定魂灵与精神之海');
  }
  if (character.tags.any((tag) => tag.contains('魂灵') || tag.contains('精神之海'))) {
    affinity += 8;
    reasons.add('相关经历提高进化可能');
  }
  affinity = affinity.clamp(0, 100);
  final growth = spirit.years ~/ 3000 + spirit.bond ~/ 20 + affinity ~/ 25;
  final stage = switch (growth) {
    >= 15 => '神性蜕变期',
    >= 11 => '本源觉醒期',
    >= 7 => '成熟期',
    >= 4 => '成长期',
    _ => '幼生期',
  };
  final routes = <String>[];
  if (_containsAny(spiritText, const <String>['精神', '瞳', '幻', '梦'])) {
    routes.add('星穹幻瞳王');
  }
  if (_containsAny(spiritText, const <String>['龙', '雷', '霆'])) {
    routes.add('九霄神龙灵');
  }
  if (_containsAny(spiritText, const <String>['冰', '雪', '霜'])) {
    routes.add('极冬帝灵');
  }
  if (_containsAny(spiritText, const <String>['生命', '藤', '树', '花'])) {
    routes.add('万灵生命体');
  }
  if (character.soulEngineerLevel >= 5) routes.add('灵导共生核心');
  if (spirit.bond >= 75) routes.add('契魂守望者');
  if (routes.isEmpty) routes.add('血脉返祖形态');
  return SoulSpiritGrowthProfile(
    growthStage: stage,
    affinity: affinity,
    evolutionRoutes: List<String>.unmodifiable(routes.toSet()),
    reasons: List<String>.unmodifiable(reasons),
  );
}

bool _containsAny(String text, Iterable<String> values) =>
    values.any(text.contains);
