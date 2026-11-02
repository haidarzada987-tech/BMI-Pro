import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/storage/storage_service.dart';
import '../../models/user_profile.dart';
import '../../services/bmi_service.dart';
import '../../services/health_service.dart';
import '../../services/goal_service.dart';
import '../../services/character_service.dart';
import '../../services/unit_service.dart';
import '../../core/storage/unit_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Future<void> addWeight() async {
    final controller = TextEditingController();
    final unit = ref.read(unitProvider);
    final value = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('addWeight')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '${context.tr('currentWeight')} (${const UnitService().label(unit)})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed != null && parsed > 0) {
                Navigator.pop(context, const UnitService().toKg(parsed, unit));
              }
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
    controller.dispose();

    if (value != null) {
      await StorageService.addWeight(value);
      await StorageService.updateCurrentWeight(value);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = StorageService.getProfile();
    if (raw == null) return const SizedBox.shrink();

    final profile = UserProfile.fromMap(raw);
    final bmi = const BMIService().calculate(
      weightKg: profile.currentWeightKg,
      heightCm: profile.heightCm,
    );
    final health = const HealthService();
    final bmr = health.bmr(
      gender: profile.gender,
      age: profile.age,
      weightKg: profile.currentWeightKg,
      heightCm: profile.heightCm,
    );
    final tdee = health.tdee(bmr, profile.activityLevel);
    final start = StorageService.getStartWeight() ?? profile.currentWeightKg;
    final goal = const GoalService();
    final progress = goal.progress(
      start: start,
      current: profile.currentWeightKg,
      target: profile.targetWeightKg,
    );
    final remaining = goal.remaining(
      profile.currentWeightKg,
      profile.targetWeightKg,
    );
    final reached =
        goal.reached(profile.currentWeightKg, profile.targetWeightKg);
    final character = const CharacterService().select(
      gender: profile.gender,
      age: profile.age,
      bmi: bmi,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('appName')),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            context.tr('overview'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          _card(
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('yourBmi')),
                      const SizedBox(height: 4),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(context.tr(const BMIService().category(bmi))),
                    ],
                  ),
                ),
                _AnimatedCharacter(assetPath: character.assetPath),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metric(context.tr('bmr'), '${bmr.round()} kcal')),
              const SizedBox(width: 10),
              Expanded(child: _metric(context.tr('tdee'), '${tdee.round()} kcal')),
            ],
          ),
          const SizedBox(height: 12),
          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('weightGoal'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress, minHeight: 8),
                const SizedBox(height: 10),
                Text(
                  reached
                      ? context.tr('goalReached')
                      : '${remaining.toStringAsFixed(1)} ${context.tr('kgToGo')}',
                ),
                ..._summaryLines(context, profile.targetWeightKg),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: addWeight,
            icon: const Icon(Icons.monitor_weight_outlined),
            label: Text(context.tr('logWeight')),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: () => context.push('/calculator'),
            icon: const Icon(Icons.calculate_outlined),
            label: Text(context.tr('calculator')),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: context.tr('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            label: context.tr('progress'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: context.tr('profile'),
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) context.push('/weight-history');
          if (index == 2) context.push('/profile');
        },
      ),
    );
  }

  /// "This week: -0.5 kg" line and, when the trend points at the goal,
  /// a rough "about N weeks to your goal" estimate. Empty when the
  /// history is too short to say anything honest.
  List<Widget> _summaryLines(BuildContext context, double targetKg) {
    final history = StorageService.getWeightHistory();
    if (history.length < 2) return const [];
    final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
    final latest = sorted.last;

    // Baseline: the newest entry that is at least ~a week old.
    final weekAgo = latest.date.subtract(const Duration(days: 7));
    final baseIndex =
        sorted.lastIndexWhere((e) => !e.date.isAfter(weekAgo));
    if (baseIndex < 0) return const [];
    final base = sorted[baseIndex];
    final spanDays = latest.date.difference(base.date).inDays;
    if (spanDays < 5) return const [];

    final unit = ref.read(unitProvider);
    const unitService = UnitService();
    final change = unitService.fromKg(latest.weightKg - base.weightKg, unit);
    final sign = change > 0 ? '+' : '';
    final lines = <Widget>[
      const SizedBox(height: 6),
      Text(
        context.tr('weekChange').replaceAll(
              '{v}',
              '$sign${change.toStringAsFixed(1)} ${unitService.label(unit)}',
            ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ];

    // ETA from the whole recorded trend, only when it moves toward the goal.
    final totalDays =
        latest.date.difference(sorted.first.date).inDays.toDouble();
    final remainingKg = latest.weightKg - targetKg;
    if (totalDays >= 5 && remainingKg.abs() > 0.05) {
      final perDay = (latest.weightKg - sorted.first.weightKg) / totalDays;
      if (perDay != 0 && (perDay < 0) == (remainingKg > 0)) {
        final weeks = (remainingKg.abs() / perDay.abs() / 7).ceil();
        if (weeks >= 1 && weeks <= 520) {
          lines.add(const SizedBox(height: 2));
          lines.add(
            Text(
              context.tr('etaGoal').replaceAll('{w}', '$weeks'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
      }
    }
    return lines;
  }

  Widget _card(Widget child) => Card(
        child: Padding(padding: const EdgeInsets.all(18), child: child),
      );

  Widget _metric(String title, String value) => _card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(value),
          ],
        ),
      );
}

/// The character does a little jump-and-wiggle whenever it is tapped.
class _AnimatedCharacter extends StatefulWidget {
  const _AnimatedCharacter({required this.assetPath});

  final String assetPath;

  @override
  State<_AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<_AnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.forward(from: 0),
      child: AnimatedBuilder(
        animation: _controller,
        child: SizedBox(
          width: 110,
          height: 150,
          child: Image.asset(
            widget.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person_outline,
              size: 72,
            ),
          ),
        ),
        builder: (context, child) {
          final t = _controller.value;
          final jump = -16 * math.sin(math.pi * t);
          final wiggle = 0.09 * math.sin(t * math.pi * 4) * (1 - t);
          final scale = 1 + 0.05 * math.sin(math.pi * t);
          return Transform.translate(
            offset: Offset(0, jump),
            child: Transform.rotate(
              angle: wiggle,
              alignment: Alignment.bottomCenter,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
