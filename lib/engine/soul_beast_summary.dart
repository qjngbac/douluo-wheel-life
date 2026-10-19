import '../domain/models.dart';

class SoulBeastLifeSummary {
  const SoulBeastLifeSummary({
    required this.identity,
    required this.destiny,
    required this.territory,
    required this.maximumHumanThreat,
    required this.feats,
    this.keyAlly,
    this.keyEnemy,
  });

  final String identity;
  final String destiny;
  final String territory;
  final int maximumHumanThreat;
  final String? keyAlly;
  final String? keyEnemy;
  final List<String> feats;
}

SoulBeastLifeSummary composeSoulBeastLifeSummary(GameState state) {
  final character = state.character;
  final relationships = state.relationships.toList();
  final allies =
      relationships.where((item) => item.alive && item.trust >= 50).toList()
        ..sort((a, b) => b.trust.compareTo(a.trust));
  final enemies = relationships.where((item) => item.trust <= 30).toList()
    ..sort((a, b) => a.trust.compareTo(b.trust));
  const featWords = <String>['击退', '击杀', '守住', '蜕变', '神', '领主', '共主', '救下'];
  final feats = state.timeline
      .where(
        (entry) =>
            entry.stage.contains('遭遇') ||
            entry.stage.contains('蜕变') ||
            featWords.any(entry.title.contains),
      )
      .map((entry) => entry.title)
      .toSet()
      .take(4)
      .toList(growable: false);
  return SoulBeastLifeSummary(
    identity: '${character.martialSoul ?? '无名魂兽'}（${character.beastArchetype}）',
    destiny: '${character.beastPath}，最终修为 ${character.beastYears} 年',
    territory:
        '${character.beastHabitat}，族群 ${character.beastClanPopulation}，'
        '资源 ${character.beastResources}，敌对压力 ${character.beastEnemyPressure}',
    maximumHumanThreat: character.maximumHumanThreat,
    keyAlly: allies.firstOrNull?.name,
    keyEnemy: enemies.firstOrNull?.name,
    feats: feats,
  );
}
