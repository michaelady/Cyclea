import 'package:cyclea/domain/prediction.dart';
import 'package:cyclea/domain/symptom.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_decor.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:cyclea/widgets/advice_card_view.dart';
import 'package:cyclea/widgets/cycle_ring.dart';
import 'package:cyclea/widgets/cyclea_empty_state.dart';
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
                        const CycleaWordmark(),
                        const SizedBox(height: 4),
                        Text(
                          '$hello · ${DateFormat.MMMEd().format(today)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(controller.isGuest ? 'Guest' : 'Synced'),
                    avatar: CycleaIcon(
                      controller.isGuest ? CycleaGlyph.guest : CycleaGlyph.cloudLeaf,
                      filled: true,
                      size: 16,
                      color: controller.isGuest ? CycleaColors.lilac : CycleaColors.sage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const DisclaimerBanner(),
              const SizedBox(height: 20),
              BloomHero(
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
                              ? 'Log a period start to open the bloom and see cycle day estimates.'
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
                        glyph: CycleaGlyph.drop,
                        title: 'Next period',
                        value: _nextPeriodLabel(prediction),
                        caption: prediction.nextPeriodStart == null
                            ? prediction.confidence.label
                            : '${prediction.confidence.label} · about ${prediction.uncertaintyDays} days of uncertainty',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SurfaceCard(
                      child: _ForecastBlock(
                        glyph: CycleaGlyph.blossom,
                        title: 'Fertile window',
                        value: _fertileLabel(prediction),
                        caption: 'Calendar estimate only',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (todayLog == null)
                CycleaEmptyState(
                  glyph: CycleaGlyph.petal,
                  title: 'Today is still a blank page',
                  body: 'Log flow, a few symptoms, or a quiet note. Nothing is required — this stays on-device in guest mode.',
                  action: FilledButton.tonal(
                    onPressed: () => showLogEditor(context, date: today),
                    child: const Text('Log today'),
                  ),
                )
              else
                SurfaceCard(
                  onTap: () => showLogEditor(context, date: today),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CycleaIcon(CycleaGlyph.sun, filled: true, size: 18),
                          const SizedBox(width: 8),
                          Text('Today', style: Theme.of(context).textTheme.titleLarge),
                          const Spacer(),
                          TextButton(
                            onPressed: () => showLogEditor(context, date: today),
                            child: const Text('Edit today'),
                          ),
                        ],
                      ),
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
                              IconLabelChip(
                                glyph: glyphForSymptom(id),
                                label: SymptomCatalog.labelFor(id),
                              ),
                          ],
                        ),
                      ],
                      if (todayLog.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(todayLog.notes, style: Theme.of(context).textTheme.bodySmall),
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
    required this.glyph,
    required this.title,
    required this.value,
    required this.caption,
  });

  final CycleaGlyph glyph;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CycleaIcon(glyph, filled: true, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(caption, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
