import 'package:flutter/material.dart';

import '../../data/era_data.dart';
import '../../domain/models.dart';
import '../../engine/soul_beast_archetype.dart';
import '../../engine/life_identity_engine.dart';
import '../../engine/soul_bone_quality.dart';
import '../../engine/soul_spirit_growth.dart';
import '../../engine/technology_asset_engine.dart';
import 'ring_detail_sheet.dart';

class CharacterSummary extends StatelessWidget {
  const CharacterSummary({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final identity = <(String, String)>[
      if (character.characterName != null) ('姓名', character.characterName!),
      if (character.era != null) ('时代', character.era!),
      if (character.timeline != null) ('时间线', character.timeline!),
      if (character.gender != null) ('性别', character.gender!),
      if (character.race != null) ('种族', character.race!),
    ];
    final gifts = <(String, String)>[
      if (character.appearance != null) ('容貌', character.appearance!),
      if (character.personality != null) ('性格', character.personality!),
      if (character.family != null) ('家庭 / 血脉', character.family!),
      if (character.constitution != null) ('体质', character.constitution!),
      if (character.spirit != null) ('精神', character.spirit!),
      if (character.talent != null) ('武魂天赋', character.talent!),
    ];
    final causes = <(String, String)>[
      if (character.eraId != null)
        ('主角锚点', profileForEraId(character.eraId).protagonist),
      if (character.eraId != null)
        ('相对年份', relativeYearLabel(character.protagonistOffset)),
      if (character.faction != null) ('势力', character.faction!),
      if (character.mentor != null) ('导师', character.mentor!),
      if (character.aspiration != null) ('人生志向', character.aspiration!),
      if (displayLifeTitles(character).isNotEmpty)
        ('称号', displayLifeTitles(character).join('、')),
      if (displayLifeMarks(character).isNotEmpty)
        ('人生印记', displayLifeMarks(character).join('、')),
    ];
    final growth = <(String, String)>[
      if (character.age > 0) ('年龄', '${character.age} 岁'),
      if (character.route == RouteType.soulBeast &&
          character.martialSoul != null)
        ('本体', character.martialSoul!),
      if (character.route == RouteType.soulBeast && character.beastYears > 0)
        ('修为', '${character.beastYears} 年'),
      if (character.route == RouteType.soulBeast) ('命途', character.beastPath),
      if (character.route == RouteType.soulBeast)
        ('种族', character.beastArchetype),
      if (character.route == RouteType.soulBeast)
        (
          '天赋',
          soulBeastTalentDescription(
            SoulBeastArchetype.values.firstWhere(
              (item) =>
                  soulBeastArchetypeName(item) == character.beastArchetype,
              orElse: () => SoulBeastArchetype.land,
            ),
          ),
        ),
      if (character.route == RouteType.soulBeast)
        ('血脉', '${character.beastBloodlinePower}'),
      if (character.route == RouteType.soulBeast)
        ('灵智', '${character.beastIntelligence}'),
      if (character.route == RouteType.soulBeast)
        ('领地', '${character.beastTerritory}'),
      if (character.route == RouteType.soulBeast)
        ('族群声望', '${character.beastPrestige}'),
      if (character.route == RouteType.soulBeast)
        ('人类威胁', '${character.humanThreat}'),
      if (character.route == RouteType.soulBeast)
        ('羁绊', '${character.beastBond}'),
      if (character.route == RouteType.soulBeast)
        ('族群', '${character.beastClanPopulation}'),
      if (character.route == RouteType.soulBeast)
        ('资源', '${character.beastResources}'),
      if (character.route == RouteType.soulBeast)
        ('敌对压力', '${character.beastEnemyPressure}'),
      if (character.route == RouteType.soulBeast)
        ('栖息地', character.beastHabitat),
      if (character.route != RouteType.soulBeast &&
          character.innatePower != null)
        ('先天魂力', '${character.innatePower} 级'),
      if (character.route != RouteType.soulBeast && character.soulPower > 0)
        ('当前魂力', '${character.soulPower} 级'),
      if (character.route != RouteType.soulBeast &&
          character.ringCapacityBonus > 0)
        ('魂环承受力', '+${character.ringCapacityBonus}%'),
      if (character.soulBones.isNotEmpty)
        ('魂骨', '${character.soulBones.length} 块'),
      if (character.soulSpirits.isNotEmpty)
        ('魂灵', '${character.soulSpirits.length} 位'),
      if (character.soulEngineerLevel > 0)
        ('魂导师', '${character.soulEngineerLevel} 级'),
      if (character.battleArmorStage != null)
        ('斗铠', character.battleArmorStage!),
      if (character.mechaRank != null) ('机甲', character.mechaRank!),
      if (character.starCommandLevel > 0)
        ('星战指挥', '${character.starCommandLevel} 级'),
      if (character.technologyAssets.isNotEmpty)
        ('科技资产', '${character.technologyAssets.length} 件'),
      if (character.godhood != null) ('神位', character.godhood!),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xdd102346),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x5574d7ff)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '已获得信息',
                style: TextStyle(
                  color: Color(0xfff7d77f),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '点击属性查看完整档案',
                style: TextStyle(color: Color(0xff9babca), fontSize: 11),
              ),
            ],
          ),
          if (identity.isNotEmpty)
            _SummaryGroup(title: '基本身份', entries: identity),
          if (gifts.isNotEmpty) _SummaryGroup(title: '先天禀赋', entries: gifts),
          if (causes.isNotEmpty) _SummaryGroup(title: '因果路径', entries: causes),
          if (growth.isNotEmpty ||
              character.martialSoul != null ||
              character.soulRings.isNotEmpty ||
              character.secondarySoulRings.isNotEmpty)
            _GrowthGroup(entries: growth, character: character),
        ],
      ),
    );
  }
}

