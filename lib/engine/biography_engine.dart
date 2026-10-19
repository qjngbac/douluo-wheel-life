import '../domain/models.dart';
import '../domain/presentation_labels.dart';
import 'combat_loadout_engine.dart';
import 'soul_bone_quality.dart';
import 'story_director.dart';

class BiographyEngine {
  const BiographyEngine();

  String compose(GameState state) {
    final character = state.character;
    final identity = <String>[
      if (character.era != null) character.era!,
      if (character.timeline != null) character.timeline!,
      if (character.race != null) character.race!,
    ].join('，');
    final opening =
        '这段人生始于$identity。${character.gender == null ? '' : '你以${character.gender}性的身份来到世间。'}'
        '${character.personality == null ? '' : '性格是${character.personality}，这让许多命运判定走向了不同方向。'}';
    final history = _keyEntries(state.timeline)
        .map(
          (entry) =>
              '${entry.age}岁，${entry.title}：${entry.description}'
              '${sanitizePlayerFacingLines(entry.effects).isEmpty ? '' : '（${sanitizePlayerFacingLines(entry.effects).join('、')}）'}',
        )
        .join('\n\n');
    final rings = character.secondaryMartialSoul != null
        ? '\n\n第一武魂${character.martialSoul ?? '未名武魂'}${_ringCountText(character.soulRings.length)}，'
              '第二武魂${character.secondaryMartialSoul}${_ringCountText(character.secondarySoulRings.length)}，'
              '共${character.soulRings.length + character.secondarySoulRings.length}枚魂环。'
        : character.soulRings.isEmpty
        ? ''
        : '\n\n你最终拥有${character.soulRings.length}枚魂环，其中的魂技与经历都留在了能力档案中。';
    final closest = state.relationships.where((item) => item.alive).toList()
      ..sort((a, b) => b.trust.compareTo(a.trust));
    final bonds = closest.isEmpty
        ? ''
        : '\n\n命运并非独行。与你羁绊最深的是${closest.first.name}'
              '（${playerFacingRelationshipType(closest.first.type)}），信任达到${closest.first.trust}。';
    final godhood = character.godhood == null
        ? ''
        : '\n\n三重神考之后，你凝聚了${character.godhood}，神考评价为${state.godTrialScore}。';
    final route = dominantStoryTheme(character);
    final routeText = route == null ? '' : '\n\n持续发生的选择最终汇成“$route”人生主线。';
    final strongestBones = List<SoulBone>.from(character.soulBones)
      ..sort(
        (left, right) => soulBoneQualityScore(
          right,
          character,
        ).compareTo(soulBoneQualityScore(left, character)),
      );
    final boneText = strongestBones.isEmpty
        ? ''
        : '\n\n最具代表性的魂骨是${strongestBones.first.name}，魂骨技为${strongestBones.first.skillName}。';
    final resources = <String>[
      if (character.goldCoins > 0) '金魂币${goldCoinAmount(character.goldCoins)}',
      if (character.rareMetals > 0) '稀有金属${character.rareMetals}',
      if (character.factionReputation > 0) '势力声望${character.factionReputation}',
      if (character.soulBeastTrust > 0) '魂兽信任${character.soulBeastTrust}',
      if (character.starMerit > 0) '星际功勋${character.starMerit}',
    ];
    final resourceText = resources.isEmpty
        ? ''
        : '\n\n成长途中积累了${resources.join('、')}。';
    final loadout = combatLoadout(character);
    final loadoutText =
        '\n\n最终战斗构筑为强攻${loadout.offense}、防御${loadout.defense}、控制${loadout.control}、机动${loadout.mobility}。';
    return '$opening\n\n$history$rings$bonds$routeText$boneText$resourceText$loadoutText$godhood\n\n最终，你的人生以“${state.ending ?? '命运未明'}”落幕。传记只摘录真实发生的关键节点。';
  }

  String _ringCountText(int count) => count == 9 ? '九环' : '$count环';

  List<TimelineEntry> _keyEntries(List<TimelineEntry> entries) {
    final eligible = entries.where((entry) => entry.age > 0).toList();
    if (eligible.length <= 12) return eligible;
    final selected = <TimelineEntry>[...eligible.take(2)];
    const keyWords = <String>['魂环', '神途', '神考', '结局', '传承', '羁绊', '时代'];
    for (final entry in eligible) {
      if (keyWords.any(
            (word) => entry.stage.contains(word) || entry.title.contains(word),
          ) &&
          !selected.contains(entry)) {
        selected.add(entry);
      }
      if (selected.length >= 9) break;
    }
    for (final entry in eligible.skip(eligible.length - 3)) {
      if (!selected.contains(entry)) selected.add(entry);
    }
    return selected;
  }
}
