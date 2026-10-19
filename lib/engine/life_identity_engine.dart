import '../domain/models.dart';

String lifeChapter(Character character, {required int eventCount}) {
  if (character.route == RouteType.soulBeast) {
    if (character.godhood != null || character.beastYears >= 500000) {
      return '神路·万兽朝宗';
    }
    if (character.beastYears >= 100000) return '蜇变·凶兽之路';
    if (eventCount >= 60) return '觉醒·族群兴衰';
    if (eventCount >= 20) return '成长·领地争锋';
    return '幼年·血脉初醒';
  }
  if (character.godhood != null || character.soulPower >= 95) {
    return '神路·百级问天';
  }
  if (character.soulPower >= 80) return '巅峰·封号之路';
  if (character.soulPower >= 50 || eventCount >= 60) return '历练·大陆风云';
  if (character.soulPower >= 10 || eventCount >= 20) return '成长·魂师修行';
  return '幼年·武魂觉醒';
}

String aspirationProgress(Character character) {
  final aspiration = character.aspiration;
  if (aspiration == null || aspiration.isEmpty) return '尚未立下人生志向';
  final achieved = switch (aspiration) {
    '登临神界' => character.godhood != null,
    '守护魂兽' => character.soulBeastTrust >= 60 || character.beastBond >= 70,
    '成为魂导神匠' => character.soulEngineerLevel >= 10,
    '重建宗门' => character.factionReputation >= 70,
    '统一大陆' => character.factionReputation >= 90,
    '探索星海' => character.starCommandLevel >= 8,
    '向宿敌复仇' => character.lifeMarks.any((mark) => mark.contains('复仇完成')),
    _ => false,
  };
  return achieved ? '$aspiration·已达成' : '$aspiration·推进中';
}

List<String> derivedLifeTitles(Character character) {
  final titles = <String>[...displayLifeTitles(character)];
  void add(String value) {
    if (!titles.contains(value)) titles.add(value);
  }

  final ringCount =
      character.soulRings.length + character.secondarySoulRings.length;
  if (character.route == RouteType.soulBeast &&
      character.beastYears >= 100000) {
    add('十万年兽王');
  }
  if (character.route != RouteType.soulBeast &&
      character.soulPower >= 90 &&
      ringCount >= 9) {
    add('九环封号');
  }
  if (character.hasTwinMartialSouls && ringCount >= 18) add('双生绝巅');
  if (character.soulEngineerLevel >= 10) {
    add('魂导神匠');
  } else if (character.soulEngineerLevel >= 9) {
    add('九级魂导师');
  } else if (character.soulEngineerLevel >= 6) {
    add('高级魂导师');
  } else if (character.soulEngineerLevel >= 3) {
    add('魂导技师');
  }
  if (character.godhood != null) {
    add('神界登临者');
    add(character.godhood!);
  }
  return List<String>.unmodifiable(titles);
}

List<String> displayLifeTitles(Character character) =>
    List<String>.unmodifiable(
      character.earnedTitles.where(
        (title) => title != '神界登临者' || character.godhood != null,
      ),
    );

String displayLifeName(Character character) {
  final name = character.characterName?.trim();
  final titles = derivedLifeTitles(character);
  if (name == null || name.isEmpty) {
    return titles.isEmpty ? '无名命运者' : titles.last;
  }
  return titles.isEmpty ? name : '$name·${titles.last}';
}

List<String> lifeAchievements(Character character) {
  final achievements = <String>[];
  final ringCount =
      character.soulRings.length + character.secondarySoulRings.length;
  if (character.hasTwinMartialSouls && ringCount >= 18) {
    achievements.add('双生绝巅');
  }
  if (ringCount >= 9) achievements.add('九环人生');
  if (character.soulRings.isNotEmpty &&
      character.soulRings.first.years >= 100000) {
    achievements.add('逆天第一环');
  }
  if (character.soulBones.where((bone) => bone.setId != null).length >= 6) {
    achievements.add('六骨共鸣');
  }
  if (character.godhood != null) achievements.add('登临神界');
  if (character.route == RouteType.soulBeast &&
      character.beastClanPopulation >= 80) {
    achievements.add('万兽共主');
  }
  return achievements;
}

void recordLifeIdentity(
  Character character, {
  required String title,
  required List<String> effects,
}) {
  final concreteEffects = effects.where(
    (effect) =>
        !<String>['概率', '倾向', '影响', '决定', '修正', '取决'].any(effect.contains),
  );
  final text = '$title${concreteEffects.join()}';
  void mark(String value) {
    if (!character.lifeMarks.contains(value)) character.lifeMarks.add(value);
    if (character.lifeMarks.length > 10) character.lifeMarks.removeAt(0);
  }

  void earn(String value) {
    if (!character.earnedTitles.contains(value)) {
      character.earnedTitles.add(value);
    }
  }

  if (character.status != LifeStatus.dead &&
      (text.contains('重伤') || text.contains('反噬'))) {
    mark('重伤但幸存');
    earn('逆境幸存者');
  }
  if (text.contains('击杀')) mark('击杀宿敌');
  if (text.contains('拯救') || text.contains('救下')) {
    mark('改写他人命运');
  }
  if (character.godhood != null) earn('神界登临者');
  for (final derived in derivedLifeTitles(character)) {
    earn(derived);
  }
}

List<String> displayLifeMarks(Character character) {
  final result = <String>[];
  for (final mark in character.lifeMarks) {
    final separator = mark.indexOf('：');
    final normalized = separator < 0 ? mark : mark.substring(separator + 1);
    if (normalized.isNotEmpty && !result.contains(normalized)) {
      result.add(normalized);
    }
  }
  return List<String>.unmodifiable(result);
}
