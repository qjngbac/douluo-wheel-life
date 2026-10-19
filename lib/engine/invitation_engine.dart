import '../domain/models.dart';
import '../data/soul_beast_data.dart';
import '../data/soul_spirit_data.dart';

const Map<String, List<List<String>>> _bestTiers = <String, List<List<String>>>{
  'appearance': <List<String>>[
    <String>['appearance-rare'],
    <String>['appearance-outstanding'],
  ],
  'race': <List<String>>[
    <String>['race-beast-shape', 'race-beast-top', 'race-human-bloodline'],
    <String>['race-beast-advanced', 'race-human-family', 'race-human'],
  ],
  'family': <List<String>>[
    <String>['family-special', 'family-hidden'],
    <String>['family-sect', 'family-noble', 'family-soul'],
  ],
  'constitution': <List<String>>[
    <String>['body-monster'],
    <String>['body-gifted'],
  ],
  'spirit': <List<String>>[
    <String>['spirit-special'],
    <String>['spirit-genius'],
  ],
  'talent': <List<String>>[
    <String>['talent-god'],
    <String>['talent-genius', 'talent-rare'],
  ],
  'martialSoul': <List<String>>[
    <String>[
      'soul-double',
      'soul-six-wing-angel',
      'soul-ice-scorpion',
      'soul-silver-dragon',
      'soul-blue-silver-emperor',
      'soul-haotian-hammer',
    ],
    <String>['soul-special', 'soul-mutate', 'soul-golden-dragon'],
  ],
  'primaryMartialSoul': <List<String>>[
    <String>[
      'soul-six-wing-angel',
      'soul-ice-scorpion',
      'soul-silver-dragon',
      'soul-blue-silver-emperor',
      'soul-haotian-hammer',
    ],
    <String>['soul-special', 'soul-golden-dragon', 'soul-nine-treasure'],
  ],
  'secondaryMartialSoul': <List<String>>[
    <String>[
      'soul-six-wing-angel',
      'soul-ice-scorpion',
      'soul-silver-dragon',
      'soul-blue-silver-emperor',
      'soul-haotian-hammer',
    ],
    <String>['soul-special', 'soul-golden-dragon', 'soul-nine-treasure'],
  ],
  'innatePower': <List<String>>[
    <String>['power-10'],
    <String>['power-9', 'power-8', 'power-7'],
  ],
  'beastSpecies': <List<String>>[
    <String>[
      'beast-auspicious',
      'beast-phoenix',
      'beast-dragon',
      'beast-chaos-qilin',
      'beast-void-dragon',
      'beast-nether-phoenix',
      'beast-mystic-tortoise',
    ],
    <String>['beast-life-tree', 'beast-gold-butterfly', 'beast-ice-scorpion'],
  ],
  'beastBloodline': <List<String>>[
    <String>['blood-royal'],
    <String>['blood-ancient'],
  ],
  'beastCultivation': <List<String>>[
    <String>['cultivation-shape'],
    <String>['cultivation-10000'],
  ],
  'soulBoneDrop': <List<String>>[
    <String>['bone-drop-found'],
    <String>['bone-drop-none'],
  ],
  'soulBoneSlot': <List<String>>[
    <String>['bone-slot-external'],
    <String>[
      'bone-slot-head',
      'bone-slot-torso',
      'bone-slot-leftArm',
      'bone-slot-rightArm',
      'bone-slot-leftLeg',
      'bone-slot-rightLeg',
    ],
  ],
  'soulBoneOutcome': <List<String>>[
    <String>['bone-perfect', 'bone-fuse'],
    <String>['bone-normal', 'bone-replace'],
  ],
  'soulSpiritOutcome': <List<String>>[
    <String>['spirit-perfect'],
    <String>['spirit-steady', 'spirit-trial'],
  ],
  'eventCount': <List<String>>[
    <String>['events-8'],
    <String>['events-5'],
  ],
  'ageGrowth': <List<String>>[
    <String>['human-time-1', 'beast-time-1'],
    <String>['human-time-2', 'beast-time-2'],
  ],
  'cultivationGrowth': <List<String>>[
    <String>['training-miracle', 'beast-training-ancestral'],
    <String>['training-breakthrough', 'beast-training-awaken'],
  ],
  'ringMethod': <List<String>>[
    <String>['ring-sacrifice', 'ring-help'],
    <String>['ring-family', 'ring-academy'],
  ],
  'ringCandidate': <List<String>>[
    <String>[
      'ring-spirit-gift',
      'ring-sacrifice-blue-whale',
      'ring-sacrifice-jade-deer',
      'ring-sacrifice-starlight-unicorn',
      'ring-sacrifice-flame-phoenix',
      'ring-sacrifice-frost-moth',
      'ring-sacrifice-ancient-tree',
      'ring-ditian',
      'ring-evil-eye-tyrant',
      'ring-deep-sea-whale-king',
    ],
    <String>[
      'ring-sky-bull-python',
      'ring-titan-ape',
      'ring-evil-god-tiger',
      'ring-golden-lion',
    ],
  ],
  'ringOutcome': <List<String>>[
    <String>['absorb-breakthrough'],
    <String>['absorb-perfect'],
  ],
  'encounterOutcome': <List<String>>[
    <String>['encounter-crush', 'encounter-kill', 'cooperate-perfect'],
    <String>[
      'encounter-wound-opponent',
      'encounter-win',
      'cooperate-win',
      'cooperate-rescue',
    ],
  ],
  'beastDestiny': <List<String>>[
    <String>['beast-path-god'],
    <String>['beast-path-contract', 'beast-path-shape', 'beast-path-sacrifice'],
  ],
  'godhoodEvent': <List<String>>[
    <String>[
      'god-path-asura',
      'god-path-sea',
      'god-path-life',
      'god-path-destruction',
      'god-path-fate',
      'god-path-time',
      'god-path-twin-balance',
      'god-path-twin-chaos',
      'god-path-twin-fusion',
    ],
    <String>[
      'god-path-stars',
      'god-path-thunder',
      'god-path-soul',
      'god-path-void',
    ],
  ],
  'godhoodTrial': <List<String>>[
    <String>['trial-law-resonance', 'trial-bond', 'trial-hold-heart'],
    <String>['trial-break-limit', 'trial-sacrifice'],
  ],
  'ending': <List<String>>[
    <String>[
      'end-legend',
      'end-beast-god',
      'end-beast-contract',
      'end-beast-bridge',
      'end-beast-rebirth',
    ],
    <String>[
      'end-strong',
      'end-achievement',
      'end-beast',
      'end-beast-survivor',
      'end-beast-lord',
      'end-beast-clan',
      'end-beast-shape',
      'end-beast-coexist',
    ],
  ],
};

