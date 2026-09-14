import 'package:cyclea/domain/advice.dart';
import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/cycle_stats.dart';
import 'package:cyclea/domain/prediction.dart';
import 'package:cyclea/domain/symptom.dart';

class AdviceEngine {
  static List<AdviceCard> cardsFor({
    required CycleStats stats,
    required CyclePrediction prediction,
  }) {
    final cards = <AdviceCard>[
      const AdviceCard(
        id: 'not-contraception',
        title: 'Estimates, not contraception',
        body:
            'Next-period and fertile-window dates are calendar guesses from your logs. They are not a method to avoid or achieve pregnancy, and they are not a lab or ultrasound result.',
        tag: 'Important',
      ),
      AdviceCard(
        id: 'phase',
        title: _phaseTitle(prediction.phaseToday),
        body: prediction.phaseToday.blurb,
        tag: 'This phase',
      ),
    ];

    if (stats.completeCycleCount >= 2 && stats.averageCycleLength != null) {
      final avg = stats.averageCycleLength!.toStringAsFixed(1);
      final sd = stats.cycleStdDev?.toStringAsFixed(1) ?? '—';
      cards.add(
        AdviceCard(
          id: 'your-length',
          title: 'Your cycle is a range',
          body:
              'Across ${stats.completeCycleCount} logged cycles, your average length is $avg days (variation ±$sd). '
              'A “normal” cycle is often described as roughly 21–35 days, but your pattern matters more than a textbook 28.',
          tag: 'Your stats',
        ),
      );
    } else {
      cards.add(
        const AdviceCard(
          id: 'log-more',
          title: 'Predictions improve with a few cycles',
          body:
              'Log period start and end as they happen. After two or more complete cycles, Cyclea can show your personal average, variability, and early/late rhythm.',
          tag: 'Getting started',
        ),
      );
    }

    if (stats.irregular) {
      cards.add(
        const AdviceCard(
          id: 'irregular',
          title: 'Irregular can still be trackable',
          body:
              'Your recent cycle lengths spread out more than average. That is common and has many non-serious causes, but only a clinician can interpret it for you. Cyclea widens the uncertainty band instead of pretending you have a clockwork 28-day cycle.',
          tag: 'Your pattern',
        ),
      );
    } else if (stats.classifiedCount >= 3) {
      final onTimePct = (stats.onTimeRate * 100).round();
      cards.add(
        AdviceCard(
          id: 'timing',
          title: 'On-time vs early vs late',
          body:
              '$onTimePct% of your logged cycles landed within ±${stats.onTimeWindowDays} days of your own average. '
              'Early and late here only means compared with you — not a diagnosis.',
          tag: 'Your stats',
        ),
      );
    }

    final lutealTop = _topSymptom(stats.symptomsByPhase[CyclePhase.luteal] ?? {});
    final periodTop = _topSymptom(stats.symptomsByPhase[CyclePhase.menstrual] ?? {});
    if (lutealTop != null) {
      cards.add(
        AdviceCard(
          id: 'luteal-symptom',
          title: 'A luteal-phase pattern',
          body:
              '${SymptomCatalog.labelFor(lutealTop)} showed up most often in your luteal-phase logs. '
              'Patterns like this can help you plan rest or routines. They do not diagnose PMDD, anemia, or any condition.',
          tag: 'Symptoms',
        ),
      );
    }
    if (periodTop != null && periodTop != lutealTop) {
      cards.add(
        AdviceCard(
          id: 'period-symptom',
          title: 'During bleeding',
          body:
              '${SymptomCatalog.labelFor(periodTop)} is your most-logged period-day symptom so far. '
              'Heat, hydration, and iron-rich meals help some people; others need clinical care for pain or very heavy bleeding.',
          tag: 'Symptoms',
        ),
      );
    }

    cards.add(
      const AdviceCard(
        id: 'iron',
        title: 'Period days and iron (education)',
        body:
            'Menstrual blood loss can contribute to low iron for some people. Foods such as beans, lentils, leafy greens, and fortified grains are commonly discussed in general nutrition education — not a diet prescription from Cyclea.',
        tag: 'Education',
      ),
    );
    cards.add(
      const AdviceCard(
        id: 'luteal-science',
        title: 'Why the fertile window is ~mid-cycle',
        body:
            'The luteal phase (after ovulation) is often closer to 12–16 days than the first half of the cycle. Cyclea therefore estimates ovulation by counting backward about 14 days from your typical next period — then draws a multi-day window around that guess.',
        tag: 'Education',
      ),
    );
    cards.add(
      const AdviceCard(
        id: 'clinician',
        title: 'When to talk to a clinician',
        body:
            'Seek in-person care for soaking through protection hourly, bleeding after menopause, severe pain, pregnancy concern, or a sudden lasting change in your cycle. Cyclea cannot triage emergencies.',
        tag: 'Education',
      ),
    );

    return cards;
  }

  static String _phaseTitle(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstrual => 'You are on a logged period day',
      CyclePhase.follicular => 'Follicular-phase snapshot',
      CyclePhase.ovulatory => 'Inside the estimated fertile window',
      CyclePhase.luteal => 'Luteal-phase snapshot',
      CyclePhase.unknown => 'Log a period to place today',
    };
  }

  static String? _topSymptom(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.first.value < 2) return null;
    return entries.first.key;
  }
}
