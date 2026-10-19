import '../data/creation_data.dart';
import '../data/character_name_data.dart';
import '../data/era_data.dart';
import '../data/era_milestone_data.dart';
import '../data/godhood_data.dart';
import '../data/soul_beast_data.dart';
import '../data/soul_beast_life_data.dart';
import '../data/soul_spirit_data.dart';
import '../data/story_data.dart';
import '../data/technology_event_data.dart';
import '../domain/models.dart';
import '../domain/presentation_labels.dart';
import 'combat_loadout_engine.dart';
import 'content_fingerprint.dart';
import 'career_growth_engine.dart';
import 'life_identity_engine.dart';
import 'godhood_engine.dart';
import 'godhood_trial_engine.dart';
import 'ending_engine.dart';
import 'relationship_legacy_engine.dart';
import 'encounter_engine.dart';
import 'invitation_engine.dart';
import 'probability_explainer.dart';
import 'ring_engine.dart';
import 'seeded_random.dart';
import 'soul_beast_progression.dart';
import 'soul_beast_archetype.dart';
import 'soul_bone_engine.dart';
import 'soul_bone_quality.dart';
import 'story_director.dart';
import 'technology_asset_engine.dart';
import 'twin_martial_soul_engine.dart';
import 'weighted_picker.dart';

class GameEngine {
  static const int _maximumLifeEvents = 120;
  static const int _maximumWheelChoices = 15;
  static const int _maximumSoulBeastChoices = 15;
  static const StoryEvent _fallbackMeditationEvent = StoryEvent(
    id: 'story-fallback-meditation',
    title: '静心潜修',
    description: '斗罗大陆风云渐平，你于天地造化中冥思静坐，沉淀一身修为。',
    weight: 10,
    effects: <String, int>{'insight': 1},
  );

  GameEngine({required GameData data})
    : data = data.pools.isEmpty
          ? GameData(
              pools: buildCreationPools(),
              events: buildStoryEvents(),
              forceRoute: data.forceRoute,
            )
          : data,
      _ringEngine = const RingEngine();

  factory GameEngine.production() => GameEngine(
    data: GameData(pools: buildCreationPools(), events: buildStoryEvents()),
  );

  final GameData data;
  final RingEngine _ringEngine;
  late final String contentFingerprint = computeContentFingerprint(data);

  ProbabilityBreakdown probabilityBreakdownFor(
    GameState state,
    WheelPool pool,
    WheelOption option,
  ) {
    final baseWeight = baseWeightFor(state, pool.id, option.id);
    final total = pool.options.fold<double>(
      0,
      (sum, item) => sum + item.weight,
    );
    final ratio = baseWeight <= 0 ? 1.0 : option.weight / baseWeight;
    final reasons = <String>[
      if (pool.id == 'life') '性格、经历、关系与事件阶段共同参与本次判定',
      if (pool.id == 'encounterOutcome') '双方综合实力与当前伤势直接改变胜负分布',
      if (pool.id == 'ringCandidate' || pool.id == 'ringOutcome')
        '猎魂方式、契合度与承受上限共同参与本次判定',
      if (pool.id.startsWith('soulBone')) '魂环年份、特殊颜色、既有部位与吸收风险共同参与判定',
      if (pool.id.startsWith('soulSpirit')) '所处时代、武魂契合、魂灵品质与双方羁绊共同参与判定',
      if (pool.id == 'godhoodEvent' ||
          pool.id == 'godhoodTrial' ||
          pool.id == 'godhoodOutcome')
        '神途、魂环、经历与羁绊共同参与本次判定',
      if (state.invitationMode) '本局强化提高优质结果，同时保留普通与风险结果',
      if (ratio > 1.01) '当前因果提高了这一结果的出现倾向',
      if (ratio < .99) '当前因果降低了这一结果的出现倾向',
    ];
    if (reasons.isEmpty) reasons.add('当前没有额外因果影响');
    return ProbabilityBreakdown(
      baseWeight: baseWeight,
      finalWeight: option.weight,
      finalProbability: total <= 0 ? 0 : option.weight / total,
      reasons: reasons,
    );
  }

  double baseWeightFor(GameState state, String poolId, String optionId) {
    if (poolId == 'life') {
      return data.events
              .where((event) => event.id == optionId)
              .firstOrNull
              ?.weight ??
          1;
    }
    final dynamicPool = switch (poolId) {
      'ending' => _endingPool(state),
      'encounterOutcome' => buildEncounterOutcomePool(state),
      'martialSoul' => _martialSoulAwakeningPool(state),
      'primaryMartialSoul' => _concreteMartialSoulPool(state, secondary: false),
      'secondaryMartialSoul' => _concreteMartialSoulPool(
        state,
        secondary: true,
      ),
      'characterName' => _characterNamePool(state),
      'careerGrowth' => buildCareerGrowthPool(state.character),
      'ringTarget' => _ringTargetPool(state),
      'ringMethod' => _ringMethodPool(state),
      'soulSpiritCandidate' => soulSpiritCandidatePool(state),
      'soulSpiritOutcome' =>
        state.pendingSoulSpirit == null
            ? null
            : soulSpiritOutcomePool(state.pendingSoulSpirit!, state.character),
      'soulSpiritGrant' => soulSpiritGrantPool(state.character),
      'soulBoneDrop' =>
        state.pendingSoulBoneRing == null
            ? null
            : soulBoneDropPool(state.pendingSoulBoneRing!, eligible: true),
      'soulBoneSlot' =>
        state.pendingSoulBoneRing == null
            ? null
            : soulBoneSlotPool(state.character, state.pendingSoulBoneRing!),
      'soulBoneOutcome' =>
        state.pendingSoulBone == null
            ? null
            : soulBoneOutcomePool(state.character, state.pendingSoulBone!),
      'godhoodTrial' => buildGodhoodTrialPool(state),
      'beastMilestone' => _beastMilestonePool(state.character),
      'beastAction' => buildSoulBeastActionPool(state.character),
      'beastDestiny' => buildSoulBeastDestinyPool(state.character),
      'technologyDisposal' => () {
        final asset = state.character.technologyAssets
            .where((asset) => asset.id == state.pendingTechnologyAssetId)
            .firstOrNull;
        return asset == null
            ? null
            : WheelPool(
                id: 'technologyDisposal',
                title: '科技资产报废决策',
                options: technologyDisposalOptions(asset),
              );
      }(),
      'eraMilestone' =>
        eraMilestones
            .where((item) => item.id == state.pendingEraMilestoneId)
            .map(
              (item) => WheelPool(
                id: 'eraMilestone',
                title: item.title,
                options: item.options,
              ),
            )
            .firstOrNull,
      _ => data.pools[poolId],
    };
    return dynamicPool?.options
            .where((option) => option.id == optionId)
            .firstOrNull
            ?.weight ??
        1;
  }

  GameState newLife(String seed) {
    final random = SeededRandom.fromSeed(seed);
    return GameState(
      seed: seed,
      randomState: random.state,
      contentFingerprint: contentFingerprint,
    );
  }

  WheelPool? currentWheel(GameState state) {
    final poolId = state.currentPoolId;
    if (state.isFinished || poolId == null) return null;
    if (poolId == 'life') return _withInvitation(state, _lifePool(state));
    if (poolId == 'martialSoul') {
      return _withInvitation(
        state,
        _finalizedPool(_martialSoulAwakeningPool(state), state),
      );
    }
    if (poolId == 'encounterOutcome') {
      return _withInvitation(state, buildEncounterOutcomePool(state));
    }
    if (poolId == 'ending') {
      return _withInvitation(state, _finalizedPool(_endingPool(state), state));
    }
    if (poolId == 'eraMilestone') {
      final milestone = eraMilestones
          .where((item) => item.id == state.pendingEraMilestoneId)
          .firstOrNull;
      if (milestone == null) return null;
      return _withInvitation(
        state,
        _finalizedPool(
          WheelPool(
            id: 'eraMilestone',
            title: milestone.title,
            options: milestone.options,
          ),
          state,
        ),
      );
    }
    if (poolId == 'beastMilestone') {
      return _withInvitation(
        state,
        _finalizedPool(_beastMilestonePool(state.character), state),
      );
    }
    if (poolId == 'beastAction') {
      return _withInvitation(
        state,
        _finalizedPool(buildSoulBeastActionPool(state.character), state),
      );
    }
    if (poolId == 'beastDestiny') {
      return _withInvitation(
        state,
        _finalizedPool(buildSoulBeastDestinyPool(state.character), state),
      );
    }
    if (poolId == 'primaryMartialSoul' || poolId == 'secondaryMartialSoul') {
      return _withInvitation(
        state,
        _finalizedPool(
          _concreteMartialSoulPool(
            state,
            secondary: poolId == 'secondaryMartialSoul',
          ),
          state,
        ),
      );
    }
    if (poolId == 'characterName') return _characterNamePool(state);
    if (poolId == 'careerGrowth') {
      return _withInvitation(state, buildCareerGrowthPool(state.character));
    }
    if (poolId == 'ringTarget') {
      return _ringTargetPool(state);
    }
    if (poolId == 'ringCandidate') {
      final source = data.pools[poolId];
      if (source == null) return null;
      return _withInvitation(
        state,
        _finalizedPool(_ringCandidatePool(source, state), state),
      );
    }
    if (poolId == 'ringMethod') {
      final pool = _ringMethodPool(state);
      return _withInvitation(
        state,
        _finalizedPool(
          WheelPool(
            id: pool.id,
            title: pool.title,
            options: _availableOptions(pool, state),
          ),
          state,
        ),
      );
    }
    if (poolId == 'soulSpiritCandidate') {
      return _withInvitation(state, soulSpiritCandidatePool(state));
    }
    if (poolId == 'soulSpiritOutcome') {
      final spirit = state.pendingSoulSpirit;
      if (spirit == null) return null;
      return _withInvitation(
        state,
        soulSpiritOutcomePool(spirit, state.character),
      );
    }
    if (poolId == 'soulSpiritGrant') {
      final pool = soulSpiritGrantPool(state.character);
      return pool.options.isEmpty ? null : _withInvitation(state, pool);
    }
    if (poolId == 'soulBoneDrop') {
      final ring = state.pendingSoulBoneRing;
      if (ring == null) return null;
      return _withInvitation(state, soulBoneDropPool(ring, eligible: true));
    }
    if (poolId == 'soulBoneSlot') {
      final ring = state.pendingSoulBoneRing;
      if (ring == null) return null;
      return _withInvitation(state, soulBoneSlotPool(state.character, ring));
    }
    if (poolId == 'soulBoneOutcome') {
      final bone = state.pendingSoulBone;
      if (bone == null) return null;
      return _withInvitation(state, soulBoneOutcomePool(state.character, bone));
    }
    if (poolId == 'technologyDisposal') {
      final id = state.pendingTechnologyAssetId;
      final asset = state.character.technologyAssets
          .where((item) => item.id == id)
          .firstOrNull;
      if (asset == null) return null;
      return WheelPool(
        id: 'technologyDisposal',
        title: '科技资产报废决策',
        options: technologyDisposalOptions(asset),
      );
    }
    if (poolId == 'godhoodEvent') {
      final source = data.pools[poolId];
      if (source == null) return null;
      return _withInvitation(state, _godhoodPathPool(source, state));
    }
    if (poolId == 'godhoodTrial') {
      return _withInvitation(state, buildGodhoodTrialPool(state));
    }
    final source = poolId == 'timeline'
        ? _timelinePool(state)
        : data.pools[poolId];
    if (source == null) return null;
    return _withInvitation(
      state,
      _finalizedPool(
        WheelPool(
          id: source.id,
          title: source.title,
          options: _availableOptions(source, state),
        ),
        state,
      ),
    );
  }

  WheelPool _withInvitation(GameState state, WheelPool pool) =>
      state.invitationMode ? invitationPool(pool) : pool;

  WheelPool _characterNamePool(GameState state) {
    final configured = data.pools['characterName'];
    if (configured != null &&
        !configured.options.any((option) => option.id == 'name-generated')) {
      return configured;
    }
    return buildCharacterNamePool(
      gender: state.character.gender,
      seed: state.seed,
    );
  }

  WheelPool _concreteMartialSoulPool(
    GameState state, {
    required bool secondary,
  }) {
    final source = data.pools['martialSoul'];
    if (source == null) throw StateError('缺少武魂觉醒选项');
    final available = source.options
        .where(
          (option) =>
              option.id != 'soul-double' &&
              option.id != 'soul-mutate' &&
              (!secondary || option.text != state.character.martialSoul),
        )
        .toList(growable: false);
    return WheelPool(
      id: secondary ? 'secondaryMartialSoul' : 'primaryMartialSoul',
      title: secondary ? '第二武魂觉醒' : '第一武魂觉醒',
      options: _sampleMartialSouls(
        available,
        state,
        salt: secondary ? 'secondary' : 'primary',
        limit: _maximumWheelChoices,
      ),
    );
  }

