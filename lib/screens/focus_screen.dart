import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Full-screen timer with a breathing guide. When the user finishes, a focus
/// session is recorded and [onFinished] runs (e.g. marks the habit done).
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, required this.title, required this.minutes, this.onFinished});

  final String title;
  final int minutes;
  final void Function(AppStore store)? onFinished;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late int _remaining = widget.minutes.clamp(1, 240) * 60;
  Timer? _timer;
  bool _running = false;
  bool _finished = false;

  int get _total => widget.minutes.clamp(1, 240) * 60;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _breath.repeat(reverse: true);
    setState(() => _running = true);
  }

  void _pause() {
    _timer?.cancel();
    _breath.stop();
    setState(() => _running = false);
  }

  void _restart() {
    setState(() => _remaining = _total);
    _start();
  }

  void _tick() {
    if (!mounted) return;
    if (_remaining <= 1) {
      _complete();
      return;
    }
    setState(() => _remaining--);
  }

  void _complete() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    _breath.stop();
    final store = StoreScope.read(context);
    final today = store.today;
    store.update((d) => d.addFocusSession(today));
    widget.onFinished?.call(store);
    if (mounted) Navigator.of(context).pop();
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remaining / _total);
    return Scaffold(
      backgroundColor: AppColors.night,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Close',
                    background: AppColors.night,
                    foreground: AppColors.nightInk,
                    borderColor: AppColors.whiteFaint,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text('Focus session', style: AppText.body(13, color: AppColors.nightSoft)),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: AppText.display(30, color: AppColors.nightInk),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 3,
                                  color: AppColors.peach,
                                  backgroundColor: AppColors.whiteFaint,
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _breath,
                                builder: (context, _) {
                                  final t = Curves.easeInOut.transform(_breath.value);
                                  final size = 120 + 80 * t;
                                  final inhale = _breath.status == AnimationStatus.forward;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: size,
                                        height: size,
                                        decoration: BoxDecoration(
                                          color: AppColors.peach.withAlpha(0x40),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _running ? (inhale ? 'Breathe in' : 'Breathe out') : 'Paused',
                                          style: AppText.body(16, weight: FontWeight.w600, color: AppColors.nightInk),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _format(_remaining),
                          style: AppText.body(52, weight: FontWeight.w400, color: AppColors.nightInk, height: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleIconButton(
                    icon: Icons.restart_alt,
                    tooltip: 'Restart',
                    size: 56,
                    background: AppColors.night,
                    foreground: AppColors.nightInk,
                    borderColor: AppColors.whiteFaint,
                    onPressed: _restart,
                  ),
                  const SizedBox(width: 24),
                  CircleIconButton(
                    icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    tooltip: _running ? 'Pause' : 'Resume',
                    size: 80,
                    background: AppColors.peach,
                    foreground: AppColors.ink,
                    borderColor: null,
                    onPressed: _running ? _pause : _start,
                  ),
                  const SizedBox(width: 24),
                  CircleIconButton(
                    icon: Icons.check_rounded,
                    tooltip: 'Finish now',
                    size: 56,
                    background: AppColors.night,
                    foreground: AppColors.nightInk,
                    borderColor: AppColors.whiteFaint,
                    onPressed: _complete,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Tap the check to finish early and mark it done.',
                style: AppText.body(13, color: AppColors.nightSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
