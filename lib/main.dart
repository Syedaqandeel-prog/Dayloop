import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'data/app_store.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'core/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // SAB SE PEHLE - ONBOARDING SE BHI PEHLE NOTIFICATION MANGO
  // Yehi wala popup ab sab se pehle aayega
  try {
    await Permission.notification.request().timeout(const Duration(seconds: 3));
  } catch (_) {}

  // 1. Store load karo
  late AppStore store;
  try {
    store = await AppStore.load().timeout(const Duration(seconds: 5));
  } catch (e) {
    store = await AppStore.load();
  }

  // 2. Ab App kholo
  runApp(DayloopApp(store: store));

  // 3. App khulne ke baad service init karo
  Future.delayed(const Duration(seconds: 1), () async {
    try {
      await NotificationService().init();
      if (store.data.habits.isEmpty) {
        await NotificationService().noHabitReminder();
      }
    } catch (_) {}
  });
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

class RootGate extends StatelessWidget {
  const RootGate({super.key});
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return store.data.onboarded ? const HomeShell() : const OnboardingScreen();
  }
}