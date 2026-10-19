import 'dart:math' as math;

import '../domain/models.dart';
import '../engine/ring_engine.dart';
import '../engine/seeded_random.dart';
import '../engine/soul_spirit_growth.dart';

class SoulSpiritProfile {
  const SoulSpiritProfile({
    required this.id,
    required this.name,
    required this.species,
    required this.affinity,
    required this.skill,
    required this.description,
    this.specialColor,
    this.naturalOrigin = true,
  });

  final String id;
  final String name;
  final String species;
  final String affinity;
  final String skill;
  final String description;
  final RingColor? specialColor;
  final bool naturalOrigin;
}

const List<SoulSpiritProfile> soulSpiritProfiles = <SoulSpiritProfile>[
  SoulSpiritProfile(
    id: 'spirit-wind-deer',
    name: '风灵鹿·青岚',
    species: '风灵鹿',
    affinity: '风',
    skill: '流风跃迁',
    description: '温和敏捷，擅长速度增幅与短距闪避。',
  ),
  SoulSpiritProfile(
    id: 'spirit-star-fox',
    name: '星瞳灵狐·璃光',
    species: '星瞳灵狐',
    affinity: '精神',
    skill: '星瞳幻界',
    description: '以星光编织幻境，能够共享精神感知。',
    specialColor: RingColor.silverViolet,
  ),
  SoulSpiritProfile(
    id: 'spirit-thunder-lizard',
    name: '雷纹蜥·惊霆',
    species: '雷纹蜥',
    affinity: '雷',
    skill: '惊雷贯体',
    description: '将雷霆压缩于鳞纹，爆发力极强。',
  ),
  SoulSpiritProfile(
    id: 'spirit-ice-bear',
    name: '冰脊熊·霜岳',
    species: '冰脊熊',
    affinity: '冰',
    skill: '霜岳壁垒',
    description: '兼具寒冰控制与正面防御。',
  ),
  SoulSpiritProfile(
    id: 'spirit-vine',
    name: '碧脉藤·青萝',
    species: '碧脉古藤',
    affinity: '植物',
    skill: '万蔓回春',
    description: '生命力旺盛，可束缚敌人并修复伤势。',
    specialColor: RingColor.green,
  ),
  SoulSpiritProfile(
    id: 'spirit-fire-lion',
    name: '赤焰狮·烬牙',
    species: '赤焰狮',
    affinity: '火',
    skill: '焚野狮吼',
    description: '性情刚烈，以烈焰强化强攻能力。',
  ),
  SoulSpiritProfile(
    id: 'spirit-shadow-wolf',
    name: '幽影狼·夜逐',
    species: '幽影狼',
    affinity: '暗',
    skill: '影袭分身',
    description: '可融入阴影发动连续突袭。',
    specialColor: RingColor.redBrown,
  ),
  SoulSpiritProfile(
    id: 'spirit-earth-turtle',
    name: '玄岩龟·镇川',
    species: '玄岩龟',
    affinity: '土',
    skill: '玄岩镇域',
    description: '魂力厚重，善于守护与地形控制。',
  ),
  SoulSpiritProfile(
    id: 'spirit-water-serpent',
    name: '澜鳞蛇·沧溟',
    species: '澜鳞蛇',
    affinity: '水',
    skill: '沧溟缚浪',
    description: '操纵水流牵制对手并削弱冲击。',
    specialColor: RingColor.cyan,
  ),
  SoulSpiritProfile(
    id: 'spirit-light-butterfly',
    name: '曦光蝶·晨羽',
    species: '曦光蝶',
    affinity: '光',
    skill: '曦羽净化',
    description: '光翼能够净化异常并提供飞行能力。',
    specialColor: RingColor.moonWhite,
  ),
  SoulSpiritProfile(
    id: 'spirit-metal-tiger',
    name: '铸金虎·破军',
    species: '铸金虎',
    affinity: '金属',
    skill: '百炼虎铠',
    description: '将金属魂力凝成甲胄与利爪。',
  ),
  SoulSpiritProfile(
    id: 'spirit-space-marten',
    name: '空痕貂·折星',
    species: '空痕貂',
    affinity: '空间',
    skill: '折星瞬移',
    description: '天生亲近空间，可完成短距离跃迁。',
    specialColor: RingColor.blueGold,
  ),
  SoulSpiritProfile(
    id: 'spirit-dream-silk',
    name: '梦蚕·天绮',
    species: '万象梦蚕',
    affinity: '精神',
    skill: '梦境回响',
    description: '以精神丝线连接彼此意识，适合控制系魂师。',
  ),
  SoulSpiritProfile(
    id: 'spirit-jade-swan',
    name: '翡翠天鹅·碧姬',
    species: '翡翠天鹅',
    affinity: '生命',
    skill: '翡翠守护',
    description: '生命气息纯净，能够修复本源创伤。',
    specialColor: RingColor.emerald,
  ),
  SoulSpiritProfile(
    id: 'spirit-gold-lion',
    name: '三眼金猊·秋曜',
    species: '三眼金猊',
    affinity: '命运',
    skill: '命运裁定',
    description: '稀有祥瑞血脉，可感知并扰动命运。',
    specialColor: RingColor.roseGold,
  ),
  SoulSpiritProfile(
    id: 'spirit-dragon',
    name: '银麟幼龙·月珑',
    species: '银麟龙族',
    affinity: '元素',
    skill: '元素潮汐',
    description: '能够调动多种元素并随魂师共同成长。',
    specialColor: RingColor.rainbow,
  ),
  SoulSpiritProfile(
    id: 'spirit-sea-princess',
    name: '海公主·澄音',
    species: '海公主族',
    affinity: '水',
    skill: '海潮挽歌',
    description: '精神与水元素并重，擅长群体控制。',
    specialColor: RingColor.blueGold,
  ),
  SoulSpiritProfile(
    id: 'spirit-time-owl',
    name: '时砂鸮·岁鸣',
    species: '时砂鸮',
    affinity: '时间',
    skill: '迟滞刻印',
    description: '稀有时序魂兽，可令目标动作短暂迟缓。',
    specialColor: RingColor.gold,
  ),
  SoulSpiritProfile(
    id: 'spirit-void-whale',
    name: '虚海鲸·沉渊',
    species: '虚海鲸',
    affinity: '空间',
    skill: '虚海吞界',
    description: '体内蕴藏微型空间，兼具防御与吞噬。',
    specialColor: RingColor.crimsonGold,
  ),
  SoulSpiritProfile(
    id: 'spirit-phoenix',
    name: '涅槃青凰·栖梧',
    species: '青凰',
    affinity: '火',
    skill: '青焰涅槃',
    description: '青色生命火焰可在重伤时保护魂师。',
    specialColor: RingColor.greenGold,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-core',
    name: '星核零号',
    species: '人造星核魂灵',
    affinity: '魂导',
    skill: '星核超载',
    description: '由魂导核心培育，稳定但无法形成魂骨。',
    specialColor: RingColor.white,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-mecha-sprite',
    name: '机巧灵·弦月',
    species: '人造机巧魂灵',
    affinity: '魂导',
    skill: '灵械协同',
    description: '能够接入魂导器并自动校准输出。',
    specialColor: RingColor.cyan,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-abyss-lotus',
    name: '幽渊莲·冥汐',
    species: '幽渊莲',
    affinity: '暗',
    skill: '幽莲噬魂',
    description: '危险的精神系植物魂灵，力量强大而难以驾驭。',
    specialColor: RingColor.redBrown,
  ),
  SoulSpiritProfile(
    id: 'spirit-sun-crow',
    name: '曜日金乌·灼空',
    species: '曜日金乌',
    affinity: '火',
    skill: '大日巡天',
    description: '承载极致光火属性，拥有罕见的空战优势。',
    specialColor: RingColor.gold,
  ),
  SoulSpiritProfile(
    id: 'spirit-cloud-crane',
    name: '云海鹤·凌霄',
    species: '云海灵鹤',
    affinity: '风',
    skill: '九霄云渡',
    description: '驾驭高空罡风，以连续折返改变战场距离。',
    specialColor: RingColor.cyan,
  ),
  SoulSpiritProfile(
    id: 'spirit-gold-scorpion',
    name: '金砂蝎·曜尾',
    species: '曜金砂蝎',
    affinity: '金属',
    skill: '曜尾破甲',
    description: '将金砂凝成毒针，擅长穿透防御与持续削弱。',
    specialColor: RingColor.gold,
  ),
  SoulSpiritProfile(
    id: 'spirit-mirror-jellyfish',
    name: '镜湖水母·澜镜',
    species: '镜湖灵水母',
    affinity: '精神',
    skill: '澜镜折魂',
    description: '用透明触须折射精神冲击并制造水镜幻象。',
    specialColor: RingColor.blueGold,
  ),
  SoulSpiritProfile(
    id: 'spirit-rock-rhino',
    name: '岩心巨犀·镇岳',
    species: '岩心巨犀',
    affinity: '土',
    skill: '地脉镇岳',
    description: '引动地脉形成移动堡垒，冲锋时势不可挡。',
  ),
  SoulSpiritProfile(
    id: 'spirit-thunder-falcon',
    name: '苍穹雷隼·惊空',
    species: '苍穹雷隼',
    affinity: '雷',
    skill: '惊空雷狩',
    description: '俯冲时聚集雷霆，适合高速追猎与空中压制。',
    specialColor: RingColor.crimsonGold,
  ),
  SoulSpiritProfile(
    id: 'spirit-glass-flower',
    name: '琉璃花仙·绮罗',
    species: '七彩琉璃花',
    affinity: '生命',
    skill: '绮罗万生',
    description: '花瓣记录多种元素，可治疗同伴并净化毒素。',
    specialColor: RingColor.rainbow,
  ),
  SoulSpiritProfile(
    id: 'spirit-moon-cat',
    name: '冥月猫·夜弦',
    species: '冥月灵猫',
    affinity: '暗',
    skill: '夜弦无声',
    description: '借月影隐藏气息，在敌人感知之外完成位移。',
    specialColor: RingColor.silverViolet,
  ),
  SoulSpiritProfile(
    id: 'spirit-crystal-ant',
    name: '赤晶蚁皇·绯铠',
    species: '赤晶蚁皇',
    affinity: '力量',
    skill: '绯晶神力',
    description: '以微小体型承载惊人力量，并凝聚赤晶护甲。',
    specialColor: RingColor.redBrown,
  ),
  SoulSpiritProfile(
    id: 'spirit-forest-deer',
    name: '森罗鹿王·青宸',
    species: '森罗鹿王',
    affinity: '植物',
    skill: '森罗天幕',
    description: '号令林木形成守护领域，持续恢复范围内生命。',
    specialColor: RingColor.greenGold,
  ),
  SoulSpiritProfile(
    id: 'spirit-rainbow-mantis',
    name: '虹光螳螂·七斩',
    species: '虹光螳螂',
    affinity: '光',
    skill: '七色瞬斩',
    description: '七次变向斩击分别携带不同元素余波。',
    specialColor: RingColor.rainbow,
  ),
  SoulSpiritProfile(
    id: 'spirit-frost-maiden',
    name: '霜语雪女·凛音',
    species: '极北霜灵',
    affinity: '冰',
    skill: '凛冬静界',
    description: '令范围内热量与声音一同冻结，强化控制能力。',
    specialColor: RingColor.moonWhite,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-alchemy-fox',
    name: '炼金机械狐·铜铃',
    species: '人造炼金魂灵',
    affinity: '魂导',
    skill: '百材解析',
    description: '辨识稀有金属并在战斗中快速修补魂导器。',
    specialColor: RingColor.roseGold,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-photon-swarm',
    name: '光子蜂群·曜群',
    species: '人造蜂群魂灵',
    affinity: '光',
    skill: '千点照射',
    description: '由微型魂导单元组成，可分散侦察或汇聚光束。',
    specialColor: RingColor.white,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-tower',
    name: '守望塔灵·阿零',
    species: '人造防御魂灵',
    affinity: '防御',
    skill: '全域壁垒',
    description: '持续计算攻击轨迹，为队伍展开多层防御阵列。',
    specialColor: RingColor.cyan,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-scout',
    name: '深空侦察灵·天眼',
    species: '人造侦察魂灵',
    affinity: '精神',
    skill: '星域全景',
    description: '共享广域侦测结果，预警伏击并锁定高速目标。',
    specialColor: RingColor.blueGold,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-armor-heart',
    name: '斗铠共生灵·铠心',
    species: '人造斗铠魂灵',
    affinity: '金属',
    skill: '灵铠再生',
    description: '与斗铠共同成长，使破损部位在战斗间隙自我修复。',
    specialColor: RingColor.silverViolet,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-shipmind',
    name: '舰载战术灵·星舵',
    species: '人造舰载魂灵',
    affinity: '空间',
    skill: '折跃航线',
    description: '计算安全折跃路径，并协调舰队火力窗口。',
    specialColor: RingColor.crimsonGold,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-medical',
    name: '生命维持灵·白露',
    species: '人造医疗魂灵',
    affinity: '生命',
    skill: '白露复苏',
    description: '监测生命体征，在重伤时稳定经脉与精神之海。',
    specialColor: RingColor.moonWhite,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-gravity',
    name: '重力环灵·坠星',
    species: '人造引力魂灵',
    affinity: '空间',
    skill: '坠星力场',
    description: '改变局部重力方向，可压制敌人或辅助高速转向。',
    specialColor: RingColor.gold,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-forge',
    name: '锻造炉灵·玄锤',
    species: '人造锻造魂灵',
    affinity: '火',
    skill: '灵锻共鸣',
    description: '稳定锻造火候与金属频率，提高斗铠制作成功率。',
    specialColor: RingColor.redBrown,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-data',
    name: '万卷数据灵·墨简',
    species: '人造知识魂灵',
    affinity: '精神',
    skill: '万卷推演',
    description: '记录战斗样本并推演对手下一步行动。',
    specialColor: RingColor.green,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-dragon-core',
    name: '龙源核心灵·烁金',
    species: '人造龙源魂灵',
    affinity: '力量',
    skill: '龙源脉冲',
    description: '将龙源能量转化为稳定爆发，适配机甲与星际战机。',
    specialColor: RingColor.roseGold,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-tide-engine',
    name: '潮汐引擎灵·蓝汐',
    species: '人造海战魂灵',
    affinity: '水',
    skill: '蓝汐推进',
    description: '控制水流和推进器，在海域与太空中保持机动。',
    specialColor: RingColor.blueGold,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-chronometer',
    name: '时序校准灵·刻秒',
    species: '人造时序魂灵',
    affinity: '时间',
    skill: '战术校时',
    description: '同步队友行动节拍，让组合魂技更容易同时命中。',
    specialColor: RingColor.silverViolet,
    naturalOrigin: false,
  ),
  SoulSpiritProfile(
    id: 'spirit-artificial-void-shield',
    name: '虚空护盾灵·界壳',
    species: '人造空间魂灵',
    affinity: '防御',
    skill: '界壳偏转',
    description: '以微型空间褶皱偏转攻击，保护魂师和载具。',
    specialColor: RingColor.rainbow,
    naturalOrigin: false,
  ),
];

