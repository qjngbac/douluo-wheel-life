import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models.dart';
import '../../engine/archive_collection_engine.dart';
import '../../engine/content_fingerprint.dart';
import '../components/ring_detail_sheet.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({
    super.key,
    required this.archives,
    required this.onOpen,
    required this.onDelete,
    required this.onExport,
    required this.onImport,
    this.onRename,
    this.onFavorite,
    this.onLock,
    this.onBack,
  });

  final List<GameState> archives;
  final ValueChanged<GameState> onOpen;
  final Future<void> Function(GameState) onDelete;
  final String Function() onExport;
  final Future<int> Function(String) onImport;
  final Future<void> Function(GameState, String)? onRename;
  final Future<void> Function(GameState, bool)? onFavorite;
  final Future<void> Function(GameState, bool)? onLock;
  final VoidCallback? onBack;

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  var _query = '';
  var _route = '全部';
  var _achievement = '全部成就';
  late bool _archiveListExpanded;
  final Set<String> _comparisonSeeds = <String>{};

  @override
  void initState() {
    super.initState();
    _archiveListExpanded = widget.archives.length <= 4;
  }

  List<GameState> get _visibleArchives {
    final result = widget.archives
        .where((state) {
          final character = state.character;
          final isBeast = character.route == RouteType.soulBeast;
          if (_route == '魂师' && isBeast) return false;
          if (_route == '魂兽' && !isBeast) return false;
          if (_achievement == '已成神' && character.godhood == null) return false;
          if (_achievement == '未成神' && character.godhood != null) return false;
          if (_achievement == '九环/百万年' &&
              !(character.soulRings.length >= 9 ||
                  character.beastYears >= 1000000)) {
            return false;
          }
          if (_query.isEmpty) return true;
          final text = <String?>[
            state.ending,
            state.archiveAlias,
            character.characterName,
            character.era,
            character.martialSoul,
            character.secondaryMartialSoul,
            character.godhood,
            ...character.soulRings.expand(
              (ring) => <String>[ring.source, ring.skillName],
            ),
            ...character.secondarySoulRings.expand(
              (ring) => <String>[ring.source, ring.skillName],
            ),
            ...character.soulBones.expand(
              (bone) => <String>[bone.name, bone.source, bone.skillName],
            ),
            ...character.spareSoulBones.expand(
              (bone) => <String>[bone.name, bone.source, bone.skillName],
            ),
            ...character.soulSpirits.expand(
              (spirit) => <String>[
                spirit.name,
                spirit.species,
                spirit.skillName,
              ],
            ),
            ...character.technologyAssets.expand(
              (asset) => <String>[asset.name, asset.source, asset.description],
            ),
            ...state.relationships.map((relationship) => relationship.name),
            ...state.timeline.map((entry) => entry.title),
          ].whereType<String>().join();
          return text.toLowerCase().contains(_query.toLowerCase());
        })
        .toList(growable: false);
    result.sort((left, right) {
      if (left.archiveFavorite != right.archiveFavorite) {
        return left.archiveFavorite ? -1 : 1;
      }
      return 0;
    });
    return result;
  }

  List<GameState> get _comparison => widget.archives
      .where((state) => _comparisonSeeds.contains(state.seed))
      .take(2)
      .toList(growable: false);

  void _toggleComparison(GameState state) {
    setState(() {
      if (!_comparisonSeeds.remove(state.seed)) {
        if (_comparisonSeeds.length >= 2) {
          _comparisonSeeds.remove(_comparisonSeeds.first);
        }
        _comparisonSeeds.add(state.seed);
      }
    });
  }

  Future<void> _export() async {
    await Clipboard.setData(ClipboardData(text: widget.onExport()));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('档案备份已复制到剪贴板')));
  }

  Future<void> _import() async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('导入人生档案'),
        content: TextField(
          key: const Key('archive-import'),
          controller: controller,
          minLines: 5,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: '粘贴此前导出的 JSON 备份',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('导入'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final added = await widget.onImport(raw);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已导入 $added 段新人生')));
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }

  Future<void> _confirmDelete(GameState state) async {
    if (state.archiveLocked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('该档案已保护，请先解除保护。')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除档案'),
        content: Text('确认删除“${state.ending ?? '未命名人生'}”吗？此操作无法撤销。'),
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
    if (confirmed == true) await widget.onDelete(state);
  }

  Future<void> _rename(GameState state) async {
    final controller = TextEditingController(
      text: state.archiveAlias ?? state.ending ?? '',
    );
    final alias = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('修改档案别名'),
        content: TextField(
          key: const Key('archive-alias-input'),
          controller: controller,
          maxLength: 24,
          decoration: const InputDecoration(hintText: '例如：星海神匠人生'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (alias != null) await widget.onRename?.call(state, alias);
  }

  Future<void> _manageArchive(GameState state, String action) async {
    switch (action) {
      case 'rename':
        await _rename(state);
      case 'favorite':
        await widget.onFavorite?.call(state, !state.archiveFavorite);
      case 'lock':
        await widget.onLock?.call(state, !state.archiveLocked);
      case 'delete':
        await _confirmDelete(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionSummary = widget.archives.isEmpty
        ? null
        : composeArchiveCollectionSummary(widget.archives);
    return Scaffold(
      appBar: AppBar(
        title: const Text('人生档案馆'),
        leading: widget.onBack == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) => value == 'export' ? _export() : _import(),
            itemBuilder: (context) => const <PopupMenuEntry<String>>[
              PopupMenuItem(value: 'export', child: Text('复制备份')),
              PopupMenuItem(value: 'import', child: Text('导入备份')),
            ],
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              key: const Key('archive-search'),
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '搜索结局、武魂、魂环或成长收藏',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: <String>['全部', '魂师', '魂兽']
                  .map(
                    (label) => FilterChip(
                      label: Text(label),
                      selected: _route == label,
                      onSelected: (_) => setState(() => _route = label),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: <String>['全部成就', '已成神', '未成神', '九环/百万年']
                  .map(
                    (label) => FilterChip(
                      label: Text(label),
                      selected: _achievement == label,
                      onSelected: (_) => setState(() => _achievement = label),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          if (_comparison.isNotEmpty) _buildComparisonCard(),
          if (widget.archives.isEmpty)
            _buildArchiveList()
          else
            _buildArchiveListSection(),
          if (collectionSummary != null)
            _buildArchiveRecordsCard(collectionSummary),
          if (collectionSummary != null)
            _buildRareRingCompendiumCard(collectionSummary),
          if (collectionSummary != null)
            _buildGrowthCollectionCodex(collectionSummary),
          if (widget.archives.isNotEmpty) _buildCompendiumCard(),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() => Card(
    margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('人生对比（${_comparison.length}/2）'),
          const SizedBox(height: 6),
          for (final state in _comparison)
            Text(
              '${state.ending ?? '未命名'}：${state.character.age}岁，'
              '${state.character.route == RouteType.soulBeast ? '${state.character.beastYears}年修为' : '${state.character.soulPower}级/${_ringCountLabel(state.character)}'}',
            ),
        ],
      ),
    ),
  );

  Widget _buildRareRingCompendiumCard(ArchiveCollectionSummary summary) {
    final discoveries = summary.rareRings;
    return Card(
      key: const Key('rare-ring-compendium'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ExpansionTile(
        leading: const Icon(Icons.auto_awesome),
        title: const Text('稀有魂环图鉴'),
        subtitle: Text(
          discoveries.isEmpty
              ? '尚未发现特殊颜色魂环'
              : '已发现 ${discoveries.length} 种来源与颜色组合',
        ),
        children: discoveries
            .map(
              (entry) => ListTile(
                dense: true,
                leading: RingColorBadge(color: entry.color, size: 30),
                title: Text(
                  '${ringColorLabel(entry.color)} · ${entry.source} · ${entry.maximumYears}年',
                ),
                subtitle: Text('首次：${entry.firstLifeTitle}'),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildArchiveRecordsCard(ArchiveCollectionSummary summary) {
    final records = <(ArchiveRecord?, String)>[
      (summary.strongestRing, '年'),
      (summary.highestSoulPower, '级'),
      (summary.highestBeastYears, '年'),
      (summary.mostAllies, '人'),
      (summary.largestClan, '只'),
      (summary.rarestBeastPath, ''),
      (summary.strongestSoulBone, '分'),
      (summary.highestCombatLoadout, '分'),
      (summary.richestResources, '点'),
    ];
    return Card(
      key: const Key('archive-records'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ExpansionTile(
        leading: const Icon(Icons.emoji_events_outlined),
        title: const Text('跨人生纪录'),
        subtitle: const Text('比较全部已保存人生的巅峰成就'),
        children: records
            .where((item) => item.$1 != null)
            .map(
              (item) => ListTile(
                dense: true,
                title: Text(
                  item.$1!.label.startsWith('最稀有命途')
                      ? item.$1!.label
                      : '${item.$1!.label}：${item.$1!.value}${item.$2}',
                ),
                subtitle: Text('保持者：${item.$1!.lifeTitle}'),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildGrowthCollectionCodex(ArchiveCollectionSummary summary) {
    final discoveries = <(String, List<CrossLifeDiscovery>)>[
      ('魂骨图鉴', summary.soulBoneDiscoveries),
      ('魂灵图鉴', summary.soulSpiritDiscoveries),
      ('科技资产图鉴', summary.technologyDiscoveries),
    ];
    return Card(
      key: const Key('growth-collection-codex'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ExpansionTile(
        leading: const Icon(Icons.collections_bookmark_outlined),
        title: const Text('成长收藏图鉴'),
        subtitle: Text(
          '魂骨 ${summary.soulBoneDiscoveries.length}　魂灵 ${summary.soulSpiritDiscoveries.length}　'
          '科技 ${summary.technologyDiscoveries.length}',
        ),
        children: <Widget>[
          for (final group in discoveries) ...<Widget>[
            ListTile(
              dense: true,
              title: Text(
                group.$1,
                style: const TextStyle(
                  color: Color(0xff74d7ff),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (group.$2.isEmpty)
              const ListTile(dense: true, title: Text('尚未收录'))
            else
              ...group.$2.map(
                (entry) => ListTile(
                  dense: true,
                  title: Text(entry.name),
                  subtitle: Text(
                    '最高品质：${entry.highestQualityLabel}\n'
                    '首次获得：${entry.firstLifeTitle}　出现 ${entry.occurrenceCount} 次\n'
                    '对应人生：${entry.lifeTitles.join('、')}',
                  ),
                ),
              ),
          ],
          const ListTile(
            dense: true,
            title: Text(
              '成就与隐藏图鉴',
              style: TextStyle(
                color: Color(0xfff7d77f),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summary.achievements
                  .map(
                    (achievement) => Chip(
                      avatar: Icon(
                        achievement.unlocked
                            ? Icons.verified
                            : Icons.lock_outline,
                        size: 17,
                      ),
                      label: Text(
                        achievement.unlocked ? achievement.name : '未解锁·???',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompendiumCard() {
    final martialSouls = widget.archives
        .expand(
          (state) => <String?>[
            state.character.martialSoul,
            state.character.secondaryMartialSoul,
          ],
        )
        .whereType<String>()
        .toSet();
    final godhoods = widget.archives
        .map((state) => state.character.godhood)
        .whereType<String>()
        .toSet();
    final soulBeasts = widget.archives
        .expand(
          (state) => <SoulRing>[
            ...state.character.soulRings,
            ...state.character.secondarySoulRings,
          ],
        )
        .map((ring) => ring.source)
        .where((name) => name.isNotEmpty)
        .toSet();
    final people = widget.archives
        .expand((state) => state.relationships)
        .map((relationship) => relationship.name)
        .where((name) => name.isNotEmpty)
        .toSet();
    return Card(
      key: const Key('life-compendium'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ExpansionTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: const Text('命运图鉴'),
        subtitle: Text(
          '武魂 ${martialSouls.length}  神位 ${godhoods.length}  '
          '魂兽 ${soulBeasts.length}  人物 ${people.length}',
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(
              <String>[
                if (martialSouls.isNotEmpty) '武魂：${martialSouls.join('、')}',
                if (godhoods.isNotEmpty) '神位：${godhoods.join('、')}',
                if (soulBeasts.isNotEmpty) '魂兽：${soulBeasts.join('、')}',
                if (people.isNotEmpty) '人物：${people.join('、')}',
              ].join('\n'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveList() {
    final archives = _visibleArchives;
    if (widget.archives.isEmpty) {
      return const Center(child: Text('还没有结束的人生档案。'));
    }
    if (archives.isEmpty) return const Center(child: Text('没有符合条件的人生。'));
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: archives.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final state = archives[index];
        final character = state.character;
        return Card(
          child: ListTile(
            key: Key('archive-item-$index'),
            onTap: () => widget.onOpen(state),
            onLongPress: () => _confirmDelete(state),
            leading: Icon(
              state.archiveFavorite ? Icons.star : Icons.auto_stories_outlined,
              color: state.archiveFavorite ? const Color(0xfff7d77f) : null,
            ),
            title: Text(_archiveTitle(state)),
            subtitle: Text(
              '${character.route == RouteType.soulBeast ? '魂兽' : '魂师'}  '
              '${character.era ?? '未知时代'}  ${state.timeline.length} 条记录'
              '${state.archiveLocked ? '  · 已保护' : ''}'
              '${_usesLegacyContent(state) ? '  · 旧内容版本' : ''}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  tooltip: _comparisonSeeds.contains(state.seed)
                      ? '移出对比'
                      : '加入对比',
                  onPressed: () => _toggleComparison(state),
                  icon: Icon(
                    _comparisonSeeds.contains(state.seed)
                        ? Icons.compare_arrows
                        : Icons.add_chart,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: '档案管理',
                  onSelected: (action) => _manageArchive(state, action),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem(value: 'rename', child: Text('修改别名')),
                    PopupMenuItem(
                      value: 'favorite',
                      child: Text(state.archiveFavorite ? '取消收藏' : '收藏档案'),
                    ),
                    PopupMenuItem(
                      value: 'lock',
                      child: Text(state.archiveLocked ? '解除保护' : '保护档案'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('删除档案')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchiveListSection() => Card(
    key: const Key('archive-list-section'),
    margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: ExpansionTile(
      initiallyExpanded: _archiveListExpanded,
      onExpansionChanged: (expanded) {
        if (_archiveListExpanded == expanded) return;
        setState(() => _archiveListExpanded = expanded);
      },
      leading: const Icon(Icons.auto_stories_outlined),
      title: Text('人生记录（${_visibleArchives.length}）'),
      subtitle: Text(
        _visibleArchives.length == widget.archives.length
            ? '点击展开或收起全部已保存人生'
            : '筛选结果 ${_visibleArchives.length}/${widget.archives.length}',
      ),
      children: _archiveListExpanded ? <Widget>[_buildArchiveList()] : const [],
    ),
  );

  String _ringCountLabel(Character character) =>
      character.secondaryMartialSoul == null
      ? '${character.soulRings.length}环'
      : '${character.soulRings.length}+${character.secondarySoulRings.length}环';

  String _archiveTitle(GameState state) =>
      state.archiveAlias?.trim().isNotEmpty == true
      ? state.archiveAlias!.trim()
      : state.ending ?? '未命名人生';

  bool _usesLegacyContent(GameState state) =>
      state.contentFingerprint.isEmpty ||
      state.contentFingerprint != currentContentFingerprint();
}
