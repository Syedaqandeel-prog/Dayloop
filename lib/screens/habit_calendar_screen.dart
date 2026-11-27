import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/dates.dart';
import '../core/models.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HabitCalendarScreen extends StatefulWidget {
  const HabitCalendarScreen({super.key});

  @override
  State<HabitCalendarScreen> createState() => _HabitCalendarScreenState();
}

class _HabitCalendarScreenState extends State<HabitCalendarScreen> {
  late DateTime _weekStart;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(DateTime.now());
    _weekStart = addDays(today, -(today.weekday - 1));
    _selectedDay = today;
  }

  @override
  Widget build(BuildContext context) {
    final data = StoreScope.of(context).data;
    final today = StoreScope.read(context).today;
    final currentWeekStart = addDays(today, -(today.weekday - 1));
    final weekEnd = addDays(_weekStart, 6);
    final planned = data.plannedHabits(_selectedDay);
    final completed =
        planned.where((habit) => data.isDone(_selectedDay, habit.id)).length;
    final isTracked = !_selectedDay.isBefore(data.firstUse);
    final isFuture = _selectedDay.isAfter(today);
    final missed = isTracked && !isFuture && !isSameDay(_selectedDay, today)
        ? planned.length - completed
        : 0;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text('WEEKLY PROGRESS',
              style: AppText.label.copyWith(color: AppColors.accent)),
          const SizedBox(height: 4),
          Text('Habit calendar', style: AppText.display(30)),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                CircleIconButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Previous week',
                  onPressed: () => setState(() {
                    _weekStart = addDays(_weekStart, -7);
                    _selectedDay = _weekStart;
                  }),
                ),
                Expanded(
                  child: Text(
                    _weekLabel(_weekStart, weekEnd),
                    textAlign: TextAlign.center,
                    style: AppText.body(14, weight: FontWeight.w700),
                  ),
                ),
                CircleIconButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Next week',
                  onPressed: isSameDay(_weekStart, currentWeekStart)
                      ? null
                      : () => setState(() {
                            _weekStart = addDays(_weekStart, 7);
                            _selectedDay = _weekStart;
                          }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: _CalendarDayButton(
                      day: addDays(_weekStart, i),
                      selected: isSameDay(_selectedDay, addDays(_weekStart, i)),
                      isToday: isSameDay(today, addDays(_weekStart, i)),
                      markerColor:
                          _dayMarkerColor(data, addDays(_weekStart, i), today),
                      onTap: () =>
                          setState(() => _selectedDay = addDays(_weekStart, i)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(prettyDate(_selectedDay), style: AppText.display(23)),
          const SizedBox(height: 10),
          if (!isTracked)
            const AppCard(
                child:
                    Text('Habit tracking starts on your first day in the app.'))
          else if (data.habits.isEmpty)
            const AppCard(
                child: Text(
                    'No habits yet. Add habits to see them in your calendar.'))
          else ...[
            _DaySummary(
              completed: completed,
              planned: planned.length,
              missed: missed,
              isFuture: isFuture,
              isToday: isSameDay(_selectedDay, today),
            ),
            const SizedBox(height: 10),
            for (final slot in DaySlot.values)
              for (final habit
                  in data.sortedHabits.where((habit) => habit.slot == slot))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HabitStatusCard(
                    habit: habit,
                    data: data,
                    day: _selectedDay,
                    today: today,
                  ),
                ),
          ],
          const SizedBox(height: 8),
          const _CalendarLegend(),
        ],
      ),
    );
  }

  Color? _dayMarkerColor(AppData data, DateTime day, DateTime today) {
    if (day.isBefore(data.firstUse) || day.isAfter(today)) return null;
    final planned = data.plannedHabits(day);
    if (planned.isEmpty) return null;
    final done = data.doneCount(day);
    if (done == 0 && isSameDay(day, today)) return AppColors.accent;
    if (done == 0) return AppColors.warn;
    if (done == planned.length) return AppColors.success;
    return AppColors.accent;
  }

  String _weekLabel(DateTime start, DateTime end) {
    if (start.month == end.month && start.year == end.year) {
      return '${start.day}–${end.day} ${kMonthNames[end.month - 1]} ${end.year}';
    }
    final startYear = start.year == end.year ? '' : ' ${start.year}';
    return '${start.day} ${kMonthNames[start.month - 1].substring(0, 3)}$startYear – '
        '${end.day} ${kMonthNames[end.month - 1].substring(0, 3)} ${end.year}';
  }
}

