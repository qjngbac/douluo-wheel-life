import '../domain/models.dart';
import 'seeded_random.dart';
import 'soul_bone_quality.dart';

const Set<RingColor> _ordinaryRingColors = <RingColor>{
  RingColor.yellow,
  RingColor.purple,
  RingColor.black,
};

const List<SoulBoneSlot> _regularSlots = <SoulBoneSlot>[
  SoulBoneSlot.head,
  SoulBoneSlot.torso,
  SoulBoneSlot.leftArm,
  SoulBoneSlot.rightArm,
  SoulBoneSlot.leftLeg,
  SoulBoneSlot.rightLeg,
];

double soulBoneDropChance(SoulRing ring) {
  final base = switch (ring.years) {
    >= 100000 => 1.0,
    >= 10000 => .50,
    >= 1000 => .20,
    _ => .05,
  };
  if (_ordinaryRingColors.contains(ring.color)) return base;
  return (base * 1.5).clamp(0, 1);
}

bool soulBoneEligibleForMethod(String? methodId) => !<String>{
  'ring-spirit-artificial',
  'ring-spirit-platform',
  'ring-spirit-inherit',
  'ring-spirit-grant',
}.contains(methodId);

WheelPool soulBoneDropPool(SoulRing ring, {required bool eligible}) {
  if (!eligible) {
    return const WheelPool(
      id: 'soulBoneDrop',
      title: '魂骨凝聚判定',
      options: <WheelOption>[
        WheelOption(id: 'bone-drop-none', text: '非真实魂兽遗骨', weight: 1),
      ],
    );
  }
  final chance = soulBoneDropChance(ring);
  return WheelPool(
    id: 'soulBoneDrop',
    title: '魂骨凝聚判定',
    options: <WheelOption>[
      WheelOption(
        id: 'bone-drop-found',
        text: chance >= 1 ? '必定凝聚魂骨' : '凝聚魂骨',
        weight: chance * 100,
      ),
      if (chance < 1)
        WheelOption(
          id: 'bone-drop-none',
          text: '未形成魂骨',
          weight: (1 - chance) * 100,
        ),
    ],
  );
}

WheelPool soulBoneSlotPool(Character character, SoulRing ring) {
  final occupied = character.soulBones
      .where((bone) => bone.slot != SoulBoneSlot.external)
      .map((bone) => bone.slot)
      .toSet();
  final missing = _regularSlots
      .where((slot) => !occupied.contains(slot))
      .toList(growable: false);
  final candidates = ring.years >= 100000 && missing.isNotEmpty
      ? missing
      : _regularSlots;
  final regularWeight = 95 / candidates.length;
  return WheelPool(
    id: 'soulBoneSlot',
    title: '魂骨部位',
    options: <WheelOption>[
      for (final slot in candidates)
        WheelOption(
          id: 'bone-slot-${slot.name}',
          text: soulBoneSlotName(slot),
          weight: regularWeight,
        ),
      const WheelOption(id: 'bone-slot-external', text: '外附魂骨', weight: 5),
    ],
  );
}

SoulBoneSlot soulBoneSlotForOption(String optionId) =>
    SoulBoneSlot.values
        .where((slot) => optionId == 'bone-slot-${slot.name}')
        .firstOrNull ??
    SoulBoneSlot.external;

WheelPool soulBoneOutcomePool(Character character, SoulBone bone) {
  final existing = bone.slot == SoulBoneSlot.external
      ? null
      : character.soulBones.where((item) => item.slot == bone.slot).firstOrNull;
  final duplicate = existing != null;
  if (duplicate) {
    final comparison = compareSoulBones(existing, bone, character);
    final options = switch (comparison) {
      SoulBoneComparison.stronger => const <WheelOption>[
        WheelOption(id: 'bone-replace', text: '高阶魂骨覆盖进化', weight: 40),
        WheelOption(id: 'bone-fuse', text: '同源融合共同进化', weight: 32),
        WheelOption(id: 'bone-store', text: '封存备用魂骨', weight: 15),
        WheelOption(id: 'bone-salvage', text: '回收魂骨精华', weight: 8),
        WheelOption(id: 'bone-give-up', text: '放弃这块魂骨', weight: 5),
      ],
      SoulBoneComparison.comparable => const <WheelOption>[
        WheelOption(id: 'bone-fuse', text: '同阶魂骨融合进化', weight: 40),
        WheelOption(id: 'bone-replace', text: '谨慎替换原有魂骨', weight: 24),
        WheelOption(id: 'bone-store', text: '封存备用魂骨', weight: 20),
        WheelOption(id: 'bone-salvage', text: '回收魂骨精华', weight: 8),
        WheelOption(id: 'bone-give-up', text: '保留旧魂骨', weight: 8),
      ],
      SoulBoneComparison.weaker => const <WheelOption>[
        WheelOption(id: 'bone-fuse', text: '提炼精华融入旧骨', weight: 25),
        WheelOption(id: 'bone-store', text: '封存备用魂骨', weight: 32),
        WheelOption(id: 'bone-salvage', text: '回收魂骨精华', weight: 25),
        WheelOption(id: 'bone-give-up', text: '放弃低阶魂骨', weight: 18),
      ],
    };
    return WheelPool(
      id: 'soulBoneOutcome',
      title: '同部位魂骨品质抉择',
      options: options,
    );
  }
  return const WheelPool(
    id: 'soulBoneOutcome',
    title: '魂骨吸收结果',
    options: <WheelOption>[
      WheelOption(id: 'bone-perfect', text: '魂骨完美融合', weight: 18),
      WheelOption(id: 'bone-normal', text: '顺利吸收魂骨', weight: 57),
      WheelOption(id: 'bone-injury', text: '排斥后带伤融合', weight: 18),
      WheelOption(id: 'bone-fail', text: '魂骨吸收失败', weight: 7),
    ],
  );
}

