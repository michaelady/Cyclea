import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/symptom.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:cyclea/widgets/advice_card_view.dart';
import 'package:cyclea/widgets/disclaimer_banner.dart';
import 'package:cyclea/widgets/stat_card.dart';
import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final stats = controller.stats;
    final avg = stats.averageCycleLength;
    final sd = stats.cycleStdDev;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text('Insights', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Personal statistics from your logs, plus short educational advice. Not a diagnosis.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const DisclaimerBanner(),
              const SizedBox(height: 16),
              Row(
                children: [
                  StatCard(
                    label: 'Average cycle',
                    value: avg == null ? '—' : '${avg.toStringAsFixed(1)}d',
                    caption: stats.completeCycleCount == 0
                        ? 'Need 2 period starts'
                        : '${stats.completeCycleCount} complete cycles',
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    label: 'Variability',
                    value: sd == null ? '—' : '±${sd.toStringAsFixed(1)}',
                    caption: stats.irregular ? 'Wider than usual' : 'Sample std. dev.',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  StatCard(
                    label: 'Period length',
                    value: stats.averagePeriodLength == null
                        ? '—'
                        : '${stats.averagePeriodLength!.toStringAsFixed(1)}d',
                    caption: stats.lastPeriodStart == null ? 'Log bleeding days' : 'Average span',
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    label: 'Range',
                    value: stats.minCycle == null ? '—' : '${stats.minCycle}–${stats.maxCycle}',
                    caption: 'Shortest to longest',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Early · on-time · late', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Compared with your own average, counting a cycle as on-time when it is within plus or minus ${stats.onTimeWindowDays} days. This is a personal rhythm score, not a medical grade.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    if (stats.classifiedCount == 0)
                      Text(
                        'Log at least two period starts to classify timing.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else ...[
                      FrequencyBar(
                        label: 'Early',
                        value: stats.earlyRate,
                        color: CycleaColors.sand,
                      ),
                      FrequencyBar(
                        label: 'On-time',
                        value: stats.onTimeRate,
                        color: CycleaColors.sage,
                      ),
                      FrequencyBar(
                        label: 'Late',
                        value: stats.lateRate,
                        color: CycleaColors.rose,
                      ),
                    ],
                    if (stats.cycleLengths.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Recent cycle lengths', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _CycleBars(lengths: stats.cycleLengths),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Symptoms by phase', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Counts of days you logged each symptom, grouped by estimated phase. Phases use your average cycle and a ~14-day luteal assumption.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    for (final phase in [
                      CyclePhase.menstrual,
                      CyclePhase.follicular,
                      CyclePhase.ovulatory,
                      CyclePhase.luteal,
                    ])
                      _PhaseSymptoms(
                        phase: phase,
                        counts: stats.symptomsByPhase[phase] ?? const {},
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Advice cards', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              for (final card in controller.adviceCards) ...[
                AdviceCardView(card: card),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleBars extends StatelessWidget {
  const _CycleBars({required this.lengths});

  final List<int> lengths;

  @override
  Widget build(BuildContext context) {
    final recent = lengths.length > 8 ? lengths.sublist(lengths.length - 8) : lengths;
    final maxLen = recent.reduce((a, b) => a > b ? a : b).toDouble();
    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final length in recent)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$length', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: (length / maxLen).clamp(0.15, 1),
                        widthFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: CycleaColors.rose.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhaseSymptoms extends StatelessWidget {
  const _PhaseSymptoms({required this.phase, required this.counts});

  final CyclePhase phase;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final top = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final shown = top.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(phase.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          if (shown.isEmpty)
            Text('No symptoms logged in this phase yet.', style: Theme.of(context).textTheme.bodySmall)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in shown)
                  Chip(
                    label: Text('${SymptomCatalog.labelFor(entry.key)} · ${entry.value}'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
