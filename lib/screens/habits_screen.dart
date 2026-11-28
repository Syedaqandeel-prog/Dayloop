import 'package:flutter/material.dart';

import '../core/models.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

// Habit ke naam se sahi icon - sirf wohi icon jo common.dart me hain
String habitIconForTitle(String title) {
  final n = title.toLowerCase().trim();
  if (n.isEmpty) return 'focus';

  if (n.contains('read') || n.contains('book') || n.contains('study') || n.contains('learn') || n.contains('quran') || n.contains('novel'))
    return 'book';
  if (n.contains('swim')) return 'swim';
  if (n.contains('water') || n.contains('drink') || n.contains('pani')) return 'water';
  if (n.contains('tv') || n.contains('drama') || n.contains('youtube') || n.contains('netflix')) return 'tv';
  if (n.contains('movie') || n.contains('film') || n.contains('watch')) return 'movie';
  if (n.contains('run') || n.contains('jog')) return 'run';
  if (n.contains('walk')) return 'walk';
  if (n.contains('gym') || n.contains('workout') || n.contains('exercise') || n.contains('yoga') || n.contains('stretch') || n.contains('push') || n.contains('plank')) return 'workout';
  if (n.contains('cycle') || n.contains('bike')) return 'bike';
  if (n.contains('dance')) return 'dance';
  if (n.contains('sleep') || n.contains('nap') || n.contains('rest')) return 'sleep';
  if (n.contains('meditat') || n.contains('breathe') || n.contains('calm') || n.contains('mindful')) return 'meditate';
  if (n.contains('pray') || n.contains('namaz') || n.contains('dua')) return 'prayer';
  if (n.contains('cook') || n.contains('food') || n.contains('eat') || n.contains('breakfast') || n.contains('lunch') || n.contains('dinner') || n.contains('diet')) return 'food';
  if (n.contains('tea') || n.contains('coffee') || n.contains('chai')) return 'coffee';
  if (n.contains('music') || n.contains('song') || n.contains('sing') || n.contains('guitar') || n.contains('piano')) return 'music';
  if (n.contains('code') || n.contains('coding') || n.contains('program') || n.contains('computer') || n.contains('laptop')) return 'code';
  if (n.contains('work') || n.contains('office') || n.contains('job') || n.contains('meeting')) return 'work';
  if (n.contains('clean') || n.contains('room') || n.contains('house') || n.contains('wash') || n.contains('laundry')) return 'clean';
  if (n.contains('money') || n.contains('save') || n.contains('budget')) return 'money';
  if (n.contains('call') || n.contains('phone') || n.contains('family') || n.contains('friend') || n.contains('mother') || n.contains('father')) return 'call';
  if (n.contains('journal') || n.contains('diary') || n.contains('write') || n.contains('gratitude')) return 'journal';
  if (n.contains('draw') || n.contains('paint') || n.contains('art')) return 'art';
  if (n.contains('plant') || n.contains('garden') || n.contains('nature') || n.contains('flower')) return 'plant';
  if (n.contains('dog') || n.contains('cat') || n.contains('pet')) return 'pet';
  if (n.contains('drive') || n.contains('car') || n.contains('travel') || n.contains('trip')) return 'car';
  if (n.contains('shop') || n.contains('grocery') || n.contains('market') || n.contains('buy')) return 'shop';
  if (n.contains('medicine') || n.contains('doctor') || n.contains('vitamin') || n.contains('health')) return 'health';
  if (n.contains('school') || n.contains('college') || n.contains('university') || n.contains('homework') || n.contains('class') || n.contains('exam')) return 'school';
  if (n.contains('sun') || n.contains('morning')) return 'sun';
  if (n.contains('spa') || n.contains('beauty') || n.contains('shower') || n.contains('skin')) return 'spa';

  return 'focus';
}

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final habits = store.data.sortedHabits;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
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
                      EmojiTile(habitIconForTitle(h.title)),
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
                        icon: Icon(Icons.edit_outlined, color: AppColors.muted),
                        onPressed: () => showHabitEditor(context, habit: h),
                      ),
                      IconButton(
                        tooltip: 'Delete ${h.title}',
                        icon: Icon(Icons.delete_outline, color: AppColors.muted),
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
  late String _icon = habitIconForTitle(widget.habit?.title ?? '');
  late bool _iconTouched = false;
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
    final finalIcon = _iconTouched ? _icon : habitIconForTitle(title);
    store.update((d) {
      if (_isEdit) {
        d.updateHabit(
          Habit(id: widget.habit!.id, title: title, minutes: _minutes, liteMinutes: lite, slot: _slot, icon: finalIcon),
        );
      } else {
        d.addHabit(
          Habit(id: d.newId('habit'), title: title, minutes: _minutes, liteMinutes: lite, slot: _slot, icon: finalIcon),
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
              onChanged: (value) {
                if (_error != null) setState(() => _error = null);
                if (!_iconTouched) {
                  setState(() => _icon = habitIconForTitle(value));
                }
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
                      color: _icon == key ? AppColors.accentSoft : AppColors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: _icon == key ? AppColors.accent : AppColors.line,
                          width: _icon == key ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setState(() {
                          _icon = key;
                          _iconTouched = true;
                        }),
                        child: SizedBox(width: 48, height: 48, child: Center(child: Emoji3D(key, size: 30))),
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