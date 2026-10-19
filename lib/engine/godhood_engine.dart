import '../domain/models.dart';

const int maximumDivinityScore = 100;

int calculateDivinityScore(Character character) {
  if (character.status == LifeStatus.dead) return 0;

  final allRings = <SoulRing>[
    ...character.soulRings,
    ...character.secondarySoulRings,
  ];
  var score = 0;
  score += (((character.soulPower - 80).clamp(0, 40)) * .6).round();
  score += (character.soulRings.length * 2).clamp(0, 18);
  score += character.secondarySoulRings.length.clamp(0, 9);
  score += _ringQualityScore(allRings);
  score += _martialSoulScore(character.martialSoul);
  if (character.secondaryMartialSoul != null) {
    score += 4 + _martialSoulScore(character.secondaryMartialSoul) ~/ 2;
  }
  score += _talentScore(character.talent);
  score += ((character.innatePower ?? 0) ~/ 2).clamp(0, 5);
  score += (character.ringCapacityBonus ~/ 10).clamp(0, 6);
  score += (character.luck ~/ 10).clamp(0, 3);
  score += _experienceScore(character.tags);

  final cappedScore = score.clamp(0, maximumDivinityScore);
  if (character.status == LifeStatus.injured) {
    return (cappedScore - 10).clamp(0, maximumDivinityScore);
  }
  return cappedScore;
}

int _ringQualityScore(List<SoulRing> rings) {
  final totalYears = rings.fold<int>(0, (total, ring) => total + ring.years);
  final hundredThousandYearRings = rings
      .where((ring) => ring.years >= 100000)
      .length;
  final specialRings = rings.where(
    (ring) =>
        ring.color == RingColor.gold ||
        ring.color == RingColor.orangeGold ||
        ring.color == RingColor.greenGold ||
        ring.color == RingColor.blueGold ||
        ring.color == RingColor.emerald ||
        ring.color == RingColor.silverViolet ||
        ring.color == RingColor.crimsonGold ||
        ring.color == RingColor.green ||
        ring.color == RingColor.moonWhite ||
        ring.color == RingColor.redBrown ||
        ring.color == RingColor.cyan ||
        ring.color == RingColor.roseGold ||
        ring.color == RingColor.rainbow ||
        _specialRingSources.contains(ring.source),
  );

  final totalYearsScore = (totalYears ~/ 250000).clamp(0, 16);
  final highAgeScore = hundredThousandYearRings.clamp(0, 9);
  final specialScore = (specialRings.length * 2).clamp(0, 6);
  return totalYearsScore + highAgeScore + specialScore;
}

const Set<String> _specialRingSources = <String>{
  '神赐魂环',
  '自愿献祭的魂兽',
  '凶兽本源魂环',
  '生命古树之灵',
};

int _martialSoulScore(String? martialSoul) => switch (martialSoul) {
  '双生武魂' => 10,
  '未知变异武魂' => 8,
  '苍雷龙印' => 7,
  null => 0,
  _ => 3,
};

int _talentScore(String? talent) => switch (talent) {
  '神级潜质' => 8,
  '妖孽' => 7,
  '绝世' => 6,
  '顶尖' => 5,
  '优秀' => 4,
  '良好' => 3,
  '普通' => 2,
  '微弱' => 1,
  _ => 0,
};

int _experienceScore(List<String> tags) {
  const experienceValues = <String, int>{
    '神考资格': 5,
    '海神考核': 7,
    '领域雏形': 5,
    '凶兽认可': 4,
    '深厚羁绊': 3,
    '武魂领悟': 3,
    '精神海扩张': 3,
    '战场经验': 2,
    '命运回响': 2,
  };
  final score = tags.fold<int>(
    0,
    (total, tag) => total + (experienceValues[tag] ?? 0),
  );
  return score.clamp(0, 20);
}
