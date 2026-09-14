enum SymptomCategory { physical, energy, mood }

class SymptomDef {
  const SymptomDef({
    required this.id,
    required this.label,
    required this.category,
  });

  final String id;
  final String label;
  final SymptomCategory category;
}

class SymptomCatalog {
  static const List<SymptomDef> all = [
    SymptomDef(id: 'cramps', label: 'Cramps', category: SymptomCategory.physical),
    SymptomDef(id: 'headache', label: 'Headache', category: SymptomCategory.physical),
    SymptomDef(id: 'bloating', label: 'Bloating', category: SymptomCategory.physical),
    SymptomDef(
      id: 'breast_tenderness',
      label: 'Breast tenderness',
      category: SymptomCategory.physical,
    ),
    SymptomDef(id: 'back_pain', label: 'Back pain', category: SymptomCategory.physical),
    SymptomDef(id: 'acne', label: 'Acne', category: SymptomCategory.physical),
    SymptomDef(id: 'nausea', label: 'Nausea', category: SymptomCategory.physical),
    SymptomDef(
      id: 'pelvic_pain',
      label: 'Pelvic pain',
      category: SymptomCategory.physical,
    ),
    SymptomDef(
      id: 'digestive',
      label: 'Digestive changes',
      category: SymptomCategory.physical,
    ),
    SymptomDef(id: 'dizziness', label: 'Dizziness', category: SymptomCategory.physical),
    SymptomDef(
      id: 'joint_pain',
      label: 'Joint pain',
      category: SymptomCategory.physical,
    ),
    SymptomDef(
      id: 'appetite_up',
      label: 'Increased appetite',
      category: SymptomCategory.physical,
    ),
    SymptomDef(
      id: 'appetite_down',
      label: 'Low appetite',
      category: SymptomCategory.physical,
    ),
    SymptomDef(id: 'cravings', label: 'Cravings', category: SymptomCategory.physical),
    SymptomDef(id: 'fatigue', label: 'Fatigue', category: SymptomCategory.energy),
    SymptomDef(
      id: 'high_energy',
      label: 'High energy',
      category: SymptomCategory.energy,
    ),
    SymptomDef(
      id: 'sleep_issues',
      label: 'Sleep changes',
      category: SymptomCategory.energy,
    ),
    SymptomDef(
      id: 'brain_fog',
      label: 'Brain fog',
      category: SymptomCategory.energy,
    ),
    SymptomDef(
      id: 'mood_swings',
      label: 'Mood swings',
      category: SymptomCategory.mood,
    ),
    SymptomDef(id: 'anxiety', label: 'Anxiety', category: SymptomCategory.mood),
    SymptomDef(
      id: 'irritability',
      label: 'Irritability',
      category: SymptomCategory.mood,
    ),
    SymptomDef(id: 'low_mood', label: 'Low mood', category: SymptomCategory.mood),
    SymptomDef(id: 'tearful', label: 'Tearful', category: SymptomCategory.mood),
    SymptomDef(id: 'calm', label: 'Calm / content', category: SymptomCategory.mood),
  ];

  static final Map<String, SymptomDef> byId = {
    for (final symptom in all) symptom.id: symptom,
  };

  static String labelFor(String id) => byId[id]?.label ?? id;
}
