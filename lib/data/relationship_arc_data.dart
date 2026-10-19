import '../domain/models.dart';

class _HumanArcSpec {
  const _HumanArcSpec({
    required this.id,
    required this.name,
    required this.type,
    required this.titles,
    required this.descriptions,
    required this.tags,
    required this.weights,
    this.trustDeltas = const <int>[16, 24, 34],
  });

  final String id;
  final String name;
  final String type;
  final List<String> titles;
  final List<String> descriptions;
  final List<String> tags;
  final List<double> weights;
  final List<int> trustDeltas;
}

List<StoryEvent> buildHumanRelationshipArcs() {
  const arcs = <_HumanArcSpec>[
    _HumanArcSpec(
      id: 'human-mentor-legacy',
      name: '云岚导师',
      type: '导师',
      titles: <String>['风崖授课', '替师守关', '接续云岚衣钵'],
      descriptions: <String>[
        '云岚导师看出你运转魂力时的隐患，在风崖上为你校正根基。',
        '导师闭关遭逢旧敌，你守住山门，也第一次理解他未竟的责任。',
        '云岚导师把毕生心得交给你，你选择继承其中的信念而非照搬道路。',
      ],
      tags: <String>['云岚指点', '云岚守关', '云岚传承'],
      weights: <double>[7, 5, 3],
    ),
    _HumanArcSpec(
      id: 'human-sect-trial',
      name: '玄穹宗',
      type: '宗门',
      titles: <String>['玄穹外门试炼', '宗门危局抉择', '执掌玄穹星印'],
      descriptions: <String>[
        '你在玄穹宗的外门试炼中选择帮助落后的同门，赢得最初的认可。',
        '宗门遭遇内外夹击，你查清叛徒而没有把无辜者卷入清算。',
        '长老会将玄穹星印交给你，它既是权力，也是守护门人的责任。',
      ],
      tags: <String>['玄穹入门', '玄穹守义', '玄穹星印'],
      weights: <double>[8, 4.5, 2.5],
    ),
    _HumanArcSpec(
      id: 'human-companion-journey',
      name: '沈星河',
      type: '挚友',
      titles: <String>['星河同行', '秘境背靠背', '共赴天涯之约'],
      descriptions: <String>[
        '你与沈星河因一次护送任务结伴，互补的行事方式让旅途少了许多风险。',
        '秘境坍塌时，你们把后背交给彼此，从绝境里带回所有队员。',
        '沈星河放弃独占机缘，与你立下无论强弱都并肩前行的约定。',
      ],
      tags: <String>['星河同行', '星河生死交', '星河之约'],
      weights: <double>[9, 5, 3],
      trustDeltas: <int>[20, 34, 40],
    ),
    _HumanArcSpec(
      id: 'human-rival-oath',
      name: '叶孤鸿',
      type: '宿敌',
      titles: <String>['擂台初逢叶孤鸿', '宿敌联手破阵', '巅峰再战之约'],
      descriptions: <String>[
        '叶孤鸿在擂台上击败了你，却拒绝用羞辱换取声名。',
        '更大的敌人封锁遗迹，你与叶孤鸿暂时联手，在较量中建立尊重。',
        '你们没有消除竞争，而是约定把彼此推向能够触及的最高峰。',
      ],
      tags: <String>['孤鸿宿敌', '孤鸿并肩', '巅峰战约'],
      weights: <double>[7, 4, 2.5],
      trustDeltas: <int>[8, 22, 35],
    ),
    _HumanArcSpec(
      id: 'human-family-pact',
      name: '故乡亲族',
      type: '家族',
      titles: <String>['旧匣中的家书', '故乡血脉危机', '重立守望家约'],
      descriptions: <String>[
        '一封旧家书让你得知家族曾以守护平民为誓，并非只为血脉荣耀。',
        '故乡遭逢灾难，你在个人机缘与亲族安危之间选择先救人。',
        '你废除陈旧的尊卑规矩，以互助和担当重新立下家约。',
      ],
      tags: <String>['家书旧约', '故乡守护', '守望家约'],
      weights: <double>[8, 4.5, 2.8],
    ),
  ];

  return <StoryEvent>[
    for (final arc in arcs)
      for (var stage = 0; stage < 3; stage++)
        StoryEvent(
          id: '${arc.id}-${stage + 1}',
          title: arc.titles[stage],
          description: arc.descriptions[stage],
          weight: arc.weights[stage],
          route: RouteType.human,
          minAge: 10 + stage * 6,
          minSoulPower: stage * 20,
          effects: <String, int>{
            'luck': stage + 1,
            if (stage == 2) 'ringCapacity': 6,
          },
          addTags: <String>[arc.tags[stage]],
          requiredTags: stage == 0
              ? const <String>[]
              : <String>[arc.tags[stage - 1]],
          forbiddenTags: <String>[arc.tags[stage]],
          arcId: arc.id,
          arcStage: stage + 1,
          repeatLimit: 1,
          relationshipId: arc.id,
          relationshipName: arc.name,
          relationshipType: arc.type,
          trustDelta: arc.trustDeltas[stage],
          affectionDelta: arc.type == '挚友' || arc.type == '家族'
              ? 10 + stage * 6
              : 0,
        ),
  ];
}