WheelPool invitationPool(WheelPool pool) {
  if (pool.options.length < 2) return pool;
  if (pool.id == 'life') return _strengthenedLifePool(pool);
  if (pool.id == 'godhoodOutcome') {
    return _strengthenByTiers(pool, <List<String>>[
      pool.options
          .where((option) => option.id.startsWith('god-success-sovereign-'))
          .map((option) => option.id)
          .toList(growable: false),
      pool.options
          .where((option) => option.id.startsWith('god-success-major-'))
          .map((option) => option.id)
          .toList(growable: false),
    ]);
  }
  if (pool.id == 'ringCandidate') {
    final qualities = pool.options
        .map((option) => soulBeastProfileForId(option.id)?.quality ?? 0)
        .toSet();
    final bestQuality = qualities.reduce((a, b) => a > b ? a : b);
    if (bestQuality > 0) {
      return _strengthenByTiers(pool, <List<String>>[
        pool.options
            .where(
              (option) =>
                  (soulBeastProfileForId(option.id)?.quality ?? 0) ==
                  bestQuality,
            )
            .map((option) => option.id)
            .toList(growable: false),
        pool.options
            .where(
              (option) =>
                  (soulBeastProfileForId(option.id)?.quality ?? 0) ==
                  bestQuality - 1,
            )
            .map((option) => option.id)
            .toList(growable: false),
      ]);
    }
  }
  if (pool.id == 'soulSpiritCandidate') {
    return _strengthenByTiers(pool, <List<String>>[
      pool.options
          .where((option) => soulSpiritProfile(option.id).specialColor != null)
          .map((option) => option.id)
          .toList(growable: false),
      pool.options
          .where((option) => soulSpiritProfile(option.id).specialColor == null)
          .map((option) => option.id)
          .toList(growable: false),
    ]);
  }
  final tiers = _bestTiers[pool.id];
  if (tiers != null) return _strengthenByTiers(pool, tiers);
  return _strengthenByEffects(pool);
}

WheelPool _strengthenByTiers(WheelPool pool, List<List<String>> tiers) {
  final presentTiers = tiers
      .map(
        (tier) =>
            tier.where((id) => pool.options.any((option) => option.id == id)),
      )
      .where((tier) => tier.isNotEmpty)
      .map((tier) => tier.toSet())
      .toList(growable: false);
  if (presentTiers.isEmpty) return pool;

  final primary = presentTiers.first;
  final secondary = presentTiers.length > 1
      ? presentTiers[1]
      : const <String>{};
  final other = pool.options
      .where(
        (option) =>
            !primary.contains(option.id) && !secondary.contains(option.id),
      )
      .map((option) => option.id)
      .toSet();
  final groups = <(Set<String>, double)>[
    (primary, .40),
    if (secondary.isNotEmpty) (secondary, other.isEmpty ? .60 : .45),
    if (other.isNotEmpty) (other, secondary.isEmpty ? .60 : .15),
  ];
  return _applyProbabilityBudgets(pool, groups);
}

