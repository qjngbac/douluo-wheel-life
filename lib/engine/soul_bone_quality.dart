import 'dart:math' as math;

import '../domain/models.dart';

enum SoulBoneComparison { stronger, comparable, weaker }

class SoulBoneReplacementReport {
  const SoulBoneReplacementReport({
    required this.existing,
    required this.incoming,
    required this.currentScore,
    required this.incomingScore,
    required this.scoreDelta,
    required this.lostSkill,
    required this.gainedSkill,
    required this.integrityDelta,
    required this.lostSetBonuses,
  });

  final SoulBone? existing;
  final SoulBone incoming;
  final int currentScore;
  final int incomingScore;
  final int scoreDelta;
  final String? lostSkill;
  final String gainedSkill;
  final int integrityDelta;
  final List<String> lostSetBonuses;
}

class SoulBoneSetBonus {
  const SoulBoneSetBonus({
    required this.id,
    required this.name,
    required this.pieceCount,
    required this.offense,
    required this.defense,
    required this.control,
    required this.recovery,
  });

  final String id;
  final String name;
  final int pieceCount;
  final int offense;
  final int defense;
  final int control;
  final int recovery;

  String get description => switch (pieceCount) {
    >= 6 => '六件共鸣：攻防、控制与恢复全面升华',
    >= 4 => '四件共鸣：解锁血脉领域',
    _ => '两件共鸣：同源魂骨互相增幅',
  };
}

const Set<RingColor> _ordinaryColors = <RingColor>{
  RingColor.yellow,
  RingColor.purple,
  RingColor.black,
};

int soulBoneQualityScore(SoulBone bone, Character character) {
  var score = math.sqrt(bone.years.clamp(1, 1000000)) * 2;
  if (bone.originColor != null && !_ordinaryColors.contains(bone.originColor)) {
    score += 180;
  }
  if (bone.evolvable) score += 100;
  if (bone.slot == SoulBoneSlot.external) score += 80;
  if (_soulBoneAffinity(bone, character)) score += 120;
  score *= .45 + bone.integrity.clamp(0, 100) / 100 * .55;
  return score.round();
}

SoulBoneComparison compareSoulBones(
  SoulBone existing,
  SoulBone incoming,
  Character character,
) {
  final oldScore = soulBoneQualityScore(existing, character).clamp(1, 1000000);
  final ratio = soulBoneQualityScore(incoming, character) / oldScore;
  if (ratio >= 1.18) return SoulBoneComparison.stronger;
  if (ratio <= .82) return SoulBoneComparison.weaker;
  return SoulBoneComparison.comparable;
}

SoulBoneReplacementReport analyzeSoulBoneReplacement(
  Character character,
  SoulBone incoming,
) {
  final existing = incoming.slot == SoulBoneSlot.external
      ? null
      : character.soulBones
            .where((bone) => bone.slot == incoming.slot)
            .firstOrNull;
  final before = activeSoulBoneSetBonuses(
    character,
  ).map((set) => set.name).toSet();
  final afterCharacter = character.copy();
  if (existing != null) {
    afterCharacter.soulBones.removeWhere((bone) => bone.id == existing.id);
  }
  afterCharacter.soulBones.add(incoming);
  final after = activeSoulBoneSetBonuses(
    afterCharacter,
  ).map((set) => set.name).toSet();
  final currentScore = existing == null
      ? 0
      : soulBoneQualityScore(existing, character);
  final incomingScore = soulBoneQualityScore(incoming, character);
  return SoulBoneReplacementReport(
    existing: existing,
    incoming: incoming,
    currentScore: currentScore,
    incomingScore: incomingScore,
    scoreDelta: incomingScore - currentScore,
    lostSkill: existing?.skillName,
    gainedSkill: incoming.skillName,
    integrityDelta: incoming.integrity - (existing?.integrity ?? 0),
    lostSetBonuses: before.difference(after).toList(growable: false),
  );
}

({String id, String name})? soulBoneSetIdentity(String source) {
  const groups = <({String id, String name, List<String> keywords})>[
    (id: 'storm-dragon', name: '苍穹雷龙套装', keywords: <String>['龙', '雷', '霆']),
    (
      id: 'life-forest',
      name: '万灵森域套装',
      keywords: <String>['藤', '树', '花', '鹿', '生命'],
    ),
    (
      id: 'spirit-dream',
      name: '灵眸梦境套装',
      keywords: <String>['精神', '梦', '瞳', '狐'],
    ),
    (id: 'ocean-tide', name: '沧海潮汐套装', keywords: <String>['海', '鲸', '鲨', '潮']),
    (
      id: 'frost-domain',
      name: '极北霜域套装',
      keywords: <String>['冰', '雪', '霜', '寒'],
    ),
    (id: 'flame-sky', name: '焚天神火套装', keywords: <String>['火', '焰', '凰', '阳']),
    (
      id: 'shadow-abyss',
      name: '幽渊暗影套装',
      keywords: <String>['暗', '影', '幽', '邪'],
    ),
  ];
  for (final group in groups) {
    if (group.keywords.any(source.contains)) {
      return (id: group.id, name: group.name);
    }
  }
  return null;
}

List<SoulBoneSetBonus> activeSoulBoneSetBonuses(Character character) {
  final grouped = <String, List<SoulBone>>{};
  for (final bone in character.soulBones) {
    final id = bone.setId;
    if (id != null) grouped.putIfAbsent(id, () => <SoulBone>[]).add(bone);
  }
  return grouped.entries
      .where((entry) => entry.value.length >= 2)
      .map((entry) {
        final pieces = entry.value.length;
        final name = entry.value.first.setName ?? '同源魂骨套装';
        return SoulBoneSetBonus(
          id: entry.key,
          name: name,
          pieceCount: pieces,
          offense: pieces >= 6
              ? 18
              : pieces >= 4
              ? 11
              : 5,
          defense: pieces >= 6
              ? 18
              : pieces >= 4
              ? 10
              : 4,
          control: pieces >= 4 ? 8 : 3,
          recovery: pieces >= 6
              ? 12
              : pieces >= 4
              ? 6
              : 2,
        );
      })
      .toList(growable: false);
}

bool _soulBoneAffinity(SoulBone bone, Character character) {
  final soul =
      '${character.martialSoul ?? ''}${character.secondaryMartialSoul ?? ''}';
  if (soul.isEmpty) return false;
  const pairs = <List<String>>[
    <String>['龙', '雷', '霆'],
    <String>['冰', '雪', '霜', '寒'],
    <String>['火', '焰', '凰', '阳'],
    <String>['精神', '梦', '瞳', '眼'],
    <String>['藤', '草', '树', '生命'],
    <String>['海', '水', '潮', '鲸'],
    <String>['暗', '影', '幽'],
  ];
  final source = '${bone.source}${bone.name}${bone.skillName}';
  return pairs.any(
    (group) => group.any(soul.contains) && group.any(source.contains),
  );
}
