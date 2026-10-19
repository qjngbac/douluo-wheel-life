enum RouteType { undecided, human, soulBeast }

enum LifeStatus { alive, injured, dead, ended }

enum EncounterType { combat, cooperation }

enum MartialSoulSlot { primary, secondary }

enum PersonalityTrait {
  calm,
  careful,
  brave,
  warm,
  ambitious,
  free,
  proud,
  hot,
  loner,
  scholar,
  loyal,
  cunning,
  merciful,
  stubborn,
}

PersonalityTrait? personalityTraitFromTags(Iterable<String> tags) {
  final value = tags
      .where((tag) => tag.startsWith('性格:personality-'))
      .lastOrNull;
  if (value == null) return null;
  final name = value.substring('性格:personality-'.length);
  return PersonalityTrait.values
      .where((trait) => trait.name == name)
      .firstOrNull;
}

enum RingColor {
  white,
  yellow,
  purple,
  black,
  red,
  gold,
  orangeGold,
  greenGold,
  blueGold,
  emerald,
  silverViolet,
  crimsonGold,
  green,
  moonWhite,
  redBrown,
  cyan,
  roseGold,
  rainbow,
}

String ringColorName(RingColor color) => switch (color) {
  RingColor.white => '白',
  RingColor.yellow => '黄',
  RingColor.purple => '紫',
  RingColor.black => '黑',
  RingColor.red => '红',
  RingColor.gold => '金',
  RingColor.orangeGold => '橙金',
  RingColor.greenGold => '绿金',
  RingColor.blueGold => '蓝金',
  RingColor.emerald => '翡翠绿',
  RingColor.silverViolet => '银紫',
  RingColor.crimsonGold => '赤金',
  RingColor.green => '翠绿',
  RingColor.moonWhite => '月白',
  RingColor.redBrown => '红褐',
  RingColor.cyan => '青蓝',
  RingColor.roseGold => '玫瑰金',
  RingColor.rainbow => '七彩',
};

String enumName(Object value) => value.toString().split('.').last;

T enumValue<T extends Enum>(Iterable<T> values, Object? value, T fallback) {
  return values.where((item) => enumName(item) == value).firstOrNull ??
      fallback;
}

class SoulRing {
  const SoulRing({
    required this.color,
    required this.years,
    required this.source,
    required this.skillName,
    required this.description,
  });

  final RingColor color;
  final int years;
  final String source;
  final String skillName;
  final String description;

  Map<String, Object> toJson() => <String, Object>{
    'color': enumName(color),
    'years': years,
    'source': source,
    'skillName': skillName,
    'description': description,
  };