  WheelPool _martialSoulAwakeningPool(GameState state) {
    final source = data.pools['martialSoul'];
    if (source == null) throw StateError('缺少武魂觉醒选项');
    final selected = _sampleMartialSouls(
      source.options,
      state,
      salt: 'awakening',
      limit: _maximumWheelChoices,
    );
    return WheelPool(id: source.id, title: source.title, options: selected);
  }

  List<WheelOption> _sampleMartialSouls(
    List<WheelOption> source,
    GameState state, {
    required String salt,
    required int limit,
  }) {
    if (source.length <= limit) return source;
    final remaining = List<WheelOption>.from(source);
    final random = SeededRandom.fromSeed(
      '${state.seed}|martial-soul|$salt|${state.character.martialSoul ?? ''}',
    );
    final selected = <WheelOption>[];
    while (selected.length < limit) {
      selected.add(remaining.removeAt(random.nextInt(remaining.length)));
    }
    return selected;
  }

  WheelPool _ringTargetPool(GameState state) {
    final character = state.character;
    if (!character.hasTwinMartialSouls) {
      throw StateError('单武魂角色不应进入魂环归属判定');
    }
    final primaryFull = character.soulRings.length >= 9;
    final secondaryFull = character.secondarySoulRings.length >= 9;
    return WheelPool(
      id: 'ringTarget',
      title: '选择魂环归属',
      options: <WheelOption>[
        if (!primaryFull)
          WheelOption(
            id: 'ring-target-primary',
            text: '第一武魂·${character.martialSoul}',
            weight: secondaryFull ? 1 : 80,
          ),
        if (!secondaryFull && character.soulRings.length >= 5)
          WheelOption(
            id: 'ring-target-secondary',
            text: '第二武魂·${character.secondaryMartialSoul}',
            weight: primaryFull ? 1 : 20,
          ),
      ],
    );
  }

  WheelPool _ringMethodPool(GameState state) {
    final source = data.pools['ringMethod'];
    if (source == null) throw StateError('缺少魂环获取方式');
    return WheelPool(
      id: source.id,
      title: source.title,
      options: <WheelOption>[
        ...source.options,
        if (soulSpiritSystemAvailable(state.character))
          ...soulSpiritMethodOptions,
      ],
    );
  }

  Character _ringCharacter(GameState state) {
    final character = state.character;
    if (state.pendingRingTarget != MartialSoulSlot.secondary) return character;
    final target = character.copy()
      ..martialSoul = character.secondaryMartialSoul
      ..soulRings = List<SoulRing>.from(character.secondarySoulRings);
    return target;
  }

  int _ringNumberFor(GameState state) {
    final ownRingNumber = _ringCharacter(state).soulRings.length + 1;
    if (state.pendingRingTarget != MartialSoulSlot.secondary) {
      return ownRingNumber.clamp(1, 9);
    }
    final cultivationTier = state.character.soulRings.length + 1;
    return (ownRingNumber > cultivationTier ? ownRingNumber : cultivationTier)
        .clamp(1, 9);
  }

  WheelPool _ringCandidatePool(WheelPool source, GameState state) {
    final ringCharacter = _ringCharacter(state);
    final ringNumber = _ringNumberFor(state);
    final available = soulBeastOptionsForRing(
      _availableOptions(source, state),
      ringNumber,
    );
    final unlockedSpecials = available
        .where((option) => option.requiredTags.isNotEmpty)
        .toList(growable: false);
    final legendary = available
        .where(
          (option) =>
              option.requiredTags.isEmpty &&
              (soulBeastProfileForId(option.id)?.quality ?? 0) >= 5,
        )
        .toList(growable: false);
    if (available.length <= _maximumSoulBeastChoices) {
      return WheelPool(id: source.id, title: source.title, options: available);
    }
    final random = SeededRandom.fromSeed(
      '${state.seed}|ring-candidates|${state.pendingRingTarget?.name}|$ringNumber|${state.randomState}|v${state.rngVersion}',
    );
    final selected = _shuffled(unlockedSpecials, random).take(10).toList();
    selected.addAll(_shuffled(legendary, random).take(3));
    final selectedIds = selected.map((option) => option.id).toSet();
    final contextual =
        available.where((option) => !selectedIds.contains(option.id)).toList()
          ..sort((a, b) {
            double score(WheelOption option) {
              final profile = soulBeastProfileForId(option.id);
              return option.weight *
                  (profile == null
                      ? 1
                      : soulBeastContextMultiplier(
                          profile,
                          ringCharacter,
                          state.pendingHunt,
                        ));
            }

            return score(b).compareTo(score(a));
          });
    selected.addAll(contextual.take(5));
    selectedIds.addAll(selected.map((option) => option.id));
    final remaining = _shuffled(
      available.where((option) => !selectedIds.contains(option.id)).toList(),
      random,
    );
    selected.addAll(remaining.take(_maximumSoulBeastChoices - selected.length));
    return WheelPool(id: source.id, title: source.title, options: selected);
  }

  WheelPool _godhoodPathPool(WheelPool source, GameState state) {
    final options = _availableOptions(source, state)
        .map(
          (option) => WheelOption(
            id: option.id,
            text: option.text,
            weight: _adjustedWeight(source.id, option, state),
            requiredTags: option.requiredTags,
            forbiddenTags: option.forbiddenTags,
          ),
        )
        .toList();
    final twinPaths =
        options
            .where((option) => option.id.startsWith('god-path-twin-'))
            .toList()
          ..sort((a, b) => b.weight.compareTo(a.weight));
    final unlockedSpecials =
        options
            .where(
              (option) =>
                  option.requiredTags.isNotEmpty &&
                  !option.id.startsWith('god-path-twin-'),
            )
            .toList()
          ..sort((a, b) => b.weight.compareTo(a.weight));
    final ordinary =
        options.where((option) => option.requiredTags.isEmpty).toList()
          ..sort((a, b) => b.weight.compareTo(a.weight));
    final selected = <WheelOption>[...twinPaths, ...unlockedSpecials];
    final remainingSlots = (_maximumWheelChoices - selected.length)
        .clamp(0, _maximumWheelChoices)
        .toInt();
    selected.addAll(ordinary.take(remainingSlots));
    return WheelPool(
      id: source.id,
      title: source.title,
      options: selected.take(_maximumWheelChoices).toList(growable: false),
    );
  }

  List<T> _shuffled<T>(List<T> source, SeededRandom random) {
    final result = List<T>.from(source);
    for (var index = result.length - 1; index > 0; index--) {
      final other = random.nextInt(index + 1);
      final value = result[index];
      result[index] = result[other];
      result[other] = value;
    }
    return result;
  }

  WheelPool _finalizedPool(WheelPool pool, GameState state) => WheelPool(
    id: pool.id,
    title: pool.title,
    options: pool.options
        .map(
          (option) => WheelOption(
            id: option.id,
            text: option.text,
            weight: _adjustedWeight(pool.id, option, state),
            minAge: option.minAge,
            maxAge: option.maxAge,
            route: option.route,
            requiredTags: option.requiredTags,
            forbiddenTags: option.forbiddenTags,
            effects: option.effects,
          ),
        )
        .toList(growable: false),
  );

  WheelPool _timelinePool(GameState state) {
    final profile = profileForEraId(state.character.eraId);
    final source = data.pools['timeline']!;
    return WheelPool(
      id: source.id,
      title: source.title,
      options: source.options
          .map(
            (option) => WheelOption(
              id: option.id,
              text: timelineLabelFor(option.id, profile),
              weight: option.weight,
              minAge: option.minAge,
              maxAge: option.maxAge,
              route: option.route,
              requiredTags: option.requiredTags,
              forbiddenTags: option.forbiddenTags,
              effects: option.effects,
            ),
          )
          .toList(growable: false),
    );
  }

  GameState advance(GameState current) {
    if (current.isFinished) return current.copy();
    final state = current.copy();
    final pool = currentWheel(state);
    if (pool == null) {
      throw StateError('当前人生没有可执行的命运阶段');
    }

    final options = _availableOptions(pool, state);
    final random = SeededRandom.fromState(state.randomState);
    final selected = pickWeighted(
      options
          .map(
            (option) =>
                Weighted<WheelOption>(value: option, weight: option.weight),
          )
          .toList(growable: false),
      random,
    );

    if (pool.id == 'life') {
      _applyStory(state, selected, pool, random);
    } else {
      _applyPoolChoice(state, selected, pool, random);
    }
    state.randomState = random.state;
    return state;
  }

  GameState simulateToEnd(String seed) {
    var state = newLife(seed);
    for (var turn = 0; turn < 900 && !state.isFinished; turn++) {
      state = advance(state);
    }
    if (!state.isFinished) {
      throw StateError('人生在预期步骤内没有结束');
    }
    return state;
  }

  List<WheelOption> _availableOptions(WheelPool pool, GameState state) {
    final character = state.character;
    return pool.options
        .where((option) {
          if (option.route != null && option.route != character.route) {
            return false;
          }
          if (character.age < option.minAge || character.age > option.maxAge) {
            return false;
          }
          if (!character.tags.toSet().containsAll(option.requiredTags)) {
            return false;
          }
          if (option.forbiddenTags.any(character.tags.contains)) return false;
          if (pool.id == 'race' && data.forceRoute != null) {
            final isBeast =
                option.id.contains('beast') || option.id == 'race-unknown';
            return data.forceRoute == RouteType.soulBeast ? isBeast : !isBeast;
          }
          if (pool.id == 'innatePower') {
            final power = _innatePowerFromOption(option.id);
            final band = _innatePowerBand(character.talent);
            if (power != null && (power < band.min || power > band.max)) {
              return false;
            }
          }
          return true;
        })
        .toList(growable: false);
  }

  double _adjustedWeight(String poolId, WheelOption option, GameState state) {
    var multiplier = 1.0;
    final character = state.character;
    if ((poolId == 'martialSoul' ||
            poolId == 'primaryMartialSoul' ||
            poolId == 'secondaryMartialSoul') &&
        (character.talent == '绝世' ||
            character.talent == '妖孽' ||
            character.talent == '神级潜质')) {
      if (option.id == 'soul-double' || option.id == 'soul-special') {
        multiplier *= 4;
      }
      if (option.id == 'soul-mutate') multiplier *= 2;
    }
    if (poolId == 'innatePower') {
      final power = _innatePowerFromOption(option.id);
      if (power != null) {
        final preferred = _innatePowerBand(character.talent).preferred;
        final distance = (power - preferred).abs();
        multiplier *= switch (distance) {
          0 => 3,
          1 => 1.75,
          2 => .9,
          _ => .45,
        };
      }
    }
    if (poolId == 'ringMethod') {
      if (character.family?.contains('魂师') ?? false) {
        if (option.id == 'ring-family' || option.id == 'ring-academy') {
          multiplier *= 2;
        }
      }
      if (character.tags.contains('导师赏识') && option.id == 'ring-academy') {
        multiplier *= 2;
      }
      if (character.tags.contains('谨慎求生') && option.id == 'ring-alone') {
        multiplier *= .55;
      }
    }
    if (poolId == 'ringCandidate') {
      final ringCharacter = _ringCharacter(state);
      final profile = soulBeastProfileForId(option.id);
      final affinity = profile == null
          ? 1.0
          : soulBeastContextMultiplier(
              profile,
              ringCharacter,
              state.pendingHunt,
            );
      final methodAffinity = state.pendingHunt?.affinityMultiplier ?? 1;
      multiplier *= 1 + (affinity - 1) * methodAffinity;
    }
    if (poolId == 'godhoodEvent') {
      multiplier *= godhoodPathMultiplier(option.id, character);
    }
    if (poolId == 'ringOutcome') {
      multiplier *= _ringOutcomeMultiplier(option.id, state);
    }
    if (poolId == 'cultivationGrowth') {
      if (character.tags.contains('性格:personality-stubborn') &&
          (option.id == 'training-diligent' ||
              option.id == 'training-breakthrough')) {
        multiplier *= 1.55;
      }
      if (character.tags.contains('性格:personality-scholar') &&
          option.id == 'training-insight') {
        multiplier *= 1.7;
      }
      if (character.tags.contains('性格:personality-careful') &&
          option.id == 'training-steady') {
        multiplier *= 1.35;
      }
      if (character.tags.contains('性格:personality-hot') &&
          option.id == 'training-miracle') {
        multiplier *= 1.5;
      }
    }
    if (poolId == 'godhoodOutcome') {
      final divinity = calculateDivinityScore(character);
      final trialFactor = (state.godTrialScore / 9).clamp(-.25, 1.5);
      if (option.id.startsWith('god-success')) {
        multiplier *= 1 + divinity / 45 + trialFactor;
        if (character.tags.contains('神考资格')) multiplier *= 1.25;
      }
      if (option.id.startsWith('god-success-sovereign-')) {
        final readiness = divinity / maximumDivinityScore;
        multiplier *= readiness * readiness;
      }
      if (option.id == 'god-fall') {
        multiplier *= (1.35 - divinity / 120 - trialFactor / 2).clamp(.12, 1.5);
      }
    }
    return option.weight * multiplier;
  }

