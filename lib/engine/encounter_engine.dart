import '../domain/models.dart';
import 'combat_loadout_engine.dart';

int characterCombatPower(Character character) {
  final loadoutBonus = combatLoadout(character).overall ~/ 18;
  if (character.route == RouteType.soulBeast) {
    final years = character.beastYears.clamp(1, 1000000);
    final tier = switch (years) {
      >= 1000000 => 125,
      >= 500000 => 115,
      >= 100000 => 100,
      >= 50000 => 88,
      >= 10000 => 72,
      >= 1000 => 48,
      >= 100 => 25,
      _ => 10,
    };
    final beastDevelopment =
        character.beastBloodlinePower ~/ 10 +
        character.beastIntelligence ~/ 20 +
        character.beastTerritory ~/ 25 +
        character.beastPrestige ~/ 25 +
        character.beastBond ~/ 30 +
        character.beastClanPopulation ~/ 25 +
        character.beastResources ~/ 30 -
        character.beastEnemyPressure ~/ 35;
    return tier +
        beastDevelopment +
        character.ringCapacityBonus ~/ 5 +
        character.luck +
        loadoutBonus;
  }
  final ringQuality =
      <SoulRing>[
        ...character.soulRings,
        ...character.secondarySoulRings,
      ].fold<int>(
        0,
        (sum, ring) =>
            sum +
            (ring.years >= 100000
                ? 3
                : ring.years >= 10000
                ? 2
                : 1),
      );
  return character.soulPower +
      ringQuality +
      character.ringCapacityBonus ~/ 6 +
      loadoutBonus;
}

WheelPool buildEncounterOutcomePool(GameState state) {
  final encounter = state.pendingEncounter;
  if (encounter == null) {
    throw StateError('遭遇判定缺少对手信息');
  }
  final ownPower = characterCombatPower(state.character).clamp(1, 300);
  final opponentPower = encounter.opponentPower.clamp(1, 300);
  final advantage = (ownPower / opponentPower).clamp(.18, 5.5);
  final injuryPenalty = state.character.injuryTurns > 0 ? .72 : 1.0;
  final effective = advantage * injuryPenalty;
  final loadout = combatLoadout(state.character);
  double adjusted(String id, double weight) =>
      weight * combatOutcomeModifier(id, loadout);
  if (encounter.type == EncounterType.cooperation) {
    final synergy = ((ownPower + opponentPower) / 100).clamp(.35, 3.2);
    return WheelPool(
      id: 'encounterOutcome',
      title: '与${encounter.opponentName}的合作判定',
      options: <WheelOption>[
        WheelOption(
          id: 'cooperate-perfect',
          text: '完美配合扭转危局',
          weight: adjusted('cooperate-perfect', 8 * synergy),
        ),
        WheelOption(
          id: 'cooperate-win',
          text: '并肩击破眼前强敌',
          weight: adjusted('cooperate-win', 24 * synergy),
        ),
        WheelOption(
          id: 'cooperate-rescue',
          text: '替对方挡下致命一击',
          weight: adjusted('cooperate-rescue', 10 * effective),
        ),
        WheelOption(
          id: 'cooperate-narrow',
          text: '付出代价勉强脱身',
          weight: adjusted('cooperate-narrow', 18),
        ),
        WheelOption(
          id: 'cooperate-wounded',
          text: '配合失误双双重伤',
          weight: adjusted('cooperate-wounded', 10 / synergy),
        ),
        WheelOption(
          id: 'cooperate-betrayed',
          text: '遭到背叛独自突围',
          weight: adjusted('cooperate-betrayed', 5 / effective.clamp(.25, 5)),
        ),
        WheelOption(
          id: 'cooperate-sacrifice',
          text: '同伴牺牲为你断后',
          weight: adjusted('cooperate-sacrifice', 3 / synergy),
        ),
        WheelOption(
          id: 'cooperate-fall',
          text: '联手失败一同陨落',
          weight: adjusted('cooperate-fall', 1.0 / synergy),
        ),
      ],
    );
  }
  return WheelPool(
    id: 'encounterOutcome',
    title: '与${encounter.opponentName}的遭遇判定',
    options: <WheelOption>[
      WheelOption(
        id: 'encounter-crush',
        text: '压倒性获胜',
        weight: adjusted('encounter-crush', 9 * effective * effective),
      ),
      WheelOption(
        id: 'encounter-kill',
        text: '抓住破绽将其击杀',
        weight: adjusted('encounter-kill', 2.2 * effective * effective),
      ),
      WheelOption(
        id: 'encounter-wound-opponent',
        text: '重伤对手迫其退走',
        weight: adjusted('encounter-wound-opponent', 13 * effective),
      ),
      WheelOption(
        id: 'encounter-win',
        text: '稳扎稳打击败对手',
        weight: adjusted('encounter-win', 26 * effective),
      ),
      WheelOption(
        id: 'encounter-draw',
        text: '势均力敌各自退开',
        weight: adjusted('encounter-draw', 18),
      ),
      WheelOption(
        id: 'encounter-escape',
        text: '看清差距成功脱身',
        weight: adjusted('encounter-escape', 14 / effective.clamp(.3, 3)),
      ),
      WheelOption(
        id: 'encounter-defeat',
        text: '遭到击败失去机缘',
        weight: adjusted('encounter-defeat', 22 / effective.clamp(.2, 5)),
      ),
      WheelOption(
        id: 'encounter-heavy-injury',
        text: '被对手重伤濒死',
        weight: adjusted(
          'encounter-heavy-injury',
          9 / (effective * effective).clamp(.08, 25),
        ),
      ),
      WheelOption(
        id: 'encounter-fall',
        text: '战败后当场陨落',
        weight: adjusted(
          'encounter-fall',
          1.15 / (effective * effective).clamp(.08, 25),
        ),
      ),
    ],
  );
}

