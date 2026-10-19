import 'dart:math' as math;

import '../domain/models.dart';

String technologyAssetStatus(TechnologyAsset asset) {
  if (asset.memorial) return '纪念收藏';
  if (asset.integrity <= 0) return '待报废';
  if (asset.equipped) return '已装备';
  return '库存';
}

TechnologyAsset? technologyAssetNeedingDisposal(Character character) =>
    character.technologyAssets
        .where(
          (asset) => asset.equipped && !asset.memorial && asset.integrity <= 0,
        )
        .firstOrNull;

int technologyAssetQualityScore(TechnologyAsset asset) {
  final rank = switch (asset.type) {
    TechnologyType.warship => 70,
    TechnologyType.starfighter => 55,
    TechnologyType.battleArmor => 50,
    TechnologyType.mecha => 45,
    TechnologyType.soulDevice => 30,
  };
  final namedRank = RegExp(r'\d+').firstMatch(asset.rank)?.group(0);
  final rankValue =
      int.tryParse(namedRank ?? '') ??
      (asset.rank.contains('九级') || asset.rank.contains('旗舰') ? 9 : 3);
  return (rank +
          rankValue * 12 +
          asset.upgradeLevel * 25 +
          math.sqrt(asset.integrity.clamp(0, 100)) * 3)
      .round();
}

List<WheelOption> technologyDisposalOptions(TechnologyAsset asset) =>
    const <WheelOption>[
      WheelOption(id: 'tech-dispose-recycle', text: '回收材料', weight: 42),
      WheelOption(id: 'tech-dispose-research', text: '拆解研究', weight: 36),
      WheelOption(id: 'tech-dispose-memorial', text: '保留纪念', weight: 22),
    ];

TechnologyAsset upgradedTechnologyAsset(TechnologyAsset asset) =>
    asset.copyWith(
      upgradeLevel: (asset.upgradeLevel + 1).clamp(0, 9),
      integrity: (asset.integrity + 12).clamp(0, 100),
    );