class _SummaryGroup extends StatelessWidget {
  const _SummaryGroup({required this.title, required this.entries});

  final String title;
  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Color(0xff74d7ff),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 5,
          children: entries
              .map(
                (entry) => Text(
                  '${entry.$1}：${entry.$2}',
                  style: const TextStyle(
                    color: Color(0xffeaf1ff),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    ),
  );
}

class _GrowthGroup extends StatelessWidget {
  const _GrowthGroup({required this.entries, required this.character});

  final List<(String, String)> entries;
  final Character character;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '觉醒与成长',
          style: TextStyle(
            color: Color(0xff74d7ff),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 12,
          runSpacing: 5,
          children: entries
              .map((entry) => _growthEntry(context, entry))
              .toList(growable: false),
        ),
        if (character.route != RouteType.soulBeast &&
            (character.martialSoul != null ||
                character.soulRings.isNotEmpty)) ...<Widget>[
          const SizedBox(height: 8),
          _MartialSoulRings(
            label: character.hasTwinMartialSouls ? '第一武魂' : '武魂',
            name: character.martialSoul ?? '尚未记录',
            rings: character.soulRings,
            slotId: 'primary',
          ),
          if (character.secondaryMartialSoul != null) ...<Widget>[
            const SizedBox(height: 7),
            _MartialSoulRings(
              label: '第二武魂',
              name: character.secondaryMartialSoul!,
              rings: character.secondarySoulRings,
              slotId: 'secondary',
            ),
          ],
        ],
      ],
    ),
  );

  Widget _growthEntry(BuildContext context, (String, String) entry) {
    final key = switch (entry.$1) {
      '魂骨' => 'soul-bones',
      '魂灵' => 'soul-spirits',
      '魂导师' || '斗铠' || '机甲' || '星战指挥' || '科技资产' => 'technology',
      '神位' => 'godhood',
      _ => null,
    };
    final text = Text(
      '${entry.$1}：${entry.$2}',
      style: TextStyle(
        color: key == null ? const Color(0xffeaf1ff) : const Color(0xfff7d77f),
        fontSize: 12,
        decoration: null,
      ),
    );
    if (key == null) return text;
    return Semantics(
      button: true,
      label: '查看${entry.$1}详情',
      child: InkWell(
        key: Key('growth-detail-$key'),
        onTap: () => _showGrowthDetail(context, key),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: text,
        ),
      ),
    );
  }

  Future<void> _showGrowthDetail(BuildContext context, String key) =>
      switch (key) {
        'soul-bones' => _showSoulBones(context),
        'soul-spirits' => _showSoulSpirits(context),
        'technology' => _showTechnology(context),
        'godhood' => _showGodhood(context),
        _ => Future<void>.value(),
      };

  Future<void> _showSoulBones(BuildContext context) {
    final sections = <Widget>[];
    if (character.soulBones.isNotEmpty) {
      sections.add(const _DetailHeading('已装备魂骨'));
      sections.addAll(character.soulBones.map(_soulBoneCard));
    }
    if (character.spareSoulBones.isNotEmpty) {
      sections.add(const _DetailHeading('备用魂骨'));
      sections.addAll(character.spareSoulBones.map(_spareSoulBoneCard));
    }
    return _showArchiveDialog(context, '魂骨档案', sections);
  }

  Widget _soulBoneCard(SoulBone bone) {
    final originColor = bone.originColor == null
        ? '普通魂骨'
        : '${ringColorLabel(bone.originColor!)}特殊本源';
    return _DetailCard(
      title: bone.name,
      lines: <String>[
        '部位：${soulBoneSlotName(bone.slot)}',
        '年限：${bone.years} 年　品质评分：${soulBoneQualityScore(bone, character)}',
        '来源：${bone.source}　本源：$originColor',
        '完整度：${bone.integrity}%　成长性：${bone.evolvable ? '可进化' : '已定型'}',
        if (bone.setName != null) '套装：${bone.setName}',
        '魂骨技：${bone.skillName}',
        bone.description,
      ],
    );
  }

  Widget _spareSoulBoneCard(SoulBone bone) {
    final report = analyzeSoulBoneReplacement(character, bone);
    final delta = report.scoreDelta;
    final replacement = report.existing == null
        ? '当前部位为空，装备后强度 +${report.incomingScore}'
        : '对比${report.existing!.name}：替换后强度 ${delta >= 0 ? '+' : ''}$delta'
              '（${report.currentScore} → ${report.incomingScore}）';
    return _DetailCard(
      title: bone.name,
      lines: <String>[
        '部位：${soulBoneSlotName(bone.slot)}　年限：${bone.years} 年',
        '来源：${bone.source}　魂骨技：${bone.skillName}',
        replacement,
        if (report.lostSkill != null) '失去魂骨技：${report.lostSkill}',
        '获得魂骨技：${report.gainedSkill}',
        '完整度变化：${report.integrityDelta >= 0 ? '+' : ''}${report.integrityDelta}%',
        if (report.lostSetBonuses.isNotEmpty)
          '失去套装：${report.lostSetBonuses.join('、')}',
        if (report.lostSetBonuses.isEmpty) '套装影响：不会失去已激活套装',
        bone.description,
      ],
    );
  }

  Future<void> _showSoulSpirits(BuildContext context) {
    final sections = <Widget>[
      ...character.soulSpirits.map((spirit) {
        final profile = soulSpiritGrowthProfile(spirit, character);
        return _DetailCard(
          title: spirit.name,
          lines: <String>[
            '种族：${spirit.species}　年限：${spirit.years} 年',
            '品质：${spirit.quality}　来源：${spirit.naturalOrigin ? '自然契约' : '人工魂灵'}',
            '成长阶段：${profile.growthStage}　武魂契合：${profile.affinity}',
            '羁绊：${spirit.bond}　剩余赐环：${spirit.remainingRingGrants} 次',
            '进化路线：${profile.evolutionRoutes.join('、')}',
            '魂灵技：${spirit.skillName}',
            ...profile.reasons.map((reason) => '进化影响：$reason'),
            spirit.description,
          ],
        );
      }),
      const _DetailNote(
        '魂灵契约与魂灵赐环不会触发魂骨凝聚；'
        '魂骨来自真实猎魂或独立剧情。羁绊、武魂属性、'
        '时代科技和相关事件共同影响魂灵进化。',
      ),
    ];
    return _showArchiveDialog(context, '魂灵档案', sections);
  }

  Future<void> _showTechnology(BuildContext context) {
    final overview = <String>[
      if (character.soulEngineerLevel > 0)
        '魂导师：${character.soulEngineerLevel} 级',
      if (character.battleArmorStage != null)
        '斗铠：${character.battleArmorStage}',
      if (character.mechaRank != null) '机甲：${character.mechaRank}',
      if (character.starCommandLevel > 0)
        '星战指挥：${character.starCommandLevel} 级',
    ];
    final sections = <Widget>[
      if (overview.isNotEmpty) _DetailCard(title: '科技成长', lines: overview),
      if (character.technologyAssets.isNotEmpty) const _DetailHeading('已获得资产'),
      ...character.technologyAssets.map(
        (asset) => _DetailCard(
          title: asset.name,
          lines: <String>[
            '类型：${technologyTypeName(asset.type)}　等阶：${asset.rank}',
            '状态：${technologyAssetStatus(asset)}　升级：+${asset.upgradeLevel}',
            '完整度：${asset.integrity}%　品质：${technologyAssetQualityScore(asset)}',
            if (!asset.memorial && asset.integrity < 60) '维护：建议维修，低完整度会降低实战贡献',
            if (!asset.memorial && asset.integrity >= 60) '维护：状态稳定，可通过剧情继续升级',
            '报废时可选：回收材料、拆解研究、保留纪念',
            '来源：${asset.source}',
            asset.description,
          ],
        ),
      ),
    ];
    return _showArchiveDialog(context, '魂导科技档案', sections);
  }

  Future<void> _showGodhood(BuildContext context) =>
      _showArchiveDialog(context, '神位档案', <Widget>[
        _DetailCard(
          title: character.godhood ?? '尚未凝聚神位',
          lines: <String>[
            '神性评分：${character.divinityScore}',
            '该神位由武魂、魂环、魂骨、战绩与人生选择共同凝聚。',
          ],
        ),
      ]);

  Future<void> _showArchiveDialog(
    BuildContext context,
    String title,
    List<Widget> children,
  ) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}

