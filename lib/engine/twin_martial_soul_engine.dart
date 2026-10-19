import '../domain/models.dart';

class TwinMartialSoulEffect {
  const TwinMartialSoulEffect({
    required this.tag,
    required this.title,
    required this.description,
    required this.fusionSkill,
  });

  final String tag;
  final String title;
  final String description;
  final String fusionSkill;
}

TwinMartialSoulEffect twinMartialSoulEffect(String primary, String secondary) {
  final combined = '$primary$secondary';
  final fire = _containsAny(combined, <String>['火', '炎', '焰', '凤凰']);
  final frost = _containsAny(combined, <String>['冰', '雪', '霜', '寒']);
  final light = _containsAny(combined, <String>['光', '天使', '太阳']);
  final shadow = _containsAny(combined, <String>['暗', '影', '幽', '死亡', '冥']);
  final plant = _containsAny(combined, <String>['蓝银', '藤', '草', '花', '树']);
  final healing = _containsAny(combined, <String>['海棠', '生命', '回春', '琉璃塔']);
  final water = _containsAny(combined, <String>['水', '海', '潮', '雨']);
  final wind = _containsAny(combined, <String>['风', '燕', '翼']);
  final mental = _containsAny(combined, <String>['眼', '眸', '梦', '精神', '罗盘']);

  if ((fire && frost) || (light && shadow)) {
    return TwinMartialSoulEffect(
      tag: '双武魂冲突',
      title: fire && frost ? '冰火相克' : '光暗相斥',
      description: '两种力量日常修炼更困难，但在极限状态下更容易爆发越阶突破。',
      fusionSkill: fire && frost ? '冰火寂灭界' : '黎明永夜轮',
    );
  }
  if ((plant && (healing || water || light)) ||
      (wind && fire) ||
      (mental && healing)) {
    return TwinMartialSoulEffect(
      tag: '双武魂互补',
      title: wind && fire ? '风火相生' : '生息互补',
      description: '两个武魂可以弥补彼此短板，提高修炼稳定性与魂环吸收成功率。',
      fusionSkill: wind && fire ? '风火燎原域' : '森罗生命界',
    );
  }
  return const TwinMartialSoulEffect(
    tag: '双武魂共鸣',
    title: '双魂同律',
    description: '两个武魂属性并不相斥，能够在战斗中切换节奏并形成连携。',
    fusionSkill: '双魂万象阵',
  );
}

TwinMartialSoulEffect? effectForCharacter(Character character) {
  final primary = character.martialSoul;
  final secondary = character.secondaryMartialSoul;
  if (primary == null || secondary == null) return null;
  return twinMartialSoulEffect(primary, secondary);
}

void applyTwinMartialSoulAwakening(Character character) {
  final effect = effectForCharacter(character);
  if (effect == null) return;
  character.tags.removeWhere(
    (tag) => tag == '双武魂互补' || tag == '双武魂冲突' || tag == '双武魂共鸣',
  );
  _addTag(character, effect.tag);
  _addTag(character, '双武魂组合：${effect.title}');
  _addTag(character, '融合魂技潜质：${effect.fusionSkill}');
}

bool unlockTwinMartialSoulFusion(Character character) {
  final effect = effectForCharacter(character);
  if (effect == null ||
      character.soulRings.length < 5 ||
      character.secondarySoulRings.length < 5 ||
      character.tags.contains('武魂融合')) {
    return false;
  }
  _addTag(character, '武魂融合');
  _addTag(character, '武魂融合技：${effect.fusionSkill}');
  return true;
}

int twinCultivationBonus(Character character) =>
    switch (effectForCharacter(character)?.tag) {
      '双武魂互补' => 1,
      '双武魂冲突' => -1,
      _ => 0,
    };

double twinRingOutcomeMultiplier(String outcomeId, Character character) {
  return switch (effectForCharacter(character)?.tag) {
    '双武魂互补' when outcomeId == 'absorb-perfect' => 1.35,
    '双武魂互补' when outcomeId == 'absorb-normal' => 1.2,
    '双武魂互补' when outcomeId == 'absorb-death' => .75,
    '双武魂冲突' when outcomeId == 'absorb-breakthrough' => 1.45,
    '双武魂冲突' when outcomeId == 'absorb-hard' => 1.2,
    '双武魂冲突' when outcomeId == 'absorb-fail' => 1.15,
    _ => 1,
  };
}

bool _containsAny(String text, Iterable<String> keywords) =>
    keywords.any(text.contains);

void _addTag(Character character, String tag) {
  if (!character.tags.contains(tag)) character.tags.add(tag);
}
