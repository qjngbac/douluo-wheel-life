import '../domain/models.dart';

class GodhoodPathProfile {
  const GodhoodPathProfile({
    required this.id,
    required this.pathText,
    required this.weight,
    required this.sovereignName,
    required this.majorName,
    required this.minorName,
    required this.planeName,
    this.requiredTags = const <String>[],
  });

  final String id;
  final String pathText;
  final double weight;
  final String sovereignName;
  final String majorName;
  final String minorName;
  final String planeName;
  final List<String> requiredTags;
}

const List<GodhoodPathProfile> godhoodPaths = <GodhoodPathProfile>[
  GodhoodPathProfile(
    id: 'god-path-stars',
    pathText: '踏上星穹战神之路',
    weight: 9,
    sovereignName: '星海神王',
    majorName: '星穹战神',
    minorName: '星轨神使',
    planeName: '星域守望者',
  ),
  GodhoodPathProfile(
    id: 'god-path-thunder',
    pathText: '执掌九霄雷霆权柄',
    weight: 8,
    sovereignName: '万雷神王',
    majorName: '九霄雷神',
    minorName: '引雷神官',
    planeName: '雷泽界主',
  ),
  GodhoodPathProfile(
    id: 'god-path-dream',
    pathText: '以万梦编织精神神国',
    weight: 8,
    sovereignName: '太虚梦主',
    majorName: '万梦灵神',
    minorName: '梦境使徒',
    planeName: '灵梦界主',
  ),
  GodhoodPathProfile(
    id: 'god-path-sword',
    pathText: '一剑斩开凡神界限',
    weight: 9,
    sovereignName: '无极剑主',
    majorName: '太初剑神',
    minorName: '凌霄剑使',
    planeName: '剑域守望者',
  ),
  GodhoodPathProfile(
    id: 'god-path-forge',
    pathText: '熔炼万器铸造神座',
    weight: 8,
    sovereignName: '万器神王',
    majorName: '天工铸神',
    minorName: '百炼神匠',
    planeName: '器魂界主',
  ),
  GodhoodPathProfile(
    id: 'god-path-fate',
    pathText: '拨动众生命运轮盘',
    weight: 7,
    sovereignName: '命运神王',
    majorName: '命轮之神',
    minorName: '因果神使',
    planeName: '天命守望者',
  ),
  GodhoodPathProfile(
    id: 'god-path-frost',
    pathText: '在永冻尽头凝聚神性',
    weight: 8,
    sovereignName: '极寒神王',
    majorName: '玄霜神女',
    minorName: '冰魄神使',
    planeName: '雪境界主',
  ),
  GodhoodPathProfile(
    id: 'god-path-flame',
    pathText: '以不灭天焰重铸神躯',
    weight: 8,
    sovereignName: '焚天神王',
    majorName: '天焰神君',
    minorName: '赤阳神使',
    planeName: '炎域界主',
  ),
  GodhoodPathProfile(
    id: 'god-path-shadow',
    pathText: '让幽夜成为自身神国',
    weight: 8,
    sovereignName: '永夜神王',
    majorName: '幽夜之神',
    minorName: '影界神使',
    planeName: '暗幕守望者',
  ),
  GodhoodPathProfile(
    id: 'god-path-beasts',
    pathText: '汇聚万兽血脉登神',
    weight: 7,
    sovereignName: '万兽神王',
    majorName: '万兽神皇',
    minorName: '百兽神使',
    planeName: '荒古界主',
  ),
  GodhoodPathProfile(
    id: 'god-path-soul',
    pathText: '点燃不灭灵魂神火',
    weight: 8,
    sovereignName: '灵魂神王',
    majorName: '灵魂之神',
    minorName: '魂灯神使',
    planeName: '灵界守望者',
  ),
  GodhoodPathProfile(
    id: 'god-path-void',
    pathText: '横渡虚空建立神域',
    weight: 7,
    sovereignName: '虚空神王',
    majorName: '太虚之神',
    minorName: '空间神使',
    planeName: '虚界之主',
  ),
  GodhoodPathProfile(
    id: 'god-path-time',
    pathText: '聆听岁月长河回响',
    weight: 6,
    sovereignName: '时光神王',
    majorName: '时序之神',
    minorName: '流年神使',
    planeName: '岁月守望者',
  ),
  GodhoodPathProfile(
    id: 'god-path-mountain',
    pathText: '背负山海凝聚神座',
    weight: 9,
    sovereignName: '山海神王',
    majorName: '镇岳之神',
    minorName: '山河神使',
    planeName: '大地界主',
  ),
  GodhoodPathProfile(
    id: 'god-path-wind',
    pathText: '驾驭九天罡风登临',
    weight: 9,
    sovereignName: '天风神王',
    majorName: '御风之神',
    minorName: '青岚神使',
    planeName: '风境界主',
  ),
  GodhoodPathProfile(
    id: 'god-path-healing',
    pathText: '以众生愿力孕育春神',
    weight: 8,
    sovereignName: '众生神王',
    majorName: '春生之神',
    minorName: '回春神使',
    planeName: '生灵守望者',
  ),
  GodhoodPathProfile(
    id: 'god-path-guardian',
    pathText: '守护大陆直到法则回应',
    weight: 10,
    sovereignName: '守序神王',
    majorName: '天垣守护神',
    minorName: '壁垒神使',
    planeName: '大陆守望者',
  ),
  GodhoodPathProfile(
    id: 'god-path-abyss',
    pathText: '镇压深渊反铸无畏神格',
    weight: 6,
    sovereignName: '镇渊神王',
    majorName: '无畏战神',
    minorName: '破渊神使',
    planeName: '深渊看守者',
  ),
  GodhoodPathProfile(
    id: 'god-path-sea',
    pathText: '接受海神最终考验',
    weight: 4,
    sovereignName: '海神王',
    majorName: '海神',
    minorName: '沧海神使',
    planeName: '海洋守望者',
    requiredTags: <String>['海神考核'],
  ),
  GodhoodPathProfile(
    id: 'god-path-life',
    pathText: '回应生命神殿召唤',
    weight: 4,
    sovereignName: '生命神王',
    majorName: '生命之神',
    minorName: '生机神使',
    planeName: '生命古域之主',
    requiredTags: <String>['生命祝福'],
  ),
  GodhoodPathProfile(
    id: 'god-path-asura',
    pathText: '直面修罗神的杀戮神考',
    weight: 2.5,
    sovereignName: '修罗神王',
    majorName: '修罗神',
    minorName: '杀戮神使',
    planeName: '修罗界守望者',
    requiredTags: <String>['神考资格'],
  ),
  GodhoodPathProfile(
    id: 'god-path-angel',
    pathText: '接受天使圣光审判',
    weight: 3,
    sovereignName: '圣光神王',
    majorName: '天使神',
    minorName: '炽天神使',
    planeName: '光明守望者',
    requiredTags: <String>['神考资格'],
  ),
  GodhoodPathProfile(
    id: 'god-path-emotion',
    pathText: '以七情六欲铸就神格',
    weight: 3,
    sovereignName: '情绪神王',
    majorName: '情绪之神',
    minorName: '心灵神使',
    planeName: '心界守望者',
    requiredTags: <String>['精神海扩张'],
  ),
  GodhoodPathProfile(
    id: 'god-path-destruction',
    pathText: '在毁灭与新生间悟道',
    weight: 2,
    sovereignName: '毁灭神王',
    majorName: '破灭之神',
    minorName: '寂灭神使',
    planeName: '终焉守望者',
    requiredTags: <String>['领域雏形'],
  ),
  GodhoodPathProfile(
    id: 'god-path-phoenix',
    pathText: '历经九次涅槃神火',
    weight: 3,
    sovereignName: '涅槃神王',
    majorName: '凤凰神',
    minorName: '凤炎神使',
    planeName: '涅槃界主',
    requiredTags: <String>['武魂领悟'],
  ),
  GodhoodPathProfile(
    id: 'god-path-speed',
    pathText: '突破天地极速法则',
    weight: 3.5,
    sovereignName: '极速神王',
    majorName: '速度之神',
    minorName: '追光神使',
    planeName: '天际守望者',
    requiredTags: <String>['战场经验'],
  ),
  GodhoodPathProfile(
    id: 'god-path-nine-color',
    pathText: '以九彩祝福回应众生',
    weight: 3.5,
    sovereignName: '九彩神王',
    majorName: '九彩神女',
    minorName: '琉彩神使',
    planeName: '九宝界主',
    requiredTags: <String>['深厚羁绊'],
  ),
  GodhoodPathProfile(
    id: 'god-path-world',
    pathText: '承受天地法则洗礼',
    weight: 8,
    sovereignName: '万法神王',
    majorName: '法则之神',
    minorName: '万象神使',
    planeName: '位面裁定者',
  ),
  GodhoodPathProfile(
    id: 'god-path-inheritance',
    pathText: '回应远古神位传承',
    weight: 4,
    sovereignName: '太古神王',
    majorName: '古神继承者',
    minorName: '远古神使',
    planeName: '古神遗境之主',
    requiredTags: <String>['神考资格'],
  ),
  GodhoodPathProfile(
    id: 'god-path-self',
    pathText: '以自身道路凝聚神性',
    weight: 9,
    sovereignName: '本源神王',
    majorName: '自证之神',
    minorName: '道途神使',
    planeName: '自创神域之主',
  ),
  GodhoodPathProfile(
    id: 'god-path-twin-balance',
    pathText: '调和双生本源凝聚两仪神格',
    weight: 4,
    sovereignName: '两仪神王',
    majorName: '双生调律神',
    minorName: '两仪神使',
    planeName: '双生界主',
    requiredTags: <String>['双武魂互补'],
  ),
  GodhoodPathProfile(
    id: 'god-path-twin-chaos',
    pathText: '驾驭相克双魂铸成混沌神座',
    weight: 2.5,
    sovereignName: '混沌神王',
    majorName: '逆律战神',
    minorName: '冲突神使',
    planeName: '混沌界主',
    requiredTags: <String>['双武魂冲突'],
  ),
  GodhoodPathProfile(
    id: 'god-path-twin-fusion',
    pathText: '以武魂融合技开辟共鸣神域',
    weight: 3,
    sovereignName: '共鸣神王',
    majorName: '万象融合神',
    minorName: '同律神使',
    planeName: '共鸣界主',
    requiredTags: <String>['武魂融合'],
  ),
];

