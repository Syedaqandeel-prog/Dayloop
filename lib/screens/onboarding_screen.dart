import 'package:flutter/material.dart';

import '../core/dates.dart';
import '../core/models.dart';
import '../core/self_care_library.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 4;

  final PageController _pages = PageController();
  final TextEditingController _name = TextEditingController();
  final Set<int> _templates = <int>{};
  int _page = 0;
  bool _selfCareEnabled = true;
  int? _weekday;
  final Set<String> _categories = <String>{};

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    FocusScope.of(context).unfocus();
    _pages.animateToPage(page, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  void _next() {
    if (_page == 2 && _templates.isEmpty) {
      showNotice(context, 'Pick at least one habit to start with.');
      return;
    }
    if (_page == 3 && _selfCareEnabled && _categories.isEmpty) {
      showNotice(context, 'Pick at least one thing for your Self-Care Day.');
      return;
    }
    if (_page < _pageCount - 1) {
      _goTo(_page + 1);
    } else {
      _finish();
    }
  }

  void _finish() {
    final store = StoreScope.read(context);
    final indices = _templates.toList()..sort();
    store.update((d) {
      d.name = _name.text.trim();
      d.habits.clear();
      for (final i in indices) {
        final t = kHabitTemplates[i];
        d.addHabit(
          Habit(
            id: d.newId('habit'),
            title: t.title,
            minutes: t.minutes,
            liteMinutes: t.liteMinutes,
            slot: t.slot,
            icon: t.icon,
          ),
        );
      }
      d.selfCare = SelfCareSettings(enabled: _selfCareEnabled, weekday: _weekday ?? DateTime.sunday, categories: {..._categories});
      d.onboarded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Back goes to the previous onboarding step; on the first step it closes the app.
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _page > 0) _goTo(_page - 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      if (_page > 0)
                        CircleIconButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: 'Back',
                          onPressed: () => _goTo(_page - 1),
                        ),
                      const Spacer(),
                      Text('${_page + 1} of $_pageCount', style: AppText.body(13, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (p) => setState(() => _page = p),
                  children: [_welcomePage(), _namePage(), _habitsPage(), _selfCarePage()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _pageCount; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _page ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _page ? AppColors.accent : AppColors.line,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(_page == _pageCount - 1 ? 'Start my journey' : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageShell({required String title, required String subtitle, required Widget child}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
      children: [
        Text(title, style: AppText.display(30)),
        const SizedBox(height: 8),
        Text(subtitle, style: AppText.body(15, color: AppColors.muted)),
        const SizedBox(height: 24),
        child,
      ],
    );
  }

  Widget _welcomePage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: AppColors.night, shape: BoxShape.circle),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(color: AppColors.peach.withAlpha(0x40), shape: BoxShape.circle),
                    ),
                    Positioned(
                      top: 62,
                      right: 62,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: AppColors.peach, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text('Small steps,\na calmer life.', style: AppText.display(34)),
            const SizedBox(height: 12),
            Text(
              'Build routines that bend with your energy, take a real rest day every week, '
              'and watch your progress grow.',
              style: AppText.body(15, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _namePage() {
    return _pageShell(
      title: 'What should we call you?',
      subtitle: 'Optional. It only stays on this phone.',
      child: TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        maxLength: 30,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _next(),
        decoration: const InputDecoration(hintText: 'Your name', counterText: ''),
      ),
    );
  }

  Widget _habitsPage() {
    return _pageShell(
      title: 'Pick a few habits',
      subtitle: 'Start small. You can add, edit or remove habits anytime.',
      child: Column(
        children: [
          for (var i = 0; i < kHabitTemplates.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TemplateTile(
                template: kHabitTemplates[i],
                selected: _templates.contains(i),
                onTap: () => setState(() {
                  if (!_templates.remove(i)) _templates.add(i);
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _selfCarePage() {
    return _pageShell(
      title: 'Your weekly Self-Care Day',
      subtitle: 'One day a week just for you. We plan it, you just show up.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _selfCareEnabled,
              onChanged: (v) => setState(() => _selfCareEnabled = v),
              title: Text('Turn on Self-Care Day', style: AppText.body(15, weight: FontWeight.w600)),
            ),
          ),
          if (_selfCareEnabled) ...[
            const SizedBox(height: 18),
            const SectionLabel('Pick your day'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var w = 1; w <= 7; w++)
                  ChoicePill(
                    label: kWeekdayNames[w - 1].substring(0, 3),
                    selected: _weekday == w,
                    onTap: () => setState(() => _weekday = w),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const SectionLabel('What should it include?'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in kSelfCareCategories)
                  ChoicePill(
                    label: c.label,
                    icon: appIcon(c.icon),
                    selected: _categories.contains(c.id),
                    onTap: () => setState(() {
                      if (!_categories.remove(c.id)) _categories.add(c.id);
                    }),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template, required this.selected, required this.onTap});

  final HabitTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        borderColor: selected ? AppColors.accent : AppColors.line,
        color: selected ? AppColors.accentSoft : AppColors.card,
        child: Row(
          children: [
            EmojiTile(template.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.title, style: AppText.body(15, weight: FontWeight.w700)),
                  Text(
                    '${template.slot.label} · ${template.minutes} min',
                    style: AppText.body(12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.accent : AppColors.line,
            ),
          ],
        ),
      ),
    );
  }
}