  factory SoulRing.fromJson(Map<String, Object?> json) => SoulRing(
    color: enumValue(RingColor.values, json['color'], RingColor.white),
    years: (json['years'] as num?)?.toInt() ?? 0,
    source: json['source'] as String? ?? '',
    skillName: json['skillName'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

enum SoulBoneSlot {
  head,
  torso,
  leftArm,
  rightArm,
  leftLeg,
  rightLeg,
  external,
}

String soulBoneSlotName(SoulBoneSlot slot) => switch (slot) {
  SoulBoneSlot.head => '头部魂骨',
  SoulBoneSlot.torso => '躯干魂骨',
  SoulBoneSlot.leftArm => '左臂魂骨',
  SoulBoneSlot.rightArm => '右臂魂骨',
  SoulBoneSlot.leftLeg => '左腿魂骨',
  SoulBoneSlot.rightLeg => '右腿魂骨',
  SoulBoneSlot.external => '外附魂骨',
};

class SoulBone {
  const SoulBone({
    required this.id,
    required this.name,
    required this.slot,
    required this.years,
    required this.source,
    required this.skillName,
    required this.description,
    this.evolvable = false,
    this.originColor,
    this.integrity = 100,
    this.setId,
    this.setName,
  });

  final String id;
  final String name;
  final SoulBoneSlot slot;
  final int years;
  final String source;
  final String skillName;
  final String description;
  final bool evolvable;
  final RingColor? originColor;
  final int integrity;
  final String? setId;
  final String? setName;

  SoulBone copyWith({
    String? id,
    String? name,
    int? years,
    String? source,
    String? skillName,
    String? description,
    bool? evolvable,
    RingColor? originColor,
    int? integrity,
    String? setId,
    String? setName,
  }) => SoulBone(
    id: id ?? this.id,
    name: name ?? this.name,
    slot: slot,
    years: years ?? this.years,
    source: source ?? this.source,
    skillName: skillName ?? this.skillName,
    description: description ?? this.description,
    evolvable: evolvable ?? this.evolvable,
    originColor: originColor ?? this.originColor,
    integrity: integrity ?? this.integrity,
    setId: setId ?? this.setId,
    setName: setName ?? this.setName,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'slot': enumName(slot),
    'years': years,
    'source': source,
    'skillName': skillName,
    'description': description,
    'evolvable': evolvable,
    'originColor': originColor == null ? null : enumName(originColor!),
    'integrity': integrity,
    'setId': setId,
    'setName': setName,
  };

  factory SoulBone.fromJson(Map<String, Object?> json) => SoulBone(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '未知魂骨',
    slot: enumValue(SoulBoneSlot.values, json['slot'], SoulBoneSlot.head),
    years: (json['years'] as num?)?.toInt() ?? 0,
    source: json['source'] as String? ?? '未知来源',
    skillName: json['skillName'] as String? ?? '未知魂骨技',
    description: json['description'] as String? ?? '',
    evolvable: json['evolvable'] as bool? ?? false,
    originColor: json['originColor'] == null
        ? null
        : enumValue(RingColor.values, json['originColor'], RingColor.black),
    integrity: (json['integrity'] as num?)?.toInt() ?? 100,
    setId: json['setId'] as String?,
    setName: json['setName'] as String?,
  );
}

class SoulSpirit {
  const SoulSpirit({
    required this.id,
    required this.name,
    required this.species,
    required this.years,
    required this.quality,
    required this.bond,
    required this.remainingRingGrants,
    required this.skillName,
    required this.description,
    this.naturalOrigin = false,
  });

  final String id;
  final String name;
  final String species;
  final int years;
  final String quality;
  final int bond;
  final int remainingRingGrants;
  final String skillName;
  final String description;
  final bool naturalOrigin;

  SoulSpirit copyWith({
    int? years,
    String? quality,
    int? bond,
    int? remainingRingGrants,
  }) => SoulSpirit(
    id: id,
    name: name,
    species: species,
    years: years ?? this.years,
    quality: quality ?? this.quality,
    bond: bond ?? this.bond,
    remainingRingGrants: remainingRingGrants ?? this.remainingRingGrants,
    skillName: skillName,
    description: description,
    naturalOrigin: naturalOrigin,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'species': species,
    'years': years,
    'quality': quality,
    'bond': bond,
    'remainingRingGrants': remainingRingGrants,
    'skillName': skillName,
    'description': description,
    'naturalOrigin': naturalOrigin,
  };

  factory SoulSpirit.fromJson(Map<String, Object?> json) => SoulSpirit(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '未知魂灵',
    species: json['species'] as String? ?? '未知种族',
    years: (json['years'] as num?)?.toInt() ?? 0,
    quality: json['quality'] as String? ?? '普通',
    bond: (json['bond'] as num?)?.toInt() ?? 0,
    remainingRingGrants: (json['remainingRingGrants'] as num?)?.toInt() ?? 0,
    skillName: json['skillName'] as String? ?? '未知魂灵技',
    description: json['description'] as String? ?? '',
    naturalOrigin: json['naturalOrigin'] as bool? ?? false,
  );
}

enum TechnologyType { soulDevice, battleArmor, mecha, starfighter, warship }

String technologyTypeName(TechnologyType type) => switch (type) {
  TechnologyType.soulDevice => '魂导器',
  TechnologyType.battleArmor => '斗铠',
  TechnologyType.mecha => '机甲',
  TechnologyType.starfighter => '星际战机',
  TechnologyType.warship => '星际战舰',
};

class TechnologyAsset {
  const TechnologyAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.rank,
    required this.description,
    required this.source,
    this.integrity = 100,
    this.equipped = true,
    this.upgradeLevel = 0,
    this.memorial = false,
  });

  final String id;
  final String name;
  final TechnologyType type;
  final String rank;
  final String description;
  final String source;
  final int integrity;
  final bool equipped;
  final int upgradeLevel;
  final bool memorial;

  TechnologyAsset copyWith({
    int? integrity,
    bool? equipped,
    int? upgradeLevel,
    bool? memorial,
  }) => TechnologyAsset(
    id: id,
    name: name,
    type: type,
    rank: rank,
    description: description,
    source: source,
    integrity: integrity ?? this.integrity,
    equipped: equipped ?? this.equipped,
    upgradeLevel: upgradeLevel ?? this.upgradeLevel,
    memorial: memorial ?? this.memorial,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'type': enumName(type),
    'rank': rank,
    'description': description,
    'source': source,
    'integrity': integrity,
    'equipped': equipped,
    'upgradeLevel': upgradeLevel,
    'memorial': memorial,
  };

  factory TechnologyAsset.fromJson(Map<String, Object?> json) =>
      TechnologyAsset(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '未知魂导装备',
        type: enumValue(
          TechnologyType.values,
          json['type'],
          TechnologyType.soulDevice,
        ),
        rank: json['rank'] as String? ?? '普通',
        description: json['description'] as String? ?? '',
        source: json['source'] as String? ?? '未知来源',
        integrity: (json['integrity'] as num?)?.toInt() ?? 100,
        equipped: json['equipped'] as bool? ?? false,
        upgradeLevel: (json['upgradeLevel'] as num?)?.toInt() ?? 0,
        memorial: json['memorial'] as bool? ?? false,
      );
}

class TimelineEntry {
  const TimelineEntry({
    required this.age,
    required this.stage,
    required this.title,
    required this.description,
    this.effects = const <String>[],
  });

  final int age;
  final String stage;
  final String title;
  final String description;
  final List<String> effects;

  Map<String, Object> toJson() => <String, Object>{
    'age': age,
    'stage': stage,
    'title': title,
    'description': description,
    'effects': effects,
  };

  factory TimelineEntry.fromJson(Map<String, Object?> json) => TimelineEntry(
    age: (json['age'] as num?)?.toInt() ?? 0,
    stage: json['stage'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    effects: (json['effects'] as List<Object?>? ?? const <Object?>[])
        .whereType<String>()
        .toList(growable: false),
  );
}

class HuntContext {
  const HuntContext({
    required this.methodId,
    required this.methodName,
    required this.riskMultiplier,
    required this.affinityMultiplier,
    this.candidateSource,
    this.habitat,
  });

