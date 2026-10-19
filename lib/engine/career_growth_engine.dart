import '../domain/models.dart';

const _battleArmorStages = <String>['一字斗铠', '二字斗铠', '三字斗铠', '四字斗铠'];
const _mechaRanks = <String>['黄色机甲', '紫色机甲', '黑色机甲', '红级机甲', '星际机甲'];

bool hasCareerGrowth(Character character) =>
    (character.soulEngineerLevel > 0 && character.soulEngineerLevel < 10) ||
    (character.starCommandLevel > 0 && character.starCommandLevel < 10) ||
    _hasNext(_battleArmorStages, character.battleArmorStage) ||
    _hasNext(_mechaRanks, character.mechaRank);

WheelPool buildCareerGrowthPool(Character character) {
  final options = <WheelOption>[
    const WheelOption(id: 'career-stable', text: '本阶段专注于巩固基础', weight: 70),
    if (character.soulEngineerLevel > 0 &&
        character.soulEngineerLevel < 10) ...<WheelOption>[
      const WheelOption(
        id: 'career-engineer-plus-1',
        text: '魂导研究突破一级',
        weight: 18,
      ),
      const WheelOption(
        id: 'career-engineer-plus-2',
        text: '魂导灵感连续突破两级',
        weight: 4,
      ),
    ],
    if (character.starCommandLevel > 0 &&
        character.starCommandLevel < 10) ...<WheelOption>[
      const WheelOption(
        id: 'career-command-plus-1',
        text: '星战指挥提升一级',
        weight: 12,
      ),
      const WheelOption(
        id: 'career-command-plus-2',
        text: '星战推演连续突破两级',
        weight: 3,
      ),
    ],
    if (_hasNext(_battleArmorStages, character.battleArmorStage))
      const WheelOption(id: 'career-armor-plus-1', text: '斗铠完成一次进阶', weight: 6),
    if (_hasNext(_mechaRanks, character.mechaRank))
      const WheelOption(
        id: 'career-mecha-plus-1',
        text: '机甲操控与品阶同步提升',
        weight: 6,
      ),
  ];
  return WheelPool(id: 'careerGrowth', title: '职业成长判定', options: options);
}

List<String> applyCareerGrowth(Character character, WheelOption choice) {
  switch (choice.id) {
    case 'career-engineer-plus-1':
      return <String>[_raiseSoulEngineer(character, 1)];
    case 'career-engineer-plus-2':
      return <String>[_raiseSoulEngineer(character, 2)];
    case 'career-command-plus-1':
      return <String>[_raiseStarCommand(character, 1)];
    case 'career-command-plus-2':
      return <String>[_raiseStarCommand(character, 2)];
    case 'career-armor-plus-1':
      final before = character.battleArmorStage!;
      character.battleArmorStage = _next(_battleArmorStages, before);
      return <String>['斗铠阶段 $before → ${character.battleArmorStage}'];
    case 'career-mecha-plus-1':
      final before = character.mechaRank!;
      character.mechaRank = _next(_mechaRanks, before);
      return <String>['机甲品阶 $before → ${character.mechaRank}'];
    default:
      return const <String>['本阶段没有职业等级提升'];
  }
}

String _raiseSoulEngineer(Character character, int delta) {
  final before = character.soulEngineerLevel;
  character.soulEngineerLevel = (before + delta).clamp(0, 10);
  return '魂导师等级 $before → ${character.soulEngineerLevel}';
}

String _raiseStarCommand(Character character, int delta) {
  final before = character.starCommandLevel;
  character.starCommandLevel = (before + delta).clamp(0, 10);
  return '星战指挥等级 $before → ${character.starCommandLevel}';
}

bool _hasNext(List<String> stages, String? current) =>
    current != null && stages.contains(current) && stages.last != current;

String _next(List<String> stages, String current) {
  final index = stages.indexOf(current);
  return stages[(index + 1).clamp(0, stages.length - 1)];
}
