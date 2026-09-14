enum FlowLevel {
  none,
  spotting,
  light,
  medium,
  heavy;

  String get label => switch (this) {
    FlowLevel.none => 'None',
    FlowLevel.spotting => 'Spotting',
    FlowLevel.light => 'Light',
    FlowLevel.medium => 'Medium',
    FlowLevel.heavy => 'Heavy',
  };

  bool get isBleeding => this != FlowLevel.none;

  static FlowLevel fromName(String? name) {
    return FlowLevel.values.firstWhere(
      (value) => value.name == name,
      orElse: () => FlowLevel.none,
    );
  }
}
