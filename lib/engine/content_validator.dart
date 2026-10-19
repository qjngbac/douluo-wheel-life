import '../data/godhood_data.dart';
import '../data/soul_beast_data.dart';
import '../data/soul_beast_life_data.dart';
import '../domain/models.dart';

class ContentIssue {
  const ContentIssue({
    required this.code,
    required this.location,
    required this.message,
  });

  final String code;
  final String location;
  final String message;
}

const Set<String> _allowedEffectKeys = <String>{
  'age',
  'rate',
  'flat',
  'beastRate',
  'soulPower',
  'luck',
  'injury',
  'death',
  'ringCapacity',
  'recovery',
  'beastYears',
  'beastBloodline',
  'beastIntelligence',
  'beastTerritory',
  'beastPrestige',
  'humanThreat',
  'beastBond',
  'beastClan',
  'beastResources',
  'beastEnemyPressure',
  'goldCoins',
  'rareMetals',
  'factionReputation',
  'soulBeastTrust',
  'starMerit',
};

List<ContentIssue> validateGameData(GameData data) {
  final issues = <ContentIssue>[];
  final seenPoolIds = <String>{};
  final seenIds = <String>{};
  final normalBeastActions = buildSoulBeastActionPool(
    Character(route: RouteType.soulBeast),
  );
  final remnantActions = buildSoulBeastActionPool(
    Character(route: RouteType.soulBeast, beastPath: '献祭残魂'),
  );
  final beastDestinies = buildSoulBeastDestinyPool(
    Character(route: RouteType.soulBeast),
  );
  final reachableTags = <RouteType, Set<String>>{
    RouteType.human: <String>{'genius', '谨慎求生', '孤儿', '双武魂互补', '双武魂冲突', '武魂融合'},
    RouteType.soulBeast: <String>{
      'genius',
      '谨慎求生',
      '孤儿',
      ...normalBeastActions.options.map((option) => '当前行动：${option.text}'),
      ...remnantActions.options.map((option) => '当前行动：${option.text}'),
      ...beastDestinies.options.map(
        (option) =>
            '魂兽命途:${switch (option.id) {
              'beast-path-shape' => '魂兽化形',
              'beast-path-contract' => '契约魂灵',
              'beast-path-sacrifice' => '献祭残魂',
              'beast-path-god' => '兽神候选',
              _ => '荒野兽身',
            }}',
      ),
    },
  };
  final requirements = <({String location, String tag, RouteType? route})>[];
  final producers =
      <({List<String> tags, List<String> requires, RouteType? route})>[];
  final arcEvents = <String, List<StoryEvent>>{};

  for (final entry in data.pools.entries) {
    final pool = entry.value;
    if (entry.key != pool.id) {
      issues.add(
        ContentIssue(
          code: 'pool_key_mismatch',
          location: 'pool:${entry.key}',
          message: '转盘映射键“${entry.key}”与转盘 ID“${pool.id}”不一致',
        ),
      );
    }
    if (!seenPoolIds.add(pool.id)) {
      issues.add(
        ContentIssue(
          code: 'duplicate_pool_id',
          location: 'pool:${entry.key}',
          message: '转盘 ID“${pool.id}”重复',
        ),
      );
    }
    if (pool.options.isEmpty) {
      issues.add(
        ContentIssue(
          code: 'empty_pool',
          location: 'pool:${pool.id}',
          message: '转盘“${pool.title}”没有选项',
        ),
      );
    }
    for (final option in pool.options) {
      final location = 'pool:${pool.id}/option:${option.id}';
      _validateId(seenIds, option.id, location, issues);
      _validateWeight(option.weight, location, issues);
      _validateEffects(option.effects, location, issues);
      for (final tag in option.requiredTags) {
        requirements.add((location: location, tag: tag, route: option.route));
      }
      final producedTag = switch (pool.id) {
        'era' => 'era:${option.id}',
        'faction' => 'faction:${option.id}',
        'mentor' => 'mentor:${option.id}',
        'personality' => '性格:${option.id}',
        'godhoodEvent' => '神途:${option.id}',
        _ => null,
      };
      if (producedTag != null) {
        producers.add((
          tags: <String>[producedTag],
          requires: option.requiredTags,
          route: option.route,
        ));
      }
    }
  }

  if (data.events.isEmpty) {
    issues.add(
      const ContentIssue(
        code: 'empty_pool',
        location: 'pool:life',
        message: '人生事件转盘没有选项',
      ),
    );
  }
  for (final event in data.events) {
    final location = 'event:${event.id}';
    _validateId(seenIds, event.id, location, issues);
    _validateWeight(event.weight, location, issues);
    _validateEffects(event.effects, location, issues);
    producers.add((
      tags: event.addTags,
      requires: event.requiredTags,
      route: event.route,
    ));
    if (event.arcId != null) {
      arcEvents.putIfAbsent(event.arcId!, () => <StoryEvent>[]).add(event);
    }
    for (final tag in event.requiredTags) {
      requirements.add((location: location, tag: tag, route: event.route));
    }
  }

  var changed = true;
  while (changed) {
    changed = false;
    for (final producer in producers) {
      for (final route in _contentRoutes(producer.route)) {
        final reachable = reachableTags[route]!;
        if (!producer.requires.every(reachable.contains)) continue;
        for (final tag in producer.tags) {
          if (reachable.add(tag)) changed = true;
        }
      }
    }
  }

  for (final entry in arcEvents.entries) {
    final events = entry.value
      ..sort((a, b) => a.arcStage.compareTo(b.arcStage));
    final stages = events.map((event) => event.arcStage).toSet();
    final maximumStage = stages.isEmpty
        ? 0
        : stages.reduce((a, b) => a > b ? a : b);
    final valid =
        maximumStage > 0 &&
        List<int>.generate(
          maximumStage,
          (index) => index + 1,
        ).every(stages.contains);
    if (!valid) {
      issues.add(
        ContentIssue(
          code: 'invalid_arc_sequence',
          location: 'arc:${entry.key}',
          message: '连续剧情必须从第 1 阶段开始且不得跳级或重复',
        ),
      );
    }
    for (var index = 1; index < events.length; index++) {
      final previous = events[index - 1];
      final current = events[index];
      if (current.maxAge < previous.minAge) {
        issues.add(
          ContentIssue(
            code: 'invalid_arc_window',
            location: 'arc:${entry.key}/stage:${current.arcStage}',
            message: '后续剧情的最晚年龄早于前一阶段的最早年龄',
          ),
        );
      }
      if (previous.route != null &&
          current.route != null &&
          previous.route != current.route) {
        issues.add(
          ContentIssue(
            code: 'invalid_arc_route',
            location: 'arc:${entry.key}/stage:${current.arcStage}',
            message: '同一连续剧情不能在互斥路线之间切换',
          ),
        );
      }
    }
  }

  for (final requirement in requirements) {
    final canReach = _contentRoutes(
      requirement.route,
    ).any((route) => reachableTags[route]!.contains(requirement.tag));
    if (!canReach) {
      issues.add(
        ContentIssue(
          code: 'unproducible_required_tag',
          location: requirement.location,
          message: '前置标签“${requirement.tag}”无法由当前内容产出',
        ),
      );
    }
  }
  return issues;
}

