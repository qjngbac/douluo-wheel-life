import '../data/creation_data.dart';
import '../data/soul_beast_data.dart';
import '../data/story_data.dart';
import '../domain/models.dart';

String computeContentFingerprint(GameData data) {
  final buffer = StringBuffer('douluo-content-v1|engine-rules-v11');
  void field(Object? value) {
    final text = value?.toString() ?? '<null>';
    buffer
      ..write(text.length)
      ..write(':')
      ..write(text)
      ..write('|');
  }

  field(data.forceRoute?.name);
  for (final poolEntry in data.pools.entries) {
    field('pool');
    field(poolEntry.key);
    final pool = poolEntry.value;
    field(pool.id);
    field(pool.title);
    for (var index = 0; index < pool.options.length; index++) {
      final option = pool.options[index];
      field(index);
      field(option.id);
      field(option.text);
      field(option.weight);
      field(option.minAge);
      field(option.maxAge);
      field(option.route?.name);
      for (final tag in option.requiredTags) {
        field('required:$tag');
      }
      for (final tag in option.forbiddenTags) {
        field('forbidden:$tag');
      }
      for (final effect in option.effects.entries) {
        field('effect:${effect.key}:${effect.value}');
      }
    }
  }
  for (var index = 0; index < data.events.length; index++) {
    final event = data.events[index];
    field('event');
    field(index);
    field(event.id);
    field(event.title);
    field(event.description);
    field(event.weight);
    field(event.route?.name);
    field(event.minAge);
    field(event.maxAge);
    field(event.minProtagonistYear);
    field(event.maxProtagonistYear);
    field(event.minSoulPower);
    field(event.minBeastYears);
    for (final era in event.eraIds) {
      field('era:$era');
    }
    for (final tag in event.requiredTags) {
      field('required:$tag');
    }
    for (final tag in event.forbiddenTags) {
      field('forbidden:$tag');
    }
    for (final tag in event.addTags) {
      field('add:$tag');
    }
    for (final effect in event.effects.entries) {
      field('effect:${effect.key}:${effect.value}');
    }
    for (final trait in event.favoredPersonalities) {
      field('favored:${trait.name}');
    }
    for (final trait in event.conflictingPersonalities) {
      field('conflicting:${trait.name}');
    }
    field(event.arcId);
    field(event.arcStage);
    field(event.repeatLimit);
    field(event.cooldownYears);
    field(event.relationshipId);
    field(event.relationshipName);
    field(event.relationshipType);
    field(event.trustDelta);
    field(event.affectionDelta);
    field(event.minRelationshipTrust);
    field(event.maxRelationshipTrust);
    field(event.relationshipMustBeAlive);
    field(event.encounter?.opponentId);
    field(event.encounter?.opponentName);
    field(event.encounter?.type.name);
    field(event.encounter?.opponentPower);
  }
  for (var index = 0; index < soulBeastLibrary.length; index++) {
    final profile = soulBeastLibrary[index];
    field('soul-beast');
    field(index);
    field(profile.id);
    field(profile.name);
    field(profile.weight);
    field(profile.minRing);
    field(profile.maxRing);
    field(profile.quality);
    field(profile.affinity);
    field(profile.trait);
    for (final habitat in profile.habitats) {
      field('habitat:$habitat');
    }
    for (final tag in profile.requiredTags) {
      field('required:$tag');
    }
    field(profile.specialColor?.name);
    field(profile.specialYearsLower);
    field(profile.specialYearsUpper);
  }

  var hash = BigInt.parse('cbf29ce484222325', radix: 16);
  final prime = BigInt.parse('100000001b3', radix: 16);
  final mask = BigInt.parse('ffffffffffffffff', radix: 16);
  for (final unit in buffer.toString().codeUnits) {
    hash ^= BigInt.from(unit);
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

final String _currentContentFingerprint = computeContentFingerprint(
  GameData(pools: buildCreationPools(), events: buildStoryEvents()),
);

String currentContentFingerprint() => _currentContentFingerprint;
