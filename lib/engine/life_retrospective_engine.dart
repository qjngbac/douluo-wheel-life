import '../domain/models.dart';

List<String> keyLifeChapters(GameState state) {
  final entries = state.timeline;
  final character = state.character;
  final chapters = <String>[];
  var relationshipChapters = 0;
  var primaryRingIndex = 0;
  var secondaryRingIndex = 0;
  for (var index = 0; index < entries.length; index++) {
    final entry = entries[index];
    if (entry.age <= 0) continue;
    if (entry.stage.contains('武魂觉醒')) {
      final label = entry.stage.startsWith('第一')
          ? '觉醒第一武魂'
          : entry.stage.startsWith('第二')
          ? '觉醒第二武魂'
          : '觉醒武魂';
      _addUnique(chapters, '${entry.age}岁 $label：${entry.title}');
      continue;
    }
    final ringEffect = entry.effects.where(_isObtainedRing).firstOrNull;
    if (ringEffect != null) {
      final ring = ringEffect.replaceFirst(RegExp(r'^.*?获得'), '');
      final target = entry.effects
          .where((effect) => effect.startsWith('附加至'))
          .map((effect) => effect.substring(3))
          .firstOrNull;
      final isSecondary =
          character.secondaryMartialSoul != null &&
          target == character.secondaryMartialSoul;
      final recordedRing = isSecondary
          ? secondaryRingIndex < character.secondarySoulRings.length
                ? character.secondarySoulRings[secondaryRingIndex]
                : null
          : primaryRingIndex < character.soulRings.length
          ? character.soulRings[primaryRingIndex]
          : null;
      if (isSecondary) {
        secondaryRingIndex++;
      } else {
        primaryRingIndex++;
      }
      final source =
          entry.effects
              .where((effect) => effect.startsWith('魂环来源：'))
              .map((effect) => effect.substring('魂环来源：'.length))
              .firstOrNull ??
          recordedRing?.source;
      final recordedPower = entry.effects
          .where((effect) => effect.startsWith('当前魂力'))
          .map((effect) => effect.replaceAll(' ', '').substring(4))
          .firstOrNull;
      final power = isSecondary
          ? '90级后补环'
          : _normalizedRingMilestone(recordedPower);
      String? bone;
      for (var next = index + 1; next < entries.length; next++) {
        final candidate = entries[next];
        if (candidate.age != entry.age) break;
        if (candidate.effects.any(_isObtainedRing)) break;
        bone = candidate.effects
            .where((effect) => effect.startsWith('获得魂骨：'))
            .map((effect) => effect.substring('获得魂骨：'.length))
            .firstOrNull;
        if (bone != null) break;
      }
      _addUnique(
        chapters,
        '${entry.age}岁 '
        '${character.hasTwinMartialSouls && target != null ? '$target武魂' : ''}'
        '获得$ring'
        '${source == null || source.isEmpty ? '' : '（$source）'}'
        '${bone == null ? '' : '，附带$bone'}'
        '${power == null ? '' : '，魂力$power'}',
      );
      continue;
    }
    if (relationshipChapters < 4 &&
        entry.effects.any((effect) => effect.contains('产生交集'))) {
      _addUnique(chapters, '${entry.age}岁 ${entry.title}');
      relationshipChapters++;
      continue;
    }
    if (_isMajorEntry(entry)) {
      _addUnique(chapters, '${entry.age}岁 ${entry.title}');
    }
  }
  return chapters;
}

String? _normalizedRingMilestone(String? recordedPower) {
  final value = int.tryParse(
    RegExp(r'\d+').firstMatch(recordedPower ?? '')?.group(0) ?? '',
  );
  if (value == null) return null;
  return '${((value ~/ 10) * 10).clamp(10, 90)}级';
}

bool _isObtainedRing(String effect) =>
    effect.contains('获得') && effect.contains('魂环') && !effect.contains('没有获得');

bool _isMajorEntry(TimelineEntry entry) {
  final text = '${entry.stage}${entry.title}${entry.effects.join()}';
  return <String>[
        '最终结局',
        '最终命运',
        '神位',
        '神考',
        '遭遇战',
        '击杀',
        '魂灵契约',
        '时代节点',
      ].any(text.contains) ||
      (entry.stage.contains('职业成长') &&
          entry.effects.any((effect) => effect.contains('→')));
}

void _addUnique(List<String> target, String value) {
  if (!target.contains(value)) target.add(value);
}
