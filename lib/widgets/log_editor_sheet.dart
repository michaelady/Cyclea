import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';
import 'package:cyclea/domain/symptom.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showLogEditor(BuildContext context, {required DateTime date}) {
  final existing = AppScope.of(context).logOn(date);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => LogEditorSheet(date: dateOnly(date), existing: existing),
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
    final controller = AppScope.of(context);
    await controller.saveLog(
      DailyLog(
        date: widget.date,
        isPeriod: _period,
        flow: _period ? (_flow == FlowLevel.none ? FlowLevel.medium : _flow) : FlowLevel.none,
        symptomIds: _symptoms,
        notes: _notes.text.trim(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
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
                  for (final level in FlowLevel.values.where((item) => item != FlowLevel.none))
                    ChoiceChip(
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
  final now = DateTime.now();
  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 2),
    lastDate: DateTime(now.year + 1),
    initialDateRange: DateTimeRange(start: now, end: now),
    helpText: 'Period start and end',
  );
  if (range == null) return;
  await controller.markPeriodRange(range.start, range.end);
}
