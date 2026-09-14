import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:cyclea/widgets/disclaimer_banner.dart';
import 'package:cyclea/widgets/log_editor_sheet.dart';
import 'package:cyclea/widgets/phase_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focused;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(DateTime.now());
    _focused = today;
    _selected = today;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final prediction = controller.prediction;
    final stats = controller.stats;
    final selectedLog = controller.logOn(_selected);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Calendar', style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  FilledButton.tonal(
                    onPressed: () => showPeriodRangeDialog(context),
                    child: const Text('Log period range'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const DisclaimerBanner(),
              const SizedBox(height: 12),
              const CalendarLegend(),
              const SizedBox(height: 8),
              Card(
                child: TableCalendar<void>(
                  firstDay: DateTime.utc(DateTime.now().year - 2, 1, 1),
                  lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
                  focusedDay: _focused,
                  selectedDayPredicate: (day) => isSameDay(day, _selected),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(color: scheme.onSurface),
                  ),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selected = dateOnly(selected);
                      _focused = focused;
                    });
                  },
                  onPageChanged: (focused) => _focused = focused,
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focused) => _dayCell(day, selected: false),
                    todayBuilder: (context, day, focused) => _dayCell(day, selected: false, today: true),
                    selectedBuilder: (context, day, focused) => _dayCell(day, selected: true),
                    markerBuilder: (context, day, events) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMMEEEEd().format(_selected),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(_statusLine(controller, _selected), style: Theme.of(context).textTheme.bodyMedium),
                    if (selectedLog?.symptomIds.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${selectedLog!.symptomIds.length} symptom${selectedLog.symptomIds.length == 1 ? '' : 's'} logged',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (selectedLog?.notes.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(selectedLog!.notes),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: () => showLogEditor(context, date: _selected),
                          child: Text(selectedLog == null ? 'Add log' : 'Edit log'),
                        ),
                        if (selectedLog != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => controller.deleteLog(_selected),
                            child: const Text('Delete'),
                          ),
                        ],
                      ],
                    ),
                    if (stats.lastPeriodStart == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Predicted days appear after you log at least one period start. Uncertainty stays wide until a few cycles exist.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ] else if (prediction.irregular || prediction.usedDefaultCycle) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Shaded prediction days are uncertain (${prediction.confidence.label}). Irregular cycles are OK — the window is just wider.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayCell(DateTime day, {required bool selected, bool today = false}) {
    final controller = AppScope.of(context);
    final log = controller.logOn(day);
    final prediction = controller.prediction;
    Color? fill;
    Color? border;
    if (log != null && (log.isPeriod || log.flow.isBleeding)) {
      fill = CycleaColors.rose.withValues(alpha: selected ? 1 : 0.85);
    } else if (prediction.isFertile(day)) {
      fill = CycleaColors.sage.withValues(alpha: 0.35);
      border = CycleaColors.sage;
    } else if (prediction.isPredictedPeriod(day)) {
      fill = CycleaColors.sand.withValues(alpha: 0.4);
      border = CycleaColors.sand;
    } else if (prediction.isPredictedPeriodBand(day)) {
      border = CycleaColors.sand.withValues(alpha: 0.7);
    }
    final textColor = fill != null && (log?.isPeriod ?? false)
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: selected && fill == null ? Theme.of(context).colorScheme.primary : fill,
        shape: BoxShape.circle,
        border: border == null ? null : Border.all(color: border, width: today || selected ? 2 : 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: selected && fill == null ? Colors.white : textColor,
          fontWeight: today || selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  String _statusLine(CycleController controller, DateTime day) {
    final log = controller.logOn(day);
    if (log != null && log.isPeriod) return 'Logged period · ${log.flow.label} flow';
    if (controller.prediction.isFertile(day)) {
      return 'Inside the estimated fertile window (not contraception).';
    }
    if (controller.prediction.isPredictedPeriod(day)) {
      return 'Predicted period day (about ${controller.prediction.uncertaintyDays} days of uncertainty).';
    }
    if (log != null) return 'Symptoms or notes logged.';
    return 'No log yet. Tap Add log to edit this day.';
  }
}