class _CalendarDayButton extends StatelessWidget {
  const _CalendarDayButton({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.markerColor,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final Color? markerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.white : AppColors.ink;
    return Semantics(
      label:
          '${kWeekdayNames[day.weekday - 1]}, ${day.day}${isToday ? ', today' : ''}',
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.accent : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kWeekdayShort[day.weekday - 1],
                  style: AppText.body(11,
                      weight: FontWeight.w600,
                      color: selected ? AppColors.white : AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text('${day.day}',
                    style: AppText.body(15,
                        weight: FontWeight.w700, color: color)),
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: markerColor ??
                        (isToday && !selected
                            ? AppColors.accent
                            : Colors.transparent),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary({
    required this.completed,
    required this.planned,
    required this.missed,
    required this.isFuture,
    required this.isToday,
  });

  final int completed;
  final int planned;
  final int missed;
  final bool isFuture;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final label = isFuture
        ? 'Planned habits'
        : isToday
            ? 'Completed so far'
            : 'Completed';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label,
                      style: AppText.body(14, weight: FontWeight.w700))),
              Text('$completed / $planned',
                  style: AppText.body(14,
                      weight: FontWeight.w700, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 10),
          SoftProgressBar(value: planned == 0 ? 0 : completed / planned),
          if (missed > 0) ...[
            const SizedBox(height: 8),
            Text('$missed ${missed == 1 ? 'habit' : 'habits'} missed',
                style: AppText.body(12, color: AppColors.warn)),
          ],
        ],
      ),
    );
  }
}

class _HabitStatusCard extends StatelessWidget {
  const _HabitStatusCard(
      {required this.habit,
      required this.data,
      required this.day,
      required this.today});

  final Habit habit;
  final AppData data;
  final DateTime day;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final planned = data.plannedHabits(day).any((item) => item.id == habit.id);
    final done = data.isDone(day, habit.id);
    final isTracked = !day.isBefore(data.firstUse);
    final isFuture = day.isAfter(today);
    final isToday = isSameDay(day, today);
    final (label, color, background, icon) = !isTracked
        ? (
            'Not tracked',
            AppColors.muted,
            AppColors.sand,
            Icons.remove_circle_outline
          )
        : !planned
            ? (
                'Not planned',
                AppColors.muted,
                AppColors.sand,
                Icons.remove_circle_outline
              )
            : done
                ? (
                    'Completed',
                    AppColors.success,
                    AppColors.successSoft,
                    Icons.check_circle_outline
                  )
                : isFuture
                    ? (
                        'Upcoming',
                        AppColors.accent,
                        AppColors.accentSoft,
                        Icons.schedule
                      )
                    : isToday
                        ? (
                            'Not done yet',
                            AppColors.muted,
                            AppColors.sand,
                            Icons.radio_button_unchecked
                          )
                        : (
                            'Missed',
                            AppColors.warn,
                            AppColors.warnSoft,
                            Icons.cancel_outlined
                          );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      child: Row(
        children: [
          IconBubble(icon: appIcon(habit.icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title,
                    style: AppText.body(14, weight: FontWeight.w700)),
                Text(habit.slot.label,
                    style: AppText.body(12, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
                color: background, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 4),
                Text(label,
                    style: AppText.body(11,
                        weight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _LegendItem(color: AppColors.success, label: 'Completed'),
        _LegendItem(color: AppColors.warn, label: 'Missed'),
        _LegendItem(color: AppColors.muted, label: 'Not done yet'),
        _LegendItem(color: AppColors.accent, label: 'Upcoming'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppText.body(11, color: AppColors.muted)),
      ],
    );
  }
}
