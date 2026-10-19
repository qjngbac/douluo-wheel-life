import '../domain/models.dart';

class _EraCast {
  const _EraCast({
    required this.eraId,
    required this.protagonist,
    required this.cast,
    required this.descriptions,
  });

  final String eraId;
  final String protagonist;
  final List<String> cast;
  final List<String> descriptions;
}

List<StoryEvent> buildEraCharacterEvents() {
  const eras = <_EraCast>[
    _EraCast(
      eraId: 'era-douluo-1',
      protagonist: '唐三',
      cast: <String>['小舞', '戴沐白', '朱竹清', '宁荣荣', '奥斯卡', '马红俊', '玉小刚', '千仞雪'],
      descriptions: <String>[
        '你在林间小道上遇见这位活泼灵动的少女，她发梢的胡萝卜发饰轻巧晃动，清澈眼神中带着不经意的纯真与隐秘戒备。',
        '你在繁华街市中偶遇邪眸白虎少年，他神色桀骜威严，举手投足间带着顶尖兽武魂的迫人霸气。',
        '黑衣少女在静谧暗影中身轻如燕，幽冥灵猫武魂冷冽迅捷，冰冷防备的表象下是对命运的不屈抗争。',
        '七宝琉璃宗的小公主一袭淡青长裙驻足珍宝阁前，神态灵动傲娇，眼底尽是对外界冒险的好奇。',
        '推着餐车沿街叫卖香肠的年轻魂师热情挥手，虽然言语滑稽，但那双桃花眼中流露着罕见的辅助系天资。',
        '红发少年正大口灌着凉水平复武魂邪火，性格直率冲动，却在关键时刻有着毫无保留的仗义。',
        '面容坚毅的大师于书阁烛光下整理武魂核心理论，字字珠玑，对武魂本质的认知令人深感震撼。',
        '金辉隐现的华贵身影于宫廷暗影中冷然俯瞰，言语优雅从容，却自有一股裁决众生般的绝对神圣威仪。',
      ],
    ),
    _EraCast(
      eraId: 'era-peerless',
      protagonist: '霍雨浩',
      cast: <String>['王冬儿', '贝贝', '唐雅', '徐三石', '江楠楠', '和菜头', '橘子', '笑红尘'],
      descriptions: <String>[
        '粉蓝发色的俊秀少年在回廊上傲然抱臂，光明女神蝶光晕流转，眉宇间尽显不服输的倔强与灵动。',
        '儒雅沉稳的蓝电霸王龙传人温和致意，举手投足间尽显首席师兄的风范，眼底更有雷霆般的决断。',
        '唐门年轻门主摆弄着机巧暗器，目光坚毅热切，无论前路多坎坷都誓要重现唐门荣光。',
        '玄冥龟武魂的少年带着几分痞气笑容，看似玩世不恭，但在同伴陷入危机时却能化身不可动摇的坚盾。',
        '柔骨魅兔少女在市集幽径中独自行走，身法轻盈敏捷，清冷防备之下是对守护家人的至纯执念。',
        '高大黝黑的青年满头大汗地调试重型魂导炮，憨厚爽朗的笑容后，深藏着对身世过往的坚忍克制。',
        '日月皇家魂导师学院的聪慧少女在篝火旁沉静推演，神情温婉，运筹帷幄之间尽显战略谋士的锋芒。',
        '红尘家族的天之骄子负手而立，三足金蟾光耀璀璨，那份追求魂导与魂力双绝顶的骄傲不加掩饰。',
      ],
    ),
    _EraCast(
      eraId: 'era-legend',
      protagonist: '唐舞麟',
      cast: <String>['古月娜', '谢邂', '许小言', '叶星澜', '原恩夜辉', '舞长空', '乐正宇', '徐笠智'],
      descriptions: <String>[
        '银发紫眸的清冷少女静立于元素微光之中，天地法则环绕，绝美眼眸深处似有阅尽万古苍生的沉静与宿命。',
        '手握双龙匕的敏捷少年在屋檐疾驰而过，言语跳脱爱开玩笑，却有着愿为同伴两肋插刀的赤诚。',
        '温婉柔弱的少女于夜空星辉下展颜轻笑，星轮冰杖流淌神秘光带，拥有逆转乾坤的绝对掌控潜能。',
        '一袭劲装的执剑少女剑意凌霄，星神剑锋芒毕露，对剑道极致的纯粹追求超越世俗一切虚妄。',
        '身负暗黑与泰坦双重神力的短发少女默然独行，冷冽少言，在极端力量的夹缝中苦苦坚守本心。',
        '白衣胜雪、冷峻如冰的强者执天霜剑默然立于风雪中，孤傲如松，眼中深藏着不为人知的凄美过往。',
        '神圣天使羽翼金辉漫卷，年轻的天使传人正气凛然，立誓扫除世间一切阴暗罪愆。',
        '体态微胖的少年笑呵呵地奉上新鲜出炉的辅助包子，憨厚体贴，永远是队伍最安心的能量后盾。',
      ],
    ),
    _EraCast(
      eraId: 'era-ultimate',
      protagonist: '蓝轩宇',
      cast: <String>['白秀秀', '钱磊', '刘锋', '蓝梦琴', '唐雨格', '原恩辉辉', '樱落红', '丁卓涵'],
      descriptions: <String>[
        '深蓝长发的高挑少女在星际战舰前迎风伫立，冰天雪魔龙威仪天成，傲娇清冷的外表下极度护短。',
        '召唤金钱武魂的微胖少年手忙脚乱地安抚着召唤生灵，古灵精怪，总能在死局中变出不可思议的奇迹。',
        '手握白龙枪的精悍少年在训练舱中不知疲倦地挥汗如雨，眼神刚毅，透着突破平庸宿命的坚忍意志。',
        '冰天雪女与玉凰琴双生武魂的白裙少女清傲绝俗，翻手风雪漫天，覆手琴音回春，风华绝代。',
        '五行麒麟的大师姐沉稳端方，五行生克运转圆融，不论面对何种风暴皆如泰山般给人安心定力。',
        '精灵王弓在手的长耳少年目光明澈纯善，林间跳跃神出鬼没，拥有洞穿万物的超凡远程压制力。',
        '外院院长雷厉风行，做事严苛果决，在学员敬畏目光下以强硬手腕护卫着学院最后的尊严与底线。',
        '星战指挥系的天才青年在全息战术星图前运筹推演，擅长险中求胜与乱战调度，指挥若定。',
      ],
    ),
  ];
  return <StoryEvent>[
    for (final era in eras) ...<StoryEvent>[
      StoryEvent(
        id: 'canon-${era.eraId}-protagonist-1',
        title: '与${era.protagonist}初次相遇',
        description: '你与${era.protagonist}在一次意外中相遇。无论彼此属于人类还是魂兽，你们都没有先用敌意定义对方。',
        weight: 6,
        eraIds: <String>[era.eraId],
        minProtagonistYear: 4,
        maxProtagonistYear: 14,
        addTags: <String>['相识:${era.protagonist}'],
        forbiddenTags: <String>['相识:${era.protagonist}'],
        arcId: 'canon-${era.eraId}-protagonist',
        arcStage: 1,
        repeatLimit: 1,
        relationshipId: 'canon-${era.eraId}-protagonist',
        relationshipName: era.protagonist,
        relationshipType: '时代人物',
        trustDelta: 18,
      ),
      StoryEvent(
        id: 'canon-${era.eraId}-protagonist-2',
        title: '与${era.protagonist}并肩解围',
        description: '共同的危机迫使你们彼此配合，选择与行动逐渐把偶遇变成了真正的信任。',
        weight: 4,
        eraIds: <String>[era.eraId],
        minProtagonistYear: 10,
        maxProtagonistYear: 28,
        requiredTags: <String>['相识:${era.protagonist}'],
        forbiddenTags: <String>['并肩:${era.protagonist}'],
        addTags: <String>['并肩:${era.protagonist}'],
        arcId: 'canon-${era.eraId}-protagonist',
        arcStage: 2,
        repeatLimit: 1,
        relationshipId: 'canon-${era.eraId}-protagonist',
        relationshipName: era.protagonist,
        relationshipType: '时代人物',
        trustDelta: 30,
      ),
      StoryEvent(
        id: 'canon-${era.eraId}-protagonist-3',
        title: '与${era.protagonist}共定时代之约',
        description: '经历立场与危机的考验后，你们约定在各自道路上守住底线，并在时代巨变中相互照应。',
        weight: 2.5,
        eraIds: <String>[era.eraId],
        minProtagonistYear: 18,
        maxProtagonistYear: 45,
        requiredTags: <String>['并肩:${era.protagonist}'],
        forbiddenTags: <String>['时代之约:${era.protagonist}'],
        addTags: <String>['时代之约:${era.protagonist}', '深厚羁绊'],
        arcId: 'canon-${era.eraId}-protagonist',
        arcStage: 3,
        repeatLimit: 1,
        relationshipId: 'canon-${era.eraId}-protagonist',
        relationshipName: era.protagonist,
        relationshipType: '时代人物',
        trustDelta: 42,
        affectionDelta: 12,
      ),
      for (var index = 0; index < era.cast.length; index++)
        StoryEvent(
          id: 'canon-${era.eraId}-cast-$index',
          title: '邂逅${era.cast[index]}',
          description: era.descriptions[index],
          weight: 3.2,
          eraIds: <String>[era.eraId],
          minProtagonistYear: 6,
          maxProtagonistYear: 45,
          addTags: <String>['时代相识:${era.cast[index]}'],
          forbiddenTags: <String>['时代相识:${era.cast[index]}'],
          repeatLimit: 1,
          relationshipId: 'canon-${era.eraId}-cast-$index',
          relationshipName: era.cast[index],
          relationshipType: '时代人物',
          trustDelta: 14 + index % 4,
        ),
    ],
  ];
}