  WheelPool _lifePool(GameState state) {
    final character = state.character;
    final protagonistYear = protagonistYearFor(character);
    final eligibleEvents = data.events
        .where((event) {
          if (event.route != null && event.route != character.route) {
            return false;
          }
          if (character.age < event.minAge || character.age > event.maxAge) {
            return false;
          }
          if (event.eraIds.isNotEmpty &&
              !event.eraIds.contains(character.eraId)) {
            return false;
          }
          if (protagonistYear < event.minProtagonistYear ||
              protagonistYear > event.maxProtagonistYear) {
            return false;
          }
          if (character.soulPower < event.minSoulPower ||
              character.beastYears < event.minBeastYears) {
            return false;
          }
          if (character.route == RouteType.soulBeast &&
              character.beastPath == '献祭残魂' &&
              !event.requiredTags.contains('魂兽命途:献祭残魂')) {
            return false;
          }
          if (!_relationshipRequirementMet(event, state)) return false;
          if (!canAffordStoryEvent(event, character)) return false;
          return character.tags.toSet().containsAll(event.requiredTags) &&
              !event.forbiddenTags.any(character.tags.contains) &&
              (event.repeatLimit <= 0 ||
                  (state.eventCounts[event.id] ?? 0) < event.repeatLimit) &&
              (state.cooldownUntilAge[event.id] ?? 0) <= character.age &&
              (event.arcId == null ||
                  event.arcStage == (state.arcStages[event.arcId!] ?? 0) + 1);
        })
        .toList(growable: false);
    final availableEvents = eligibleEvents.isNotEmpty
        ? eligibleEvents
        : const <StoryEvent>[_fallbackMeditationEvent];
    final weightedEvents = availableEvents
        .map(
          (event) => WheelOption(
            id: event.id,
            text: event.title,
            weight: event.weight * _eventWeight(event, state),
            effects: event.effects,
          ),
        )
        .toList(growable: false);
    var anchorIds = const <String>{};
    if (state.invitationMode) {
      final strengthened = invitationPool(
        WheelPool(id: 'life', title: '人生事件', options: weightedEvents),
      );
      final highest = strengthened.options
          .map((option) => option.weight)
          .reduce((a, b) => a > b ? a : b);
      anchorIds = strengthened.options
          .where((option) => option.weight == highest)
          .map((option) => option.id)
          .toSet();
    }
    final previewRandom = SeededRandom.fromSeed(
      '${state.seed}|life-preview|${state.randomState}|v${state.rngVersion}',
    );
    final sampledEvents = availableEvents
        .where((event) => anchorIds.contains(event.id))
        .take(3)
        .toList();
    final sampledIds = sampledEvents.map((event) => event.id).toSet();
    final remaining = availableEvents
        .where((event) => !sampledIds.contains(event.id))
        .toList();
    while (sampledEvents.length < _maximumWheelChoices &&
        remaining.isNotEmpty) {
      sampledEvents.add(
        remaining.removeAt(previewRandom.nextInt(remaining.length)),
      );
    }
    final options = sampledEvents
        .map(
          (event) => WheelOption(
            id: event.id,
            text: event.title,
            weight: event.weight * _eventWeight(event, state),
            effects: event.effects,
          ),
        )
        .toList(growable: false);
    return WheelPool(id: 'life', title: '人生事件', options: options);
  }

  bool _relationshipRequirementMet(StoryEvent event, GameState state) {
    final id = event.relationshipId;
    final hasRestriction =
        event.minRelationshipTrust > 0 ||
        event.maxRelationshipTrust < 100 ||
        event.relationshipMustBeAlive;
    if (id == null || !hasRestriction) return true;
    final relationship = state.relationships
        .where((item) => item.id == id)
        .firstOrNull;
    if (relationship == null) return false;
    if (event.relationshipMustBeAlive && !relationship.alive) return false;
    return relationship.trust >= event.minRelationshipTrust &&
        relationship.trust <= event.maxRelationshipTrust;
  }

  double _eventWeight(StoryEvent event, GameState state) {
    var weight = 1.0;
    final character = state.character;
    final personality = personalityTraitFromTags(character.tags);
    if (personality != null &&
        event.favoredPersonalities.contains(personality)) {
      weight *= 2;
    }
    if (personality != null &&
        event.conflictingPersonalities.contains(personality)) {
      weight *= .65;
    }
    if (event.arcId?.startsWith('beast-crisis-') ?? false) {
      if (event.arcStage == 2 && event.id.endsWith('-prepared')) {
        weight *= (.6 + character.beastResources / 50).clamp(.65, 2.2);
      }
      if (event.arcStage == 2 && event.id.endsWith('-sacrifice')) {
        weight *= (.7 + character.beastEnemyPressure / 50).clamp(.7, 2.0);
      }
    }
    if (character.luck > 6 && event.effects['luck'] != null) weight *= 1.25;
    if (character.tags.contains('秘境线索') && event.title.contains('遗迹')) {
      weight *= 1.7;
    }
    if (character.tags.contains('导师赏识') && event.title.contains('导师')) {
      weight *= 1.8;
    }
    if (character.route == RouteType.soulBeast &&
        character.tags.contains('人类警觉') &&
        event.title.contains('猎魂')) {
      weight *= .7;
    }
    if (character.route == RouteType.soulBeast) {
      final dangerous =
          (event.effects['injury'] ?? 0) > 0 ||
          (event.effects['humanThreat'] ?? 0) > 3 ||
          (event.effects['beastTerritory'] ?? 0) < 0;
      if (dangerous) weight *= 1 + character.humanThreat / 80;
      if (event.relationshipName != null) {
        weight *= 1 + character.beastBond / 120;
      }
      if ((event.effects['beastTerritory'] ?? 0) > 0) {
        weight *= 1 + character.beastTerritory / 180;
      }
      if (dangerous) weight *= 1 + character.beastEnemyPressure / 90;
      if ((event.effects['beastResources'] ?? 0) > 0 &&
          character.beastResources < 35) {
        weight *= 1.35;
      }
    }
    final hostileRival = state.relationships.any(
      (item) => item.alive && item.type == '宿敌' && item.trust < 30,
    );
    if (hostileRival &&
        ((event.effects['injury'] ?? 0) > 0 ||
            (event.effects['death'] ?? 0) > 0)) {
      weight *= 1.2;
    }
    return weight * storyDirectorMultiplier(event, state);
  }

  WheelPool _endingPool(GameState state) {
    final character = state.character;
    if (character.route == RouteType.soulBeast) {
      final options = <WheelOption>[
        const WheelOption(
          id: 'end-beast-survivor',
          text: '避过围猎延续漫长生命',
          weight: 22,
        ),
        WheelOption(
          id: 'end-beast-lord',
          text: '统御领地成为一方兽王',
          weight:
              8 +
              character.beastTerritory / 5 +
              character.beastResources / 12 -
              character.beastEnemyPressure / 18,
        ),
        WheelOption(
          id: 'end-beast-clan',
          text: '守护族群留下血脉传承',
          weight:
              7 +
              character.beastPrestige / 5 +
              character.beastClanPopulation / 8,
        ),
        WheelOption(
          id: 'end-beast-shape',
          text: '化形成人行走魂师世界',
          weight: character.beastPath == '魂兽化形' ? 28 : 0,
        ),
        WheelOption(
          id: 'end-beast-bridge',
          text: '成为人类与魂兽的桥梁',
          weight: character.beastPath == '魂兽化形'
              ? 5 + character.beastBond / 4
              : 0,
        ),
        WheelOption(
          id: 'end-beast-contract',
          text: '与契约伙伴共同踏上神途',
          weight: character.beastPath == '契约魂灵'
              ? 8 + character.beastBond / 3
              : 0,
        ),
        WheelOption(
          id: 'end-beast-rebirth',
          text: '残魂重塑血肉获得新生',
          weight: character.beastPath == '献祭残魂'
              ? 5 + character.beastBloodlinePower / 5
              : 0,
        ),
        WheelOption(
          id: 'end-beast-coexist',
          text: '以灵魂形态永伴宿主左右',
          weight: character.beastPath == '献祭残魂'
              ? 8 + character.beastBond / 3
              : 0,
        ),
        WheelOption(
          id: 'end-beast-god',
          text: '凝聚万兽信仰成就兽神',
          weight: character.beastPath == '兽神候选'
              ? 3 + character.beastPrestige / 4
              : 0,
        ),
        WheelOption(
          id: 'end-beast-fall',
          text: '在时代洪流中重伤陨落',
          weight: 5 + character.beastEnemyPressure / 8,
        ),
      ].where((option) => option.weight > 0).toList(growable: false);
      return WheelPool(id: 'ending', title: '魂兽最终命运', options: options);
    }
    final powerful = character.route == RouteType.soulBeast
        ? character.beastYears >= 100000 || character.tags.contains('极限突破')
        : character.soulPower >= 60 || character.tags.contains('极限突破');
    final options = <WheelOption>[
      const WheelOption(id: 'end-peace', text: '平凡而完整的一生', weight: 26),
      const WheelOption(id: 'end-achievement', text: '小有成就的魂师人生', weight: 28),
      WheelOption(id: 'end-strong', text: '名动一方的强者', weight: powerful ? 26 : 8),
      WheelOption(
        id: 'end-legend',
        text: '留下传说的巅峰道路',
        weight: powerful ? 9 : 1,
      ),
      WheelOption(
        id: 'end-beast',
        text: '守住一方领地的兽中王者',
        weight: character.route == RouteType.soulBeast ? 25 : 0,
      ),
      const WheelOption(id: 'end-regret', text: '遗憾落幕的人生', weight: 12),
    ];
    return WheelPool(id: 'ending', title: '最终结局', options: options);
  }