WheelPool _applyProbabilityBudgets(
  WheelPool pool,
  List<(Set<String>, double)> configuredGroups,
) {
  final groups = configuredGroups
      .where(
        (group) =>
            group.$1.any((id) => pool.options.any((option) => option.id == id)),
      )
      .toList(growable: false);
  final budgetTotal = groups.fold<double>(0, (sum, group) => sum + group.$2);
  double normalizedWeight(WheelOption option) {
    final group = groups.firstWhere((entry) => entry.$1.contains(option.id));
    final groupTotal = pool.options
        .where((item) => group.$1.contains(item.id))
        .fold<double>(0, (sum, item) => sum + item.weight);
    final normalizedBudget = group.$2 / budgetTotal;
    return groupTotal <= 0 ? 0 : option.weight / groupTotal * normalizedBudget;
  }

  return WheelPool(
    id: pool.id,
    title: pool.title,
    options: pool.options
        .map((option) => _copyWithWeight(option, normalizedWeight(option)))
        .toList(growable: false),
  );
}

WheelPool _strengthenedLifePool(WheelPool pool) {
  int score(WheelOption option) => _effectQuality(option);

  final best = pool.options.map(score).reduce((a, b) => a > b ? a : b);
  final primary = pool.options
      .where((option) => score(option) == best)
      .map((option) => option.id)
      .toSet();
  final harmful =
      pool.options
          .where((option) {
            final effects = option.effects;
            return score(option) < 0 ||
                (effects['death'] ?? 0) > 0 ||
                (effects['injury'] ?? 0) > 0;
          })
          .map((option) => option.id)
          .toSet()
        ..removeAll(primary);
  final favorable = pool.options
      .where(
        (option) =>
            score(option) > 0 &&
            !primary.contains(option.id) &&
            !harmful.contains(option.id),
      )
      .map((option) => option.id)
      .toSet();
  final neutral = pool.options
      .where(
        (option) =>
            score(option) == 0 &&
            !primary.contains(option.id) &&
            !harmful.contains(option.id),
      )
      .map((option) => option.id)
      .toSet();
  final safeBudget = harmful.isEmpty ? .60 : .55;
  return _applyProbabilityBudgets(pool, <(Set<String>, double)>[
    (primary, .40),
    if (favorable.isNotEmpty)
      (favorable, neutral.isEmpty ? safeBudget : safeBudget - .10),
    if (neutral.isNotEmpty) (neutral, favorable.isEmpty ? safeBudget : .10),
    if (harmful.isNotEmpty)
      (harmful, favorable.isEmpty && neutral.isEmpty ? .60 : .05),
  ]);
}

WheelPool _strengthenByEffects(WheelPool pool) {
  final scored = <WheelOption, int>{
    for (final option in pool.options) option: _effectQuality(option),
  };
  final distinctScores = scored.values.toSet().toList(growable: false)
    ..sort((a, b) => b.compareTo(a));
  if (distinctScores.length < 2 || distinctScores.first <= 0) return pool;

  final primary = scored.entries
      .where((entry) => entry.value == distinctScores.first)
      .map((entry) => entry.key.id)
      .toSet();
  final secondary = scored.entries
      .where((entry) => entry.value == distinctScores[1])
      .map((entry) => entry.key.id)
      .toSet();
  final other = scored.entries
      .where(
        (entry) =>
            !primary.contains(entry.key.id) &&
            !secondary.contains(entry.key.id),
      )
      .map((entry) => entry.key.id)
      .toSet();

  return _applyProbabilityBudgets(pool, <(Set<String>, double)>[
    (primary, .40),
    (secondary, other.isEmpty ? .60 : .45),
    if (other.isNotEmpty) (other, .15),
  ]);
}

int _effectQuality(WheelOption option) {
  final effects = option.effects;
  if ((effects['death'] ?? 0) > 0) return -1000000;
  var score = 0;
  score += (effects['soulPower'] ?? 0) * 100;
  score += (effects['ringCapacity'] ?? 0) * 40;
  score += (effects['luck'] ?? 0) * 30;
  score += (effects['beastCultivation'] ?? 0) ~/ 20;
  score += (effects['beastYears'] ?? 0) ~/ 5;
  score += (effects['beastBloodline'] ?? 0) * 35;
  score += (effects['beastIntelligence'] ?? 0) * 25;
  score += (effects['beastTerritory'] ?? 0) * 20;
  score += (effects['beastPrestige'] ?? 0) * 20;
  score += (effects['beastBond'] ?? 0) * 18;
  score += (effects['beastClan'] ?? 0) * 35;
  score += (effects['beastResources'] ?? 0) * 20;
  score += (effects['recovery'] ?? 0) * 30;
  score += (effects['rate'] ?? 0) * 50;
  score += (effects['flat'] ?? 0) * 40;
  score += (effects['beastRate'] ?? 0) * 8;
  score += (effects['prestige'] ?? 0) * 20;
  score += (effects['relationship'] ?? 0) * 15;
  score -= (effects['injury'] ?? 0) * 1000;
  score -= (effects['humanThreat'] ?? 0) * 30;
  score -= (effects['beastEnemyPressure'] ?? 0) * 40;
  return score;
}

WheelOption _copyWithWeight(WheelOption option, double weight) => WheelOption(
  id: option.id,
  text: option.text,
  weight: weight,
  minAge: option.minAge,
  maxAge: option.maxAge,
  route: option.route,
  requiredTags: option.requiredTags,
  forbiddenTags: option.forbiddenTags,
  effects: option.effects,
);
