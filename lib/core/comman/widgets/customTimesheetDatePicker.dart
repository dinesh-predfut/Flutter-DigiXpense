// period_picker_dialog.dart

import 'package:flutter/material.dart';

class PeriodPickerDialog extends StatefulWidget {
  final String periodType;    // "Week", "Biweekly", "Month", "SemiMonth"
  final String weekStart;     // "Monday", "Tuesday", ... "Sunday"
  final String monthStart;    // "1st", "15th", etc.
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange Function(String, DateTime, {String weekStart, String monthStart}) getRangeFromConfig;

  const PeriodPickerDialog({
    Key? key,
    required this.periodType,
    required this.weekStart,
    required this.monthStart,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.getRangeFromConfig,
  }) : super(key: key);

  @override
  State<PeriodPickerDialog> createState() => _PeriodPickerDialogState();
}

class _PeriodPickerDialogState extends State<PeriodPickerDialog> {
  late DateTime _focusedMonth;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    // Pre-select the range that contains the initialDate
    _selectedRange = widget.getRangeFromConfig(
      widget.periodType,
      widget.initialDate,
      weekStart: widget.weekStart,
      monthStart: widget.monthStart,
    );
    print('Initial selected range: ${_fmt(_selectedRange!.start)} - ${_fmt(_selectedRange!.end)}');
    print('Initial date: ${_fmt(widget.initialDate)} focused month: ${_monthLabel(_focusedMonth)}  period type: ${widget.periodType} weekStart: ${widget.weekStart} monthStart: ${widget.monthStart} ');
  }

  void _onDayTapped(DateTime date) {
    if (date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate)) return;

    final range = widget.getRangeFromConfig(
      widget.periodType,
      date,
      weekStart: widget.weekStart,
      monthStart: widget.monthStart,
    );

    // Clamp end to lastDate
    final clampedEnd = range.end.isAfter(widget.lastDate) ? widget.lastDate : range.end;
    final clampedStart = range.start.isAfter(clampedEnd) ? clampedEnd : range.start;

    setState(() {
      _selectedRange = DateTimeRange(start: clampedStart, end: clampedEnd);
    });
  }
  
  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  bool _isSelected(DateTime date) {
    if (_selectedRange == null) return false;
    return !date.isBefore(_selectedRange!.start) && !date.isAfter(_selectedRange!.end);
  }

  bool _isStart(DateTime date) => _selectedRange != null && _isSameDay(date, _selectedRange!.start);
  bool _isEnd(DateTime date) => _selectedRange != null && _isSameDay(date, _selectedRange!.end);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDisabled(DateTime date) =>
      date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Select ${widget.periodType} Period',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            // Period label chip
            if (_selectedRange != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_fmt(_selectedRange!.start)} – ${_fmt(_selectedRange!.end)}',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
                Text(
                  _monthLabel(_focusedMonth),
                  style: theme.textTheme.titleSmall,
                ),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
              ],
            ),
            // Weekday headers
            _buildWeekdayHeaders(),
            // Calendar grid
            _buildCalendarGrid(colorScheme),
            const SizedBox(height: 12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _selectedRange == null
                      ? null
                      : () => Navigator.of(context).pop(_selectedRange),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    // Rotate day labels so weekStart appears first
    const allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final startIdx = _weekdayIndex(widget.weekStart);
    final ordered = [...allDays.sublist(startIdx), ...allDays.sublist(0, startIdx)];

    return Row(
      children: ordered.map((d) => Expanded(
        child: Center(
          child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(ColorScheme colorScheme) {
    final firstOfMonth = _focusedMonth;
    final daysInMonth = DateUtils.getDaysInMonth(firstOfMonth.year, firstOfMonth.month);
    final startOffset = _weekdayOffset(firstOfMonth.weekday);

    // Total cells = offset + days, rounded up to full weeks
    final totalCells = (startOffset + daysInMonth + 6) ~/ 7 * 7;

    final cells = <DateTime?>[
      ...List.filled(startOffset, null),
      ...List.generate(daysInMonth, (i) => DateTime(firstOfMonth.year, firstOfMonth.month, i + 1)),
      ...List.filled(totalCells - startOffset - daysInMonth, null),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) {
        final date = cells[index];
        if (date == null) return const SizedBox();
        return _buildDayCell(date, colorScheme);
      },
    );
  }

  Widget _buildDayCell(DateTime date, ColorScheme colorScheme) {
    final selected = _isSelected(date);
    final isStart = _isStart(date);
    final isEnd = _isEnd(date);
    final disabled = _isDisabled(date);

    Color? cellBg;
    Color textColor = disabled
        ? colorScheme.onSurface.withOpacity(0.38)
        : colorScheme.onSurface;

    if (selected && !disabled) {
      cellBg = colorScheme.primaryContainer.withOpacity(0.5);
      textColor = colorScheme.onPrimaryContainer;
    }
    if ((isStart || isEnd) && !disabled) {
      cellBg = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    }

    // Strip left/right radius on middle cells to form a continuous band
    BorderRadius? radius;
    if (isStart && isEnd) {
      radius = BorderRadius.circular(20);
    } else if (isStart) {
      radius = const BorderRadius.horizontal(left: Radius.circular(20));
    } else if (isEnd) {
      radius = const BorderRadius.horizontal(right: Radius.circular(20));
    } else if (selected) {
      radius = BorderRadius.zero;
    }

    return GestureDetector(
      onTap: disabled ? null : () => _onDayTapped(date),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: radius,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // How many cells to offset for the first day, given weekStart
  int _weekdayOffset(int weekday) {
    // weekday: Mon=1 ... Sun=7
    final startIdx = _weekdayIndex(widget.weekStart); // 0-based Mon offset
    return (weekday - 1 - startIdx + 7) % 7;
  }

  int _weekdayIndex(String day) {
    const map = {
      'Monday': 0, 'Tuesday': 1, 'Wednesday': 2, 'Thursday': 3,
      'Friday': 4, 'Saturday': 5, 'Sunday': 6,
    };
    return map[day] ?? 0;
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _monthLabel(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.year}';
  }
}