class EncounterResolution {
  const EncounterResolution({
    required this.title,
    required this.description,
    this.injuryTurns = 0,
    this.luckDelta = 0,
    this.trustDelta = 0,
    this.killedOpponent = false,
    this.endedLife = false,
  });

  final String title;
  final String description;
  final int injuryTurns;
  final int luckDelta;
  final int trustDelta;
  final bool killedOpponent;
  final bool endedLife;
}

EncounterResolution encounterResolution(
  String optionId,
  PendingEncounter encounter,
) {
  final name = encounter.opponentName;
  return switch (optionId) {
    'encounter-crush' => EncounterResolution(
      title: '压倒性获胜',
      description: '你完全掌握战局，$name再无还手余地。',
      luckDelta: 2,
    ),
    'encounter-kill' => EncounterResolution(
      title: '击杀$name',
      description: '你抓住唯一破绽终结了$name，这条时间线从此被改写。',
      luckDelta: -1,
      killedOpponent: true,
    ),
    'encounter-wound-opponent' => EncounterResolution(
      title: '重伤$name',
      description: '你的攻击命中要害，$name只能负伤退走。',
      trustDelta: -20,
    ),
    'encounter-win' => EncounterResolution(
      title: '击败$name',
      description: '你在正面对决中占据上风，迫使$name认输退开。',
      luckDelta: 1,
    ),
    'encounter-draw' => EncounterResolution(
      title: '两败俱伤',
      description: '你与$name都没能取得决定性胜利，只得各自退开。',
      injuryTurns: 2,
    ),
    'encounter-escape' => EncounterResolution(
      title: '成功脱身',
      description: '你没有恋战，在$name封死退路前离开险地。',
      luckDelta: -1,
    ),
    'encounter-defeat' => EncounterResolution(
      title: '遭到击败',
      description: '你被$name击败，并失去了眼前的机缘。',
      injuryTurns: 2,
      luckDelta: -2,
    ),
    'encounter-heavy-injury' => EncounterResolution(
      title: '身受重伤',
      description: '$name的攻势击溃了你的防线，你在濒死前勉强逃离。',
      injuryTurns: 5,
      luckDelta: -3,
    ),
    'encounter-fall' => EncounterResolution(
      title: '战败陨落',
      description: '实力差距没能被奇迹弥补，你最终倒在$name面前。',
      endedLife: true,
    ),
    'cooperate-perfect' => EncounterResolution(
      title: '完美配合',
      description: '你与$name交换一个眼神便理解彼此，联手扭转了危局。',
      trustDelta: 18,
      luckDelta: 3,
    ),
    'cooperate-win' => EncounterResolution(
      title: '合作告捷',
      description: '你与$name并肩击破强敌，彼此建立了可靠的信任。',
      trustDelta: 12,
      luckDelta: 2,
    ),
    'cooperate-rescue' => EncounterResolution(
      title: '舍身相救',
      description: '你替$name挡下致命攻击，也让这段关系变得更深。',
      injuryTurns: 3,
      trustDelta: 22,
    ),
    'cooperate-narrow' => EncounterResolution(
      title: '勉强脱身',
      description: '计划出现偏差，你与$name付出代价后冲出包围。',
      injuryTurns: 1,
      trustDelta: 5,
    ),
    'cooperate-wounded' => EncounterResolution(
      title: '双双重伤',
      description: '错误判断让你与$name同时遭受重创。',
      injuryTurns: 4,
      trustDelta: -4,
    ),
    'cooperate-betrayed' => EncounterResolution(
      title: '遭到背叛',
      description: '$name在关键时刻改变立场，你只能独自突围。',
      injuryTurns: 2,
      trustDelta: -35,
      luckDelta: -3,
    ),
    'cooperate-sacrifice' => EncounterResolution(
      title: '同伴断后',
      description: '$name选择留下断后，你带着沉重代价活了下来。',
      trustDelta: 25,
      luckDelta: -2,
    ),
    _ => EncounterResolution(
      title: '联手失败',
      description: '你与$name未能冲破绝境，这段人生在此落幕。',
      endedLife: true,
    ),
  };
}
