import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../engine/biography_engine.dart';
import '../../engine/combat_loadout_engine.dart';
import '../../engine/life_identity_engine.dart';
import '../../engine/life_retrospective_engine.dart';
import '../../engine/soul_beast_summary.dart';

class EndingPage extends StatelessWidget {
  const EndingPage({
    super.key,
    required this.state,
    required this.onHome,
    required this.onRestart,
    this.onBackToArchive,
    this.onDelete,
  });

  final GameState state;
  final VoidCallback onHome;
  final VoidCallback onRestart;
  final VoidCallback? onBackToArchive;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final biography = const BiographyEngine().compose(state);
    return Scaffold(
      appBar: AppBar(
        title: const Text('命运结局'),
        actions: <Widget>[
          if (onBackToArchive != null)
            IconButton(
              tooltip: '返回档案馆',
              onPressed: onBackToArchive,
              icon: const Icon(Icons.arrow_back),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: '删除这份档案',
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              state.ending ?? '命运未明',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xfff7d77f),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '人生传记',
              style: TextStyle(
                color: Color(0xff74d7ff),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(biography, style: const TextStyle(height: 1.7)),
            const SizedBox(height: 20),
            _LifeRetrospective(state: state),
            if (state.character.route == RouteType.soulBeast) ...<Widget>[
              const SizedBox(height: 20),
              _SoulBeastArchiveSummary(state: state),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.autorenew),
              label: const Text('开启下一段人生'),
            ),
            const SizedBox(height: 10),
            FilledButton(onPressed: onHome, child: const Text('返回首页')),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除这份人生档案？'),
        content: const Text('删除后无法恢复。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onDelete?.call();
  }
}

class _LifeRetrospective extends StatelessWidget {
  const _LifeRetrospective({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final character = state.character;
    final titles = derivedLifeTitles(character);
    final achievements = lifeAchievements(character);
    final loadout = combatLoadout(character);
    final relationships = List<Relationship>.from(state.relationships)
      ..sort((left, right) => right.trust.compareTo(left.trust));
    final milestones = keyLifeChapters(state);
    return Card(
      color: const Color(0xff142b50),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '人生回顾',
              style: TextStyle(
                color: Color(0xff74d7ff),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text('命运之名：${displayLifeName(character)}'),
            Text('志向：${aspirationProgress(character)}'),
            if (titles.isNotEmpty) Text('称号：${titles.join('、')}'),
            if (achievements.isNotEmpty) Text('成就：${achievements.join('、')}'),
            if (character.lifeMarks.isNotEmpty)
              Text('人生印记：${displayLifeMarks(character).join('、')}'),
            if (relationships.isNotEmpty)
              Text(
                '最深羁绊：${relationships.take(3).map((item) => '${item.name}·${item.trust}').join('、')}',
              ),
            Text(
              '最终构筑：强攻${loadout.offense}、防御${loadout.defense}、控制${loadout.control}、'
              '机动${loadout.mobility}、恢复${loadout.recovery}、科技${loadout.technology}',
            ),
            if (milestones.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              const Text('关键章节', style: TextStyle(fontWeight: FontWeight.w700)),
              ...milestones.map((entry) => Text('· $entry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _SoulBeastArchiveSummary extends StatelessWidget {
  const _SoulBeastArchiveSummary({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final summary = composeSoulBeastLifeSummary(state);
    return Card(
      color: const Color(0xff142b50),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '魂兽人生总结',
              style: TextStyle(
                color: Color(0xff74d7ff),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(summary.identity),
            Text(summary.destiny),
            Text(summary.territory),
            Text('最高人类威胁 ${summary.maximumHumanThreat}'),
            if (summary.keyAlly != null) Text('关键盟友 ${summary.keyAlly}'),
            if (summary.keyEnemy != null) Text('关键敌人 ${summary.keyEnemy}'),
            if (summary.feats.isNotEmpty)
              Text('重要战绩 ${summary.feats.join('、')}'),
          ],
        ),
      ),
    );
  }
}