Iterable<RouteType> _contentRoutes(RouteType? route) =>
    route == RouteType.human || route == RouteType.soulBeast
    ? <RouteType>[route!]
    : const <RouteType>[RouteType.human, RouteType.soulBeast];

List<ContentIssue> validateSoulBeastProfiles(
  Iterable<SoulBeastProfile> profiles,
) {
  final issues = <ContentIssue>[];
  final ids = <String>{};
  final names = <String>{};
  for (final profile in profiles) {
    final location = 'soul-beast:${profile.id}';
    if (!ids.add(profile.id) || !names.add(profile.name)) {
      issues.add(
        ContentIssue(
          code: 'duplicate_soul_beast',
          location: location,
          message: '魂兽 ID 或名称重复',
        ),
      );
    }
    _validateWeight(profile.weight, location, issues);
    if (profile.minRing < 1 ||
        profile.maxRing > 9 ||
        profile.minRing > profile.maxRing) {
      issues.add(
        ContentIssue(
          code: 'invalid_ring_range',
          location: location,
          message: '魂兽适用魂环序号必须位于 1 到 9',
        ),
      );
    }
    if (profile.quality < 1 || profile.quality > 7) {
      issues.add(
        ContentIssue(
          code: 'invalid_quality',
          location: location,
          message: '魂兽品质必须位于 1 到 7',
        ),
      );
    }
    final lower = profile.specialYearsLower;
    final upper = profile.specialYearsUpper;
    if ((lower != null && lower < 1) ||
        (upper != null && upper < (lower ?? 1))) {
      issues.add(
        ContentIssue(
          code: 'invalid_year_range',
          location: location,
          message: '特殊魂环年限区间不正确',
        ),
      );
    }
  }
  return issues;
}

List<ContentIssue> validateGodhoodProfiles(
  Iterable<GodhoodPathProfile> profiles,
) {
  final issues = <ContentIssue>[];
  final ids = <String>{};
  final names = <String>{};
  for (final profile in profiles) {
    final location = 'godhood:${profile.id}';
    if (!ids.add(profile.id)) {
      issues.add(
        ContentIssue(
          code: 'duplicate_godhood',
          location: location,
          message: '神途 ID 重复',
        ),
      );
    }
    _validateWeight(profile.weight, location, issues);
    for (final name in <String>[
      profile.sovereignName,
      profile.majorName,
      profile.minorName,
      profile.planeName,
    ]) {
      if (name.trim().isEmpty || !names.add(name)) {
        issues.add(
          ContentIssue(
            code: 'invalid_godhood_name',
            location: location,
            message: '神位名称为空或重复：$name',
          ),
        );
      }
    }
  }
  return issues;
}

void _validateId(
  Set<String> seenIds,
  String id,
  String location,
  List<ContentIssue> issues,
) {
  if (!seenIds.add(id)) {
    issues.add(
      ContentIssue(
        code: 'duplicate_id',
        location: location,
        message: '内容 ID“$id”重复',
      ),
    );
  }
}

void _validateWeight(
  double weight,
  String location,
  List<ContentIssue> issues,
) {
  if (!weight.isFinite || weight <= 0) {
    issues.add(
      ContentIssue(
        code: 'non_positive_weight',
        location: location,
        message: '权重必须是正数，当前为 $weight',
      ),
    );
  }
}

void _validateEffects(
  Map<String, int> effects,
  String location,
  List<ContentIssue> issues,
) {
  for (final key in effects.keys) {
    if (!_allowedEffectKeys.contains(key)) {
      issues.add(
        ContentIssue(
          code: 'unknown_effect',
          location: location,
          message: '效果键“$key”未被规则引擎支持',
        ),
      );
    }
  }
}
