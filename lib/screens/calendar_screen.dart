import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/widgets/disclaimer_banner.dart';
import 'package:cyclea/widgets/calendar_markers.dart';
import 'package:cyclea/widgets/log_editor_sheet.dart';
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
    final futureDay = dateOnly(_selected).isAfter(dateOnly(DateTime.now()));
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
                  CycleaIcon(
                    CycleaGlyph.calendarBloom,
                    filled: true,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Calendar',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  FilledButton.tonal(
                    style: const ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(44, 48)),
                      tapTargetSize: MaterialTapTargetSize.padded,
                      visualDensity: VisualDensity.standard,
                    ),
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
                  pageAnimationEnabled: false,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: const CalendarStyle(
                    cellMargin: EdgeInsets.symmetric(vertical: 3),
                    outsideDaysVisible: false,
                  ),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selected = dateOnly(selected);
                      _focused = focused;
                    });
                  },
                  onPageChanged: (focused) => _focused = focused,
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focused) =>
                        _dayCell(day, selected: false),
                    todayBuilder: (context, day, focused) =>
                        _dayCell(day, selected: false, today: true),
                    selectedBuilder: (context, day, focused) =>
                        _dayCell(day, selected: true),
                    markerBuilder: (context, day, events) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CycleaIcon(
                          CycleaGlyph.petal,
                          filled: true,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat.yMMMMEEEEd().format(_selected),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _statusLine(controller, _selected),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
                    if (futureDay && selectedLog == null)
                      Text(
                        'You can view estimates for later days. Logs can only be saved for today or earlier.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () =>
                                showLogEditor(context, date: _selected),
                            child: Text(
                              selectedLog == null ? 'Add log' : 'Edit log',
                            ),
                          ),
                          if (selectedLog != null) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () async {
                                final confirmed = await confirmDeleteDay(
                                  context,
                                );
                                if (!confirmed || !context.mounted) return;
                                await controller.deleteLog(_selected);
                              },
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
                    ] else if (prediction.irregular ||
                        prediction.usedDefaultCycle) ...[
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
    final logged = log != null && (log.isPeriod || log.flow.isBleeding);
    final ovulation = !logged && prediction.isOvulation(day);
    final predicted = !logged && prediction.isPredictedPeriod(day);
    final fertile =
        !logged && !predicted && (prediction.isFertile(day) || ovulation);
    final band =
        !logged &&
        !fertile &&
        !predicted &&
        prediction.isPredictedPeriodBand(day);

    bool shares(DateTime other) {
      final otherLog = controller.logOn(other);
      final otherLogged =
          otherLog != null && (otherLog.isPeriod || otherLog.flow.isBleeding);
      if (logged) return otherLogged;
      final otherPredicted =
          !otherLogged && prediction.isPredictedPeriod(other);
      if (predicted) return otherPredicted;
      final otherFertile =
          !otherLogged &&
          !otherPredicted &&
          (prediction.isFertile(other) || prediction.isOvulation(other));
      return (fertile || ovulation) && otherFertile;
    }

    final previous = day.subtract(const Duration(days: 1));
    final following = day.add(const Duration(days: 1));
    return CalendarDayMarker(
      day: day.day,
      logged: logged,
      predicted: predicted,
      fertile: fertile,
      ovulation: ovulation,
      band: band,
      today: today,
      selected: selected,
      joinLeft: shares(previous),
      joinRight: shares(following),
      symptomDots: log?.symptomIds.length ?? 0,
    );
  }

  String _statusLine(CycleController controller, DateTime day) {
    final log = controller.logOn(day);
    if (log != null && log.isPeriod) {
      return 'Logged period · ${log.flow.label} flow';
    }
    if (controller.prediction.isOvulation(day)) {
      return 'Estimated ovulation day. A calendar guess, not a test.';
    }
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
