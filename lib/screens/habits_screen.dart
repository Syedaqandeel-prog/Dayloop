import 'package:flutter/material.dart';

import '../core/models.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final habits = store.data.sortedHabits;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          TabHeader(
            title: 'Your habits',
            subtitle: '${habits.length} ${habits.length == 1 ? 'habit' : 'habits'}',
            action: FilledButton.icon(
              onPressed: () => showHabitEditor(context),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New'),
            ),
          ),
          if (habits.isEmpty)
            AppCard(
              child: Text(
                'No habits yet. Tap New to add your first one.',
                style: AppText.body(14, color: AppColors.muted),
              ),
            ),
          for (final slot in DaySlot.values) ...[
            if (habits.any((h) => h.slot == slot)) SectionLabel(slot.label),
            for (final h in habits.where((h) => h.slot == slot))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  onTap: () => showHabitEditor(context, habit: h),
                  child: Row(
                    children: [
                      IconBubble(icon: appIcon(h.icon)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.title, style: AppText.body(15, weight: FontWeight.w700)),
                            Text(
                              'Full ${h.minutes} min · Lite ${h.liteMinutes} min',
                              style: AppText.body(12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit ${h.title}',
                        icon: const Icon(Icons.edit_outlined, color: AppColors.muted),
                        onPressed: () => showHabitEditor(context, habit: h),
                      ),
                      IconButton(
                        tooltip: 'Delete ${h.title}',
                        icon: const Icon(Icons.delete_outline, color: AppColors.muted),
                        onPressed: () => _delete(context, h),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, Habit h) async {
    final store = StoreScope.read(context);
    final ok = await confirmDialog(
      context,
      title: 'Delete "${h.title}"?',
      message: 'It will be removed from your routine. Past progress stays in your stats.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok) store.update((d) => d.deleteHabit(h.id));
  }
}

Future<void> showHabitEditor(BuildContext context, {Habit? habit}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.sand,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => HabitEditorSheet(habit: habit),
  );
}

class HabitEditorSheet extends StatefulWidget {
  const HabitEditorSheet({super.key, this.habit});

  final Habit? habit;

  @override
  State<HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends State<HabitEditorSheet> {
  late final TextEditingController _title = TextEditingController(text: widget.habit?.title ?? '');
  late DaySlot _slot = widget.habit?.slot ?? DaySlot.morning;
  late int _minutes = widget.habit?.minutes ?? 10;
  late int _lite = widget.habit?.liteMinutes ?? 5;
  late String _icon = widget.habit?.icon ?? 'star';
  String? _error;

  bool get _isEdit => widget.habit != null;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please give your habit a name.');
      return;
    }
    final store = StoreScope.read(context);
    final lite = _lite > _minutes ? _minutes : _lite;
    store.update((d) {
      if (_isEdit) {
        d.updateHabit(
          Habit(id: widget.habit!.id, title: title, minutes: _minutes, liteMinutes: lite, slot: _slot, icon: _icon),
        );
      } else {
        d.addHabit(
          Habit(id: d.newId('habit'), title: title, minutes: _minutes, liteMinutes: lite, slot: _slot, icon: _icon),
        );
      }
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(_isEdit ? 'Edit habit' : 'New habit', style: AppText.display(26)),
            const SizedBox(height: 18),
            TextField(
              controller: _title,
              autofocus: !_isEdit,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(hintText: 'e.g. Walk after lunch', errorText: _error, counterText: ''),
            ),
            const SizedBox(height: 8),
            const SectionLabel('When'),
            Row(
              children: [
                for (final s in DaySlot.values)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: s == DaySlot.evening ? 0 : 8),
                      child: ChoicePill(
                        label: s.label,
                        expand: true,
                        selected: _slot == s,
                        onTap: () => setState(() => _slot = s),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const SectionLabel('Duration'),
            _Stepper(
              label: 'Full version',
              value: _minutes,
              min: 1,
              max: 240,
              onChanged: (v) => setState(() {
                _minutes = v;
                if (_lite > v) _lite = v;
              }),
            ),
            const SizedBox(height: 8),
            _Stepper(
              label: 'Lite version',
              value: _lite,
              min: 1,
              max: _minutes,
              onChanged: (v) => setState(() => _lite = v),
            ),
            const SizedBox(height: 8),
            const SectionLabel('Icon'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in kHabitIconChoices)
                  Semantics(
                    selected: _icon == key,
                    label: key,
                    button: true,
                    child: Material(
                      color: _icon == key ? AppColors.accent : AppColors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: _icon == key ? AppColors.accent : AppColors.line),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setState(() => _icon = key),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(appIcon(key), color: _icon == key ? AppColors.white : AppColors.ink),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: Text(_isEdit ? 'Save changes' : 'Add habit')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  int _step(int v) => v >= 30 ? 5 : 1;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppText.body(14, weight: FontWeight.w600)),
          ),
          CircleIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'Less',
            onPressed: value <= min ? null : () => onChanged((value - _step(value - 1)).clamp(min, max)),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '$value min',
              textAlign: TextAlign.center,
              style: AppText.body(15, weight: FontWeight.w700),
            ),
          ),
          CircleIconButton(
            icon: Icons.add_rounded,
            tooltip: 'More',
            onPressed: value >= max ? null : () => onChanged((value + _step(value)).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}