WheelPool buildGodhoodPathPool() => WheelPool(
  id: 'godhoodEvent',
  title: '百级神途事件',
  options: godhoodPaths
      .map(
        (path) => WheelOption(
          id: path.id,
          text: path.pathText,
          weight: path.weight,
          requiredTags: path.requiredTags,
        ),
      )
      .toList(growable: false),
);

double godhoodPathMultiplier(String pathId, Character character) {
  var multiplier = 1.0;
  final soul =
      '${character.martialSoul ?? ''}${character.secondaryMartialSoul ?? ''}';
  final ringText = <SoulRing>[
    ...character.soulRings,
    ...character.secondarySoulRings,
  ].map((ring) => '${ring.source}${ring.skillName}${ring.description}').join();
  final combined = '$soul$ringText';
  const keywords = <String, List<String>>{
    'god-path-thunder': <String>['雷', '电', '霆'],
    'god-path-flame': <String>['火', '炎', '焰'],
    'god-path-phoenix': <String>['凰', '凤', '涅槃'],
    'god-path-frost': <String>['冰', '霜', '雪', '寒'],
    'god-path-sea': <String>['海', '水', '潮', '鲸'],
    'god-path-life': <String>['生命', '木', '藤', '鹿', '回春'],
    'god-path-healing': <String>['治疗', '回春', '生命'],
    'god-path-dream': <String>['梦', '幻', '精神', '心'],
    'god-path-soul': <String>['魂', '精神', '灵'],
    'god-path-sword': <String>['剑', '刃', '斩'],
    'god-path-forge': <String>['器', '锻', '魂导'],
    'god-path-shadow': <String>['影', '暗', '幽', '冥'],
    'god-path-wind': <String>['风', '速', '翼'],
    'god-path-beasts': <String>['兽', '龙', '血脉'],
    'god-path-stars': <String>['星', '月', '天象'],
    'god-path-time': <String>['时', '岁月'],
    'god-path-void': <String>['空', '虚'],
    'god-path-twin-balance': <String>['生命', '水', '光', '藤', '海棠'],
    'god-path-twin-chaos': <String>['冰', '火', '光', '暗', '死亡'],
    'god-path-twin-fusion': <String>['双生', '融合', '共鸣'],
  };
  final matchedKeywords = keywords[pathId] ?? const <String>[];
  multiplier += matchedKeywords.where(combined.contains).length * .42;

  const tagMatches = <String, List<String>>{
    'god-path-guardian': <String>['深厚羁绊', '调停声望', '守护者'],
    'god-path-fate': <String>['命运回响', '旧约'],
    'god-path-asura': <String>['战场经验', '绝境爆发'],
    'god-path-destruction': <String>['领域雏形', '极限突破'],
    'god-path-sea': <String>['海神考核'],
    'god-path-life': <String>['生命祝福'],
    'god-path-nine-color': <String>['深厚羁绊'],
    'god-path-speed': <String>['战场经验'],
    'god-path-inheritance': <String>['神考资格'],
    'god-path-twin-balance': <String>['双武魂互补'],
    'god-path-twin-chaos': <String>['双武魂冲突'],
    'god-path-twin-fusion': <String>['武魂融合'],
  };
  multiplier +=
      (tagMatches[pathId] ?? const <String>[])
          .where(character.tags.contains)
          .length *
      .5;

  final personality = personalityTraitFromTags(character.tags);
  final personalityPaths = <PersonalityTrait, Set<String>>{
    PersonalityTrait.loyal: <String>{
      'god-path-guardian',
      'god-path-nine-color',
    },
    PersonalityTrait.merciful: <String>{'god-path-life', 'god-path-healing'},
    PersonalityTrait.hot: <String>{'god-path-flame', 'god-path-thunder'},
    PersonalityTrait.scholar: <String>{'god-path-forge', 'god-path-time'},
    PersonalityTrait.loner: <String>{'god-path-shadow', 'god-path-void'},
    PersonalityTrait.brave: <String>{'god-path-sword', 'god-path-asura'},
    PersonalityTrait.cunning: <String>{'god-path-fate', 'god-path-shadow'},
    PersonalityTrait.calm: <String>{'god-path-frost', 'god-path-soul'},
  };
  if (personality != null &&
      (personalityPaths[personality]?.contains(pathId) ?? false)) {
    multiplier += .45;
  }
  if (character.route == RouteType.soulBeast && pathId == 'god-path-beasts') {
    multiplier += 1;
  }
  return multiplier.clamp(.5, 4.0).toDouble();
}

