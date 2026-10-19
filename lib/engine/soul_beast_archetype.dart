import '../domain/models.dart';

enum SoulBeastArchetype { plant, dragon, spirit, sea, land }

SoulBeastArchetype soulBeastArchetypeFor(String? species) {
  final name = species ?? '';
  if (RegExp(r'树|藤|草|花|竹|蓝银').hasMatch(name)) {
    return SoulBeastArchetype.plant;
  }
  if (RegExp(r'龙|蛟|麟').hasMatch(name)) return SoulBeastArchetype.dragon;
  if (RegExp(r'邪眼|梦|幻|蜃|时砂').hasMatch(name)) {
    return SoulBeastArchetype.spirit;
  }
  if (RegExp(r'海|鲨|鲸|虎鲸|玄水').hasMatch(name)) {
    return SoulBeastArchetype.sea;
  }
  return SoulBeastArchetype.land;
}

String soulBeastArchetypeName(SoulBeastArchetype archetype) =>
    switch (archetype) {
      SoulBeastArchetype.plant => '植物系',
      SoulBeastArchetype.dragon => '龙族',
      SoulBeastArchetype.spirit => '精神系',
      SoulBeastArchetype.sea => '海魂兽',
      SoulBeastArchetype.land => '陆生兽族',
    };

String soulBeastTalentDescription(SoulBeastArchetype archetype) =>
    switch (archetype) {
      SoulBeastArchetype.plant => '扎根环境，恢复与资源积累更强',
      SoulBeastArchetype.dragon => '血脉成长迅猛，争夺领地时更具威慑',
      SoulBeastArchetype.spirit => '灵智敏锐，擅长预感危险与精神交涉',
      SoulBeastArchetype.sea => '借水域迁徙，领地与族群扩张更加稳定',
      SoulBeastArchetype.land => '适应性均衡，结群狩猎和生存能力突出',
    };

Map<String, int> soulBeastInitialEffects(SoulBeastArchetype archetype) =>
    switch (archetype) {
      SoulBeastArchetype.plant => const <String, int>{
        'beastResources': 8,
        'beastTerritory': 3,
      },
      SoulBeastArchetype.dragon => const <String, int>{
        'beastBloodline': 8,
        'beastEnemyPressure': 3,
      },
      SoulBeastArchetype.spirit => const <String, int>{
        'beastIntelligence': 8,
        'humanThreat': -2,
      },
      SoulBeastArchetype.sea => const <String, int>{
        'beastTerritory': 5,
        'beastClan': 3,
      },
      SoulBeastArchetype.land => const <String, int>{
        'beastClan': 4,
        'beastPrestige': 3,
      },
    };

List<WheelOption> soulBeastSpeciesActions(String archetypeName) {
  final archetype = SoulBeastArchetype.values.firstWhere(
    (item) => soulBeastArchetypeName(item) == archetypeName,
    orElse: () => SoulBeastArchetype.land,
  );
  return switch (archetype) {
    SoulBeastArchetype.plant => const <WheelOption>[
      WheelOption(
        id: 'beast-action-species-plant-roots',
        text: '延伸根系感知整片领地',
        weight: 13,
        effects: <String, int>{'beastTerritory': 4, 'beastResources': 5},
      ),
      WheelOption(
        id: 'beast-action-species-plant-heal',
        text: '催生灵植医治受伤族群',
        weight: 11,
        effects: <String, int>{'recovery': 3, 'beastPrestige': 4},
      ),
    ],
    SoulBeastArchetype.dragon => const <WheelOption>[
      WheelOption(
        id: 'beast-action-species-dragon-aura',
        text: '释放龙威震慑敌对领主',
        weight: 12,
        effects: <String, int>{'beastBloodline': 4, 'beastEnemyPressure': -4},
      ),
      WheelOption(
        id: 'beast-action-species-dragon-hoard',
        text: '搜寻龙脉宝材充实巢穴',
        weight: 10,
        effects: <String, int>{'beastResources': 7, 'humanThreat': 2},
      ),
    ],
    SoulBeastArchetype.spirit => const <WheelOption>[
      WheelOption(
        id: 'beast-action-species-spirit-dream',
        text: '潜入梦境辨认来者敌意',
        weight: 13,
        effects: <String, int>{'beastIntelligence': 4, 'humanThreat': -3},
      ),
      WheelOption(
        id: 'beast-action-species-spirit-warning',
        text: '以精神网络预警整片族群',
        weight: 11,
        effects: <String, int>{'beastBond': 4, 'beastEnemyPressure': -3},
      ),
    ],
    SoulBeastArchetype.sea => const <WheelOption>[
      WheelOption(
        id: 'beast-action-species-sea-current',
        text: '驾驭洋流巡视海域边界',
        weight: 13,
        effects: <String, int>{'beastTerritory': 5, 'beastEnemyPressure': -2},
      ),
      WheelOption(
        id: 'beast-action-species-sea-reef',
        text: '培育珊瑚灵礁庇护幼兽',
        weight: 11,
        effects: <String, int>{'beastClan': 4, 'beastResources': 5},
      ),
    ],
    SoulBeastArchetype.land => const <WheelOption>[
      WheelOption(
        id: 'beast-action-species-land-pack',
        text: '组织兽群进行协同狩猎',
        weight: 13,
        effects: <String, int>{'beastClan': 3, 'beastResources': 5},
      ),
      WheelOption(
        id: 'beast-action-species-land-trail',
        text: '开辟隐秘兽径躲避围猎',
        weight: 11,
        effects: <String, int>{'humanThreat': -3, 'beastTerritory': 3},
      ),
    ],
  };
}

WheelOption soulBeastSpeciesEvolution(String archetypeName) {
  final archetype = SoulBeastArchetype.values.firstWhere(
    (item) => soulBeastArchetypeName(item) == archetypeName,
    orElse: () => SoulBeastArchetype.land,
  );
  return switch (archetype) {
    SoulBeastArchetype.plant => const WheelOption(
      id: 'beast-evolution-plant',
      text: '蜕变为万灵古植',
      weight: 9,
      effects: <String, int>{'beastBloodline': 6, 'beastResources': 8},
    ),
    SoulBeastArchetype.dragon => const WheelOption(
      id: 'beast-evolution-dragon',
      text: '凝聚真龙祖血',
      weight: 7,
      effects: <String, int>{'beastBloodline': 10, 'beastPrestige': 5},
    ),
    SoulBeastArchetype.spirit => const WheelOption(
      id: 'beast-evolution-spirit',
      text: '开启精神本源之眼',
      weight: 8,
      effects: <String, int>{'beastIntelligence': 10, 'beastBond': 4},
    ),
    SoulBeastArchetype.sea => const WheelOption(
      id: 'beast-evolution-sea',
      text: '唤醒远海霸主血脉',
      weight: 8,
      effects: <String, int>{'beastTerritory': 8, 'beastClan': 5},
    ),
    SoulBeastArchetype.land => const WheelOption(
      id: 'beast-evolution-land',
      text: '觉醒万兽统御本能',
      weight: 10,
      effects: <String, int>{'beastPrestige': 8, 'beastClan': 5},
    ),
  };
}
