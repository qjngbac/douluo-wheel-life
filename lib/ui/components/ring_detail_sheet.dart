import 'package:flutter/material.dart';

import '../../domain/models.dart';

Color ringColorValue(RingColor color) => switch (color) {
  RingColor.white => const Color(0xffe9edf6),
  RingColor.yellow => const Color(0xfff2ca55),
  RingColor.purple => const Color(0xffa874f5),
  RingColor.black => const Color(0xff242638),
  RingColor.red => const Color(0xffed5b5b),
  RingColor.gold => const Color(0xffffca5d),
  RingColor.orangeGold => const Color(0xffff9f43),
  RingColor.greenGold => const Color(0xff77e08a),
  RingColor.blueGold => const Color(0xff45c8f5),
  RingColor.emerald => const Color(0xff37d993),
  RingColor.silverViolet => const Color(0xffc2b7ff),
  RingColor.crimsonGold => const Color(0xffff6b55),
  RingColor.green => const Color(0xff32d26f),
  RingColor.moonWhite => const Color(0xfff5f3ff),
  RingColor.redBrown => const Color(0xffa84f42),
  RingColor.cyan => const Color(0xff38d7d9),
  RingColor.roseGold => const Color(0xffff8fa3),
  RingColor.rainbow => const Color(0xffd76dff),
};

String ringColorLabel(RingColor color) => switch (color) {
  RingColor.white => '白色',
  RingColor.yellow => '黄色',
  RingColor.purple => '紫色',
  RingColor.black => '黑色',
  RingColor.red => '红色',
  RingColor.gold => '金色',
  RingColor.orangeGold => '橙金色',
  RingColor.greenGold => '绿金色',
  RingColor.blueGold => '蓝金色',
  RingColor.emerald => '翡翠绿色',
  RingColor.silverViolet => '银紫色',
  RingColor.crimsonGold => '赤金色',
  RingColor.green => '翠绿色',
  RingColor.moonWhite => '月白色',
  RingColor.redBrown => '红褐色',
  RingColor.cyan => '青蓝色',
  RingColor.roseGold => '玫瑰金色',
  RingColor.rainbow => '七彩色',
};

class RingColorBadge extends StatelessWidget {
  const RingColorBadge({super.key, required this.color, this.size = 30});

  final RingColor color;
  final double size;

  bool get _isDivine => switch (color) {
    RingColor.gold ||
    RingColor.orangeGold ||
    RingColor.greenGold ||
    RingColor.blueGold ||
    RingColor.crimsonGold ||
    RingColor.green ||
    RingColor.moonWhite ||
    RingColor.redBrown ||
    RingColor.cyan ||
    RingColor.roseGold ||
    RingColor.rainbow => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final value = ringColorValue(color);
    return Semantics(
      container: true,
      label: '${ringColorLabel(color)}魂环',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xff10131d),
          border: Border.all(color: value, width: _isDivine ? 4 : 3),
          boxShadow: _isDivine
              ? <BoxShadow>[
                  BoxShadow(color: value.withValues(alpha: .65), blurRadius: 8),
                ]
              : null,
        ),
        child: Text(
          ringColorLabel(color).replaceAll('色', '').characters.first,
          style: TextStyle(
            color: value,
            fontSize: size * .35,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Future<void> showRingDetailSheet(BuildContext context, List<SoulRing> rings) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xff0d1b35),
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: rings.length + 1,
        separatorBuilder: (_, _) => const Divider(color: Color(0xff284875)),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '魂环详情',
                style: TextStyle(
                  color: Color(0xfff7d77f),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }
          final ring = rings[index - 1];
          return ListTile(
            leading: RingColorBadge(color: ring.color),
            title: Text(
              '${ring.years} 年  ${ringColorLabel(ring.color)}魂环',
              style: const TextStyle(color: Color(0xffeaf1ff)),
            ),
            subtitle: Text(
              '${ring.source}\n${ring.skillName}：${ring.description}',
              style: const TextStyle(color: Color(0xffa9b8d7)),
            ),
            isThreeLine: true,
          );
        },
      ),
    ),
  );
}