List<String> godhoodPathReasons(String pathId, Character character) {
  final reasons = <String>[];
  final multiplier = godhoodPathMultiplier(pathId, character);
  if (multiplier > 1.35 && character.martialSoul != null) {
    reasons.add('武魂、魂环、性格或既往经历与这条神途形成了法则共鸣');
  }
  if (character.soulRings.any((ring) => ring.years >= 100000)) {
    reasons.add('高年限魂环为凝聚神性提供了承载基础');
  }
  if (character.tags.contains('神考资格')) {
    reasons.add('既有神考资格让神界法则更容易回应');
  }
  if (reasons.isEmpty) reasons.add('一生积累使这条神途进入可选命运');
  return reasons;
}

WheelPool buildGodhoodOutcomePool() {
  final options = <WheelOption>[];
  for (final path in godhoodPaths) {
    final required = <String>['神途:${path.id}'];
    final suffix = path.id.substring('god-path-'.length);
    options.addAll(<WheelOption>[
      WheelOption(
        id: 'god-success-sovereign-$suffix',
        text: '神王位·${path.sovereignName}',
        weight: .4,
        requiredTags: required,
      ),
      WheelOption(
        id: 'god-success-major-$suffix',
        text: '一级神位·${path.majorName}',
        weight: 2.2,
        requiredTags: required,
      ),
      WheelOption(
        id: 'god-success-$suffix',
        text: '二级神位·${path.minorName}',
        weight: 8,
        requiredTags: required,
      ),
      WheelOption(
        id: 'god-success-plane-$suffix',
        text: '位面神祇·${path.planeName}',
        weight: 12,
        requiredTags: required,
      ),
    ]);
  }
  options.addAll(const <WheelOption>[
    WheelOption(id: 'god-retire', text: '神考止步后归隐人间', weight: 24),
    WheelOption(id: 'god-wounded', text: '神格破碎但保住性命', weight: 8),
    WheelOption(id: 'god-fall', text: '神考中陨落', weight: 3),
  ]);
  return WheelPool(id: 'godhoodOutcome', title: '神位结局', options: options);
}
