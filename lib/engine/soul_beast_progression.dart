import '../domain/models.dart';

const int soulBeastStoryWindowYears = 30;

int soulBeastAgeDelta(int rawYears) => rawYears.clamp(1, 3).toInt();

bool isSoulBeastAgeWindowComplete(Character character) =>
    character.lifeStartAge > 0 &&
    character.age >= character.lifeStartAge + soulBeastStoryWindowYears;

int protagonistYearFor(Character character) {
  final elapsed = character.route == RouteType.soulBeast
      ? character.age - character.lifeStartAge
      : character.age;
  return character.protagonistOffset + elapsed;
}

int soulBeastCultivationGrowth({
  required int currentYears,
  required int elapsedYears,
  required int rate,
}) {
  final acceleration = switch (currentYears) {
    >= 500000 => 900,
    >= 100000 => 700,
    >= 10000 => 320,
    >= 1000 => 130,
    >= 100 => 18,
    _ => 12,
  };
  return (elapsedYears.clamp(1, 3) * rate * acceleration)
      .clamp(1, 1000000)
      .toInt();
}
