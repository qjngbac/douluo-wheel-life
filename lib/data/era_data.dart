class EraProfile {
  const EraProfile({
    required this.id,
    required this.title,
    required this.protagonist,
    required this.factionIds,
  });

  final String id;
  final String title;
  final String protagonist;
  final List<String> factionIds;
}

const List<EraProfile> eraProfiles = <EraProfile>[
  EraProfile(
    id: 'era-douluo-1',
    title: '斗罗一·唐三时代',
    protagonist: '唐三',
    factionIds: <String>[
      'faction-shrek-1',
      'faction-wuhun',
      'faction-tiandou',
      'faction-xingluo',
      'faction-sect-1',
    ],
  ),
  EraProfile(
    id: 'era-peerless',
    title: '绝世唐门·霍雨浩时代',
    protagonist: '霍雨浩',
    factionIds: <String>[
      'faction-shrek-2',
      'faction-sunmoon',
      'faction-tangmen-2',
    ],
  ),
  EraProfile(
    id: 'era-legend',
    title: '龙王传说·唐舞麟时代',
    protagonist: '唐舞麟',
    factionIds: <String>[
      'faction-shrek-3',
      'faction-tangmen-3',
      'faction-spirit-pagoda',
      'faction-east-sea',
    ],
  ),
  EraProfile(
    id: 'era-ultimate',
    title: '终极斗罗·蓝轩宇时代',
    protagonist: '蓝轩宇',
    factionIds: <String>[
      'faction-shrek-4',
      'faction-federation',
      'faction-tangmen-4',
    ],
  ),
];

EraProfile profileForEraId(String? eraId) => eraProfiles.firstWhere(
  (profile) => profile.id == eraId,
  orElse: () => eraProfiles.first,
);

int timelineOffsetForId(String timelineId) => switch (timelineId) {
  'time-before-5' => -5,
  'time-before-4' => -4,
  'time-before-3' => -3,
  'time-before-2' => -2,
  'time-before-1' => -1,
  'time-birth' => 0,
  'time-after-1' => 1,
  'time-after-2' => 2,
  'time-after-3' => 3,
  'time-after-4' => 4,
  'time-after-5' => 5,
  _ => 0,
};

String timelineLabelFor(String timelineId, EraProfile profile) {
  final offset = timelineOffsetForId(timelineId);
  return '${profile.protagonist}${relativeYearLabel(offset)}'.replaceAll(
    ' ',
    '',
  );
}

String relativeYearLabel(int offset) {
  if (offset == 0) return '出生当年';
  final direction = offset < 0 ? '前' : '后';
  return '出生$direction ${offset.abs()} 年';
}
