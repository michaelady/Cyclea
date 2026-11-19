import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Period start/end picker.
///
/// Days after [today] cannot be selected. Taps use pointer-down so a second
/// date registers immediately, including the tap that follows the dialog open.
class PeriodRangeDialog extends StatefulWidget {
  const PeriodRangeDialog({
    super.key,
    required this.today,
    required this.firstDate,
  });

  final DateTime today;
  final DateTime firstDate;

  @override
  State<PeriodRangeDialog> createState() => _PeriodRangeDialogState();
}

class _PeriodRangeDialogState extends State<PeriodRangeDialog> {
  late DateTime _visibleMonth;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(widget.today);
    _visibleMonth = DateTime(today.year, today.month);
  }

  DateTime get _today => dateOnly(widget.today);

  bool _selectable(DateTime day) {
    final date = dateOnly(day);
    return !date.isAfter(_today) && !date.isBefore(dateOnly(widget.firstDate));
  }

  void _onDay(DateTime day) {
    if (!_selectable(day)) return;
    final date = dateOnly(day);
    setState(() {
      final start = _start;
      final end = _end;
      if (start == null || end != null) {
        _start = date;
        _end = null;
      } else if (date.isBefore(start)) {
        _end = start;
        _start = date;
      } else {
        _end = date;
      }
    });
  }

  void _shiftMonth(int delta) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    final earliest = DateTime(widget.firstDate.year, widget.firstDate.month);
    final latest = DateTime(_today.year, _today.month);
    if (next.isBefore(earliest) || next.isAfter(latest)) return;
    setState(() => _visibleMonth = next);
  }

  String get _selectionLabel {
    final start = _start;
    final end = _end;
    if (start == null) return 'Choose a start date';
    final startLabel = DateFormat.MMMd().format(start);
    if (end == null) return '$startLabel – End date';
    return '$startLabel – ${DateFormat.MMMd().format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final earliest = DateTime(widget.firstDate.year, widget.firstDate.month);
    final latest = DateTime(_today.year, _today.month);
    final canGoBack = _visibleMonth.isAfter(earliest);
    final canGoForward = _visibleMonth.isBefore(latest);
    final days = _monthCells(_visibleMonth);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Period start and end',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Choose the first bleeding day, then the last. Today is the latest day you can log.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                _selectionLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    key: const Key('period-range-prev'),
                    onPressed: canGoBack ? () => _shiftMonth(-1) : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous month',
                  ),
                  Expanded(
                    child: Text(
                      DateFormat.yMMMM().format(_visibleMonth),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    key: const Key('period-range-next'),
                    onPressed: canGoForward ? () => _shiftMonth(1) : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next month',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (final label in const [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ])
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              for (final week in days)
                Row(
                  children: [
                    for (final day in week)
                      Expanded(
                        child: day == null
                            ? const SizedBox(height: 44)
                            : _DayCell(
                                day: day,
                                enabled: _selectable(day),
                                selected: _isEndpoint(day),
                                inRange: _inRange(day),
                                onTap: () => _onDay(day),
                              ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('period-range-save'),
                    onPressed: _start == null || _end == null
                        ? null
                        : () => Navigator.of(context)
                              .pop(DateTimeRange(start: _start!, end: _end!)),
                    child: const Text('Save range'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isEndpoint(DateTime day) {
    final date = dateOnly(day);
    return date == _start || date == _end;
  }

  bool _inRange(DateTime day) {
    final start = _start;
    final end = _end;
    if (start == null || end == null) return false;
    final date = dateOnly(day);
    return !date.isBefore(start) && !date.isAfter(end);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.enabled,
    required this.selected,
    required this.inRange,
    required this.onTap,
  });

  final DateTime day;
  final bool enabled;
  final bool selected;
  final bool inRange;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = selected
        ? CycleaColors.rose
        : inRange
        ? CycleaColors.rose.withValues(alpha: 0.18)
        : null;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: enabled ? (_) => onTap() : null,
      child: SizedBox(
        key: Key('period-range-day-${dateKey(day)}'),
        height: 44,
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: !enabled
                        ? scheme.onSurface.withValues(alpha: 0.28)
                        : selected
                        ? Colors.white
                        : scheme.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<List<DateTime?>> _monthCells(DateTime month) {
  final first = DateTime(month.year, month.month);
  final count = DateTime(month.year, month.month + 1, 0).day;
  final leading = first.weekday - DateTime.monday;
  final cells = <DateTime?>[
    for (var i = 0; i < leading; i++) null,
    for (var day = 1; day <= count; day++)
      DateTime(month.year, month.month, day),
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return [for (var i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7)];
}