  final String methodId;
  final String methodName;
  final double riskMultiplier;
  final double affinityMultiplier;
  final String? candidateSource;
  final String? habitat;

  Map<String, Object?> toJson() => <String, Object?>{
    'methodId': methodId,
    'methodName': methodName,
    'riskMultiplier': riskMultiplier,
    'affinityMultiplier': affinityMultiplier,
    'candidateSource': candidateSource,
    'habitat': habitat,
  };

  factory HuntContext.fromJson(Map<String, Object?> json) => HuntContext(
    methodId: json['methodId'] as String? ?? '',
    methodName: json['methodName'] as String? ?? '',
    riskMultiplier: (json['riskMultiplier'] as num?)?.toDouble() ?? 1,
    affinityMultiplier: (json['affinityMultiplier'] as num?)?.toDouble() ?? 1,
    candidateSource: json['candidateSource'] as String?,
    habitat: json['habitat'] as String?,
  );
}

class EncounterSpec {
  const EncounterSpec({
    required this.opponentId,
    required this.opponentName,
    required this.type,
    required this.opponentPower,
  });

  final String opponentId;
  final String opponentName;
  final EncounterType type;
  final int opponentPower;
}

class PendingEncounter {
  const PendingEncounter({
    required this.eventId,
    required this.opponentId,
    required this.opponentName,
    required this.type,
    required this.opponentPower,
    required this.resumePoolId,
  });

  final String eventId;
  final String opponentId;
  final String opponentName;
  final EncounterType type;
  final int opponentPower;
  final String resumePoolId;

  Map<String, Object?> toJson() => <String, Object?>{
    'eventId': eventId,
    'opponentId': opponentId,
    'opponentName': opponentName,
    'type': enumName(type),
    'opponentPower': opponentPower,
    'resumePoolId': resumePoolId,
  };

  factory PendingEncounter.fromJson(Map<String, Object?> json) =>
      PendingEncounter(
        eventId: json['eventId'] as String? ?? '',
        opponentId: json['opponentId'] as String? ?? '',
        opponentName: json['opponentName'] as String? ?? '未知对手',
        type: enumValue(
          EncounterType.values,
          json['type'],
          EncounterType.combat,
        ),
        opponentPower: (json['opponentPower'] as num?)?.toInt() ?? 1,
        resumePoolId: json['resumePoolId'] as String? ?? 'ageGrowth',
      );
}

class Relationship {
  Relationship({
    required this.id,
    required this.name,
    required this.type,
    this.trust = 0,
    this.affection = 0,
    this.alive = true,
    List<String>? sharedEvents,
  }) : sharedEvents = sharedEvents ?? <String>[];

  final String id;
  final String name;
  final String type;
  int trust;
  int affection;
  bool alive;
  List<String> sharedEvents;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'type': type,
    'trust': trust,
    'affection': affection,
    'alive': alive,
    'sharedEvents': sharedEvents,
  };

  factory Relationship.fromJson(Map<String, Object?> json) => Relationship(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    type: json['type'] as String? ?? '',
    trust: (json['trust'] as num?)?.toInt() ?? 0,
    affection: (json['affection'] as num?)?.toInt() ?? 0,
    alive: json['alive'] as bool? ?? true,
    sharedEvents: (json['sharedEvents'] as List<Object?>? ?? const <Object?>[])
        .whereType<String>()
        .toList(),
  );
}

class Character {
  Character({
    this.route = RouteType.undecided,
    this.eraId,
    this.era,
    this.timeline,
    this.protagonistOffset = 0,
    this.gender,
    this.characterName,
    this.aspiration,
    this.appearance,
    this.race,
    this.personality,
    this.family,
    this.constitution,
    this.spirit,
    this.talent,
    this.faction,
    this.mentor,
    this.martialSoul,
    this.secondaryMartialSoul,
    this.innatePower,
    this.age = 0,
    this.lifeStartAge = 0,
    this.beastYears = 0,
    this.soulPower = 0,
    this.lifeExpectancy = 0,
    this.cultivationInsight = 0,
    this.ringCapacityBonus = 0,
    this.godhood,
    this.divinityScore = 0,
    this.beastMilestone,
    this.beastPath = '荒野兽身',
    this.beastBloodlinePower = 0,
    this.beastIntelligence = 0,
    this.beastTerritory = 0,
    this.beastPrestige = 0,
    this.humanThreat = 0,
    this.beastBond = 0,
    this.beastArchetype = '陆生兽族',
    this.beastClanPopulation = 1,
    this.beastResources = 10,
    this.beastEnemyPressure = 0,
    this.beastHabitat = '未定栖息地',
    this.maximumHumanThreat = 0,
    this.luck = 0,
    this.status = LifeStatus.alive,
    this.injuryTurns = 0,
    this.soulEngineerLevel = 0,
    this.battleArmorStage,
    this.mechaRank,
    this.starCommandLevel = 0,
    this.goldCoins = 0,
    this.rareMetals = 0,
    this.factionReputation = 0,
    this.soulBeastTrust = 0,
    this.starMerit = 0,
    List<String>? tags,
    List<String>? earnedTitles,
    List<String>? lifeMarks,
    Map<String, int>? storyThemeProgress,
    List<SoulRing>? soulRings,
    List<SoulRing>? secondarySoulRings,
    List<SoulBone>? soulBones,
    List<SoulBone>? spareSoulBones,
    List<SoulSpirit>? soulSpirits,
    List<TechnologyAsset>? technologyAssets,
  }) : tags = tags ?? <String>[],
       earnedTitles = earnedTitles ?? <String>[],
       lifeMarks = lifeMarks ?? <String>[],
       soulRings = soulRings ?? <SoulRing>[],
       secondarySoulRings = secondarySoulRings ?? <SoulRing>[],
       soulBones = soulBones ?? <SoulBone>[],
       spareSoulBones = spareSoulBones ?? <SoulBone>[],
       soulSpirits = soulSpirits ?? <SoulSpirit>[],
       technologyAssets = technologyAssets ?? <TechnologyAsset>[],
       storyThemeProgress = storyThemeProgress ?? <String, int>{};

