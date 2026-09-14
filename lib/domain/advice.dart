class AdviceCard {
  const AdviceCard({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
  });

  final String id;
  final String title;
  final String body;
  final String tag;
}

class LegalCopy {
  static const productName = 'Cyclea';

  static const shortDisclaimer =
      'Cyclea is not medical advice and is not a contraceptive. Predictions are calendar estimates from your logs.';

  static const fullDisclaimer =
      'Cyclea is a personal tracking and education tool. It is not a medical device, is not intended to diagnose, treat, cure, or prevent any condition, and is not a contraceptive or fertility-treatment product.\n\n'
      'Predictions such as next period and the fertile window are statistical estimates based on the dates you log. They can be wrong — especially with irregular cycles, stress, travel, medication, or health changes. Do not use Cyclea to avoid or achieve pregnancy.\n\n'
      'If you have concerns about your cycle, bleeding, pain, or health, talk to a qualified clinician. Cyclea does not sell health data and does not show ads.';

  static const privacySummary =
      'Logs stay on this device in guest mode. If you sign in with Google, encrypted-in-transit copies sync to your private Cloud Firestore documents. We do not sell health data or run ads. You can delete all app data from Settings.';
}