  void _applyPoolChoice(
    GameState state,
    WheelOption choice,
    WheelPool pool,
    SeededRandom random,
  ) {
    final character = state.character;
    state.latestCauses = _causalNotes(pool.id, character);
    final effects = <String>[
      ...state.latestCauses,
      ..._effectText(choice.effects),
    ];
    var description = choice.text;

    switch (pool.id) {
      case 'era':
        character.eraId = choice.id;
        character.era = choice.text;
        character.tags.add('era:${choice.id}');
        state.currentPoolId = 'timeline';
      case 'timeline':
        character.timeline = choice.text;
        character.protagonistOffset = timelineOffsetForId(choice.id);
        character.tags.add('timeline:${choice.id}');
        state.currentPoolId = 'gender';
      case 'gender':
        character.gender = choice.text;
        state.currentPoolId = 'characterName';
      case 'characterName':
        character.characterName = choice.text;
        character.tags.add('name:${choice.id}');
        state.currentPoolId = 'appearance';
      case 'appearance':
        character.appearance = choice.text;
        state.currentPoolId = 'race';
      case 'race':
        character.race = choice.text;
        character.route = choice.id.contains('human')
            ? RouteType.human
            : RouteType.soulBeast;
        if (character.route == RouteType.human &&
            character.lifeExpectancy == 0) {
          character.lifeExpectancy = 88 + random.nextInt(31);
        }
        state.currentPoolId = 'personality';
        effects.add(
          character.route == RouteType.human ? '进入人类成长路线' : '进入魂兽成长路线',
        );
      case 'personality':
        character.personality = choice.text;
        character.tags.add('性格:${choice.id}');
        if (personalityTraitFromTags(character.tags) ==
            PersonalityTrait.careful) {
          character.tags.add('谨慎求生');
        }
        state.currentPoolId = 'aspiration';
      case 'aspiration':
        character.aspiration = choice.text;
        character.tags.add('aspiration:${choice.id}');
        state.currentPoolId = character.route == RouteType.human
            ? 'family'
            : 'beastSpecies';
      case 'family':
        character.family = choice.text;
        if (choice.id == 'family-orphan') character.tags.add('孤儿');
        state.currentPoolId = 'constitution';
      case 'constitution':
        character.constitution = choice.text;
        state.currentPoolId = 'spirit';
      case 'spirit':
        character.spirit = choice.text;
        state.currentPoolId = 'talent';
      case 'talent':
        character.talent = choice.text;
        if (choice.id == 'talent-genius' ||
            choice.id == 'talent-god' ||
            choice.id == 'talent-rare') {
          character.tags.add('genius');
        }
        state.currentPoolId = character.route == RouteType.human
            ? 'martialSoul'
            : 'eventCount';
      case 'martialSoul':
        if (choice.id == 'soul-double') {
          character.tags.add('双生武魂');
          character.martialSoul = null;
          character.secondaryMartialSoul = null;
          character.soulRings.clear();
          character.secondarySoulRings.clear();
          description = '你觉醒了两个武魂，它们将分别决定两条魂环道路。';
          effects.add('接下来分别判定第一武魂与第二武魂');
          state.currentPoolId = 'primaryMartialSoul';
        } else {
          character.martialSoul = choice.text;
          character.secondaryMartialSoul = null;
          character.secondarySoulRings.clear();
          character.age = 6;
          state.currentPoolId = 'innatePower';
        }
      case 'primaryMartialSoul':
        character.martialSoul = choice.text;
        state.currentPoolId = 'secondaryMartialSoul';
      case 'secondaryMartialSoul':
        character.secondaryMartialSoul = choice.text;
        applyTwinMartialSoulAwakening(character);
        final twinEffect = effectForCharacter(character)!;
        effects
          ..add('${twinEffect.tag}：${twinEffect.title}')
          ..add('融合魂技潜质：${twinEffect.fusionSkill}');
        description = twinEffect.description;
        character.age = 6;
        state.currentPoolId = 'innatePower';
      case 'innatePower':
        character.innatePower = choice.id == 'power-10'
            ? 10
            : int.tryParse(choice.id.substring('power-'.length)) ?? 0;
        character.soulPower = character.innatePower!;
        character.age = 6;
        state.currentPoolId = 'faction';
      case 'faction':
        character.faction = choice.text;
        character.tags.add('faction:${choice.id}');
        state.currentPoolId = 'mentor';
      case 'mentor':
        character.mentor = choice.text;
        character.tags.add('mentor:${choice.id}');
        if (character.soulPower >= 10) {
          state.pendingRingTarget = MartialSoulSlot.primary;
          state.currentPoolId = 'ringMethod';
        } else {
          state.currentPoolId = 'eventCount';
        }
      case 'beastSpecies':
        character.martialSoul = choice.text;
        final archetype = soulBeastArchetypeFor(choice.text);
        character.beastArchetype = soulBeastArchetypeName(archetype);
        character.tags.add('魂兽种族:${character.beastArchetype}');
        _applyEffects(character, soulBeastInitialEffects(archetype));
        effects
          ..add('种族：${character.beastArchetype}')
          ..add(soulBeastTalentDescription(archetype));
        state.currentPoolId = 'beastBloodline';
      case 'beastBloodline':
        character.family = choice.text;
        character.beastBloodlinePower = switch (choice.id) {
          'blood-royal' => 75,
          'blood-ancient' => 60,
          'blood-pure' => 45,
          'blood-normal' => 30,
          _ => 18,
        };
        if (choice.id == 'blood-ancient' || choice.id == 'blood-royal') {
          character.tags.add('genius');
        }
        state.currentPoolId = 'beastHabitat';
      case 'beastHabitat':
        character.timeline = choice.text;
        character.beastHabitat = choice.text;
        character.beastTerritory = choice.id == 'home-deep' ? 20 : 12;
        state.currentPoolId = 'beastCultivation';
      case 'beastCultivation':
        character.age = switch (choice.id) {
          'cultivation-new' => 1,
          'cultivation-100' => 100,
          'cultivation-1000' => 1000,
          'cultivation-10000' => 1000,
          _ => 1000,
        };
        character.beastYears = switch (choice.id) {
          'cultivation-new' => 10,
          'cultivation-100' => 100,
          'cultivation-1000' => 1000,
          'cultivation-10000' => 10000,
          _ => 90000,
        };
        character.soulPower = 0;
        character.lifeStartAge = character.age;
        character.beastIntelligence = switch (choice.id) {
          'cultivation-new' => 8,
          'cultivation-100' => 16,
          'cultivation-1000' => 28,
          'cultivation-10000' => 44,
          _ => 62,
        };
        state.currentPoolId = 'constitution';
      case 'eventCount':
        state.batchResults.clear();
        state.pendingLifeEvents =
            int.tryParse(choice.id.substring('events-'.length)) ?? 1;
        description = '本轮将连续经历 ${state.pendingLifeEvents} 次人生事件。';
        effects.add('连续转动 ${state.pendingLifeEvents} 次人生事件');
        state.currentPoolId = 'life';
      case 'ageGrowth':
        effects
          ..clear()
          ..addAll(_applyAgeGrowth(state, choice));
        if (character.route == RouteType.soulBeast &&
            isSoulBeastAgeWindowComplete(character)) {
          state.currentPoolId = 'ending';
          description = '三十年主角时代已经走到终点，你积累的领地、羁绊与命途将共同决定最终结局。';
          effects.add('魂兽主线历经 ${character.age - character.lifeStartAge} 年');
        } else if (character.route == RouteType.human &&
            character.lifeExpectancy > 0 &&
            character.age >= character.lifeExpectancy) {
          character.status = LifeStatus.ended;
          state.ending = '寿终正寝';
          state.isFinished = true;
          state.currentPoolId = null;
          description = '你走完了属于自己的岁月，在亲友与往事中安然长眠。';
          effects.add('寿命达到 ${character.lifeExpectancy} 岁');
        } else {
          state.currentPoolId = hasCareerGrowth(character)
              ? 'careerGrowth'
              : 'cultivationGrowth';
        }
      case 'careerGrowth':
        effects
          ..clear()
          ..addAll(applyCareerGrowth(character, choice));
        description = '岁月推进后，你对既有职业道路进行了一次阶段性检验。';
        state.currentPoolId = 'cultivationGrowth';
      case 'cultivationGrowth':
        effects
          ..clear()
          ..addAll(_applyCultivationGrowth(state, choice));
        description = character.route == RouteType.soulBeast
            ? '经过${state.pendingYears}年的吐纳与蜕变，魂兽修为得到独立结算。'
            : '经过${state.pendingYears}年的修行，天赋、性格与既有积累共同决定了成果。';
        state.pendingYears = 0;
        state.currentPoolId = _nextStageAfterCultivation(state);
      case 'beastAction':
        character.tags.removeWhere((tag) => tag.startsWith('当前行动：'));
        character.tags.add('当前行动：${choice.text}');
        _applyEffects(character, choice.effects);
        effects
          ..clear()
          ..addAll(_effectText(choice.effects, route: character.route));
        if (choice.id == 'beast-action-migrate') {
          character.beastHabitat = switch (character.beastArchetype) {
            '植物系' => '远古灵脉林',
            '龙族' => '隐龙地脉',
            '精神系' => '迷雾幻境',
            '海魂兽' => '远海隐秘珊瑚带',
            _ => '群山隐秘兽谷',
          };
          effects.add('迁徙至${character.beastHabitat}');
        }
        description = '你选择${choice.text}，这会改变接下来可能发生的事件。';
        state.currentPoolId = 'eventCount';
      case 'beastDestiny':
        character.tags.removeWhere((tag) => tag.startsWith('魂兽命途:'));
        character.beastPath = switch (choice.id) {
          'beast-path-shape' => '魂兽化形',
          'beast-path-contract' => '契约魂灵',
          'beast-path-sacrifice' => '献祭残魂',
          'beast-path-god' => '兽神候选',
          _ => '荒野兽身',
        };
        character.tags
          ..add('魂兽命途已定')
          ..add('魂兽命途:${character.beastPath}');
        _applyEffects(character, choice.effects);
        effects
          ..clear()
          ..add('命途：${character.beastPath}')
          ..addAll(_effectText(choice.effects, route: character.route));
        description = character.beastPath == '献祭残魂'
            ? '你自愿把力量交给可信之人，却以完整残魂留在魂环之中；这段人生并未结束。'
            : '你选择${choice.text}，此后的事件与结局将沿着${character.beastPath}展开。';
        state.currentPoolId = 'beastAction';
      case 'ringMethod':
        state.pendingRingTarget ??= MartialSoulSlot.primary;
        if (choice.id.startsWith('ring-spirit-')) {
          state.pendingSoulSpiritMethodId = choice.id;
          state.latestCauses = <String>['当前时代已开放魂灵体系，选择“${choice.text}”替代猎杀魂兽'];
          effects
            ..clear()
            ..addAll(state.latestCauses);
          description = '魂灵契约会同时赋予魂环，并可能在未来继续赐环。';
          state.currentPoolId = 'soulSpiritCandidate';
          break;
        }
        state.pendingHunt = _huntContextFor(choice);
        state.latestCauses = <String>[
          '选择“${choice.text}”：${_huntMethodReason(state.pendingHunt!)}',
        ];
        effects
          ..clear()
          ..addAll(state.latestCauses);
        description = '${choice.text}会同时影响候选魂兽的契合度与吸收风险。';
        state.currentPoolId = 'ringCandidate';
      case 'soulSpiritCandidate':
        final methodId = state.pendingSoulSpiritMethodId;
        if (methodId == null) throw StateError('魂灵候选阶段缺少获取方式');
        final contract = createSoulSpiritContract(
          profileId: choice.id,
          ringNumber: _ringNumberFor(state),
          methodId: methodId,
          character: _ringCharacter(state),
          invitationMode: state.invitationMode,
          random: random,
        );
        state.pendingSoulSpirit = contract.spirit;
        state.pendingRing = contract.ring;
        effects
          ..clear()
          ..add('候选魂灵：${contract.spirit.name}')
          ..add('契约年份：${contract.spirit.years}年')
          ..add('可继续赐环：${contract.spirit.remainingRingGrants}次');
        description = contract.spirit.description;
        state.currentPoolId = 'soulSpiritOutcome';
      case 'soulSpiritOutcome':
        _resolveSoulSpiritOutcome(state, choice, effects);
        description = '你与魂灵完成灵魂契约，彼此将共同成长并承担后果。';
      case 'soulSpiritGrant':
        _resolveSoulSpiritGrant(state, choice, effects, random);
        description = '既有魂灵回应魂力瓶颈，以自身本源赐予新的魂环。';
      case 'ringCandidate':
        final ringCharacter = _ringCharacter(state);
        state.pendingRing = _ringEngine.createRing(
          character: ringCharacter,
          source: choice.text,
          random: random,
          invitationMode: state.invitationMode,
          ringNumber: _ringNumberFor(state),
        );
        final hunt = state.pendingHunt;
        if (hunt != null) {
          state.pendingHunt = HuntContext(
            methodId: hunt.methodId,
            methodName: hunt.methodName,
            riskMultiplier: hunt.riskMultiplier,
            affinityMultiplier: hunt.affinityMultiplier,
            candidateSource: choice.text,
            habitat: hunt.habitat,
          );
        }
        state.latestCauses = _ringCandidateCauses(state, choice);
        effects
          ..clear()
          ..addAll(state.latestCauses);
        description =
            '${choice.text}与${ringCharacter.martialSoul ?? '当前道路'}产生契合。';
        state.currentPoolId = 'ringOutcome';
      case 'ringTarget':
        state.pendingRingTarget = choice.id == 'ring-target-secondary'
            ? MartialSoulSlot.secondary
            : MartialSoulSlot.primary;
        final targetName = character.martialSoulFor(state.pendingRingTarget!);
        description = '这枚魂环将附加至$targetName。';
        effects.add('魂环归属：$targetName');
        state.currentPoolId = 'ringMethod';
      case 'ringOutcome':
        final ring = state.pendingRing;
        state.latestCauses = _ringOutcomeCauses(state);
        effects
          ..clear()
          ..addAll(state.latestCauses);
        _resolveRingOutcome(state, choice, effects);
        description = _ringOutcomeDescription(choice.text, ring);
      case 'soulBoneDrop':
        final ring = state.pendingSoulBoneRing;
        if (ring == null) throw StateError('魂骨判定阶段缺少来源魂环');
        if (choice.id == 'bone-drop-found') {
          description = '${ring.source}的遗骨中凝聚出一块魂骨，接下来判定形成部位。';
          effects
            ..clear()
            ..add('发现${ring.years}年魂骨')
            ..add('来源：${ring.source}');
          state.currentPoolId = 'soulBoneSlot';
        } else {
          description = '${ring.source}的力量已完整汇入魂环，没有留下魂骨。';
          effects
            ..clear()
            ..add('本次未形成魂骨');
          state.pendingSoulBoneRing = null;
          state.currentPoolId = _nextStageAfterCultivation(state);
        }
      case 'soulBoneSlot':
        final ring = state.pendingSoulBoneRing;
        if (ring == null) throw StateError('魂骨部位阶段缺少来源魂环');
        final slot = soulBoneSlotForOption(choice.id);
        state.pendingSoulBone = createSoulBone(
          ring: ring,
          slot: slot,
          random: random,
        );
        description = '魂骨最终凝聚为${soulBoneSlotName(slot)}，其中蕴藏着独立魂骨技。';
        effects
          ..clear()
          ..add('魂骨部位：${soulBoneSlotName(slot)}')
          ..add('魂骨名称：${state.pendingSoulBone!.name}');
        state.currentPoolId = 'soulBoneOutcome';
      case 'soulBoneOutcome':
        final bone = state.pendingSoulBone;
        if (bone == null) throw StateError('魂骨吸收阶段缺少候选魂骨');
        _resolveSoulBoneOutcome(state, choice, bone, effects);
        description = '你对${bone.name}作出选择，魂骨技“${bone.skillName}”的命运就此确定。';
      case 'godhoodEvent':
        character.tags.add('神途:${choice.id}');
        state.pendingGodPathId = choice.id;
        state.godTrialStep = 0;
        state.godTrialScore = 0;
        character.divinityScore = calculateDivinityScore(character);
        state.latestCauses = godhoodPathReasons(choice.id, character);
        effects
          ..clear()
          ..addAll(state.latestCauses);
        description = '百级之后，${choice.text}成为你最后一段命运道路。';
        state.currentPoolId = 'godhoodTrial';
      case 'godhoodTrial':
        final score = choice.effects['trialScore'] ?? 0;
        state.godTrialScore += score;
        _applyEffects(character, choice.effects);
        state.godTrialStep++;
        effects
          ..clear()
          ..add('神考评价 ${score >= 0 ? '+' : ''}$score')
          ..add('累计神考评价 ${state.godTrialScore}');
        description =
            '你在第${state.godTrialStep}重神考中选择“${choice.text}”，这会直接影响最终神位结局。';
        if (state.godTrialStep < 3) {
          state.currentPoolId = 'godhoodTrial';
        } else {
          character.tags.add('三重神考完成:${state.pendingGodPathId}');
          state.currentPoolId = 'godhoodOutcome';
        }
      case 'godhoodOutcome':
        _resolveGodhood(state, choice, effects);
        description = _godhoodDescription(choice.id, character.godhood);
      case 'eraMilestone':
        final milestone = eraMilestones.firstWhere(
          (item) => item.id == state.pendingEraMilestoneId,
        );
        _applyEffects(character, choice.effects);
        state.triggeredEraMilestones.add(milestone.id);
        if (milestone.id == 'd2-spirit-birth') {
          character.tags.add('魂灵体系解锁');
        }
        state.pendingEraMilestoneId = null;
        state.latestCauses = <String>[
          '主角纪年到达${milestone.protagonistYear}年，触发“${milestone.title}”',
        ];
        effects
          ..clear()
          ..addAll(state.latestCauses)
          ..addAll(_effectText(choice.effects, route: character.route));
        description = '${milestone.description}\n你选择了${choice.text}。';
        state.currentPoolId = character.route == RouteType.soulBeast
            ? 'beastAction'
            : 'eventCount';
      case 'beastMilestone':
        final milestone = state.pendingBeastMilestone;
        _applyEffects(character, choice.effects);
        character.tags.add('血脉蜕变：${choice.text}');
        character.soulPower = 0;
        character.soulRings.clear();
        character.beastMilestone = milestone;
        state.pendingBeastMilestone = null;
        state.latestCauses = <String>[
          '魂兽修为跨越${_beastMilestoneLabel(milestone)}，触发血脉蜕变',
        ];
        effects
          ..clear()
          ..addAll(state.latestCauses)
          ..addAll(_effectText(choice.effects, route: character.route));
        description = '漫长积累引发血脉蜕变，你选择${choice.text}稳固新的境界。';
        state.currentPoolId = 'beastAction';
      case 'encounterOutcome':
        _resolveEncounter(state, choice, effects);
        description = state.latestResult ?? choice.text;
      case 'technologyDisposal':
        description = _resolveTechnologyDisposal(state, choice, effects);
      case 'ending':
        state.ending = personalizedEnding(state, choice.text);
        state.isFinished = true;
        state.currentPoolId = null;
        character.status = LifeStatus.ended;
      default:
        throw StateError('未知命运阶段：${pool.id}');
    }

    _record(state, pool.title, choice.text, description, effects);
  }