  RouteType route;
  String? eraId;
  String? era;
  String? timeline;
  int protagonistOffset;
  String? gender;
  String? characterName;
  String? aspiration;
  String? appearance;
  String? race;
  String? personality;
  String? family;
  String? constitution;
  String? spirit;
  String? talent;
  String? faction;
  String? mentor;
  String? martialSoul;
  String? secondaryMartialSoul;
  int? innatePower;
  int age;
  int lifeStartAge;
  int beastYears;
  int soulPower;
  int lifeExpectancy;
  int cultivationInsight;
  int ringCapacityBonus;
  String? godhood;
  int divinityScore;
  String? beastMilestone;
  String beastPath;
  int beastBloodlinePower;
  int beastIntelligence;
  int beastTerritory;
  int beastPrestige;
  int humanThreat;
  int beastBond;
  String beastArchetype;
  int beastClanPopulation;
  int beastResources;
  int beastEnemyPressure;
  String beastHabitat;
  int maximumHumanThreat;
  int luck;
  LifeStatus status;
  int injuryTurns;
  int soulEngineerLevel;
  String? battleArmorStage;
  String? mechaRank;
  int starCommandLevel;
  int goldCoins;
  int rareMetals;
  int factionReputation;
  int soulBeastTrust;
  int starMerit;
  List<String> tags;
  List<String> earnedTitles;
  List<String> lifeMarks;
  Map<String, int> storyThemeProgress;
  List<SoulRing> soulRings;
  List<SoulRing> secondarySoulRings;
  List<SoulBone> soulBones;
  List<SoulBone> spareSoulBones;
  List<SoulSpirit> soulSpirits;
  List<TechnologyAsset> technologyAssets;

  bool get hasTwinMartialSouls => secondaryMartialSoul != null;

  String? martialSoulFor(MartialSoulSlot slot) => switch (slot) {
    MartialSoulSlot.primary => martialSoul,
    MartialSoulSlot.secondary => secondaryMartialSoul,
  };

  List<SoulRing> soulRingsFor(MartialSoulSlot slot) => switch (slot) {
    MartialSoulSlot.primary => soulRings,
    MartialSoulSlot.secondary => secondarySoulRings,
  };

  Character copy() => Character.fromJson(toJson());

  Map<String, Object?> toJson() => <String, Object?>{
    'route': enumName(route),
    'eraId': eraId,
    'era': era,
    'timeline': timeline,
    'protagonistOffset': protagonistOffset,
    'gender': gender,
    'characterName': characterName,
    'aspiration': aspiration,
    'appearance': appearance,
    'race': race,
    'personality': personality,
    'family': family,
    'constitution': constitution,
    'spirit': spirit,
    'talent': talent,
    'faction': faction,
    'mentor': mentor,
    'martialSoul': martialSoul,
    'secondaryMartialSoul': secondaryMartialSoul,
    'innatePower': innatePower,
    'age': age,
    'lifeStartAge': lifeStartAge,
    'beastYears': beastYears,
    'soulPower': soulPower,
    'lifeExpectancy': lifeExpectancy,
    'cultivationInsight': cultivationInsight,
    'ringCapacityBonus': ringCapacityBonus,
    'godhood': godhood,
    'divinityScore': divinityScore,
    'beastMilestone': beastMilestone,
    'beastPath': beastPath,
    'beastBloodlinePower': beastBloodlinePower,
    'beastIntelligence': beastIntelligence,
    'beastTerritory': beastTerritory,
    'beastPrestige': beastPrestige,
    'humanThreat': humanThreat,
    'beastBond': beastBond,
    'beastArchetype': beastArchetype,
    'beastClanPopulation': beastClanPopulation,
    'beastResources': beastResources,
    'beastEnemyPressure': beastEnemyPressure,
    'beastHabitat': beastHabitat,
    'maximumHumanThreat': maximumHumanThreat,
    'luck': luck,
    'status': enumName(status),
    'injuryTurns': injuryTurns,
    'soulEngineerLevel': soulEngineerLevel,
    'battleArmorStage': battleArmorStage,
    'mechaRank': mechaRank,
    'starCommandLevel': starCommandLevel,
    'goldCoins': goldCoins,
    'rareMetals': rareMetals,
    'factionReputation': factionReputation,
    'soulBeastTrust': soulBeastTrust,
    'starMerit': starMerit,
    'tags': tags,
    'earnedTitles': earnedTitles,
    'lifeMarks': lifeMarks,
    'storyThemeProgress': storyThemeProgress,
    'soulRings': soulRings.map((ring) => ring.toJson()).toList(),
    'secondarySoulRings': secondarySoulRings
        .map((ring) => ring.toJson())
        .toList(),
    'soulBones': soulBones.map((bone) => bone.toJson()).toList(),
    'spareSoulBones': spareSoulBones.map((bone) => bone.toJson()).toList(),
    'soulSpirits': soulSpirits.map((spirit) => spirit.toJson()).toList(),
    'technologyAssets': technologyAssets
        .map((asset) => asset.toJson())
        .toList(),
  };

