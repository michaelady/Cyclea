import 'package:cyclea/domain/prediction.dart';
import 'package:cyclea/domain/symptom.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/widgets/advice_card_view.dart';
import 'package:cyclea/widgets/cycle_ring.dart';
import 'package:cyclea/widgets/disclaimer_banner.dart';
import 'package:cyclea/widgets/log_editor_sheet.dart';
import 'package:cyclea/widgets/phase_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final prediction = controller.prediction;
    final stats = controller.stats;
    final today = DateTime.now();
    final todayLog = controller.logOn(today);
    final hour = today.hour;
    final hello = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cyclea', style: Theme.of(context).textTheme.headlineMedium),
                        Text(
                          '$hello · ${DateFormat.MMMEd().format(today)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(controller.isGuest ? 'Guest' : 'Synced'),
                    avatar: Icon(
                      controller.isGuest ? Icons.visibility_off_outlined : Icons.cloud_done_outlined,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const DisclaimerBanner(),
              const SizedBox(height: 20),
              SurfaceCard(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stack = constraints.maxWidth < 420;
                    final ring = CycleRing(
                      cycleDay: prediction.cycleDay,
                      cycleLength: prediction.expectedCycleLength,
                      phase: prediction.phaseToday,
                    );
                    final details = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhaseChip(phase: prediction.phaseToday),
                        const SizedBox(height: 8),
                        Text(
                          prediction.cycleDay == null
                              ? 'Log a period start to see cycle day and estimates.'
                              : 'Day ${prediction.cycleDay} of a typical ${prediction.expectedCycleLength}-day cycle for you.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (stats.irregular) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Your recent lengths vary, so this placement is approximate.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    );
                    if (stack) {
                      return Column(
                        children: [
                          ring,
                          const SizedBox(height: 12),
                          details,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        ring,
                        const SizedBox(width: 16),
                        Expanded(child: details),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SurfaceCard(
                      child: _ForecastBlock(
                        title: 'Next period',
                        value: _nextPeriodLabel(prediction),
                        caption:
                            '${prediction.confidence.label} · ±${prediction.uncertaintyDays} days',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SurfaceCard(
                      child: _ForecastBlock(
                        title: 'Fertile window',
                        value: _fertileLabel(prediction),
                        caption: 'Calendar estimate only',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                onTap: () => showLogEditor(context, date: today),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Today', style: Theme.of(context).textTheme.titleLarge),
                        const Spacer(),
                        TextButton(
                          onPressed: () => showLogEditor(context, date: today),
                          child: Text(todayLog == null ? 'Log today' : 'Edit today'),
                        ),
                      ],
                    ),
                    if (todayLog == null)
                      Text(
                        'No symptoms or flow logged yet for today.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else ...[
                      if (todayLog.isPeriod)
                        Text(
                          'Period · ${todayLog.flow.label} flow',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (todayLog.symptomIds.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final id in todayLog.symptomIds)
                              Chip(label: Text(SymptomCatalog.labelFor(id))),
                          ],
                        ),
                      ],
                      if (todayLog.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(todayLog.notes, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Advice', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Short educational cards from your stats. Not a diagnosis.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              AdviceCardView(card: controller.adviceCards.first),
              const SizedBox(height: 12),
              if (controller.logs.isEmpty)
                FilledButton.tonal(
                  onPressed: () => showPeriodRangeDialog(context),
                  child: const Text('Log a period range'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _nextPeriodLabel(CyclePrediction prediction) {
    final start = prediction.nextPeriodStart;
    if (start == null) return 'Needs a period start';
    return DateFormat.MMMd().format(start);
  }

  static String _fertileLabel(CyclePrediction prediction) {
    if (prediction.fertileStart == null || prediction.fertileEnd == null) {
      return 'Needs more logs';
    }
    return '${DateFormat.MMMd().format(prediction.fertileStart!)} – ${DateFormat.MMMd().format(prediction.fertileEnd!)}';
  }
}

class _ForecastBlock extends StatelessWidget {
  const _ForecastBlock({
    required this.title,
    required this.value,
    required this.caption,
  });

  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(caption, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