  void _applyStory(
    GameState state,
    WheelOption choice,
    WheelPool pool,
    SeededRandom random,
  ) {
    final event =
        data.events.where((item) => item.id == choice.id).firstOrNull ??
        _fallbackMeditationEvent;
    final character = state.character;
    final immediateEffects = Map<String, int>.from(event.effects);
    final insight = character.route == RouteType.human
        ? (immediateEffects['soulPower'] ?? 0).clamp(0, 1000000)
        : 0;
    if (insight > 0) {
      character.cultivationInsight += insight;
      immediateEffects.remove('soulPower');
    }
    _applyEffects(character, immediateEffects);
    final beastGrowth = character.route == RouteType.soulBeast
        ? _beastCultivationFromEvent(event, random)
        : 0;
    character.beastYears += beastGrowth;
    for (final tag in event.addTags) {
      if (!character.tags.contains(tag)) character.tags.add(tag);
    }
    state.eventCounts[event.id] = (state.eventCounts[event.id] ?? 0) + 1;
    if (event.cooldownYears > 0) {
      state.cooldownUntilAge[event.id] = character.age + event.cooldownYears;
    }
    if (event.arcId != null && event.arcStage > 0) {
      state.arcStages[event.arcId!] = event.arcStage;
    }
    recordStoryDirection(state, event);
    _applyRelationshipEvent(state, event);
    _recordRelationshipLegacy(state);
    final technologyEffect = _applyTechnologyReward(character, event.id);
    final rescueEffect = _tryRelationshipRescue(state, event);
    state.lifeEventCount++;
    state.pendingLifeEvents = (state.pendingLifeEvents - 1).clamp(0, 8).toInt();
    final effects = <String>[
      ..._effectText(
        event.effects,
        route: character.route,
        positiveSoulPowerIsInsight: character.route == RouteType.human,
      ),
      if (beastGrowth > 0) '修为 +$beastGrowth 年',
      if (event.relationshipName != null) '与${event.relationshipName}产生交集',
      ...technologyEffect,
    ];
    if (rescueEffect != null) effects.add(rescueEffect);
    state.latestTitle = event.title;
    state.latestResult = event.description;
    state.latestEffects = effects;
    state.batchResults.add(
      BatchResult(
        title: event.title,
        result: event.description,
        age: character.age,
        effects: effects,
      ),
    );
    state.timeline.add(
      TimelineEntry(
        age: character.age,
        stage: pool.title,
        title: event.title,
        description: event.description,
        effects: effects,
      ),
    );
    if (character.status == LifeStatus.dead) {
      state.ending = '意外陨落';
      state.isFinished = true;
      state.currentPoolId = null;
      return;
    }
    if (event.encounter != null) {
      final encounter = event.encounter!;
      state.pendingEncounter = PendingEncounter(
        eventId: event.id,
        opponentId: encounter.opponentId,
        opponentName: encounter.opponentName,
        type: encounter.type,
        opponentPower: encounter.opponentPower,
        resumePoolId: state.pendingLifeEvents > 0 ? 'life' : 'ageGrowth',
      );
      state.currentPoolId = 'encounterOutcome';
      return;
    }
    if (state.pendingLifeEvents > 0) {
      state.currentPoolId = 'life';
    } else {
      state.currentPoolId = 'ageGrowth';
    }
  }

  List<String> _applyTechnologyReward(Character character, String eventId) {
    final reward = technologyRewardForEvent(eventId);
    if (reward == null) return const <String>[];
    character.soulEngineerLevel =
        (character.soulEngineerLevel + reward.soulEngineerDelta).clamp(0, 10);
    character.starCommandLevel =
        (character.starCommandLevel + reward.starCommandDelta).clamp(0, 10);
    if (reward.battleArmorStage != null) {
      character.battleArmorStage = reward.battleArmorStage;
    }
    if (reward.mechaRank != null) character.mechaRank = reward.mechaRank;
    final asset = reward.asset;
    if (asset != null &&
        !character.technologyAssets.any((item) => item.id == asset.id)) {
      character.technologyAssets = character.technologyAssets
          .map(
            (item) =>
                item.type == asset.type ? item.copyWith(equipped: false) : item,
          )
          .toList();
      character.technologyAssets.add(asset.copyWith(equipped: true));
    }
    final effects = <String>[
      if (asset != null) '获得${technologyTypeName(asset.type)}：${asset.name}',
      if (reward.soulEngineerDelta > 0) '魂导师能力 +${reward.soulEngineerDelta}',
      if (reward.battleArmorStage != null) '斗铠阶段：${reward.battleArmorStage}',
      if (reward.mechaRank != null) '机甲等级：${reward.mechaRank}',
      if (reward.starCommandDelta > 0) '星战指挥 +${reward.starCommandDelta}',
    ];
    if (reward.soulBoneRepair > 0 && character.soulBones.isNotEmpty) {
      character.soulBones = List<SoulBone>.from(character.soulBones);
      final indexed = character.soulBones.indexed.reduce(
        (left, right) => left.$2.integrity <= right.$2.integrity ? left : right,
      );
      final bone = indexed.$2;
      final integrity = (bone.integrity + reward.soulBoneRepair).clamp(0, 100);
      character.soulBones[indexed.$1] = bone.copyWith(integrity: integrity);
      effects.add('${bone.name}修复至 $integrity% 完整度');
    }
    if (reward.technologyRepair > 0 && character.technologyAssets.isNotEmpty) {
      character.technologyAssets = List<TechnologyAsset>.from(
        character.technologyAssets,
      );
      final repairable = character.technologyAssets.indexed
          .where((item) => !item.$2.memorial)
          .toList();
      if (repairable.isEmpty) return effects;
      final indexed = repairable.reduce(
        (left, right) => left.$2.integrity <= right.$2.integrity ? left : right,
      );
      final target = indexed.$2;
      final integrity = (target.integrity + reward.technologyRepair).clamp(
        0,
        100,
      );
      character.technologyAssets[indexed.$1] = target.copyWith(
        integrity: integrity,
      );
      effects.add('${target.name}修复至 $integrity% 完整度');
    }
    if (reward.technologyUpgrade > 0 &&
        character.technologyAssets.any((asset) => !asset.memorial)) {
      character.technologyAssets = List<TechnologyAsset>.from(
        character.technologyAssets,
      );
      final index = character.technologyAssets.indexWhere(
        (asset) => asset.equipped && !asset.memorial,
      );
      final targetIndex = index >= 0
          ? index
          : character.technologyAssets.indexWhere((asset) => !asset.memorial);
      final target = character.technologyAssets[targetIndex];
      final upgraded = upgradedTechnologyAsset(target);
      character.technologyAssets[targetIndex] = upgraded;
      effects.add('${target.name}升级至 +${upgraded.upgradeLevel}');
    }
    return effects;
  }

  void _applyRelationshipEvent(GameState state, StoryEvent event) {
    final id = event.relationshipId;
    final name = event.relationshipName;
    if (id == null || name == null) return;
    final existing = state.relationships.where((item) => item.id == id);
    final relationship = existing.isEmpty
        ? Relationship(
            id: id,
            name: name,
            type: event.relationshipType,
            trust: state.character.route == RouteType.soulBeast ? 30 : 0,
          )
        : existing.first;
    if (existing.isEmpty) state.relationships.add(relationship);
    relationship.trust = (relationship.trust + event.trustDelta)
        .clamp(0, 100)
        .toInt();
    relationship.affection = (relationship.affection + event.affectionDelta)
        .clamp(0, 100)
        .toInt();
    if (!relationship.sharedEvents.contains(event.title)) {
      relationship.sharedEvents.add(event.title);
    }
  }

  void _recordRelationshipLegacy(GameState state) {
    final legacy = relationshipLegacyFor(state);
    final skill = legacy.skillName;
    if (skill == null) return;
    final prefix = legacy.kind == RelationshipLegacyKind.ally ? '组合魂技' : '宿敌战技';
    final tag = '$prefix：$skill';
    if (!state.character.tags.contains(tag)) state.character.tags.add(tag);
  }

  String? _tryRelationshipRescue(GameState state, StoryEvent event) {
    if (state.character.status != LifeStatus.dead ||
        (event.effects['death'] ?? 0) <= 0 ||
        state.character.tags.any((tag) => tag.startsWith('羁绊救援:'))) {
      return null;
    }
    final rescuers =
        state.relationships
            .where((item) => item.alive && item.trust >= 70)
            .toList()
          ..sort((a, b) => b.trust.compareTo(a.trust));
    if (rescuers.isEmpty) return null;
    final rescuer = rescuers.first;
    state.character.status = LifeStatus.injured;
    state.character.injuryTurns = 4;
    rescuer.trust = (rescuer.trust - 25).clamp(0, 100).toInt();
    rescuer.sharedEvents.add('生死救援');
    state.character.tags.add('羁绊救援:${rescuer.id}');
    return '${rescuer.name}以深厚羁绊救下了你，自己也付出了代价';
  }

