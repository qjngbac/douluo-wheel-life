import 'seeded_random.dart';

class Weighted<T> {
  const Weighted({required this.value, required this.weight});

  final T value;
  final double weight;
}

T pickWeighted<T>(List<Weighted<T>> options, SeededRandom random) {
  final available = options
      .where((option) => option.weight.isFinite && option.weight > 0)
      .toList(growable: false);
  final total = available.fold<double>(0, (sum, option) => sum + option.weight);

  if (available.isEmpty || total <= 0) {
    throw StateError('没有可用的命运选项');
  }

  final target = random.nextDouble() * total;
  var cursor = 0.0;
  for (final option in available) {
    cursor += option.weight;
    if (target < cursor) {
      return option.value;
    }
  }
  return available.last.value;
}