SoulBone createSoulBone({
  required SoulRing ring,
  required SoulBoneSlot slot,
  required SeededRandom random,
}) {
  final names = _boneNames[slot]!;
  final skills = _boneSkills[slot]!;
  final name = '${ring.source}·${names[random.nextInt(names.length)]}';
  final skill = skills[random.nextInt(skills.length)];
  final set = soulBoneSetIdentity(ring.source);
  return SoulBone(
    id: 'bone-${slot.name}-${ring.years}-${random.nextInt(1 << 30)}',
    name: name,
    slot: slot,
    years: ring.years,
    source: ring.source,
    skillName: skill,
    description:
        '${soulBoneSlotName(slot)}承载了${ring.source}${ringColorName(ring.color)}色魂环对应的血脉特性，并赋予魂骨技“$skill”。',
    evolvable:
        slot == SoulBoneSlot.external ||
        ring.years >= 100000 ||
        !_ordinaryRingColors.contains(ring.color),
    originColor: ring.color,
    setId: set?.id,
    setName: set?.name,
  );
}

SoulBone fuseSoulBones(SoulBone previous, SoulBone incoming) => SoulBone(
  id: '${incoming.id}-fusion',
  name: '融魂·${incoming.name}',
  slot: incoming.slot,
  years: (previous.years + incoming.years * .35).round(),
  source: '${previous.source} / ${incoming.source}',
  skillName: '${previous.skillName}·${incoming.skillName}',
  description: '两块同部位魂骨在风险中完成同源融合。',
  evolvable: true,
  originColor: incoming.originColor ?? previous.originColor,
  integrity: ((previous.integrity + incoming.integrity) / 2 + 8).round().clamp(
    0,
    100,
  ),
  setId: incoming.setId ?? previous.setId,
  setName: incoming.setName ?? previous.setName,
);

const Map<SoulBoneSlot, List<String>> _boneNames = <SoulBoneSlot, List<String>>{
  SoulBoneSlot.head: <String>['洞天灵眸头骨', '凝神王冠头骨', '幻心明镜头骨', '万象感知头骨'],
  SoulBoneSlot.torso: <String>['山河镇魂躯干骨', '不灭玄甲躯干骨', '生命炉心躯干骨', '星渊吞纳躯干骨'],
  SoulBoneSlot.leftArm: <String>['破阵左臂骨', '寒渊左臂骨', '万藤左臂骨', '虚空擒龙左臂骨'],
  SoulBoneSlot.rightArm: <String>['裂天右臂骨', '炽阳右臂骨', '震岳右臂骨', '龙魂断海右臂骨'],
  SoulBoneSlot.leftLeg: <String>['踏风左腿骨', '幻影左腿骨', '地脉左腿骨', '雪踪无痕左腿骨'],
  SoulBoneSlot.rightLeg: <String>['逐雷右腿骨', '破空右腿骨', '潮汐右腿骨', '天鹏振翅右腿骨'],
  SoulBoneSlot.external: <String>[
    '八荒蛛矛外附骨',
    '星蜮光翼外附骨',
    '翡翠生命角外附骨',
    '虚空尾刃外附骨',
    '龙鳞神铠外附骨',
  ],
};

const Map<SoulBoneSlot, List<String>> _boneSkills =
    <SoulBoneSlot, List<String>>{
      SoulBoneSlot.head: <String>['精神震爆', '幻境破妄', '灵魂锁定', '未来一瞬'],
      SoulBoneSlot.torso: <String>['不灭魂甲', '伤势转移', '生命回流', '元素吞纳'],
      SoulBoneSlot.leftArm: <String>['寒渊之握', '万藤囚笼', '虚空擒拿', '左界封印'],
      SoulBoneSlot.rightArm: <String>['裂天龙爪', '炽阳破城', '震岳神拳', '断海一击'],
      SoulBoneSlot.leftLeg: <String>['幻影流光', '踏雪无痕', '地脉瞬步', '逆向闪烁'],
      SoulBoneSlot.rightLeg: <String>['逐雷之步', '破空飞踢', '潮汐跃迁', '天鹏振翅'],
      SoulBoneSlot.external: <String>['外骨进化', '八荒穿刺', '星翼遁空', '龙鳞覆体', '生命再生'],
    };