class _DetailHeading extends StatelessWidget {
  const _DetailHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xff74d7ff),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        ...lines
            .where((line) => line.isNotEmpty)
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(line),
              ),
            ),
      ],
    ),
  );
}

class _DetailNote extends StatelessWidget {
  const _DetailNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0x221d9bd1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text, style: const TextStyle(height: 1.45)),
  );
}

class _MartialSoulRings extends StatelessWidget {
  const _MartialSoulRings({
    required this.label,
    required this.name,
    required this.rings,
    required this.slotId,
  });

  final String label;
  final String name;
  final List<SoulRing> rings;
  final String slotId;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final nameWidth = (constraints.maxWidth * .3).clamp(68.0, 108.0);
      final ringWidth = (constraints.maxWidth - nameWidth - 6).clamp(
        126.0,
        double.infinity,
      );
      final slotWidth = (ringWidth / 9).clamp(14.0, 24.0);
      final badgeSize = (slotWidth - 2).clamp(13.0, 20.0);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: nameWidth,
            child: InkWell(
              key: Key('martial-soul-name-$slotId'),
              onTap: () => _showFullName(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  '$label：$name',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xffeaf1ff),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(9, (index) {
                  final ring = index < rings.length ? rings[index] : null;
                  if (ring == null) {
                    return SizedBox(
                      key: Key('ring-$slotId-empty-$index'),
                      width: slotWidth,
                      height: 32,
                      child: Center(
                        child: Container(
                          width: badgeSize,
                          height: badgeSize,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x669babca)),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: const Color(0x999babca),
                              fontSize: badgeSize * .42,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Semantics(
                    key: Key('ring-$slotId-$index'),
                    button: true,
                    label: '${ringColorLabel(ring.color)}魂环',
                    child: ExcludeSemantics(
                      child: SizedBox(
                        width: slotWidth,
                        height: 32,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              showRingDetailSheet(context, <SoulRing>[ring]),
                          child: Center(
                            child: RingColorBadge(
                              color: ring.color,
                              size: badgeSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      );
    },
  );

  Future<void> _showFullName(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(label),
      content: Text(name),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}
