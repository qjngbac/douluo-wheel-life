import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models.dart';
import '../../domain/presentation_labels.dart';
import '../../engine/game_engine.dart';
import '../../engine/combat_loadout_engine.dart';
import '../../engine/soul_beast_archetype.dart';
import '../../engine/soul_beast_evolution_tree.dart';
import '../../engine/soul_bone_quality.dart';
import '../../engine/story_director.dart';
import '../../state/game_controller.dart';
import '../components/character_summary.dart';
import '../components/destiny_wheel.dart';
import '../components/result_card.dart';
import '../components/ring_detail_sheet.dart';

List<String> visibleCharacterTags(Iterable<String> tags) {
  final visible = <String>[];
  for (final tag in sanitizePlayerFacingLines(tags)) {
    if (tag == 'genius') continue;
    if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(tag)) continue;
    if (!visible.contains(tag)) visible.add(tag);
  }
  return visible;
}

Future<void> showWheelOptionsSheet(
  BuildContext context,
  GameState state,
  GameEngine engine,
  WheelPool pool,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xff0d1b35),
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        itemCount: pool.options.length + 1,
        separatorBuilder: (_, _) => const Divider(color: Color(0xff284875)),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const ListTile(
              title: Text(
                '全部命运选项',
                style: TextStyle(
                  color: Color(0xfff7d77f),
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text('扇区大小仍受命运权重影响，性格、经历和本局强化都可能改变结果。'),
            );
          }
          final option = pool.options[index - 1];
          final breakdown = engine.probabilityBreakdownFor(state, pool, option);
          return ListTile(
            leading: CircleAvatar(child: Text('$index')),
            title: Text(wheelOptionDisplayText(option.text)),
            subtitle: Text('影响因素：${breakdown.reasons.join('；')}'),
          );
        },
      ),
    ),
  );
}

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.controller, this.onFinished});

  final GameController controller;
  final VoidCallback? onFinished;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var _tab = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant GamePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _spin() async {
    final settings = widget.controller.settings;
    if (settings.haptics) HapticFeedback.mediumImpact();
    if (settings.sounds) SystemSound.play(SystemSoundType.click);
    await widget.controller.spin();
    if (mounted && (widget.controller.state?.isFinished ?? false)) {
      widget.onFinished?.call();
    }
  }

  Future<void> _showSettings() async {
    var settings = widget.controller.settings;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: const Text('游戏设置'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SwitchListTile(
                  title: const Text('快速动画'),
                  value: settings.fastMode,
                  onChanged: (value) => refresh(
                    () => settings = settings.copyWith(fastMode: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('跳过动画'),
                  value: settings.skipAnimations,
                  onChanged: (value) => refresh(
                    () => settings = settings.copyWith(skipAnimations: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('震动反馈'),
                  value: settings.haptics,
                  onChanged: (value) => refresh(
                    () => settings = settings.copyWith(haptics: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('操作音效'),
                  value: settings.sounds,
                  onChanged: (value) => refresh(
                    () => settings = settings.copyWith(sounds: value),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () async {
                await widget.controller.updateSettings(settings);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('保存设置'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestEndLife() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('结束当前人生？'),
        content: const Text('确认后会立即记录结局并保存到人生档案，随后可以开启下一段人生。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('继续人生'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('结束并归档'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.controller.endCurrentLife();
    if (mounted) widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    if (state == null) {
      return const Scaffold(body: Center(child: Text('正在读取人生……')));
    }
    final wheel = widget.controller.isSpinning
        ? widget.controller.lastSpin?.wheel
        : widget.controller.engine.currentWheel(state);
    final selectedIndex = widget.controller.lastSpin?.selectedIndex ?? 0;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '第 ${state.timeline.length + 1} 次命运判定',
                    style: const TextStyle(
                      color: Color(0xff74d7ff),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      TextButton(
                        key: const Key('current-life-menu'),
                        onPressed: widget.controller.isJudging
                            ? null
                            : _requestEndLife,
                        child: const Text(
                          '当前人生',
                          style: TextStyle(
                            color: Color(0xfff7d77f),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('game-settings'),
                        tooltip: '游戏设置',
                        onPressed: widget.controller.isJudging
                            ? null
                            : _showSettings,
                        icon: const Icon(Icons.settings_outlined, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: <Widget>[
                  _LifeTab(
                    state: state,
                    engine: widget.controller.engine,
                    wheel: wheel,
                    selectedIndex: selectedIndex,
                    presentationSequence:
                        widget.controller.lastSpin?.sequence ?? 0,
                    animationDuration: wheel == null
                        ? Duration.zero
                        : widget.controller.presentationDurationFor(wheel),
                    spinning: widget.controller.isSpinning,
                    fastMode: widget.controller.fastMode,
                    onFastModeChanged: widget.controller.setFastMode,
                    onSpin: _spin,
                    autoEventsPaused: widget.controller.autoEventsPaused,
                    onPauseAutoEvents: widget.controller.pauseAutoEvents,
                    onResumeAutoEvents: widget.controller.resumeAutoEvents,
                    canCompleteSecondaryRings:
                        widget.controller.canCompleteSecondaryRings,
                    onCompleteSecondaryRings:
                        widget.controller.completeSecondaryRings,
                    onResolveFinishedLife: () {
                      if (widget.controller.state?.isFinished ?? false) {
                        widget.onFinished?.call();
                      }
                    },
                  ),
                  _AttributesTab(character: state.character),
                  _RelationshipsTab(state: state),
                  _AbilitiesTab(state: state, controller: widget.controller),
                  _HistoryTab(timeline: state.timeline),
                ],
              ),
            ),
            NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (index) => setState(() => _tab = index),
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories),
                  label: '人生',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: '属性',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: '关系',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bolt_outlined),
                  selectedIcon: Icon(Icons.bolt),
                  label: '能力',
                ),
                NavigationDestination(icon: Icon(Icons.history), label: '历史'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LifeTab extends StatelessWidget {
  const _LifeTab({
    required this.state,
    required this.engine,
    required this.wheel,
    required this.selectedIndex,
    required this.presentationSequence,
    required this.animationDuration,
    required this.spinning,
    required this.fastMode,
    required this.onFastModeChanged,
    required this.onSpin,
    required this.autoEventsPaused,
    required this.onPauseAutoEvents,
    required this.onResumeAutoEvents,
    required this.canCompleteSecondaryRings,
    required this.onCompleteSecondaryRings,
    required this.onResolveFinishedLife,
  });

  final GameState state;
  final GameEngine engine;
  final WheelPool? wheel;
  final int selectedIndex;
  final int presentationSequence;
  final Duration animationDuration;
  final bool spinning;
  final bool fastMode;
  final ValueChanged<bool> onFastModeChanged;
  final VoidCallback onSpin;
  final bool autoEventsPaused;
  final VoidCallback onPauseAutoEvents;
  final Future<void> Function() onResumeAutoEvents;
  final bool canCompleteSecondaryRings;
  final Future<SecondaryRingRunSummary> Function() onCompleteSecondaryRings;
  final VoidCallback onResolveFinishedLife;

  Future<void> _completeSecondaryRings(BuildContext context) async {
    final summary = await onCompleteSecondaryRings();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(summary.completed ? '第二武魂附环完成' : '连续附环已暂停'),
        content: Text(
          summary.acquiredRings.isEmpty
              ? summary.pausedReason ?? '本次没有获得新魂环。'
              : <String>[
                  '本次共获得 ${summary.acquiredRings.length} 枚魂环：',
                  ...summary.acquiredRings.map(
                    (ring) =>
                        '${ring.years} 年${ringColorLabel(ring.color)}魂环 · ${ring.source}',
                  ),
                  if (summary.pausedReason != null) summary.pausedReason!,
                ].join('\n'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
    onResolveFinishedLife();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
    children: <Widget>[
      CharacterSummary(character: state.character),
      if (!state.isFinished && wheel != null) ...<Widget>[
        Padding(
          key: const Key('wheel-section'),
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            wheel!.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: const Color(0xffeaf1ff)),
          ),
        ),
        if (wheel!.id == 'ringTarget')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: <Widget>[
                Chip(
                  key: const Key('ring-progress-primary'),
                  avatar: const Icon(Icons.looks_one_outlined, size: 17),
                  label: Text('第一武魂 ${state.character.soulRings.length}/9'),
                ),
                Chip(
                  key: const Key('ring-progress-secondary'),
                  avatar: const Icon(Icons.looks_two_outlined, size: 17),
                  label: Text(
                    '第二武魂 ${state.character.secondarySoulRings.length}/9',
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '点击转动，长按查看完整选项。',
              style: TextStyle(color: Color(0xff9babca), fontSize: 12),
            ),
            const SizedBox(width: 10),
            FilterChip(
              label: const Text('快速'),
              selected: fastMode,
              onSelected: spinning ? null : onFastModeChanged,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.pendingLifeEvents > 0 && (spinning || autoEventsPaused))
          Center(
            child: OutlinedButton.icon(
              onPressed: autoEventsPaused
                  ? () => onResumeAutoEvents()
                  : onPauseAutoEvents,
              icon: Icon(autoEventsPaused ? Icons.play_arrow : Icons.pause),
              label: Text(autoEventsPaused ? '继续连续事件' : '暂停连续事件'),
            ),
          ),
        if (canCompleteSecondaryRings)
          Center(
            child: FilledButton.tonalIcon(
              key: const Key('complete-secondary-rings'),
              onPressed: spinning
                  ? null
                  : () => _completeSecondaryRings(context),
              icon: const Icon(Icons.fast_forward),
              label: const Text('连续附加第二武魂魂环'),
            ),
          ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DestinyWheel(
              pool: wheel!,
              selectedIndex: selectedIndex,
              spinning: spinning,
              presentationSequence: presentationSequence,
              animationDuration: animationDuration,
              onTap: onSpin,
              onLongPress: () =>
                  showWheelOptionsSheet(context, state, engine, wheel!),
            ),
          ),
        ),
      ],
      ResultCard(
        title: state.latestTitle,
        result: state.latestResult,
        effects: state.latestEffects,
        causes: state.latestCauses,
      ),
      if (state.batchResults.isNotEmpty)
        Card(
          key: const Key('life-event-batch'),
          child: ExpansionTile(
            title: Text('本轮共发生 ${state.batchResults.length} 件事'),
            subtitle: const Text('点击回顾本轮连续事件'),
            children: state.batchResults
                .map(
                  (result) => ListTile(
                    leading: Text('${result.age}岁'),
                    title: Text(result.title),
                    subtitle: Text(result.result),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      if (state.isFinished)
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Text(
            '本次人生已结束：${state.ending}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xfff7d77f)),
          ),
        ),
    ],
  );
}

class _AttributesTab extends StatelessWidget {
  const _AttributesTab({required this.character});
  final Character character;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: <Widget>[CharacterSummary(character: character)],
  );
}

class _RelationshipsTab extends StatelessWidget {
  const _RelationshipsTab({required this.state});
  final GameState state;
  @override
  Widget build(BuildContext context) {
    final character = state.character;
    final experiences = visibleCharacterTags(character.tags);
    final hasRelationships =
        character.faction != null ||
        character.mentor != null ||
        state.relationships.isNotEmpty;
    if (!hasRelationships && experiences.isEmpty) {
      return const Center(child: Text('这段人生尚未留下明确关系。'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          '关系与重要经历',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (character.faction != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: Text('势力：${character.faction}'),
            ),
          ),
        if (character.mentor != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.school_outlined),
              title: Text('导师：${character.mentor}'),
            ),
          ),
        ...state.relationships.map(
          (relationship) => Card(
            child: ExpansionTile(
              leading: Icon(
                relationship.alive ? Icons.favorite_outline : Icons.healing,
              ),
              title: Text(relationship.name),
              subtitle: Text(
                '${playerFacingRelationshipType(relationship.type)}  '
                '${playerFacingRelationshipStance(relationship)}  '
                '信任 ${relationship.trust}  羁绊 ${relationship.affection}',
              ),
              children: relationship.sharedEvents
                  .map(
                    (event) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.history, size: 18),
                      title: Text(event),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
        if (experiences.isNotEmpty)
          Card(
            child: ExpansionTile(
              title: Text('重要经历（${experiences.length}）'),
              subtitle: const Text('点击查看已触发的中文因果'),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: experiences
                        .map((tag) => Chip(label: Text(tag)))
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AbilitiesTab extends StatelessWidget {
  const _AbilitiesTab({required this.state, required this.controller});
  final GameState state;
  final GameController controller;

  Future<void> _showInvitationDialog(BuildContext context) async {
    var code = '';
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('输入邀请码'),
          content: TextField(
            key: const Key('invitation-code'),
            autofocus: true,
            keyboardType: TextInputType.number,
            onChanged: (value) => code = value,
            decoration: InputDecoration(
              labelText: '邀请码',
              errorText: error,
              helperText: '仅强化当前这一段人生',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final unlocked = await controller.unlockInvitation(code);
                if (!dialogContext.mounted) return;
                if (unlocked) {
                  Navigator.pop(dialogContext);
                } else {
                  setDialogState(() => error = '邀请码不正确');
                }
              },
              child: const Text('确认启用'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadout = combatLoadout(state.character);
    final buildProfile = combatBuildProfile(state.character);
    final mainline = dominantStoryTheme(state.character);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          state.character.route == RouteType.soulBeast ? '魂兽能力与命途' : '能力与魂环',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.key_outlined),
            title: Text(state.invitationMode ? '本局强化已开启' : '输入邀请码'),
            subtitle: Text(
              state.invitationMode
                  ? '本局后续命运大幅偏向优质结果，其他合理选项仍有较小概率出现；下一段人生恢复普通概率。'
                  : controller.isJudging
                  ? '命运判定进行中，结束后可以启用本局强化。'
                  : '邀请码只影响当前人生，也可以在中途启用。',
            ),
            trailing: state.invitationMode
                ? const Icon(Icons.verified, color: Color(0xfff3ce70))
                : const Icon(Icons.chevron_right),
            onTap: state.invitationMode || controller.isJudging
                ? null
                : () => _showInvitationDialog(context),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ExpansionTile(
            key: const Key('combat-build-profile'),
            leading: const Icon(
              Icons.shield_outlined,
              color: Color(0xfff3ce70),
            ),
            title: const Text('战斗能力'),
            subtitle: Text(
              '构筑：${buildProfile.title}\n'
              '强攻 ${loadout.offense}　防御 ${loadout.defense}　控制 ${loadout.control}\n'
              '机动 ${loadout.mobility}　恢复 ${loadout.recovery}　科技 ${loadout.technology}',
            ),
            children: <Widget>[
              ListTile(
                dense: true,
                title: const Text('优势与联动'),
                subtitle: Text(
                  <String>[
                    ...buildProfile.strengths,
                    ...buildProfile.synergies,
                  ].join('\n'),
                ),
              ),
              ListTile(
                dense: true,
                title: const Text('短板与冲突'),
                subtitle: Text(buildProfile.risks.join('\n')),
              ),
            ],
          ),
        ),
        if (state.character.goldCoins > 0 ||
            state.character.rareMetals > 0 ||
            state.character.factionReputation > 0 ||
            state.character.soulBeastTrust > 0 ||
            state.character.starMerit > 0)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xffa9f0d1),
              ),
              title: const Text('成长资源'),
              subtitle: Text(
                '金魂币 ${goldCoinAmount(state.character.goldCoins)}　稀有金属 ${state.character.rareMetals}\n'
                '势力声望 ${state.character.factionReputation}　魂兽信任 ${state.character.soulBeastTrust}　星际功勋 ${state.character.starMerit}',
              ),
              isThreeLine: true,
            ),
          ),
        if (mainline != null)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.route_outlined,
                color: Color(0xff74d7ff),
              ),
              title: const Text('人生主线'),
              subtitle: Text(
                '$mainline · 已推进 ${state.character.storyThemeProgress[mainline]} 个关键节点',
              ),
            ),
          ),
        if (state.character.route == RouteType.soulBeast)
          _BeastAbilitiesCard(character: state.character),
        if (state.character.route != RouteType.soulBeast &&
            state.character.martialSoul != null)
          Text(
            '${state.character.hasTwinMartialSouls ? '第一武魂' : '武魂'}：${state.character.martialSoul}',
            style: const TextStyle(
              color: Color(0xff74d7ff),
              fontWeight: FontWeight.w700,
            ),
          ),
        if (state.character.hasTwinMartialSouls) ...<Widget>[
          const SizedBox(height: 8),
          Card(
            color: const Color(0xff142b50),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '双武魂组合',
                    style: TextStyle(
                      color: Color(0xfff7d77f),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...state.character.tags
                      .where(
                        (tag) =>
                            tag.startsWith('双武魂组合：') ||
                            tag.startsWith('融合魂技潜质：') ||
                            tag.startsWith('武魂融合技：'),
                      )
                      .map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            tag,
                            style: const TextStyle(color: Color(0xffd9e7ff)),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
        if (state.character.soulBones.isNotEmpty)
          Card(
            child: ExpansionTile(
              leading: const Icon(
                Icons.hexagon_outlined,
                color: Color(0xfff3ce70),
              ),
              title: Text('魂骨（${state.character.soulBones.length}）'),
              subtitle: Text(
                '${state.character.soulBones.where((bone) => bone.slot != SoulBoneSlot.external).length}/6 常规部位'
                '${state.character.soulBones.any((bone) => bone.slot == SoulBoneSlot.external) ? '　拥有外附魂骨' : ''}',
              ),
              children: state.character.soulBones
                  .map(
                    (bone) => ListTile(
                      title: Text(
                        '${soulBoneSlotName(bone.slot)}　${bone.name}',
                      ),
                      subtitle: Text(
                        '${bone.years}年　来源：${bone.source}\n'
                        '品质 ${soulBoneQualityScore(bone, state.character)}　完整度 ${bone.integrity}%'
                        '${bone.setName == null ? '' : '　${bone.setName}'}\n'
                        '魂骨技：${bone.skillName}\n${bone.description}',
                      ),
                      isThreeLine: true,
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        if (state.character.spareSoulBones.isNotEmpty)
          Card(
            child: ExpansionTile(
              leading: const Icon(
                Icons.inventory_outlined,
                color: Color(0xffb8a6ff),
              ),
              title: Text('备用魂骨（${state.character.spareSoulBones.length}）'),
              subtitle: const Text('未装备，可用于后续替换、融合或收藏'),
              children: state.character.spareSoulBones
                  .map(
                    (bone) => ListTile(
                      title: Text(
                        '${soulBoneSlotName(bone.slot)}　${bone.name}',
                      ),
                      subtitle: Text(
                        '${bone.years}年　品质 ${soulBoneQualityScore(bone, state.character)}　完整度 ${bone.integrity}%\n'
                        '魂骨技：${bone.skillName}',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        if (state.character.soulSpirits.isNotEmpty)
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.auto_awesome, color: Color(0xff74d7ff)),
              title: Text('魂灵（${state.character.soulSpirits.length}）'),
              subtitle: Text(
                '总剩余赐环 ${state.character.soulSpirits.fold<int>(0, (sum, spirit) => sum + spirit.remainingRingGrants)} 次',
              ),
              children: state.character.soulSpirits
                  .map(
                    (spirit) => ListTile(
                      title: Text('${spirit.name}　${spirit.quality}'),
                      subtitle: Text(
                        '${spirit.years}年　羁绊 ${spirit.bond}　剩余赐环 ${spirit.remainingRingGrants}次\n'
                        '魂灵技：${spirit.skillName}\n${spirit.description}',
                      ),
                      isThreeLine: true,
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        if (state.character.technologyAssets.isNotEmpty ||
            state.character.soulEngineerLevel > 0 ||
            state.character.battleArmorStage != null ||
            state.character.mechaRank != null ||
            state.character.starCommandLevel > 0)
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.memory, color: Color(0xffa9f0d1)),
              title: Text('魂导科技（${state.character.technologyAssets.length}）'),
              subtitle: Text(
                <String>[
                  if (state.character.soulEngineerLevel > 0)
                    '魂导师 ${state.character.soulEngineerLevel}级',
                  if (state.character.battleArmorStage != null)
                    state.character.battleArmorStage!,
                  if (state.character.mechaRank != null)
                    state.character.mechaRank!,
                  if (state.character.starCommandLevel > 0)
                    '星战指挥 ${state.character.starCommandLevel}级',
                ].join('　'),
              ),
              children: state.character.technologyAssets
                  .map(
                    (asset) => ListTile(
                      title: Text(
                        '${technologyTypeName(asset.type)}　${asset.name}',
                      ),
                      subtitle: Text(
                        '${asset.rank}　完整度 ${asset.integrity}%　来源：${asset.source}\n${asset.description}',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        if (state.character.route != RouteType.soulBeast &&
            state.character.soulRings.isEmpty)
          const Text('尚未获得魂环。'),
        ...state.character.soulRings.map(
          (ring) => Card(
            child: ListTile(
              leading: RingColorBadge(color: ring.color, size: 34),
              title: Text(
                '${ring.years} 年  ${ringColorLabel(ring.color)}  ${ring.skillName}',
              ),
              subtitle: Text('${ring.source}\n${ring.description}'),
              isThreeLine: true,
            ),
          ),
        ),
        if (state.character.secondaryMartialSoul != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            '第二武魂：${state.character.secondaryMartialSoul}',
            style: const TextStyle(
              color: Color(0xff74d7ff),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (state.character.secondarySoulRings.isEmpty) const Text('尚未获得魂环。'),
          ...state.character.secondarySoulRings.map(
            (ring) => Card(
              child: ListTile(
                leading: RingColorBadge(color: ring.color, size: 34),
                title: Text(
                  '${ring.years} 年  ${ringColorLabel(ring.color)}  ${ring.skillName}',
                ),
                subtitle: Text('${ring.source}\n${ring.description}'),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BeastAbilitiesCard extends StatelessWidget {
  const _BeastAbilitiesCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final evolution = soulBeastEvolutionTree(character);
    return Card(
      color: const Color(0xff142b50),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '本体：${character.martialSoul ?? '尚未显现'}',
              style: const TextStyle(
                color: Color(0xff74d7ff),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text('命途：${character.beastPath}'),
            Text('种族：${character.beastArchetype}'),
            Text(
              '天赋：${soulBeastTalentDescription(SoulBeastArchetype.values.firstWhere((item) => soulBeastArchetypeName(item) == character.beastArchetype, orElse: () => SoulBeastArchetype.land))}',
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: <Widget>[
                Text('血脉 ${character.beastBloodlinePower}'),
                Text('灵智 ${character.beastIntelligence}'),
                Text('领地 ${character.beastTerritory}'),
                Text('族群声望 ${character.beastPrestige}'),
                Text('人类威胁 ${character.humanThreat}'),
                Text('羁绊 ${character.beastBond}'),
                Text('族群 ${character.beastClanPopulation}'),
                Text('资源 ${character.beastResources}'),
                Text('敌对压力 ${character.beastEnemyPressure}'),
                Text('栖息地 ${character.beastHabitat}'),
              ],
            ),
            if (character.tags.any(
              (tag) => tag.startsWith('组合魂技：') || tag.startsWith('宿敌战技：'),
            )) ...<Widget>[
              const SizedBox(height: 10),
              const Text(
                '长期羁绊能力',
                style: TextStyle(
                  color: Color(0xfff7d77f),
                  fontWeight: FontWeight.w700,
                ),
              ),
              ...character.tags
                  .where(
                    (tag) => tag.startsWith('组合魂技：') || tag.startsWith('宿敌战技：'),
                  )
                  .map((tag) => Text(tag)),
            ],
            const SizedBox(height: 8),
            const Text(
              '魂兽没有魂力与魂环；修为年限、血脉和生存经历共同决定实力。',
              style: TextStyle(color: Color(0xff9babca), fontSize: 12),
            ),
            const Divider(height: 24),
            Text(
              '血脉进化树 · 当前${evolution.stages[evolution.currentStageIndex].name}',
              style: const TextStyle(
                color: Color(0xfff7d77f),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...evolution.stages.indexed.map((entry) {
              final index = entry.$1;
              final stage = entry.$2;
              final reached = index <= evolution.currentStageIndex;
              final current = index == evolution.currentStageIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      reached ? Icons.check_circle : Icons.lock_outline,
                      size: 18,
                      color: current
                          ? const Color(0xfff3ce70)
                          : reached
                          ? const Color(0xff74d7ff)
                          : const Color(0xff71809e),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(stage.name),
                          Text(
                            reached ? stage.description : stage.requirement,
                            style: const TextStyle(
                              color: Color(0xff9babca),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends StatefulWidget {
  const _HistoryTab({required this.timeline});
  final List<TimelineEntry> timeline;

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  var _filter = '全部';

  bool _matches(TimelineEntry entry) => switch (_filter) {
    '魂环' => entry.stage.contains('魂环'),
    '神位' => entry.stage.contains('神') || entry.title.contains('神'),
    '重要事件' => entry.stage == '人生事件',
    '结局' => entry.stage.contains('结局') || entry.title.contains('结局'),
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final visible = widget.timeline.where(_matches).toList(growable: false);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 8,
            children: <String>['全部', '重要事件', '魂环', '神位', '结局']
                .map(
                  (label) => FilterChip(
                    label: Text(label),
                    selected: _filter == label,
                    onSelected: (_) => setState(() => _filter = label),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('没有符合条件的命运记录。'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final entry = visible[index];
                    return ExpansionTile(
                      leading: Text(
                        '${entry.age}岁',
                        style: const TextStyle(color: Color(0xfff7d77f)),
                      ),
                      title: Text(entry.title),
                      subtitle: Text(entry.description),
                      childrenPadding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (sanitizePlayerFacingLines(entry.effects).isEmpty)
                          const Text('本次记录没有数值变化。')
                        else ...<Widget>[
                          const Text(
                            '结果与影响',
                            style: TextStyle(color: Color(0xff74d7ff)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sanitizePlayerFacingLines(entry.effects).join('  '),
                          ),
                        ],
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
