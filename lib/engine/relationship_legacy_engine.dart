import '../domain/models.dart';

enum RelationshipLegacyKind { ally, rival, none }

class RelationshipLegacy {
  const RelationshipLegacy({
    required this.kind,
    this.personName,
    this.skillName,
    this.endingSuffix = '',
  });

  final RelationshipLegacyKind kind;
  final String? personName;
  final String? skillName;
  final String endingSuffix;
}

RelationshipLegacy relationshipLegacyFor(GameState state) {
  if (state.character.route != RouteType.soulBeast) {
    return const RelationshipLegacy(kind: RelationshipLegacyKind.none);
  }
  final living = state.relationships.where((item) => item.alive).toList();
  final allies = living.where((item) => item.trust >= 70).toList()
    ..sort((a, b) => b.trust.compareTo(a.trust));
  final rivals = living.where((item) => item.trust <= 30).toList()
    ..sort((a, b) => a.trust.compareTo(b.trust));
  final allyStrength = allies.isEmpty ? -1 : allies.first.trust - 50;
  final rivalStrength = rivals.isEmpty ? -1 : 50 - rivals.first.trust;
  if (allyStrength < 0 && rivalStrength < 0) {
    return const RelationshipLegacy(kind: RelationshipLegacyKind.none);
  }
  if (allyStrength >= rivalStrength) {
    final ally = allies.first;
    final skill = _allySkill(state.character.beastArchetype);
    return RelationshipLegacy(
      kind: RelationshipLegacyKind.ally,
      personName: ally.name,
      skillName: skill,
      endingSuffix: '·与${ally.name}共创“$skill”',
    );
  }
  final rival = rivals.first;
  final skill = _rivalSkill(state.character.beastArchetype);
  return RelationshipLegacy(
    kind: RelationshipLegacyKind.rival,
    personName: rival.name,
    skillName: skill,
    endingSuffix: '·与${rival.name}的宿命决战改写时代',
  );
}

String _allySkill(String archetype) {
  if (archetype.contains('龙')) return '龙魂共鸣·天地同契';
  if (archetype.contains('植物')) return '万木同心·生命结界';
  if (archetype.contains('精神')) return '双心幻界·灵魂共鸣';
  if (archetype.contains('海')) return '沧溟合流·潮汐神域';
  return '万兽并肩·山河共守';
}

String _rivalSkill(String archetype) {
  if (archetype.contains('龙')) return '逆命猎杀·断龙天痕';
  if (archetype.contains('植物')) return '逆命猎杀·枯荣轮回';
  if (archetype.contains('精神')) return '逆命猎杀·心界崩解';
  if (archetype.contains('海')) return '逆命猎杀·断海孤潮';
  return '逆命猎杀·荒原绝境';
}
