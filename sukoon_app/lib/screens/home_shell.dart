import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme/app_theme.dart';
import 'achievements_screen.dart';
import 'habit_calendar_screen.dart';
import 'habits_screen.dart';
import 'profile_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _tab = 0;
  AppStore? _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = StoreScope.read(context);
    if (!identical(store, _store)) {
      _store?.removeListener(_onStoreChanged);
      _store = store..addListener(_onStoreChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) => _onStoreChanged());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _store?.removeListener(_onStoreChanged);
    super.dispose();
  }

  /// When the app comes back (maybe on a new day) refresh "today".
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _store?.update((_) {});
    }
  }

  void _onStoreChanged() {
    final store = _store;
    if (store == null || !mounted) return;
    final notices = store.takeNotices();
    if (notices.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      for (final n in notices) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.emoji_events_outlined, color: AppColors.peach),
                const SizedBox(width: 10),
                Expanded(child: Text(n)),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _openTab(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          TodayScreen(onOpenHabits: () => _openTab(1)),
          const HabitsScreen(),
          const HabitCalendarScreen(),
          const AchievementsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _openTab,
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.accentSoft,
        surfaceTintColor: AppColors.card,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}

/// Header used at the top of each tab.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) ...[
                  Text(subtitle!, style: AppText.body(13, color: AppColors.muted)),
                  const SizedBox(height: 2),
                ],
                Text(title, style: AppText.display(30)),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
