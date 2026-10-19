class SeededRandom {
  SeededRandom._(this._state);

  factory SeededRandom.fromSeed(String seed) {
    var hash = 0x811c9dc5;
    for (final unit in seed.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return SeededRandom._(hash == 0 ? 0x6d2b79f5 : hash);
  }

  factory SeededRandom.fromState(int state) => SeededRandom._(
    (state & 0xffffffff) == 0 ? 0x6d2b79f5 : state & 0xffffffff,
  );

  int _state;

  int get state => _state;

  int _nextUint32() {
    _state ^= (_state << 13) & 0xffffffff;
    _state ^= _state >> 17;
    _state ^= (_state << 5) & 0xffffffff;
    _state &= 0xffffffff;
    return _state;
  }

  double nextDouble() => _nextUint32() / 0x100000000;

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', '必须是正整数');
    }
    return _nextUint32() % max;
  }
}