bool soulSpiritSystemAvailable(Character character) =>
    switch (character.eraId) {
      'era-peerless' => character.tags.contains('魂灵体系解锁'),
      'era-legend' || 'era-ultimate' => true,
      _ => false,
    };

const List<WheelOption> soulSpiritMethodOptions = <WheelOption>[
  WheelOption(id: 'ring-spirit-contract', text: '与真实魂兽缔结魂灵', weight: 12),
  WheelOption(id: 'ring-spirit-artificial', text: '购买人造魂灵', weight: 10),
  WheelOption(id: 'ring-spirit-platform', text: '传灵平台匹配魂灵', weight: 9),
  WheelOption(id: 'ring-spirit-inherit', text: '继承前辈契约魂灵', weight: 4),
];

WheelPool soulSpiritCandidatePool(GameState state) {
  final methodId = state.pendingSoulSpiritMethodId;
  var profiles = soulSpiritProfiles.where((profile) {
    if (methodId == 'ring-spirit-artificial' ||
        methodId == 'ring-spirit-platform') {
      return !profile.naturalOrigin;
    }
    return profile.naturalOrigin;
  }).toList();
  if (profiles.length < 15) {
    profiles = List<SoulSpiritProfile>.from(soulSpiritProfiles);
  }
  final random = SeededRandom.fromSeed(
    '${state.seed}|soul-spirit|$methodId|${state.randomState}',
  );
  final selected = List<SoulSpiritProfile>.from(profiles);
  for (var index = selected.length - 1; index > 0; index--) {
    final swap = random.nextInt(index + 1);
    final value = selected[index];
    selected[index] = selected[swap];
    selected[swap] = value;
  }
  return WheelPool(
    id: 'soulSpiritCandidate',
    title: '候选魂灵',
    options: selected
        .take(15)
        .map(
          (profile) => WheelOption(
            id: profile.id,
            text: '${profile.name}·${profile.affinity}系',
            weight: _profileWeight(profile, state),
          ),
        )
        .toList(growable: false),
  );
}

