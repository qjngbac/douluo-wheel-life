import 'package:flutter/material.dart';

import '../../state/game_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.controller,
    required this.onStart,
    required this.onAbandonAndStart,
    required this.onContinue,
    required this.onArchive,
  });

  final GameController controller;
  final VoidCallback onStart;
  final VoidCallback onAbandonAndStart;
  final VoidCallback onContinue;
  final VoidCallback onArchive;

  Future<void> _requestStart(BuildContext context) async {
    if (!controller.canContinue) {
      onStart();
      return;
    }
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('当前人生尚未结束'),
        content: const Text('开始新人生会替换当前进度，请明确选择如何处理。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'continue'),
            child: const Text('继续当前人生'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'archive'),
            child: const Text('放弃并归档'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'replace'),
            child: const Text('覆盖并开始'),
          ),
        ],
      ),
    );
    switch (choice) {
      case 'continue':
        onContinue();
      case 'archive':
        onAbandonAndStart();
      case 'replace':
        onStart();
    }
  }

  Future<void> _showAbout(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('关于斗罗命运转盘'),
      content: const Text(
        '这是非官方同人作品，仅用于离线娱乐。\n\n'
        '游戏完全离线运行，不需要账号，不上传存档，也不会请求网络权限。'
        '人物与世界观相关名称归原著及相应权利方所有。',
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('知道了'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-.25, -.65),
          radius: 1.25,
          colors: <Color>[
            Color(0xff1b3f78),
            Color(0xff081126),
            Color(0xff040915),
          ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          key: const Key('about-game'),
                          tooltip: '关于游戏',
                          onPressed: () => _showAbout(context),
                          icon: const Icon(Icons.info_outline),
                        ),
                      ),
                      const Spacer(flex: 2),
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xfff3ce70),
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '斗罗命运转盘',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xfff9e4ad),
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '命运不会询问你的意见。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xffa9b8d7),
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(flex: 2),
                      FilledButton(
                        onPressed: () => _requestStart(context),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: const Color(0xffd4a44d),
                          foregroundColor: const Color(0xff102040),
                        ),
                        child: const Text('开始新人生'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: controller.canContinue ? onContinue : null,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: const Color(0xffd9e8ff),
                        ),
                        child: const Text('继续人生'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onArchive,
                        child: const Text(
                          '人生档案馆',
                          style: TextStyle(color: Color(0xffb69aff)),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '离线纯随机模式  每段人生由 Seed 与规则引擎决定',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff7284a8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
