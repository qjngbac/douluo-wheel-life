import '../domain/models.dart';

class EraMilestone {
  const EraMilestone({
    required this.id,
    required this.eraId,
    required this.protagonistYear,
    required this.title,
    required this.description,
    required this.options,
  });

  final String id;
  final String eraId;
  final int protagonistYear;
  final String title;
  final String description;
  final List<WheelOption> options;
}

const List<WheelOption> _standardResponses = <WheelOption>[
  WheelOption(
    id: 'era-watch',
    text: '谨慎旁观局势',
    weight: 48,
    effects: <String, int>{'luck': 1},
  ),
  WheelOption(
    id: 'era-enter',
    text: '主动踏入风暴',
    weight: 36,
    effects: <String, int>{'soulPower': 2},
  ),
  WheelOption(
    id: 'era-protect',
    text: '守护身边之人',
    weight: 16,
    effects: <String, int>{'ringCapacity': 4},
  ),
];

const List<EraMilestone> eraMilestones = <EraMilestone>[
  EraMilestone(
    id: 'd1-awakening',
    eraId: 'era-douluo-1',
    protagonistYear: 6,
    title: '武魂觉醒之年',
    description: '大陆新一代魂师陆续觉醒，旧秩序出现了第一道涟漪。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd1-shrek',
    eraId: 'era-douluo-1',
    protagonistYear: 12,
    title: '史莱克新生代',
    description: '一群年轻魂师开始崭露头角，各方势力重新审视未来。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd1-contest',
    eraId: 'era-douluo-1',
    protagonistYear: 14,
    title: '全大陆魂师大赛',
    description: '年轻天才汇聚赛场，荣耀背后也暗藏势力角逐。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd1-war',
    eraId: 'era-douluo-1',
    protagonistYear: 24,
    title: '大陆决战前夜',
    description: '阵营之间的矛盾走向决战，任何选择都会留下时代回声。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd2-shrek',
    eraId: 'era-peerless',
    protagonistYear: 11,
    title: '史莱克入学季',
    description: '魂导科技兴起，新一代魂师在传统与革新之间成长。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd2-contest',
    eraId: 'era-peerless',
    protagonistYear: 14,
    title: '新一届斗魂大赛',
    description: '魂师与魂导师同台争锋，战法体系正在改变。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd2-exchange',
    eraId: 'era-peerless',
    protagonistYear: 17,
    title: '日月交流风波',
    description: '魂导技术与宗门传承碰撞，知识也成为力量。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd2-war',
    eraId: 'era-peerless',
    protagonistYear: 24,
    title: '帝国战争阴云',
    description: '大陆局势骤然紧张，个人命运被卷入更大的战争。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd2-spirit-birth',
    eraId: 'era-peerless',
    protagonistYear: 20,
    title: '魂灵体系诞生',
    description: '人与魂兽以契约共存的新道路公开，魂环获取方式由此改变。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd3-eastsea',
    eraId: 'era-legend',
    protagonistYear: 10,
    title: '东海城少年期',
    description: '魂导文明深入日常，年轻魂师迎来新的修炼道路。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd3-shrek',
    eraId: 'era-legend',
    protagonistYear: 15,
    title: '史莱克风云',
    description: '学院、传灵塔与宗门之间的平衡逐渐动摇。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd3-disaster',
    eraId: 'era-legend',
    protagonistYear: 18,
    title: '大陆灾变',
    description: '突如其来的灾难改变无数人的去向与立场。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd3-abyss',
    eraId: 'era-legend',
    protagonistYear: 24,
    title: '深渊危机',
    description: '位面危机逼近，大陆强者必须共同作出抉择。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd4-school',
    eraId: 'era-ultimate',
    protagonistYear: 12,
    title: '星际学院选拔',
    description: '魂师文明迈向星海，天赋与团队同样重要。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd4-space',
    eraId: 'era-ultimate',
    protagonistYear: 16,
    title: '首次星际远航',
    description: '未知星域带来机缘，也放大了每一次判断的代价。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd4-frontier',
    eraId: 'era-ultimate',
    protagonistYear: 20,
    title: '联邦边疆风波',
    description: '文明边界之外的冲突，迫使年轻一代承担责任。',
    options: _standardResponses,
  ),
  EraMilestone(
    id: 'd4-dragon',
    eraId: 'era-ultimate',
    protagonistYear: 25,
    title: '龙族血脉回响',
    description: '古老血脉与星际秩序相遇，神级道路再度开启。',
    options: _standardResponses,
  ),
];

List<EraMilestone> milestonesForEra(String? eraId) =>
    eraMilestones.where((item) => item.eraId == eraId).toList(growable: false)
      ..sort(
        (left, right) => left.protagonistYear.compareTo(right.protagonistYear),
      );

EraMilestone? nextDueEraMilestone({
  required String? eraId,
  required int protagonistYear,
  required Iterable<String> triggeredIds,
}) {
  final triggered = triggeredIds.toSet();
  for (final milestone in milestonesForEra(eraId)) {
    if (milestone.protagonistYear <= protagonistYear &&
        !triggered.contains(milestone.id)) {
      return milestone;
    }
  }
  return null;
}
