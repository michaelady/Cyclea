enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
  unknown;

  String get label => switch (this) {
    CyclePhase.menstrual => 'Menstrual',
    CyclePhase.follicular => 'Follicular',
    CyclePhase.ovulatory => 'Fertile window',
    CyclePhase.luteal => 'Luteal',
    CyclePhase.unknown => 'Unspecified',
  };

  String get shortLabel => switch (this) {
    CyclePhase.menstrual => 'Period',
    CyclePhase.follicular => 'Follicular',
    CyclePhase.ovulatory => 'Fertile',
    CyclePhase.luteal => 'Luteal',
    CyclePhase.unknown => '—',
  };

  String get blurb => switch (this) {
    CyclePhase.menstrual =>
      'Bleeding days. Energy and comfort often vary; rest and iron-rich meals can help some people.',
    CyclePhase.follicular =>
      'After bleeding, many people notice energy gradually returning as the next ovulation approaches.',
    CyclePhase.ovulatory =>
      'The calendar fertile window is an estimate around likely ovulation — not a contraception or conception tool.',
    CyclePhase.luteal =>
      'The stretch after ovulation. PMS-type symptoms are more common here for some people.',
    CyclePhase.unknown =>
      'Log a period start so Cyclea can estimate where you are in your cycle.',
  };
}
