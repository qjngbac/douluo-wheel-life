import '../domain/models.dart';

class SoulBeastEvolutionStage {
  const SoulBeastEvolutionStage({
    required this.name,
    required this.description,
    required this.requirement,
  });

  final String name;
  final String description;
  final String requirement;
}

class SoulBeastEvolutionTree {
  const SoulBeastEvolutionTree({
    required this.archetypeName,
    required this.stages,
    required this.currentStageIndex,
  });

  final String archetypeName;
  final List<SoulBeastEvolutionStage> stages;
  final int currentStageIndex;

  String? get nextRequirement => currentStageIndex >= stages.length - 1
      ? null
      : stages[currentStageIndex + 1].requirement;
}

SoulBeastEvolutionTree soulBeastEvolutionTree(Character character) {
  final stages = _stagesFor(character.beastArchetype);
  final currentStageIndex =
      character.beastYears >= 1000000 && character.beastBloodlinePower >= 80
      ? 2
      : character.beastYears >= 100000 && character.beastBloodlinePower >= 40
      ? 1
      : 0;
  return SoulBeastEvolutionTree(
    archetypeName: character.beastArchetype,
    stages: stages,
    currentStageIndex: currentStageIndex,
  );
}

List<SoulBeastEvolutionStage> _stagesFor(String archetype) {
  if (archetype.contains('植物')) {
    return const <SoulBeastEvolutionStage>[
      SoulBeastEvolutionStage(
        name: '灵根异植',
        description: '扎根地脉，积蓄生命精华。',
        requirement: '已觉醒植物血脉',
      ),
      SoulBeastEvolutionStage(
        name: '万灵古植',
        description: '枝叶庇护族群，根系覆盖整片领地。',
        requirement: '十万年修为且血脉达到40',
      ),
      SoulBeastEvolutionStage(
        name: '世界生命树',
        description: '一叶生世界，一念复万灵。',
        requirement: '百万年修为且血脉达到80',
      ),
    ];
  }
  if (archetype.contains('龙')) {
    return const <SoulBeastEvolutionStage>[
      SoulBeastEvolutionStage(
        name: '蛟龙血裔',
        description: '龙息初醒，可震慑低阶猎食者。',
        requirement: '已觉醒龙族血脉',
      ),
      SoulBeastEvolutionStage(
        name: '真龙祖血',
        description: '祖血返源，肉身与元素同时蜇变。',
        requirement: '十万年修为且血脉达到40',
      ),
      SoulBeastEvolutionStage(
        name: '太初龙皇',
        description: '龙域自成，万兽闻吟而朝。',
        requirement: '百万年修为且血脉达到80',
      ),
    ];
  }
  if (archetype.contains('精神')) {
    return const <SoulBeastEvolutionStage>[
      SoulBeastEvolutionStage(
        name: '梦念灵兽',
        description: '感知情绪波动，辨识隐藏敌意。',
        requirement: '已觉醒精神血脉',
      ),
      SoulBeastEvolutionStage(
        name: '精神本源之眼',
        description: '织成心灵网络，共享族群感知。',
        requirement: '十万年修为且血脉达到40',
      ),
      SoulBeastEvolutionStage(
        name: '幻界心主',
        description: '意念即界域，可改写一方精神法则。',
        requirement: '百万年修为且血脉达到80',
      ),
    ];
  }
  if (archetype.contains('海')) {
    return const <SoulBeastEvolutionStage>[
      SoulBeastEvolutionStage(
        name: '深海异兽',
        description: '借洋流迁徙，适应多种水域。',
        requirement: '已觉醒海洋血脉',
      ),
      SoulBeastEvolutionStage(
        name: '远海霸主',
        description: '控制海流与灵礁，庇护整支族群。',
        requirement: '十万年修为且血脉达到40',
      ),
      SoulBeastEvolutionStage(
        name: '沧溟海皇',
        description: '一怒潮生，一念海平。',
        requirement: '百万年修为且血脉达到80',
      ),
    ];
  }
  return const <SoulBeastEvolutionStage>[
    SoulBeastEvolutionStage(
      name: '荒野兽王',
      description: '强化猎食、结群与生存本能。',
      requirement: '已觉醒陆生血脉',
    ),
    SoulBeastEvolutionStage(
      name: '万兽统御者',
      description: '兽群随行，领地与声望共同扩张。',
      requirement: '十万年修为且血脉达到40',
    ),
    SoulBeastEvolutionStage(
      name: '大地兽神',
      description: '山川为甲，万兽为军。',
      requirement: '百万年修为且血脉达到80',
    ),
  ];
}
