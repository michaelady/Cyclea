import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';
import 'package:cyclea/domain/symptom.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/widgets/period_range_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<bool> confirmDeleteDay(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete this day?'),
      content: const Text(
        'This removes the period mark, flow, symptoms, and notes for this date. Other days in the period stay logged.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

Future<void> showLogEditor(BuildContext context, {required DateTime date}) {
  final day = dateOnly(date);
  final existing = AppScope.of(context).logOn(day);
  if (day.isAfter(dateOnly(DateTime.now())) && existing == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can log today or earlier days.')),
    );
    return Future.value();
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    enableDrag: false,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration.zero,
      reverseDuration: Duration(milliseconds: 80),
    ),
    builder: (context) => LogEditorSheet(date: day, existing: existing),
  );
}

class LogEditorSheet extends StatefulWidget {
  const LogEditorSheet({super.key, required this.date, this.existing});

  final DateTime date;
  final DailyLog? existing;

  @override
  State<LogEditorSheet> createState() => _LogEditorSheetState();
}

class _LogEditorSheetState extends State<LogEditorSheet> {
  late bool _period;
  late FlowLevel _flow;
  late Set<String> _symptoms;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _period = existing?.isPeriod ?? false;
    _flow = existing?.flow ?? FlowLevel.none;
    _symptoms = {...?existing?.symptomIds};
    _notes = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (dateOnly(widget.date).isAfter(dateOnly(DateTime.now()))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can log today or earlier days.')),
      );
      return;
    }
    final controller = AppScope.of(context);
    await controller.saveLog(
      DailyLog(
        date: widget.date,
        isPeriod: _period,
        flow: _period
            ? (_flow == FlowLevel.none ? FlowLevel.medium : _flow)
            : FlowLevel.none,
        symptomIds: _symptoms,
        notes: _notes.text.trim(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await confirmDeleteDay(context);
    if (!confirmed || !mounted) return;
    await AppScope.of(context).deleteLog(widget.date);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final existing = AppScope.of(context).logOn(widget.date);
    final dateLabel = DateFormat.yMMMEd().format(widget.date);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Edit or delete this day’s log. Period days can be marked one at a time or as a range from Calendar.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Period day'),
              subtitle: const Text('Start, middle, or end of bleeding'),
              secondary: const CycleaIcon(
                CycleaGlyph.drop,
                filled: true,
                size: 22,
              ),
              value: _period,
              onChanged: (value) => setState(() {
                _period = value;
                if (value && _flow == FlowLevel.none) _flow = FlowLevel.medium;
                if (!value) _flow = FlowLevel.none;
              }),
            ),
            if (_period) ...[
              const SizedBox(height: 8),
              Text('Flow', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final level in FlowLevel.values.where(
                    (item) => item != FlowLevel.none,
                  ))
                    ChoiceChip(
                      visualDensity: VisualDensity.standard,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      avatar: CycleaIcon(
                        CycleaGlyph.drop,
                        filled: _flow == level,
                        size: 16,
                      ),
                      label: Text(level.label),
                      selected: _flow == level,
                      onSelected: (_) => setState(() => _flow = level),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Text('Symptoms', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _symptomGroup('Physical', SymptomCategory.physical),
            _symptomGroup('Energy', SymptomCategory.energy),
            _symptomGroup('Mood', SymptomCategory.mood),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (existing != null)
                  TextButton(
                    onPressed: _delete,
                    child: const Text('Delete day'),
                  ),
                const Spacer(),
                FilledButton(onPressed: _save, child: const Text('Save log')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _symptomGroup(String title, SymptomCategory category) {
    final items = SymptomCatalog.all.where((item) => item.category == category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                FilterChip(
                  visualDensity: VisualDensity.standard,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  avatar: CycleaIcon(
                    glyphForSymptom(item.id),
                    filled: _symptoms.contains(item.id),
                    size: 16,
                  ),
                  label: Text(item.label),
                  selected: _symptoms.contains(item.id),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _symptoms.add(item.id);
                      } else {
                        _symptoms.remove(item.id);
                      }
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showPeriodRangeDialog(BuildContext context) async {
  final controller = AppScope.of(context);
  final today = dateOnly(DateTime.now());
  final range = await showGeneralDialog<DateTimeRange>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss period range',
    transitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: PeriodRangeDialog(
          today: today,
          firstDate: DateTime(today.year - 2, today.month, today.day),
        ),
      );
    },
  );
  if (range == null) return;
  await controller.markPeriodRange(range.start, range.end);
}
