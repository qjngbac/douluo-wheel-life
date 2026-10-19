import '../domain/models.dart';

class ProbabilityBreakdown {
  const ProbabilityBreakdown({
    required this.baseWeight,
    required this.finalWeight,
    required this.finalProbability,
    required this.reasons,
  });

  final double baseWeight;
  final double finalWeight;
  final double finalProbability;
  final List<String> reasons;
}

ProbabilityBreakdown explainOptionProbability({
  required GameState state,
  required WheelPool pool,
  required WheelOption option,
  required double baseWeight,
}) {
  final total = pool.options.fold<double>(0, (sum, item) => sum + item.weight);
  final reasons = <String>[];
  final character = state.character;
  if (pool.id == 'ringMethod' &&
      character.tags.contains('导师赏识') &&
      option.id == 'ring-academy') {
    reasons.add('导师赏识提高了学院协助出现的机会');
  }
  if (pool.id == 'ringMethod' &&
      option.id == 'ring-alone' &&
      character.tags.contains('性格:personality-careful')) {
    reasons.add('谨慎性格降低了独自冒险的倾向');
  }
  if (pool.id == 'ringCandidate') {
    reasons.add('武魂、猎魂方式与已有经历共同修正候选魂兽');
  }
  if (pool.id == 'godhoodEvent' || pool.id == 'godhoodOutcome') {
    reasons.add('魂环、武魂、经历与羁绊共同影响神途');
  }
  if (state.invitationMode) {
    reasons.add('本局强化提高优质结果，但仍保留少量普通与风险选项');
  }
  if (baseWeight > 0 && (option.weight / baseWeight - 1).abs() > .01) {
    reasons.add('综合因果修正 ×${(option.weight / baseWeight).toStringAsFixed(2)}');
  }
  if (reasons.isEmpty) reasons.add('当前仅按该选项的基础权重参与判定');
  return ProbabilityBreakdown(
    baseWeight: baseWeight,
    finalWeight: option.weight,
    finalProbability: total <= 0 ? 0 : option.weight / total,
    reasons: reasons,
  );
}
