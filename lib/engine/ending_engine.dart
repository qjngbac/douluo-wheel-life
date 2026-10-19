import '../domain/models.dart';
import 'relationship_legacy_engine.dart';

String personalizedEnding(GameState state, String baseEnding) {
  final character = state.character;
  final closest = state.relationships.where((item) => item.alive).toList()
    ..sort((a, b) => b.trust.compareTo(a.trust));
  final bond = closest.isNotEmpty && closest.first.trust >= 55
      ? '，${closest.first.name}仍与你并肩'
      : '';
  if (character.godhood != null) {
    return '${character.godhood}·登临神界$bond';
  }
  if (character.route == RouteType.soulBeast) {
    final identity = character.race ?? '魂兽';
    final legacy = relationshipLegacyFor(state);
    final relationshipEnding = legacy.kind == RelationshipLegacyKind.none
        ? bond
        : legacy.endingSuffix;
    return '$baseEnding·${character.beastPath}·$identity修至${character.beastYears}年$relationshipEnding';
  }
  if (character.secondaryMartialSoul != null) {
    return '$baseEnding·双武魂圆满·'
        '${character.martialSoul ?? '第一武魂'}${character.soulRings.length}环/'
        '${character.secondaryMartialSoul}${character.secondarySoulRings.length}环$bond';
  }
  if (character.soulRings.length >= 9) {
    return '$baseEnding·九环${character.martialSoul ?? '魂师'}$bond';
  }
  if (character.martialSoul != null) {
    return '$baseEnding·${character.martialSoul}$bond';
  }
  return '$baseEnding$bond';
}
