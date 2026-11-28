import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/app_store.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'core/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final store = await AppStore.load();

  // Notification ON - English
  await NotificationService().init();
  // Agar aaj koi habit nahi hai to yaad dilao
  if (store.data.habits.isEmpty) {
    await NotificationService().noHabitReminder();
  }

  runApp(DayloopApp(store: store));
}

class DayloopApp extends StatefulWidget {
  const DayloopApp({super.key, required this.store});

  final AppStore store;

  @override
  State<DayloopApp> createState() => _DayloopAppState();
}

class _DayloopAppState extends State<DayloopApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The phone switched between light and dark: follow it in "System" mode.
  @override
  void didChangePlatformBrightness() {
    if (widget.store.data.themeMode == 'system') {
      widget.store.update((_) {});
    }
  }

  bool _isDark() {
    switch (widget.store.data.themeMode) {
      case 'dark':
        return true;
      case 'light':
        return false;
      default:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final palette = schemeById(widget.store.data.schemeId).of(_isDark());
        // Set before any screen builds in this frame.
        AppColors.current = palette;
        return StoreScope(
          store: widget.store,
          child: MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(palette),
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: palette.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const RootGate(),
          ),
        );
      },
    );
  }
}

/// Shows onboarding until it is finished, then the main app.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return store.data.onboarded ? const HomeShell() : const OnboardingScreen();
  }
}