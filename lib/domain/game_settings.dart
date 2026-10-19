class GameSettings {
  const GameSettings({
    this.fastMode = false,
    this.skipAnimations = false,
    this.haptics = true,
    this.sounds = true,
  });

  final bool fastMode;
  final bool skipAnimations;
  final bool haptics;
  final bool sounds;

  GameSettings copyWith({
    bool? fastMode,
    bool? skipAnimations,
    bool? haptics,
    bool? sounds,
  }) => GameSettings(
    fastMode: fastMode ?? this.fastMode,
    skipAnimations: skipAnimations ?? this.skipAnimations,
    haptics: haptics ?? this.haptics,
    sounds: sounds ?? this.sounds,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'fastMode': fastMode,
    'skipAnimations': skipAnimations,
    'haptics': haptics,
    'sounds': sounds,
  };

  factory GameSettings.fromJson(Map<String, Object?> json) => GameSettings(
    fastMode: json['fastMode'] as bool? ?? false,
    skipAnimations: json['skipAnimations'] as bool? ?? false,
    haptics: json['haptics'] as bool? ?? true,
    sounds: json['sounds'] as bool? ?? true,
  );

  @override
  bool operator ==(Object other) =>
      other is GameSettings &&
      other.fastMode == fastMode &&
      other.skipAnimations == skipAnimations &&
      other.haptics == haptics &&
      other.sounds == sounds;

  @override
  int get hashCode => Object.hash(fastMode, skipAnimations, haptics, sounds);
}
