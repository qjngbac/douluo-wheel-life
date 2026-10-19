import '../domain/models.dart';
import '../engine/seeded_random.dart';

const _surnames = <String>[
  '沈',
  '林',
  '叶',
  '苏',
  '顾',
  '宁',
  '罗',
  '白',
  '秦',
  '沐',
  '凌',
  '楚',
  '风',
  '蓝',
  '纪',
  '萧',
  '莫',
  '陆',
  '江',
  '洛',
  '谢',
  '许',
  '温',
  '宋',
  '裴',
  '程',
  '季',
  '唐',
  '韩',
  '云',
  '柳',
  '霍',
  '戴',
  '朱',
  '徐',
  '黎',
];

const _maleGivenNames = <String>[
  '玄策',
  '星河',
  '天衡',
  '九霄',
  '沧海',
  '凌渊',
  '无痕',
  '景行',
  '承岳',
  '云舟',
  '砚川',
  '长风',
  '照野',
  '怀瑾',
  '昭临',
  '朔尘',
  '清越',
  '闻昭',
  '知远',
  '修远',
  '临渊',
  '归尘',
  '曜辰',
  '星野',
  '苍梧',
  '长庚',
  '行舟',
  '惊鸿',
  '墨尧',
  '辰渊',
  '景澄',
  '奕川',
  '云峥',
  '澄岳',
  '予安',
  '亦航',
  '越泽',
  '时安',
  '屿川',
  '彦辰',
];

const _femaleGivenNames = <String>[
  '青岚',
  '晚灵',
  '昭雪',
  '昔颜',
  '墨秋',
  '云舒',
  '星瑶',
  '心月',
  '流萤',
  '霜华',
  '清歌',
  '若璃',
  '映雪',
  '知微',
  '望舒',
  '疏影',
  '南枝',
  '明澜',
  '绾青',
  '令仪',
  '瑾瑜',
  '清漪',
  '月见',
  '星晚',
  '云岫',
  '灵犀',
  '听雪',
  '照月',
  '兰因',
  '若蘅',
  '锦书',
  '微澜',
  '含章',
  '青黛',
  '白露',
  '云霓',
  '暮雪',
  '绮罗',
  '昭宁',
  '清欢',
];

WheelPool buildCharacterNamePool({
  required String? gender,
  required String seed,
}) {
  final female = gender == '女';
  final givenNames = female ? _femaleGivenNames : _maleGivenNames;
  final prefix = female ? 'female' : 'male';
  final options = <WheelOption>[
    for (var s = 0; s < _surnames.length; s++)
      for (var g = 0; g < givenNames.length; g++)
        WheelOption(
          id: 'name-$prefix-$s-$g',
          text: '${_surnames[s]}${givenNames[g]}',
          weight: 1,
        ),
  ];
  final random = SeededRandom.fromSeed('$seed|character-name|$prefix');
  for (var index = options.length - 1; index > 0; index--) {
    final other = random.nextInt(index + 1);
    final value = options[index];
    options[index] = options[other];
    options[other] = value;
  }
  return WheelPool(
    id: 'characterName',
    title: '命运之名',
    options: options.take(15).toList(growable: false),
  );
}