  void _resolveEncounter(
    GameState state,
    WheelOption choice,
    List<String> effects,
  ) {
    final pending = state.pendingEncounter;
    if (pending == null) throw StateError('遭遇判定缺少对手信息');
    final loadout = combatLoadout(state.character);
    final ownPower = characterCombatPower(state.character);
    final resolution = encounterResolution(choice.id, pending);
    state.latestCauses = <String>[
      '你的综合实力约为 $ownPower，对方约为 ${pending.opponentPower}',
      '战斗构筑：强攻${loadout.offense}、防御${loadout.defense}、控制${loadout.control}、机动${loadout.mobility}',
      ...loadout.reasons.take(2),
      if (state.character.injuryTurns > 0) '既有伤势降低了正面对抗的胜算',
      pending.type == EncounterType.cooperation
          ? '双方实力总和影响合作成功率'
          : '双方实力差影响胜负、重伤与击杀概率',
    ];
    effects
      ..clear()
      ..addAll(state.latestCauses);
    if (resolution.injuryTurns > 0) {
      state.character.status = LifeStatus.injured;
      state.character.injuryTurns = resolution.injuryTurns;
      effects.add('受到伤势，预计 ${resolution.injuryTurns} 个阶段恢复');
    }
    if (resolution.luckDelta != 0) {
      state.character.luck = (state.character.luck + resolution.luckDelta)
          .clamp(-20, 20)
          .toInt();
      effects.add('气运 ${_signed(resolution.luckDelta)}');
    }
    final relationships = state.relationships.where(
      (item) =>
          item.id == pending.opponentId || item.name == pending.opponentName,
    );
    if (relationships.isNotEmpty) {
      final relationship = relationships.first;
      relationship.trust = (relationship.trust + resolution.trustDelta)
          .clamp(0, 100)
          .toInt();
      relationship.sharedEvents.add(resolution.title);
      if (resolution.killedOpponent) relationship.alive = false;
    }
    if (resolution.killedOpponent) {
      state.character.tags.add('击杀:${pending.opponentId}');
      effects.add('改写${pending.opponentName}的命运');
    }
    final wearSeverity = switch (choice.id) {
      'encounter-fall' || 'cooperate-fall' => 5,
      'encounter-heavy-injury' || 'cooperate-sacrifice' => 4,
      'encounter-defeat' || 'cooperate-wounded' || 'cooperate-betrayed' => 2,
      'encounter-draw' || 'cooperate-narrow' => 1,
      _ => 0,
    };
    effects.addAll(applyCombatWear(state.character, severity: wearSeverity));
    state.latestResult = resolution.description;
    final resumePoolId = pending.resumePoolId;
    state.pendingEncounter = null;
    if (resolution.endedLife) {
      state.character.status = LifeStatus.dead;
      state.ending = '遭遇战中陨落';
      state.isFinished = true;
      state.currentPoolId = null;
      effects.add('本次人生结束');
    } else {
      final brokenAsset = technologyAssetNeedingDisposal(state.character);
      if (brokenAsset != null) {
        state.pendingTechnologyAssetId = brokenAsset.id;
        state.pendingTechnologyResumePoolId = resumePoolId;
        state.currentPoolId = 'technologyDisposal';
        effects.add('${brokenAsset.name}完整度归零，将进入报废决策');
      } else {
        state.currentPoolId = resumePoolId;
      }
    }
  }

  void _resolveRingOutcome(
    GameState state,
    WheelOption choice,
    List<String> effects,
  ) {
    final character = state.character;
    final ring = state.pendingRing;
    if (ring == null) throw StateError('魂环吸收阶段缺少候选魂环');
    final targetSlot = state.pendingRingTarget ?? MartialSoulSlot.primary;
    final targetRings = character.soulRingsFor(targetSlot);
    final targetName = character.martialSoulFor(targetSlot) ?? '当前武魂';
    final huntMethodId = state.pendingHunt?.methodId;
    final isSecondary = targetSlot == MartialSoulSlot.secondary;
    var obtainedRing = false;
    switch (choice.id) {
      case 'absorb-perfect':
      case 'absorb-normal':
      case 'absorb-hard':
      case 'absorb-breakthrough':
        targetRings.add(ring);
        obtainedRing = true;
        character.soulPower += isSecondary
            ? 1
            : choice.id == 'absorb-breakthrough'
            ? 5
            : 3;
        effects.add('获得${ring.years}年${ringColorName(ring.color)}色魂环');
        effects.add('魂环来源：${ring.source}');
        effects.add('附加至$targetName');
        effects.add('获得魂技：${ring.skillName}');
        effects.add('当前魂力 ${character.soulPower}级');
      case 'absorb-injury':
        targetRings.add(ring);
        obtainedRing = true;
        character.status = LifeStatus.injured;
        character.injuryTurns = 4;
        character.soulPower += 1;
        effects.add('带伤获得${ring.years}年${ringColorName(ring.color)}色魂环');
        effects.add('魂环来源：${ring.source}');
        effects.add('附加至$targetName');
        effects.add('当前魂力 ${character.soulPower}级');
      case 'absorb-fail':
        effects.add('没有获得魂环，下一段人生仍可能再次遇到瓶颈');
      case 'absorb-death':
        character.status = LifeStatus.dead;
        state.ending = '吸收魂环时陨落';
        state.isFinished = true;
        state.currentPoolId = null;
        effects.add('魂环反噬导致人生结束');
    }
    if (obtainedRing && unlockTwinMartialSoulFusion(character)) {
      final fusion = character.tags.lastWhere(
        (tag) => tag.startsWith('武魂融合技：'),
      );
      effects.add('解锁$fusion');
    }
    if (obtainedRing && soulBoneEligibleForMethod(huntMethodId)) {
      state.pendingSoulBoneRing = ring;
    }
    state.pendingRing = null;
    state.pendingHunt = null;
    state.pendingRingTarget = null;
    if (!state.isFinished) {
      state.currentPoolId = state.pendingSoulBoneRing == null
          ? _nextStageAfterCultivation(state)
          : 'soulBoneDrop';
    }
  }

  void _resolveSoulBoneOutcome(
    GameState state,
    WheelOption choice,
    SoulBone bone,
    List<String> effects,
  ) {
    final character = state.character;
    final existing = bone.slot == SoulBoneSlot.external
        ? null
        : character.soulBones
              .where((item) => item.slot == bone.slot)
              .firstOrNull;
    final existingScore = existing == null
        ? null
        : soulBoneQualityScore(existing, character);
    final incomingScore = soulBoneQualityScore(bone, character);
    final previousSets = activeSoulBoneSetBonuses(
      character,
    ).map((item) => '${item.id}:${item.pieceCount}').toSet();
    var obtained = false;
    effects.clear();
    switch (choice.id) {
      case 'bone-perfect':
        character.soulBones.add(bone);
        character.ringCapacityBonus += 3;
        obtained = true;
        effects.add('完美融合：魂环承受上限 +3%');
      case 'bone-normal':
        character.soulBones.add(bone);
        obtained = true;
        effects.add('顺利吸收${soulBoneSlotName(bone.slot)}');
      case 'bone-injury':
        character.soulBones.add(bone);
        character.status = LifeStatus.injured;
        character.injuryTurns = 3;
        obtained = true;
        effects.add('带伤融合，需三轮恢复');
      case 'bone-fail':
        effects.add('魂骨排斥，未能吸收');
      case 'bone-fuse':
        if (existing != null) character.soulBones.remove(existing);
        character.soulBones.add(
          existing == null ? bone : fuseSoulBones(existing, bone),
        );
        obtained = true;
        effects.add('同部位魂骨融合进化');
      case 'bone-replace':
        if (existing != null) character.soulBones.remove(existing);
        character.soulBones.add(bone);
        obtained = true;
        effects.add(
          existingScore == null
              ? '新魂骨完成装备'
              : '新魂骨替换原有部位（品质 $existingScore → $incomingScore）',
        );
      case 'bone-force':
        if (existing != null) character.soulBones.remove(existing);
        character.soulBones.add(bone);
        character.status = LifeStatus.injured;
        character.injuryTurns = 5;
        obtained = true;
        effects.add('强行替换成功，但受到严重排斥');
      case 'bone-store':
        character.spareSoulBones.add(bone);
        effects.add('魂骨已封存，可在能力页查看备用收藏');
      case 'bone-salvage':
        final metalGain = (bone.years / 4000).round().clamp(1, 250);
        final coinGain = (bone.years / 800).round().clamp(2, 1200);
        character.rareMetals += metalGain;
        character.goldCoins += coinGain;
        effects.add(
          '提炼魂骨精华：稀有金属 +$metalGain、'
          '金魂币 ${goldCoinAmount(coinGain, signed: true)}',
        );
      case 'bone-give-up':
        effects.add('放弃重复魂骨，避免吸收风险');
    }
    if (obtained) {
      effects
        ..add('获得魂骨：${bone.name}')
        ..add('获得魂骨技：${bone.skillName}')
        ..add('魂骨品质：$incomingScore');
      for (final set in activeSoulBoneSetBonuses(character)) {
        final key = '${set.id}:${set.pieceCount}';
        if (!previousSets.contains(key)) {
          effects.add('激活${set.name}${set.pieceCount}件共鸣：${set.description}');
        }
      }
    }
    state.pendingSoulBone = null;
    state.pendingSoulBoneRing = null;
    state.currentPoolId = _nextStageAfterCultivation(state);
  }

  void _resolveSoulSpiritOutcome(
    GameState state,
    WheelOption choice,
    List<String> effects,
  ) {
    var spirit = state.pendingSoulSpirit;
    final ring = state.pendingRing;
    if (spirit == null || ring == null) throw StateError('魂灵契约阶段缺少候选魂灵或魂环');
    final target = state.pendingRingTarget ?? MartialSoulSlot.primary;
    final bondBonus = switch (choice.id) {
      'spirit-perfect' => 25,
      'spirit-steady' => 14,
      'spirit-trial' => 7,
      _ => 2,
    };
    spirit = spirit.copyWith(bond: (spirit.bond + bondBonus).clamp(0, 100));
    state.character.soulSpirits.add(spirit);
    state.character.soulRingsFor(target).add(ring);
    state.character.soulPower += target == MartialSoulSlot.secondary ? 1 : 3;
    final targetName = state.character.martialSoulFor(target) ?? '当前武魂';
    effects
      ..clear()
      ..add('获得魂灵：${spirit.name}')
      ..add('魂灵羁绊：${spirit.bond}')
      ..add('获得${ring.years}年${ringColorName(ring.color)}色魂环')
      ..add('魂环来源：${ring.source}')
      ..add('附加至$targetName')
      ..add('获得魂技：${ring.skillName}')
      ..add('当前魂力 ${state.character.soulPower}级');
    if (choice.id == 'spirit-backlash') {
      state.character.status = LifeStatus.injured;
      state.character.injuryTurns = 3;
      effects.add('契约反噬：需三轮恢复');
    }
    state.pendingSoulSpirit = null;
    state.pendingSoulSpiritMethodId = null;
    state.pendingRing = null;
    state.pendingRingTarget = null;
    state.currentPoolId = _nextStageAfterCultivation(state);
  }

  void _resolveSoulSpiritGrant(
    GameState state,
    WheelOption choice,
    List<String> effects,
    SeededRandom random,
  ) {
    final index = state.character.soulSpirits.indexWhere(
      (item) => item.id == choice.id,
    );
    if (index < 0) throw StateError('魂灵赐环阶段找不到目标魂灵');
    final spirit = state.character.soulSpirits[index];
    final target = state.pendingRingTarget ?? MartialSoulSlot.primary;
    final ringNumber = state.character.soulRingsFor(target).length + 1;
    final ring = grantedSoulSpiritRing(
      spirit,
      _ringCharacter(state),
      ringNumber,
      random,
      invitationMode: state.invitationMode,
    );
    state.character.soulRingsFor(target).add(ring);
    state.character.soulSpirits[index] = spirit.copyWith(
      bond: (spirit.bond + 4).clamp(0, 100),
      remainingRingGrants: spirit.remainingRingGrants - 1,
    );
    state.character.soulPower += target == MartialSoulSlot.secondary ? 1 : 3;
    final targetName = state.character.martialSoulFor(target) ?? '当前武魂';
    effects
      ..clear()
      ..add('${spirit.name}消耗一次本源赐环')
      ..add('获得${ring.years}年${ringColorName(ring.color)}色魂环')
      ..add('魂环来源：${ring.source}')
      ..add('附加至$targetName')
      ..add('剩余赐环${spirit.remainingRingGrants - 1}次')
      ..add('当前魂力 ${state.character.soulPower}级');
    state.pendingRingTarget = null;
    state.currentPoolId = _nextStageAfterCultivation(state);
  }

