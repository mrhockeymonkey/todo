import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_actions.dart';
import 'package:todo/journey/completion_effect.dart';
import 'package:todo/journey/journey_node.dart';
import 'package:todo/journey/journey_path_painter.dart';
import 'package:todo/journey/journey_provider.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<StatefulWidget> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with TickerProviderStateMixin {
  static const double _topPadding = 120;
  static const double _spacing = 140;
  static const double _bottomPadding = 120;
  static const List<String> _cheers = ["Nice!", "Great!", "Bravo!", "Super!"];

  /// How far along the road the fill has travelled, in steps.
  late final AnimationController _path;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  /// Effects live in the app overlay so confetti can fly over the app bar
  /// rather than being clipped by the scroll view.
  final List<OverlayEntry> _effects = [];
  final GlobalKey _journeyKey = GlobalKey();
  final Random _random = Random();
  List<Offset> _centers = const [];

  @override
  void initState() {
    super.initState();
    final completed = context.read<JourneyProvider>().completed;
    _path = AnimationController.unbounded(
      vsync: this,
      value: completed.toDouble(),
    );
  }

  @override
  void dispose() {
    _clearEffects();
    _path.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _completeStep(int index) {
    final journey = context.read<JourneyProvider>();
    if (index != journey.completed) return;

    journey.complete(index);
    HapticFeedback.heavyImpact();
    _spawnEffect(
      journey.effect,
      _centers[index],
      _cheers[_random.nextInt(_cheers.length)],
    );
    if (journey.effect == JourneyEffect.shockwave) _shake.forward(from: 0);

    // Let the node pop first, then run the road to the next stop.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _path
          .animateTo(
            journey.completed.toDouble(),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
          )
          .then((_) {
            if (!mounted || !journey.isFinished) return;
            if (_path.value < JourneyProvider.steps.length) return;
            HapticFeedback.heavyImpact();
            _spawnEffect(
              JourneyEffect.confetti,
              _centers.last,
              "Journey complete!",
              big: true,
            );
          });
    });
  }

  void _spawnEffect(
    JourneyEffect type,
    Offset center,
    String label, {
    bool big = false,
  }) {
    final overlay = Overlay.of(context);
    final journeyBox =
        _journeyKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (journeyBox == null || overlayBox == null) return;
    final position = overlayBox.globalToLocal(journeyBox.localToGlobal(center));

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: IgnorePointer(
              // The overlay sits above the Scaffold, so give text a theme.
              child: Material(
                type: MaterialType.transparency,
                child: CompletionEffect(
                  type: type,
                  center: position,
                  label: label,
                  big: big,
                  onFinished: () {
                    if (_effects.remove(entry)) entry.remove();
                  },
                ),
              ),
            ),
          ),
    );
    _effects.add(entry);
    overlay.insert(entry);
  }

  void _clearEffects() {
    for (final entry in _effects) {
      entry.remove();
    }
    _effects.clear();
  }

  void _reset() {
    _clearEffects();
    context.read<JourneyProvider>().reset();
    _path.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  JourneyNodeState _stateFor(int index, int completed) {
    if (index < completed) return JourneyNodeState.done;
    // A step only becomes available once the road has reached it.
    if (index == completed && _path.value >= index - 0.001) {
      return JourneyNodeState.current;
    }
    return JourneyNodeState.locked;
  }

  @override
  Widget build(BuildContext context) {
    final journey = context.watch<JourneyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.route),
            Container(width: 10),
            const Text("Journey"),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Reset journey",
            icon: const Icon(Icons.replay),
            onPressed: _reset,
          ),
          PopupMenuButton<AppActions>(
            onSelected:
                (AppActions value) =>
                    AppActionsHelper.handleAction(value, context),
            itemBuilder:
                (context) => <PopupMenuEntry<AppActions>>[
                  AppActionsHelper.buildAction(AppActions.routines),
                  AppActionsHelper.buildAction(AppActions.settings),
                  AppActionsHelper.buildAction(AppActions.tools),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildJourney(journey)),
          _buildEffectPicker(journey),
        ],
      ),
    );
  }

  Widget _buildJourney(JourneyProvider journey) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final swing = min(width / 2 - JourneyNode.boxWidth / 2, 110.0);
      const steps = JourneyProvider.steps;

      // One stop per step plus a trophy at the end, weaving left/right.
      _centers = [
        for (var i = 0; i <= steps.length; i++)
          Offset(width / 2 + sin(i * 0.9) * swing, _topPadding + i * _spacing),
      ];
      final height = _centers.last.dy + _bottomPadding;

      return SingleChildScrollView(
        child: AnimatedBuilder(
          animation: Listenable.merge([_path, _shake]),
          builder: (context, _) {
            final t = _shake.value;
            final shake =
                t == 0 || t == 1
                    ? Offset.zero
                    : Offset(
                      sin(t * pi * 10) * 10 * (1 - t),
                      cos(t * pi * 8) * 4 * (1 - t),
                    );

            return Transform.translate(
              offset: shake,
              child: SizedBox(
                key: _journeyKey,
                width: width,
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: JourneyPathPainter(
                          points: _centers,
                          progress: _path.value,
                          trackColor: Colors.grey.shade300,
                          fillColor: const Color(0xFFFFC107),
                        ),
                      ),
                    ),
                    for (var i = 0; i < steps.length; i++)
                      _positionNode(
                        _centers[i],
                        JourneyNode(
                          key: ValueKey(steps[i].name),
                          icon: steps[i].icon,
                          label: steps[i].name,
                          state: _stateFor(i, journey.completed),
                          holdToComplete: journey.effect == JourneyEffect.hold,
                          onComplete: () => _completeStep(i),
                        ),
                      ),
                    _positionNode(
                      _centers.last,
                      JourneyNode(
                        key: const ValueKey("trophy"),
                        icon: Icons.emoji_events,
                        doneIcon: Icons.emoji_events,
                        label: "Finish",
                        state:
                            journey.isFinished &&
                                    _path.value >= steps.length - 0.001
                                ? JourneyNodeState.done
                                : JourneyNodeState.locked,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );

  Widget _positionNode(Offset center, JourneyNode node) => Positioned(
    left: center.dx - JourneyNode.boxWidth / 2,
    top: center.dy - JourneyNode.size / 2,
    child: node,
  );

  Widget _buildEffectPicker(JourneyProvider journey) => Material(
    elevation: 4,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            for (final effect in JourneyEffect.values)
              ChoiceChip(
                visualDensity: VisualDensity.compact,
                labelPadding: const EdgeInsets.only(left: 2, right: 6),
                avatar: Icon(effect.iconData, size: 18),
                label: Text(effect.friendlyName),
                selected: journey.effect == effect,
                onSelected: (_) => journey.effect = effect,
              ),
          ],
        ),
      ),
    ),
  );
}
