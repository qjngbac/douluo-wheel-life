import 'models.dart';

String goldCoinAmount(int value, {bool signed = false}) {
  final prefix = signed && value > 0 ? '+' : '';
  return '$prefix$value万';
}

final RegExp _internalToken = RegExp(
  r'(^|[：:\s])(era|timeline|time|faction|mentor|god-path|personality|ring|beast)-[a-z0-9-]+',
  caseSensitive: false,
);

List<String> sanitizePlayerFacingLines(Iterable<String> lines) => lines
    .map(playerFacingLine)
    .whereType<String>()
    .where((line) => line.trim().isNotEmpty)
    .toList(growable: false);

String playerFacingRelationshipType(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty ||
      RegExp(r'[a-z]', caseSensitive: false).hasMatch(normalized)) {
    return '命运关系';
  }
  return normalized;
}

String playerFacingRelationshipStance(Relationship relationship) {
  if (!relationship.alive) return '命运已改写';
  if (relationship.trust <= 10) return '猎杀目标';
  if (relationship.trust <= 30) return '宿敌';
  if (relationship.trust >= 70) return '盟友';
  if (relationship.trust >= 45) return '互相认可';
  return '戒备';
}

String? playerFacingLine(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return null;
  value = value.replaceFirst(RegExp(r'^获得标签[：:]\s*'), '');
  final relationship = RegExp(r'^(?:时代)?相识[：:](.+)$').firstMatch(value);
  if (relationship != null && !_containsInternalCode(relationship.group(1)!)) {
    return '结识${relationship.group(1)}';
  }
  final together = RegExp(r'^并肩[：:](.+)$').firstMatch(value);
  if (together != null && !_containsInternalCode(together.group(1)!)) {
    return '与${together.group(1)}并肩';
  }
  if (value.contains(':') ||
      value.contains('：') && _containsInternalCode(value)) {
    return null;
  }
  if (_containsInternalCode(value)) return null;
  return value;
}

bool _containsInternalCode(String value) =>
    _internalToken.hasMatch(value) ||
    RegExp(r'[a-z]+:[a-z]|[a-z]+-[a-z]+', caseSensitive: false).hasMatch(value);
