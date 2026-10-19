import '../domain/models.dart';

String storyThemeFor(StoryEvent event) {
  final text = '${event.id}${event.title}${event.description}';
  if (_containsAny(text, const <String>['星际', '战机', '舰队', '战舰', '星域'])) {
    return '星际远征';
  }
  if (_containsAny(text, const <String>['魂导', '斗铠', '机甲', '科技', '金属'])) {
    return '魂导科技';
  }
  if (_containsAny(text, const <String>['双武魂', '融合魂技', '第二武魂'])) {
    return '双武魂之路';
  }
  if (event.relationshipName != null ||
      _containsAny(text, const <String>['同伴', '盟友', '宿敌', '导师', '羁绊'])) {
    return '人物羁绊';
  }
  if (_containsAny(text, const <String>['魂兽', '献祭', '魂灵', '共生', '兽潮'])) {
    return '魂兽共生';
  }
  if (_containsAny(text, const <String>['学院', '大赛', '考核', '修炼'])) {
    return '学院成长';
  }
  if (_containsAny(text, const <String>['宗门', '家族', '势力', '帝国'])) {
    return '宗门势力';
  }
  if (event.encounter != null ||
      _containsAny(text, const <String>['战斗', '追杀', '伏击', '决战'])) {
    return '战斗征途';
  }
  return '命运探索';
}

double storyDirectorMultiplier(StoryEvent event, GameState state) {
  var multiplier = 1.0;
  if (state.recentEventIds.isNotEmpty &&
      state.recentEventIds.last == event.id) {
    multiplier *= .2;
  } else if (state.recentEventIds.contains(event.id)) {
    multiplier *= .5;
  }
  if (event.arcId != null &&
      event.arcStage > 1 &&
      state.arcStages[event.arcId] == event.arcStage - 1) {
    multiplier *= 1.7;
  }
  final progress =
      state.character.storyThemeProgress[storyThemeFor(event)] ?? 0;
  multiplier *= 1 + progress.clamp(0, 20) / 40;
  return multiplier;
}

void recordStoryDirection(GameState state, StoryEvent event) {
  state.recentEventIds.add(event.id);
  if (state.recentEventIds.length > 8) {
    state.recentEventIds.removeRange(0, state.recentEventIds.length - 8);
  }
  final theme = storyThemeFor(event);
  state.character.storyThemeProgress[theme] =
      (state.character.storyThemeProgress[theme] ?? 0) + 1;
}

String? dominantStoryTheme(Character character) {
  if (character.storyThemeProgress.isEmpty) return null;
  final entries = character.storyThemeProgress.entries.toList()
    ..sort((left, right) {
      final score = right.value.compareTo(left.value);
      return score != 0 ? score : left.key.compareTo(right.key);
    });
  return entries.first.key;
}

bool canAffordStoryEvent(StoryEvent event, Character character) {
  final effects = event.effects;
  final canPay =
      character.goldCoins >= -(effects['goldCoins'] ?? 0).clamp(-1000000, 0) &&
      character.rareMetals >=
          -(effects['rareMetals'] ?? 0).clamp(-1000000, 0) &&
      character.factionReputation >=
          -(effects['factionReputation'] ?? 0).clamp(-1000000, 0) &&
      character.soulBeastTrust >=
          -(effects['soulBeastTrust'] ?? 0).clamp(-1000000, 0) &&
      character.starMerit >= -(effects['starMerit'] ?? 0).clamp(-1000000, 0);
  if (!canPay) return false;
  if (event.title.contains('魂骨') &&
      (event.title.contains('修复') || event.title.contains('温养'))) {
    return character.soulBones.any((bone) => bone.integrity < 100);
  }
  if ((event.title.contains('维修') || event.title.contains('修复')) &&
      !event.title.contains('魂骨')) {
    return character.technologyAssets.any((asset) => asset.integrity < 100);
  }
  return true;
}

bool _containsAny(String text, Iterable<String> values) =>
    values.any(text.contains);