double _profileWeight(SoulSpiritProfile profile, GameState state) {
  var weight = profile.specialColor == null ? 9.0 : 5.0;
  final soul = state.character.martialSoul ?? '';
  if (soul.contains(profile.affinity) || soul.contains(profile.species)) {
    weight *= 1.8;
  }
  if (state.invitationMode) weight *= profile.specialColor == null ? 1.3 : 2.2;
  return weight;
}

SoulSpiritProfile soulSpiritProfile(String id) =>
    soulSpiritProfiles.firstWhere((profile) => profile.id == id);

({SoulSpirit spirit, SoulRing ring}) createSoulSpiritContract({
  required String profileId,
  required int ringNumber,
  required String methodId,
  required Character character,
  required bool invitationMode,
  required SeededRandom random,
}) {
  final profile = soulSpiritProfile(profileId);
  final spiritSafetyUpper = ringSafetyUpperFor(
    character,
    ringNumber,
    '魂灵契约',
    invitationMode: invitationMode,
  );
  final spiritYearFactor = .9 + random.nextInt(21) / 100;
  final spiritYears = (spiritSafetyUpper * 1.5 * spiritYearFactor)
      .round()
      .clamp(10, 10000000);
  final ringRange = ringYearRangeFor(
    character,
    ringNumber,
    '魂灵契约',
    invitationMode: invitationMode,
  );
  final ringSafety = ringSafetyUpperFor(
    character,
    ringNumber,
    '魂灵契约',
    invitationMode: invitationMode,
  );
  final ringMaximum = math.min(ringRange.upper, ringSafety);
  final ringMinimum = math.min(ringRange.lower, ringMaximum);
  final ringYears = ringMinimum + random.nextInt(ringMaximum - ringMinimum + 1);
  final grants = spiritYears >= 100000
      ? 3
      : spiritYears >= 10000
      ? 2
      : spiritYears >= 1000
      ? 1
      : 0;
  final natural = profile.naturalOrigin && methodId == 'ring-spirit-contract';
  final spirit = SoulSpirit(
    id: '${profile.id}-${random.nextInt(1 << 30)}',
    name: profile.name,
    species: profile.species,
    years: spiritYears,
    quality: soulSpiritQualityFor(
      spiritYears,
      specialColor: profile.specialColor,
    ),
    bond: methodId == 'ring-spirit-inherit'
        ? 70
        : natural
        ? 58
        : 42,
    remainingRingGrants: grants,
    skillName: profile.skill,
    description: profile.description,
    naturalOrigin: natural,
  );
  return (spirit: spirit, ring: soulSpiritRing(spirit, profile, ringYears));
}