  factory Character.fromJson(Map<String, Object?> json) => Character(
    route: enumValue(RouteType.values, json['route'], RouteType.undecided),
    eraId: json['eraId'] as String?,
    era: json['era'] as String?,
    timeline: json['timeline'] as String?,
    protagonistOffset: (json['protagonistOffset'] as num?)?.toInt() ?? 0,
    gender: json['gender'] as String?,
    characterName: json['characterName'] as String?,
    aspiration: json['aspiration'] as String?,
    appearance: json['appearance'] as String?,
    race: json['race'] as String?,
    personality: json['personality'] as String?,
    family: json['family'] as String?,
    constitution: json['constitution'] as String?,
    spirit: json['spirit'] as String?,
    talent: json['talent'] as String?,
    faction: json['faction'] as String?,
    mentor: json['mentor'] as String?,
    martialSoul: json['martialSoul'] as String?,
    secondaryMartialSoul: json['secondaryMartialSoul'] as String?,
    innatePower: (json['innatePower'] as num?)?.toInt(),
    age: (json['age'] as num?)?.toInt() ?? 0,
    lifeStartAge:
        (json['lifeStartAge'] as num?)?.toInt() ??
        (json['age'] as num?)?.toInt() ??
        0,
    beastYears: (json['beastYears'] as num?)?.toInt() ?? 0,
    soulPower: (json['soulPower'] as num?)?.toInt() ?? 0,
    lifeExpectancy: (json['lifeExpectancy'] as num?)?.toInt() ?? 0,
    cultivationInsight: (json['cultivationInsight'] as num?)?.toInt() ?? 0,
    ringCapacityBonus: (json['ringCapacityBonus'] as num?)?.toInt() ?? 0,
    godhood: json['godhood'] as String?,
    divinityScore: (json['divinityScore'] as num?)?.toInt() ?? 0,
    beastMilestone: json['beastMilestone'] as String?,
    beastPath: json['beastPath'] as String? ?? '荒野兽身',
    beastBloodlinePower: (json['beastBloodlinePower'] as num?)?.toInt() ?? 0,
    beastIntelligence: (json['beastIntelligence'] as num?)?.toInt() ?? 0,
    beastTerritory: (json['beastTerritory'] as num?)?.toInt() ?? 0,
    beastPrestige: (json['beastPrestige'] as num?)?.toInt() ?? 0,
    humanThreat: (json['humanThreat'] as num?)?.toInt() ?? 0,
    beastBond: (json['beastBond'] as num?)?.toInt() ?? 0,
    beastArchetype: json['beastArchetype'] as String? ?? '陆生兽族',
    beastClanPopulation: (json['beastClanPopulation'] as num?)?.toInt() ?? 1,
    beastResources: (json['beastResources'] as num?)?.toInt() ?? 10,
    beastEnemyPressure: (json['beastEnemyPressure'] as num?)?.toInt() ?? 0,
    beastHabitat: json['beastHabitat'] as String? ?? '未定栖息地',
    maximumHumanThreat:
        (json['maximumHumanThreat'] as num?)?.toInt() ??
        (json['humanThreat'] as num?)?.toInt() ??
        0,
    luck: (json['luck'] as num?)?.toInt() ?? 0,
    status: enumValue(LifeStatus.values, json['status'], LifeStatus.alive),
    injuryTurns: (json['injuryTurns'] as num?)?.toInt() ?? 0,
    soulEngineerLevel: ((json['soulEngineerLevel'] as num?)?.toInt() ?? 0)
        .clamp(0, 10),
    battleArmorStage: json['battleArmorStage'] as String?,
    mechaRank: json['mechaRank'] as String?,
    starCommandLevel: ((json['starCommandLevel'] as num?)?.toInt() ?? 0).clamp(
      0,
      10,
    ),
    goldCoins: (json['goldCoins'] as num?)?.toInt() ?? 0,
    rareMetals: (json['rareMetals'] as num?)?.toInt() ?? 0,
    factionReputation: (json['factionReputation'] as num?)?.toInt() ?? 0,
    soulBeastTrust: (json['soulBeastTrust'] as num?)?.toInt() ?? 0,
    starMerit: (json['starMerit'] as num?)?.toInt() ?? 0,
    tags: (json['tags'] as List<Object?>? ?? const <Object?>[])
        .whereType<String>()
        .toList(),
    earnedTitles: (json['earnedTitles'] as List<Object?>? ?? const <Object?>[])
        .whereType<String>()
        .toList(),
    lifeMarks: (json['lifeMarks'] as List<Object?>? ?? const <Object?>[])
        .whereType<String>()
        .toList(),
    storyThemeProgress:
        (json['storyThemeProgress'] as Map<Object?, Object?>? ??
                const <Object?, Object?>{})
            .map(
              (key, value) =>
                  MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
            ),
    soulRings: (json['soulRings'] as List<Object?>? ?? const <Object?>[])
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) => SoulRing.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList(),
    secondarySoulRings:
        (json['secondarySoulRings'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map<Object?, Object?>>()
            .map(
              (item) => SoulRing.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList(),
    soulBones: (json['soulBones'] as List<Object?>? ?? const <Object?>[])
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) => SoulBone.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList(),
    spareSoulBones:
        (json['spareSoulBones'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map<Object?, Object?>>()
            .map(
              (item) => SoulBone.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList(),
    soulSpirits: (json['soulSpirits'] as List<Object?>? ?? const <Object?>[])
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) => SoulSpirit.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList(),
    technologyAssets:
        (json['technologyAssets'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map<Object?, Object?>>()
            .map(
              (item) => TechnologyAsset.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .toList(),
  );
}

class WheelOption {
  const WheelOption({
    required this.id,
    required this.text,
    required this.weight,
    this.minAge = 0,
    this.maxAge = 1000000,
    this.route,
    this.requiredTags = const <String>[],
    this.forbiddenTags = const <String>[],
    this.effects = const <String, int>{},
  });

  final String id;
  final String text;
  final double weight;
  final int minAge;
  final int maxAge;
  final RouteType? route;
  final List<String> requiredTags;
  final List<String> forbiddenTags;
  final Map<String, int> effects;
}

class WheelPool {
  const WheelPool({
    required this.id,
    required this.title,
    required this.options,
  });

  final String id;
  final String title;
  final List<WheelOption> options;
}

class StoryEvent {
  const StoryEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.weight,
    this.route,
    this.minAge = 0,
    this.maxAge = 1000000,
    this.eraIds = const <String>[],
    this.minProtagonistYear = -1000000,
    this.maxProtagonistYear = 1000000,
    this.minSoulPower = 0,
    this.minBeastYears = 0,
    this.requiredTags = const <String>[],
    this.forbiddenTags = const <String>[],
    this.effects = const <String, int>{},
    this.addTags = const <String>[],
    this.favoredPersonalities = const <PersonalityTrait>[],
    this.conflictingPersonalities = const <PersonalityTrait>[],
    this.arcId,
    this.arcStage = 0,
    this.repeatLimit = 0,
    this.cooldownYears = 0,
    this.relationshipId,
    this.relationshipName,
    this.relationshipType = '命运同伴',
    this.trustDelta = 0,
    this.affectionDelta = 0,
    this.minRelationshipTrust = 0,
    this.maxRelationshipTrust = 100,
    this.relationshipMustBeAlive = false,
    this.encounter,
  });

  final String id;
  final String title;
  final String description;
  final double weight;
  final RouteType? route;
  final int minAge;
  final int maxAge;
  final List<String> eraIds;
  final int minProtagonistYear;
  final int maxProtagonistYear;
  final int minSoulPower;
  final int minBeastYears;
  final List<String> requiredTags;
  final List<String> forbiddenTags;
  final Map<String, int> effects;
  final List<String> addTags;
  final List<PersonalityTrait> favoredPersonalities;
  final List<PersonalityTrait> conflictingPersonalities;
  final String? arcId;
  final int arcStage;
  final int repeatLimit;
  final int cooldownYears;
  final String? relationshipId;
  final String? relationshipName;
  final String relationshipType;
  final int trustDelta;
  final int affectionDelta;
  final int minRelationshipTrust;
  final int maxRelationshipTrust;
  final bool relationshipMustBeAlive;
  final EncounterSpec? encounter;
}

class GameData {
  const GameData({required this.pools, required this.events, this.forceRoute});

  final Map<String, WheelPool> pools;
  final List<StoryEvent> events;
  final RouteType? forceRoute;

  const GameData.forceSoulBeast()
    : pools = const <String, WheelPool>{},
      events = const <StoryEvent>[],
      forceRoute = RouteType.soulBeast;
}

const String currentDataVersion = 'v7';
const int currentRngVersion = 5;
const int currentContentVersion = 11;

class GameState {
  GameState({
    required this.seed,
    required this.randomState,
    this.dataVersion = currentDataVersion,
    this.rngVersion = currentRngVersion,
    this.contentVersion = currentContentVersion,
    this.contentFingerprint = '',
    Character? character,
    List<TimelineEntry>? timeline,
    this.currentPoolId = 'era',
    this.latestTitle,
    this.latestResult,
    List<String>? latestEffects,
    this.pendingRing,
    this.pendingHunt,
    this.pendingRingTarget,
    this.pendingSoulBoneRing,
    this.pendingSoulBone,
    this.pendingSoulSpiritMethodId,
    this.pendingSoulSpirit,
    this.pendingLifeEvents = 0,
    this.pendingYears = 0,
    this.lifeEventCount = 0,
    this.isFinished = false,
    this.ending,
    List<Relationship>? relationships,
    Map<String, int>? eventCounts,
    Map<String, int>? arcStages,
    Map<String, int>? cooldownUntilAge,
    List<String>? triggeredEraMilestones,
    this.pendingEraMilestoneId,
    this.pendingBeastMilestone,
    List<String>? latestCauses,
    this.invitationMode = false,
    List<BatchResult>? batchResults,
    this.pendingGodPathId,
    this.godTrialStep = 0,
    this.godTrialScore = 0,
    this.pendingEncounter,
    List<String>? recentEventIds,
    this.archiveAlias,
    this.archiveFavorite = false,
    this.archiveLocked = false,
    this.pendingTechnologyAssetId,
    this.pendingTechnologyResumePoolId,
  }) : character = character ?? Character(),
       timeline = timeline ?? <TimelineEntry>[],
       latestEffects = latestEffects ?? <String>[],
       relationships = relationships ?? <Relationship>[],
       eventCounts = eventCounts ?? <String, int>{},
       arcStages = arcStages ?? <String, int>{},
       cooldownUntilAge = cooldownUntilAge ?? <String, int>{},
       triggeredEraMilestones = triggeredEraMilestones ?? <String>[],
       latestCauses = latestCauses ?? <String>[],
       batchResults = batchResults ?? <BatchResult>[],
       recentEventIds = recentEventIds ?? <String>[];

  final String seed;
  final String dataVersion;
  int rngVersion;
  int contentVersion;
  final String contentFingerprint;
  int randomState;
  Character character;
  List<TimelineEntry> timeline;
  String? currentPoolId;
  String? latestTitle;
  String? latestResult;
  List<String> latestEffects;
  SoulRing? pendingRing;
  HuntContext? pendingHunt;
  MartialSoulSlot? pendingRingTarget;
  SoulRing? pendingSoulBoneRing;
  SoulBone? pendingSoulBone;
  String? pendingSoulSpiritMethodId;
  SoulSpirit? pendingSoulSpirit;
  int pendingLifeEvents;
  int pendingYears;
  int lifeEventCount;
  bool isFinished;
  String? ending;
  List<Relationship> relationships;
  Map<String, int> eventCounts;
  Map<String, int> arcStages;
  Map<String, int> cooldownUntilAge;
  List<String> triggeredEraMilestones;
  String? pendingEraMilestoneId;
  String? pendingBeastMilestone;
  List<String> latestCauses;
  bool invitationMode;
  List<BatchResult> batchResults;
  String? pendingGodPathId;
  int godTrialStep;
  int godTrialScore;
  PendingEncounter? pendingEncounter;
  List<String> recentEventIds;
  String? archiveAlias;
  bool archiveFavorite;
  bool archiveLocked;
  String? pendingTechnologyAssetId;
  String? pendingTechnologyResumePoolId;

  GameState copy() => GameState.fromJson(toJson());

  Map<String, Object?> toJson() => <String, Object?>{
    'seed': seed,
    'dataVersion': dataVersion,
    'rngVersion': rngVersion,
    'contentVersion': contentVersion,
    'contentFingerprint': contentFingerprint,
    'randomState': randomState,
    'character': character.toJson(),
    'timeline': timeline.map((entry) => entry.toJson()).toList(),
    'currentPoolId': currentPoolId,
    'latestTitle': latestTitle,
    'latestResult': latestResult,
    'latestEffects': latestEffects,
    'pendingRing': pendingRing?.toJson(),
    'pendingHunt': pendingHunt?.toJson(),
    'pendingRingTarget': pendingRingTarget == null
        ? null
        : enumName(pendingRingTarget!),
    'pendingSoulBoneRing': pendingSoulBoneRing?.toJson(),
    'pendingSoulBone': pendingSoulBone?.toJson(),
    'pendingSoulSpiritMethodId': pendingSoulSpiritMethodId,
    'pendingSoulSpirit': pendingSoulSpirit?.toJson(),
    'pendingLifeEvents': pendingLifeEvents,
    'pendingYears': pendingYears,
    'lifeEventCount': lifeEventCount,
    'isFinished': isFinished,
    'ending': ending,
    'relationships': relationships.map((item) => item.toJson()).toList(),
    'eventCounts': eventCounts,
    'arcStages': arcStages,
    'cooldownUntilAge': cooldownUntilAge,
    'triggeredEraMilestones': triggeredEraMilestones,
    'pendingEraMilestoneId': pendingEraMilestoneId,
    'pendingBeastMilestone': pendingBeastMilestone,
    'latestCauses': latestCauses,
    'invitationMode': invitationMode,
    'batchResults': batchResults.map((item) => item.toJson()).toList(),
    'pendingGodPathId': pendingGodPathId,
    'godTrialStep': godTrialStep,
    'godTrialScore': godTrialScore,
    'pendingEncounter': pendingEncounter?.toJson(),
    'recentEventIds': recentEventIds,
    'archiveAlias': archiveAlias,
    'archiveFavorite': archiveFavorite,
    'archiveLocked': archiveLocked,
    'pendingTechnologyAssetId': pendingTechnologyAssetId,
    'pendingTechnologyResumePoolId': pendingTechnologyResumePoolId,
  };

  factory GameState.fromJson(Map<String, Object?> json) {
    Map<String, Object?> mapValue(Object? value) =>
        (value as Map<Object?, Object?>?)?.map(
          (key, item) => MapEntry(key.toString(), item),
        ) ??
        <String, Object?>{};

    Map<String, int> intMap(Object? value) => mapValue(
      value,
    ).map((key, item) => MapEntry(key, (item as num?)?.toInt() ?? 0));

    return GameState(
      seed: json['seed'] as String? ?? '',
      dataVersion: json['dataVersion'] as String? ?? 'v1',
      rngVersion: (json['rngVersion'] as num?)?.toInt() ?? 2,
      contentVersion: (json['contentVersion'] as num?)?.toInt() ?? 5,
      contentFingerprint: json['contentFingerprint'] as String? ?? '',
      randomState: (json['randomState'] as num?)?.toInt() ?? 1,
      character: Character.fromJson(mapValue(json['character'])),
      timeline: (json['timeline'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map((item) => TimelineEntry.fromJson(mapValue(item)))
          .toList(),
      currentPoolId: json['currentPoolId'] as String?,
      latestTitle: json['latestTitle'] as String?,
      latestResult: json['latestResult'] as String?,
      latestEffects:
          (json['latestEffects'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>()
              .toList(),
      pendingRing: json['pendingRing'] == null
          ? null
          : SoulRing.fromJson(mapValue(json['pendingRing'])),
      pendingHunt: json['pendingHunt'] == null
          ? null
          : HuntContext.fromJson(mapValue(json['pendingHunt'])),
      pendingRingTarget: json['pendingRingTarget'] == null
          ? null
          : enumValue(
              MartialSoulSlot.values,
              json['pendingRingTarget'],
              MartialSoulSlot.primary,
            ),
      pendingSoulBoneRing: json['pendingSoulBoneRing'] == null
          ? null
          : SoulRing.fromJson(mapValue(json['pendingSoulBoneRing'])),
      pendingSoulBone: json['pendingSoulBone'] == null
          ? null
          : SoulBone.fromJson(mapValue(json['pendingSoulBone'])),
      pendingSoulSpiritMethodId: json['pendingSoulSpiritMethodId'] as String?,
      pendingSoulSpirit: json['pendingSoulSpirit'] == null
          ? null
          : SoulSpirit.fromJson(mapValue(json['pendingSoulSpirit'])),
      pendingLifeEvents: (json['pendingLifeEvents'] as num?)?.toInt() ?? 0,
      pendingYears: (json['pendingYears'] as num?)?.toInt() ?? 0,
      lifeEventCount: (json['lifeEventCount'] as num?)?.toInt() ?? 0,
      isFinished: json['isFinished'] as bool? ?? false,
      ending: json['ending'] as String?,
      relationships:
          (json['relationships'] as List<Object?>? ?? const <Object?>[])
              .whereType<Map<Object?, Object?>>()
              .map((item) => Relationship.fromJson(mapValue(item)))
              .toList(),
      eventCounts: intMap(json['eventCounts']),
      arcStages: intMap(json['arcStages']),
      cooldownUntilAge: intMap(json['cooldownUntilAge']),
      triggeredEraMilestones:
          (json['triggeredEraMilestones'] as List<Object?>? ??
                  const <Object?>[])
              .whereType<String>()
              .toList(),
      pendingEraMilestoneId: json['pendingEraMilestoneId'] as String?,
      pendingBeastMilestone: json['pendingBeastMilestone'] as String?,
      latestCauses:
          (json['latestCauses'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>()
              .toList(),
      invitationMode: json['invitationMode'] as bool? ?? false,
      batchResults:
          (json['batchResults'] as List<Object?>? ?? const <Object?>[])
              .whereType<Map<Object?, Object?>>()
              .map((item) => BatchResult.fromJson(mapValue(item)))
              .toList(),
      pendingGodPathId: json['pendingGodPathId'] as String?,
      godTrialStep: (json['godTrialStep'] as num?)?.toInt() ?? 0,
      godTrialScore: (json['godTrialScore'] as num?)?.toInt() ?? 0,
      pendingEncounter: json['pendingEncounter'] == null
          ? null
          : PendingEncounter.fromJson(mapValue(json['pendingEncounter'])),
      recentEventIds:
          (json['recentEventIds'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>()
              .toList(),
      archiveAlias: json['archiveAlias'] as String?,
      archiveFavorite: json['archiveFavorite'] as bool? ?? false,
      archiveLocked: json['archiveLocked'] as bool? ?? false,
      pendingTechnologyAssetId: json['pendingTechnologyAssetId'] as String?,
      pendingTechnologyResumePoolId:
          json['pendingTechnologyResumePoolId'] as String?,
    );
  }
}

class BatchResult {
  const BatchResult({
    required this.title,
    required this.result,
    required this.age,
    this.effects = const <String>[],
  });

  final String title;
  final String result;
  final int age;
  final List<String> effects;

  Map<String, Object?> toJson() => <String, Object?>{
    'title': title,
    'result': result,
    'age': age,
    'effects': effects,
  };

  factory BatchResult.fromJson(Map<String, Object?> json) => BatchResult(
    title: json['title'] as String? ?? '未命名事件',
    result: json['result'] as String? ?? '',
    age: (json['age'] as num?)?.toInt() ?? 0,
    effects: (json['effects'] as List<Object?>? ?? const <Object?>[])
        .whereType<String>()
        .toList(),
  );
}
