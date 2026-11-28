import 'package:flutter/material.dart';

import '../core/notification_service.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import 'achievements_screen.dart';
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
  bool _notifiedEmpty = false;
  bool _notifiedUndone = false;

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

  // Notification logic - Home Screen se attached
  void _checkHabitNotifications() {
    final store = _store;
    if (store == null) return;

    final habits = store.data.habits;

    // Case 1: User ne aaj koi habit add hi nahi ki
    if (habits.isEmpty) {
      if (!_notifiedEmpty) {
        _notifiedEmpty = true;
        _notifiedUndone = false;
        NotificationService().noHabitReminder();
      }
      return;
    }

    // Case 2: Habit add ki lekin ki nahi
    _notifiedEmpty = false;
    if (!_notifiedUndone) {
      _notifiedUndone = true;
      // Pehli wali habit ka naam bhejte hain
      NotificationService().habitReminder(habits.first.title);
    }
  }

  void _onStoreChanged() {
    final store = _store;
    if (store == null || !mounted) return;
    _checkHabitNotifications();
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
                Icon(Icons.emoji_events_outlined, color: AppColors.peach),
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
    // Rebuild the shell (and its bar) when the theme or data changes.
    StoreScope.of(context);
    // Back button: from any other tab go to Today first; from Today, close the app.
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _tab != 0) _openTab(0);
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _tab,
          children: [
            TodayScreen(onOpenHabits: () => _openTab(1), onOpenProfile: () => _openTab(3)),
            const HabitsScreen(),
            const AchievementsScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _BottomBar(index: _tab, onSelect: _openTab),
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

/// Floating pill navigation on the hero colour. The active tab shows its
/// icon and name on the highlight colour; the others show their icon only,
/// all vertically centred on one line.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const List<(String, String)> _items = [
    ('📅', 'Today'),
    ('✅', 'Habits'),
    ('🏆', 'Badges'),
    ('👤', 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.night,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x38000000), blurRadius: 30, offset: Offset(0, 12))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < _items.length; i++)
              Semantics(
                button: true,
                selected: index == i,
                label: _items[i].$2,
                excludeSemantics: true,
                child: Tooltip(
                  message: _items[i].$2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: 46,
                      padding: EdgeInsets.symmetric(horizontal: index == i ? 16 : 13),
                      decoration: BoxDecoration(
                        color: index == i ? AppColors.peach : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _items[i].$1,
                            style: const TextStyle(fontSize: 22),
                          ),
                          if (index == i) ...[
                            const SizedBox(width: 7),
                            Text(
                              _items[i].$2,
                              style: AppText.body(14, weight: FontWeight.w800, color: AppColors.onPeach, height: 1),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}