SoulRing soulSpiritRing(
  SoulSpirit spirit,
  SoulSpiritProfile profile,
  int years,
) => SoulRing(
  color: profile.specialColor ?? _ordinaryColor(years),
  years: years,
  source: '魂灵·${spirit.name}',
  skillName: spirit.skillName,
  description:
      '${spirit.name}以${spirit.quality}本体通过契约赋予的'
      '${soulSpiritQualityFor(years, specialColor: profile.specialColor)}魂环，'
      '可随双方羁绊共同成长。',
);

SoulRing grantedSoulSpiritRing(
  SoulSpirit spirit,
  Character character,
  int ringNumber,
  SeededRandom random, {
  bool invitationMode = false,
}) {
  final profile = soulSpiritProfiles.firstWhere(
    (item) => spirit.name.startsWith(item.name.split('·').first),
    orElse: () => soulSpiritProfiles.first,
  );
  final range = ringYearRangeFor(
    character,
    ringNumber,
    '魂灵赐环',
    invitationMode: invitationMode,
  );
  final safety = ringSafetyUpperFor(
    character,
    ringNumber,
    '魂灵赐环',
    invitationMode: invitationMode,
  );
  final maximum = math.max(
    10,
    math.min(math.min(range.upper, safety), spirit.years),
  );
  final minimum = math.min(range.lower, maximum);
  final years = minimum + random.nextInt(maximum - minimum + 1);
  return soulSpiritRing(spirit, profile, years);
}