  HuntContext _huntContextFor(WheelOption choice) => switch (choice.id) {
    'ring-family' => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: .75,
      affinityMultiplier: 1.1,
      habitat: '森林',
    ),
    'ring-academy' => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: .7,
      affinityMultiplier: 1.15,
      habitat: '学院圈养',
    ),
    'ring-team' => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: .85,
      affinityMultiplier: 1.05,
      habitat: '湿地',
    ),
    'ring-alone' => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: 1.45,
      affinityMultiplier: 1.15,
      habitat: '荒原',
    ),
    'ring-clue' => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: .9,
      affinityMultiplier: 1.5,
      habitat: '非法猎魂',
    ),
    'ring-chance' => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: 1.25,
      affinityMultiplier: 1,
      habitat: '海域',
    ),
    'ring-help' => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: .55,
      affinityMultiplier: 1.3,
      habitat: '森林',
    ),
    'ring-sacrifice' => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: .35,
      affinityMultiplier: 1.6,
      habitat: '森林',
    ),
    _ => HuntContext(
      methodId: choice.id,
      methodName: choice.text,
      riskMultiplier: 1,
      affinityMultiplier: 1,
    ),
  };

  String _huntMethodReason(HuntContext hunt) {
    final risk = hunt.riskMultiplier > 1
        ? '风险上升'
        : hunt.riskMultiplier < 1
        ? '风险下降'
        : '风险不变';
    final affinity = hunt.affinityMultiplier > 1 ? '更容易锁定契合魂兽' : '按常规寻找魂兽';
    return '$risk，$affinity';
  }

  double _ringOutcomeMultiplier(String outcomeId, GameState state) {
    final ring = state.pendingRing;
    if (ring == null) return 1;
    final character = state.character;
    final ringCharacter = _ringCharacter(state);
    final ringNumber = _ringNumberFor(state);
    final safeUpper = ringSafetyUpperFor(
      ringCharacter,
      ringNumber,
      ring.source,
      invitationMode: state.invitationMode,
    );
    final methodRisk = state.pendingHunt?.riskMultiplier ?? 1;
    final pressure = ring.years / safeUpper * methodRisk;
    final pressureMultiplier = switch (outcomeId) {
      'absorb-perfect' =>
        pressure <= .65
            ? 2
            : pressure <= 1
            ? 1.1
            : (1 / (pressure * pressure)).clamp(.08, 1),
      'absorb-normal' => pressure <= 1 ? 1.25 : (1 / pressure).clamp(.15, 1),
      'absorb-hard' => (.8 + pressure).clamp(.8, 3),
      'absorb-injury' => (pressure * pressure).clamp(.25, 100),
      'absorb-fail' => (pressure * pressure * pressure).clamp(.15, 150),
      'absorb-breakthrough' => pressure >= .8 && pressure <= 1.35 ? 1.4 : .7,
      'absorb-death' => (pressure * pressure * pressure * pressure).clamp(
        .1,
        300,
      ),
      _ => 1,
    };
    return pressureMultiplier * twinRingOutcomeMultiplier(outcomeId, character);
  }

  List<String> _ringOutcomeCauses(GameState state) {
    final ring = state.pendingRing;
    final hunt = state.pendingHunt;
    if (ring == null) return const <String>[];
    final ringCharacter = _ringCharacter(state);
    final safeUpper = ringSafetyUpperFor(
      ringCharacter,
      _ringNumberFor(state),
      ring.source,
      invitationMode: state.invitationMode,
    );
    final risk = hunt?.riskMultiplier ?? 1;
    final pressure = ring.years / safeUpper * risk;
    final assessment = pressure <= .7
        ? '明显低于承受上限'
        : pressure <= 1
        ? '接近承受上限'
        : '超过安全承受范围';
    return <String>[
      '${ring.years}年魂环$assessment（当前安全上限约$safeUpper年）',
      '${hunt?.methodName ?? '常规猎魂'}带来${risk > 1 ? '额外' : '较低'}吸收风险',
      '体质、精神与魂环承受力共同修正了本次结果概率',
    ];
  }

  List<String> _ringCandidateCauses(GameState state, WheelOption choice) {
    final character = _ringCharacter(state);
    final hunt = state.pendingHunt;
    final profile = soulBeastProfileForId(choice.id);
    final multiplier = profile == null
        ? 1.0
        : soulBeastContextMultiplier(profile, character, hunt);
    return <String>[
      '${hunt?.methodName ?? '常规猎魂'}决定了本次遭遇的风险与搜寻范围',
      if (profile != null) '${choice.text}的主要特性是“${profile.trait}”',
      if (multiplier > 1.15)
        '${character.martialSoul ?? '当前道路'}、环境、性格或猎魂方式提高了契合概率'
      else
        '本次没有获得明显属性加成，主要依靠基础出现概率',
    ];
  }

  void _applyEffects(Character character, Map<String, int> effects) {
    if (character.route != RouteType.soulBeast) {
      character.soulPower = (character.soulPower + (effects['soulPower'] ?? 0))
          .clamp(0, 1000000)
          .toInt();
    }
    character.ringCapacityBonus =
        (character.ringCapacityBonus + (effects['ringCapacity'] ?? 0))
            .clamp(0, 500)
            .toInt();
    character.luck = (character.luck + (effects['luck'] ?? 0))
        .clamp(-20, 20)
        .toInt();
    character.goldCoins = (character.goldCoins + (effects['goldCoins'] ?? 0))
        .clamp(0, 1000000)
        .toInt();
    character.rareMetals = (character.rareMetals + (effects['rareMetals'] ?? 0))
        .clamp(0, 1000000)
        .toInt();
    character.factionReputation =
        (character.factionReputation + (effects['factionReputation'] ?? 0))
            .clamp(0, 1000000)
            .toInt();
    character.soulBeastTrust =
        (character.soulBeastTrust + (effects['soulBeastTrust'] ?? 0))
            .clamp(0, 1000000)
            .toInt();
    character.starMerit = (character.starMerit + (effects['starMerit'] ?? 0))
        .clamp(0, 1000000)
        .toInt();
    if (character.route == RouteType.soulBeast) {
      character.beastYears =
          (character.beastYears + (effects['beastYears'] ?? 0))
              .clamp(0, 1000000)
              .toInt();
      character.beastBloodlinePower =
          (character.beastBloodlinePower + (effects['beastBloodline'] ?? 0))
              .clamp(0, 100)
              .toInt();
      character.beastIntelligence =
          (character.beastIntelligence + (effects['beastIntelligence'] ?? 0))
              .clamp(0, 100)
              .toInt();
      character.beastTerritory =
          (character.beastTerritory + (effects['beastTerritory'] ?? 0))
              .clamp(0, 100)
              .toInt();
      character.beastPrestige =
          (character.beastPrestige + (effects['beastPrestige'] ?? 0))
              .clamp(0, 100)
              .toInt();
      character.humanThreat =
          (character.humanThreat + (effects['humanThreat'] ?? 0))
              .clamp(0, 100)
              .toInt();
      if (character.humanThreat > character.maximumHumanThreat) {
        character.maximumHumanThreat = character.humanThreat;
      }
      character.beastBond = (character.beastBond + (effects['beastBond'] ?? 0))
          .clamp(0, 100)
          .toInt();
      character.beastClanPopulation =
          (character.beastClanPopulation + (effects['beastClan'] ?? 0))
              .clamp(0, 999)
              .toInt();
      character.beastResources =
          (character.beastResources + (effects['beastResources'] ?? 0))
              .clamp(0, 100)
              .toInt();
      character.beastEnemyPressure =
          (character.beastEnemyPressure + (effects['beastEnemyPressure'] ?? 0))
              .clamp(0, 100)
              .toInt();
    }
    if ((effects['injury'] ?? 0) > 0) {
      character.status = LifeStatus.injured;
      character.injuryTurns = (character.injuryTurns + effects['injury']! + 1)
          .clamp(2, 12)
          .toInt();
    }
    if ((effects['recovery'] ?? 0) > 0) {
      character.injuryTurns = (character.injuryTurns - effects['recovery']!)
          .clamp(0, 12)
          .toInt();
      if (character.injuryTurns == 0 &&
          character.status == LifeStatus.injured) {
        character.status = LifeStatus.alive;
      }
    }
    if ((effects['death'] ?? 0) > 0) character.status = LifeStatus.dead;
  }

  void _record(
    GameState state,
    String stage,
    String title,
    String description,
    List<String> effects,
  ) {
    state.latestTitle = title;
    state.latestResult = description;
    state.latestEffects = effects;
    recordLifeIdentity(state.character, title: title, effects: effects);
    state.timeline.add(
      TimelineEntry(
        age: state.character.age,
        stage: stage,
        title: title,
        description: description,
        effects: effects,
      ),
    );
  }

  String _resolveTechnologyDisposal(
    GameState state,
    WheelOption choice,
    List<String> effects,
  ) {
    final id = state.pendingTechnologyAssetId;
    final index = state.character.technologyAssets.indexWhere(
      (asset) => asset.id == id,
    );
    if (index < 0) {
      final resume = state.pendingTechnologyResumePoolId ?? 'ageGrowth';
      state.pendingTechnologyAssetId = null;
      state.pendingTechnologyResumePoolId = null;
      state.currentPoolId = resume;
      return '科技资产已不在清单中，跳过处置阶段。';
    }
    final asset = state.character.technologyAssets[index];
    final score = technologyAssetQualityScore(asset);
    switch (choice.id) {
      case 'tech-dispose-recycle':
        final metal = (score / 25).round().clamp(2, 80);
        final coins = (score / 8).round().clamp(5, 300);
        state.character
          ..rareMetals += metal
          ..goldCoins += coins
          ..technologyAssets.removeAt(index);
        effects
          ..clear()
          ..add('回收稀有金属 +$metal')
          ..add('金魂币 ${goldCoinAmount(coins, signed: true)}');
      case 'tech-dispose-research':
        state.character
          ..soulEngineerLevel = (state.character.soulEngineerLevel + 1).clamp(
            0,
            10,
          )
          ..technologyAssets.removeAt(index);
        effects
          ..clear()
          ..add('拆解研究完成')
          ..add('魂导师能力 +1');
      case 'tech-dispose-memorial':
        state.character.technologyAssets[index] = asset.copyWith(
          equipped: false,
          memorial: true,
        );
        effects
          ..clear()
          ..add('作为人生纪念永久保存');
    }
    final resume = state.pendingTechnologyResumePoolId ?? 'ageGrowth';
    state.pendingTechnologyAssetId = null;
    state.pendingTechnologyResumePoolId = null;
    state.currentPoolId = resume;
    return '${asset.name}已无法继续作战，你对它作出了最终处置。';
  }

  List<String> _causalNotes(String poolId, Character character) {
    if ((poolId == 'martialSoul' ||
            poolId == 'primaryMartialSoul' ||
            poolId == 'secondaryMartialSoul') &&
        character.talent != null) {
      return <String>['武魂天赋“${character.talent}”修正了本次觉醒概率'];
    }
    if (poolId == 'ringTarget') {
      return <String>['主武魂修炼进度与双生武魂平衡共同决定魂环归属'];
    }
    if (poolId == 'innatePower' && character.talent != null) {
      return <String>['武魂天赋与觉醒结果共同影响先天魂力'];
    }
    if (poolId == 'ringMethod' && character.family != null) {
      return <String>['家庭和既有人脉影响了猎魂方式'];
    }
    if (poolId == 'ringCandidate') {
      return <String>['武魂特性与身体、精神承受力影响候选魂兽'];
    }
    return const <String>[];
  }

  List<String> _applyAgeGrowth(GameState state, WheelOption choice) {
    final character = state.character;
    if (character.route == RouteType.soulBeast && character.lifeStartAge == 0) {
      character.lifeStartAge = character.age;
    }
    final rawAge = choice.effects['age'] ?? 0;
    final proposedAge = character.route == RouteType.soulBeast
        ? soulBeastAgeDelta(rawAge)
        : rawAge;
    final remainingBeastYears =
        character.lifeStartAge + soulBeastStoryWindowYears - character.age;
    final age =
        character.route == RouteType.soulBeast &&
            remainingBeastYears < proposedAge
        ? remainingBeastYears.clamp(0, proposedAge).toInt()
        : proposedAge;
    character.age += age;
    state.pendingYears = age;
    final result = <String>['年龄 +$age 岁', '下一步单独判定修炼成果'];
    result.addAll(growSoulSpiritsForYears(character, age));
    if (character.injuryTurns > 0) {
      character.injuryTurns = (character.injuryTurns - 1).clamp(0, 12).toInt();
      if (character.injuryTurns == 0) {
        character.status = LifeStatus.alive;
        result.add('伤势已经恢复');
      } else {
        result.add('仍需 ${character.injuryTurns} 个阶段恢复');
      }
    }
    return result;
  }

  List<String> _applyCultivationGrowth(GameState state, WheelOption choice) {
    final character = state.character;
    final years = state.pendingYears;
    if (character.route == RouteType.soulBeast) {
      final growth = soulBeastCultivationGrowth(
        currentYears: character.beastYears,
        elapsedYears: years,
        rate: choice.effects['beastRate'] ?? 10,
      );
      character.beastYears += growth;
      character.soulPower = 0;
      character.soulRings.clear();
      return <String>['修为 +$growth 年', '魂兽始终没有魂力与魂环'];
    }

    final talentBonus = switch (character.talent) {
      '顶尖' => 1,
      '绝世' || '妖孽' || '神级潜质' => 2,
      '无魂师天赋' => -1,
      _ => 0,
    };
    final personalityBonus = character.tags.contains('性格:personality-stubborn')
        ? 1
        : 0;
    final insightBonus = (character.cultivationInsight + 2) ~/ 3;
    final twinBonus = twinCultivationBonus(character);
    final rawGrowth =
        (years * (choice.effects['rate'] ?? 1) +
                (choice.effects['flat'] ?? 0) +
                talentBonus +
                personalityBonus +
                twinBonus +
                insightBonus)
            .clamp(0, 1000000)
            .toInt();
    final highLevelFactor = state.invitationMode
        ? character.soulPower >= 90
              ? .8
              : character.soulPower >= 80
              ? .9
              : 1.0
        : character.soulPower >= 90
        ? .42
        : character.soulPower >= 80
        ? .55
        : character.soulPower >= 60
        ? .75
        : 1.0;
    var potentialGrowth = (rawGrowth * highLevelFactor).round();
    if (rawGrowth > 0 &&
        potentialGrowth == 0 &&
        choice.id != 'training-stalled') {
      potentialGrowth = 1;
    }
    final nextRingLevel = (character.soulRings.length + 1) * 10;
    final nextSoulPower = character.soulRings.length < 9
        ? character.soulPower >= nextRingLevel
              ? character.soulPower
              : (character.soulPower + potentialGrowth)
                    .clamp(0, nextRingLevel)
                    .toInt()
        : character.soulPower + potentialGrowth;
    final growth = nextSoulPower - character.soulPower;
    character.soulPower = nextSoulPower;
    character.cultivationInsight = 0;
    return <String>[
      '魂力 +$growth',
      if (insightBonus > 0) '既有修炼积累转化为 +$insightBonus 魂力',
      if (twinBonus > 0) '双武魂互补使修炼潜力 +$twinBonus',
      if (twinBonus < 0) '双武魂冲突使修炼潜力 $twinBonus',
    ];
  }

  String _nextStageAfterCultivation(GameState state) {
    final character = state.character;
    final nextRingLevel = (character.soulRings.length + 1) * 10;
    if (character.route == RouteType.human &&
        character.soulRings.length < 9 &&
        character.soulPower >= nextRingLevel) {
      final canGrant = character.soulSpirits.any(
        (spirit) => spirit.remainingRingGrants > 0,
      );
      if (canGrant) {
        state.pendingRingTarget = MartialSoulSlot.primary;
        return 'soulSpiritGrant';
      }
      if (character.hasTwinMartialSouls && character.soulRings.length >= 5) {
        return 'ringTarget';
      }
      state.pendingRingTarget = MartialSoulSlot.primary;
      return 'ringMethod';
    }
    if (character.route == RouteType.human &&
        character.hasTwinMartialSouls &&
        character.soulRings.length >= 9 &&
        character.secondarySoulRings.length < 9) {
      return 'ringTarget';
    }
    if (character.route == RouteType.human &&
        character.soulRings.length >= 9 &&
        (!character.hasTwinMartialSouls ||
            character.secondarySoulRings.length >= 9) &&
        character.soulPower > 100) {
      return 'godhoodEvent';
    }
    if (character.route == RouteType.soulBeast) {
      final milestone = _nextBeastMilestone(character);
      if (milestone != null) {
        state.pendingBeastMilestone = milestone;
        return 'beastMilestone';
      }
      if (character.beastYears >= 100000 &&
          !character.tags.contains('魂兽命途已定')) {
        return 'beastDestiny';
      }
    }
    final eraMilestone = nextDueEraMilestone(
      eraId: character.eraId,
      protagonistYear: protagonistYearFor(character),
      triggeredIds: state.triggeredEraMilestones,
    );
    if (eraMilestone != null) {
      state.pendingEraMilestoneId = eraMilestone.id;
      return 'eraMilestone';
    }
    if (state.lifeEventCount >= _maximumLifeEvents) return 'ending';
    if (character.route == RouteType.soulBeast) return 'beastAction';
    return 'eventCount';
  }

  WheelPool _beastMilestonePool(Character character) => WheelPool(
    id: 'beastMilestone',
    title: '魂兽血脉蜕变',
    options: <WheelOption>[
      const WheelOption(
        id: 'beast-milestone-endure',
        text: '淬炼肉身',
        weight: 26,
        effects: <String, int>{'ringCapacity': 6, 'beastBloodline': 4},
      ),
      const WheelOption(
        id: 'beast-milestone-instinct',
        text: '觉醒本命天赋',
        weight: 20,
        effects: <String, int>{
          'luck': 2,
          'beastBloodline': 3,
          'beastIntelligence': 2,
        },
      ),
      const WheelOption(
        id: 'beast-milestone-domain',
        text: '凝聚领地威压',
        weight: 16,
        effects: <String, int>{
          'ringCapacity': 3,
          'beastTerritory': 7,
          'beastPrestige': 3,
        },
      ),
      const WheelOption(
        id: 'beast-milestone-wisdom',
        text: '开启高阶灵智',
        weight: 14,
        effects: <String, int>{'beastIntelligence': 8, 'beastBond': 2},
      ),
      const WheelOption(
        id: 'beast-milestone-ancestor',
        text: '引动祖脉返流',
        weight: 7,
        effects: <String, int>{'beastBloodline': 10, 'humanThreat': 3},
      ),
      const WheelOption(
        id: 'beast-milestone-crown',
        text: '凝聚族群王印',
        weight: 8,
        effects: <String, int>{'beastPrestige': 9, 'beastTerritory': 4},
      ),
      const WheelOption(
        id: 'beast-milestone-shape',
        text: '提前推演化形之躯',
        weight: 5,
        effects: <String, int>{
          'beastIntelligence': 7,
          'beastBloodline': 5,
          'humanThreat': -2,
        },
      ),
      const WheelOption(
        id: 'beast-milestone-life',
        text: '聆听万兽生命共鸣',
        weight: 4,
        effects: <String, int>{'beastBond': 9, 'beastPrestige': 4, 'luck': 2},
      ),
      soulBeastSpeciesEvolution(character.beastArchetype),
    ],
  );

  String? _nextBeastMilestone(Character character) {
    const levels = <({int years, String id})>[
      (years: 100, id: 'hundred-years'),
      (years: 1000, id: 'thousand-years'),
      (years: 10000, id: 'ten-thousand-years'),
      (years: 100000, id: 'hundred-thousand-years'),
      (years: 1000000, id: 'million-years'),
    ];
    final previousIndex = levels.indexWhere(
      (item) => item.id == character.beastMilestone,
    );
    for (var index = previousIndex + 1; index < levels.length; index++) {
      if (character.beastYears >= levels[index].years) return levels[index].id;
    }
    return null;
  }

  String _beastMilestoneLabel(String? id) => switch (id) {
    'hundred-years' => '百年',
    'thousand-years' => '千年',
    'ten-thousand-years' => '万年',
    'hundred-thousand-years' => '十万年',
    'million-years' => '百万年',
    _ => '新的年限',
  };

  int _beastCultivationFromEvent(StoryEvent event, SeededRandom random) {
    final narrativeGrowth = event.effects['soulPower'] ?? 0;
    final base = narrativeGrowth > 0 ? narrativeGrowth * 220 : 80;
    return base + random.nextInt(180);
  }

  List<String> _effectText(
    Map<String, int> effects, {
    RouteType? route,
    bool positiveSoulPowerIsInsight = false,
  }) {
    final result = <String>[];
    if (route != RouteType.soulBeast && (effects['soulPower'] ?? 0) != 0) {
      final value = effects['soulPower']!;
      result.add(
        positiveSoulPowerIsInsight && value > 0
            ? '修炼积累 +$value'
            : '魂力 ${_signed(value)}',
      );
    }
    if ((effects['ringCapacity'] ?? 0) != 0) {
      result.add('魂环承受力 ${_signed(effects['ringCapacity']!)}%');
    }
    if ((effects['luck'] ?? 0) != 0) {
      result.add('气运 ${_signed(effects['luck']!)}');
    }
    if ((effects['goldCoins'] ?? 0) != 0) {
      result.add('金魂币 ${goldCoinAmount(effects['goldCoins']!, signed: true)}');
    }
    if ((effects['rareMetals'] ?? 0) != 0) {
      result.add('稀有金属 ${_signed(effects['rareMetals']!)}');
    }
    if ((effects['factionReputation'] ?? 0) != 0) {
      result.add('势力声望 ${_signed(effects['factionReputation']!)}');
    }
    if ((effects['soulBeastTrust'] ?? 0) != 0) {
      result.add('魂兽信任 ${_signed(effects['soulBeastTrust']!)}');
    }
    if ((effects['starMerit'] ?? 0) != 0) {
      result.add('星际功勋 ${_signed(effects['starMerit']!)}');
    }
    if (route == RouteType.soulBeast) {
      if ((effects['beastYears'] ?? 0) != 0) {
        result.add('修为 ${_signed(effects['beastYears']!)} 年');
      }
      if ((effects['beastBloodline'] ?? 0) != 0) {
        result.add('血脉 ${_signed(effects['beastBloodline']!)}');
      }
      if ((effects['beastIntelligence'] ?? 0) != 0) {
        result.add('灵智 ${_signed(effects['beastIntelligence']!)}');
      }
      if ((effects['beastTerritory'] ?? 0) != 0) {
        result.add('领地 ${_signed(effects['beastTerritory']!)}');
      }
      if ((effects['beastPrestige'] ?? 0) != 0) {
        result.add('族群声望 ${_signed(effects['beastPrestige']!)}');
      }
      if ((effects['humanThreat'] ?? 0) != 0) {
        result.add('人类威胁 ${_signed(effects['humanThreat']!)}');
      }
      if ((effects['beastBond'] ?? 0) != 0) {
        result.add('羁绊 ${_signed(effects['beastBond']!)}');
      }
      if ((effects['beastClan'] ?? 0) != 0) {
        result.add('族群 ${_signed(effects['beastClan']!)}');
      }
      if ((effects['beastResources'] ?? 0) != 0) {
        result.add('资源 ${_signed(effects['beastResources']!)}');
      }
      if ((effects['beastEnemyPressure'] ?? 0) != 0) {
        result.add('敌对压力 ${_signed(effects['beastEnemyPressure']!)}');
      }
    }
    if ((effects['injury'] ?? 0) > 0) result.add('受到伤势');
    return result;
  }

  String _signed(int value) => value > 0 ? '+$value' : '$value';

  String _ringOutcomeDescription(String outcome, SoulRing? ring) {
    if (ring == null) return outcome;
    return switch (outcome) {
      '完美吸收' => '你稳住气息，完整承接了${ring.source}的力量。',
      '正常吸收' => '吸收过程有惊无险，魂环最终稳定下来。',
      '勉强成功' => '剧痛之后，魂环仍旧停留在你的魂力轨迹中。',
      '身体重伤' => '魂环虽然成功融合，但伤势需要很长时间恢复。',
      '吸收失败' => '魂环在最后关头崩散，你只能重新寻找机会。',
      '特殊突破' => '魂环与武魂发生罕见共鸣，力量越过原有边界。',
      _ => '狂暴能量反噬全身，生命气息逐渐消散。',
    };
  }

  void _resolveGodhood(
    GameState state,
    WheelOption choice,
    List<String> effects,
  ) {
    final character = state.character;
    character.divinityScore = calculateDivinityScore(character);
    if (choice.id.startsWith('god-success')) {
      character.godhood = choice.text.replaceFirst(
        RegExp(r'^(成就|登临|凝聚|化作)'),
        '',
      );
      state.ending = '${character.godhood}·登临神界';
      character.status = LifeStatus.ended;
      effects.add('成就神位：${character.godhood}');
    } else if (choice.id == 'god-fall') {
      state.ending = '神考中陨落';
      character.status = LifeStatus.dead;
      effects.add('神途失败，人物死亡');
    } else if (choice.id == 'god-wounded') {
      state.ending = '神格破碎·重返人间';
      character.status = LifeStatus.ended;
      effects.add('神格破碎，保留百级修为与神性余辉');
    } else {
      state.ending = '神考止步·归隐人间';
      character.status = LifeStatus.ended;
      effects.add('保留百级修为，结束神位追寻');
    }
    state.ending = personalizedEnding(state, state.ending!);
    state.isFinished = true;
    state.currentPoolId = null;
    state.pendingGodPathId = null;
  }

  String _godhoodDescription(String outcomeId, String? godhood) {
    if (outcomeId.startsWith('god-success')) {
      return '武魂、魂环与一生因果在此刻汇聚，你最终成就了${godhood ?? '神位'}。';
    }
    return switch (outcomeId) {
      'god-fall' => '神界法则超过了承受极限，这段人生在神考中落幕。',
      'god-wounded' => '破碎的神格化作余辉，你带着百级修为重返人间。',
      _ => '你没有强求最后一步，带着百级修为返回人间。',
    };
  }
}

({int min, int max, int preferred}) _innatePowerBand(String? talent) =>
    switch (talent) {
      '无魂师天赋' => (min: 0, max: 0, preferred: 0),
      '微弱' => (min: 0, max: 4, preferred: 2),
      '普通' => (min: 1, max: 7, preferred: 5),
      '良好' => (min: 3, max: 8, preferred: 6),
      '优秀' => (min: 5, max: 9, preferred: 8),
      '顶尖' => (min: 7, max: 10, preferred: 9),
      '绝世' => (min: 8, max: 10, preferred: 10),
      '妖孽' => (min: 9, max: 10, preferred: 10),
      '神级潜质' => (min: 10, max: 10, preferred: 10),
      '未知变异' => (min: 0, max: 10, preferred: 7),
      _ => (min: 0, max: 10, preferred: 5),
    };

int? _innatePowerFromOption(String optionId) => optionId.startsWith('power-')
    ? int.tryParse(optionId.substring('power-'.length))
    : null;
