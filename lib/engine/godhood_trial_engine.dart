import '../domain/models.dart';
import '../data/godhood_data.dart';

const List<String> godTrialStageTitles = <String>['神念问心', '法则淬体', '众生抉择'];

WheelPool buildGodhoodTrialPool(GameState state) {
  final step = state.godTrialStep.clamp(0, 2);
  final character = state.character;
  final profile = godhoodPaths
      .where((item) => item.id == state.pendingGodPathId)
      .firstOrNull;
  final authority = profile?.majorName ?? '未知神途';
  final plane = profile?.planeName ?? '众生世界';
  final hasDeepBond = state.relationships.any(
    (item) => item.alive && item.trust >= 60,
  );
  final lawReady = character.divinityScore >= 55 || character.soulPower >= 105;
  final options = <WheelOption>[
    WheelOption(
      id: 'trial-hold-heart',
      text: step == 0 ? '在$authority神念前守住本心' : '守住本心稳步驾驭$authority',
      weight: 30,
      effects: const <String, int>{'trialScore': 2},
    ),
    WheelOption(
      id: 'trial-law-resonance',
      text: '让武魂与$authority法则共鸣',
      weight: lawReady ? 30 : 18,
      effects: const <String, int>{'trialScore': 3},
    ),
    WheelOption(
      id: 'trial-bond',
      text: '借$plane众生羁绊锚定自我',
      weight: hasDeepBond ? 30 : 8,
      effects: const <String, int>{'trialScore': 3},
    ),
    const WheelOption(
      id: 'trial-break-limit',
      text: '燃烧潜能强渡神考',
      weight: 12,
      effects: <String, int>{'trialScore': 4, 'injury': 1},
    ),
    const WheelOption(
      id: 'trial-sacrifice',
      text: '舍弃一切只求登临神位',
      weight: 5,
      effects: <String, int>{'trialScore': 5, 'injury': 1},
    ),
    const WheelOption(
      id: 'trial-hesitate',
      text: '在神威前迟疑退让',
      weight: 9,
      effects: <String, int>{'trialScore': 0},
    ),
    const WheelOption(
      id: 'trial-lose-self',
      text: '迷失于神位带来的权柄',
      weight: 2,
      effects: <String, int>{'trialScore': -2},
    ),
    WheelOption(
      id: 'trial-protect-plane',
      text: '替$plane承受一次法则反噬',
      weight: hasDeepBond ? 16 : 7,
      effects: const <String, int>{'trialScore': 3, 'injury': 1},
    ),
    WheelOption(
      id: 'trial-seize-authority',
      text: '强行夺取$authority核心权柄',
      weight: lawReady ? 8 : 3,
      effects: const <String, int>{'trialScore': 4, 'injury': 2},
    ),
    const WheelOption(
      id: 'trial-seek-guidance',
      text: '追寻前代神祇留下的残念指引',
      weight: 12,
      effects: <String, int>{'trialScore': 2},
    ),
  ];
  return WheelPool(
    id: 'godhoodTrial',
    title: '第${step + 1}重神考·$authority·${godTrialStageTitles[step]}',
    options: options,
  );
}