WheelPool soulSpiritOutcomePool(SoulSpirit spirit, [Character? character]) {
  final affinity = character == null
      ? 50
      : soulSpiritGrowthProfile(spirit, character).affinity;
  final benefit = .65 + affinity / 100;
  final backlash = (1.35 - affinity / 120).clamp(.35, 1.2);
  return WheelPool(
    id: 'soulSpiritOutcome',
    title: '魂灵契约结果',
    options: <WheelOption>[
      WheelOption(
        id: 'spirit-perfect',
        text: '灵魂共鸣·完美契约',
        weight: 24 * benefit,
      ),
      WheelOption(id: 'spirit-steady', text: '心意相通·稳定契约', weight: 48 * benefit),
      const WheelOption(id: 'spirit-trial', text: '磨合考验·契约成立', weight: 20),
      WheelOption(
        id: 'spirit-backlash',
        text: '契约反噬·带伤成功',
        weight: (spirit.naturalOrigin ? 8 : 3) * backlash,
      ),
    ],
  );
}

WheelPool soulSpiritGrantPool(Character character) => WheelPool(
  id: 'soulSpiritGrant',
  title: '魂灵赐予魂环',
  options: character.soulSpirits
      .where((spirit) => spirit.remainingRingGrants > 0)
      .take(15)
      .map(
        (spirit) => WheelOption(
          id: spirit.id,
          text: '${spirit.name}·剩余${spirit.remainingRingGrants}次',
          weight: spirit.bond.clamp(10, 100).toDouble(),
        ),
      )
      .toList(growable: false),
);

String soulSpiritQualityFor(int years, {RingColor? specialColor}) {
  final ordinary = years >= 1000000
      ? '金色百万年'
      : years >= 500000
      ? '凶兽级五十万年'
      : years >= 200000
      ? '凶兽级二十万年'
      : years >= 100000
      ? '红色十万年'
      : years >= 10000
      ? '黑色万年'
      : years >= 1000
      ? '紫色千年'
      : years >= 100
      ? '黄色百年'
      : '白色十年';
  return specialColor == null
      ? ordinary
      : '${ringColorName(specialColor)}色特殊本源·$ordinary';
}

List<String> growSoulSpiritsForYears(Character character, int elapsedYears) {
  if (elapsedYears <= 0 || character.soulSpirits.isEmpty) {
    return const <String>[];
  }
  final effects = <String>[];
  for (var index = 0; index < character.soulSpirits.length; index++) {
    final spirit = character.soulSpirits[index];
    final profile = soulSpiritProfiles
        .where((item) => spirit.name.startsWith(item.name.split('·').first))
        .firstOrNull;
    final yearlyRate =
        .004 +
        spirit.bond / 20000 +
        (character.soulEngineerLevel >= 5 ? .0015 : 0);
    final growth = (spirit.years * yearlyRate * elapsedYears).round().clamp(
      1,
      1000000,
    );
    final nextYears = (spirit.years + growth).clamp(10, 10000000);
    final nextQuality = soulSpiritQualityFor(
      nextYears,
      specialColor: profile?.specialColor,
    );
    character.soulSpirits[index] = spirit.copyWith(
      years: nextYears,
      quality: nextQuality,
    );
    effects.add('魂灵成长：${spirit.name} ${spirit.years}年 → $nextYears年');
  }
  return effects;
}

RingColor _ordinaryColor(int years) => years >= 100000
    ? RingColor.red
    : years >= 10000
    ? RingColor.black
    : years >= 1000
    ? RingColor.purple
    : years >= 100
    ? RingColor.yellow
    : RingColor.white;
