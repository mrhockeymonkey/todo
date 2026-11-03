import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/celebration/celebration_controller.dart';

/// Marks a done item as the landing spot for a completion celebration. Stays
/// invisible (but laid out) while the celebration is in flight, then pops in.
///
/// Without a [CelebrationController] above it this just shows [child].
class CelebrationTarget extends StatefulWidget {
  final String? taskId;

  /// Only done items are landing spots.
  final bool enabled;
  final Widget child;

  const CelebrationTarget({
    super.key,
    required this.taskId,
    required this.enabled,
    required this.child,
  });

  @override
  State<CelebrationTarget> createState() => _CelebrationTargetState();
}

class _CelebrationTargetState extends State<CelebrationTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );
  CelebrationController? _controller;
  bool _hidden = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = Provider.of<CelebrationController?>(
      context,
      listen: false,
    );
    if (controller != _controller) {
      _unregister(widget.taskId);
      _controller?.removeListener(_onChanged);
      _controller = controller?..addListener(_onChanged);
    }
    _register();
    _hidden = _isHidden;
  }

  @override
  void didUpdateWidget(CelebrationTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskId != widget.taskId) _unregister(oldWidget.taskId);
    _register();
  }

  @override
  void dispose() {
    _unregister(widget.taskId);
    _controller?.removeListener(_onChanged);
    _pop.dispose();
    super.dispose();
  }

  bool get _isHidden {
    final id = widget.taskId;
    return widget.enabled && id != null && (_controller?.isHidden(id) ?? false);
  }

  void _register() {
    final id = widget.taskId;
    if (id == null) return;
    widget.enabled
        ? _controller?.register(id, context)
        : _controller?.unregister(id, context);
  }

  void _unregister(String? id) {
    if (id != null) _controller?.unregister(id, context);
  }

  void _onChanged() {
    final hidden = _isHidden;
    if (hidden == _hidden) return;
    if (!hidden) _pop.forward(from: 0);
    setState(() => _hidden = hidden);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return widget.child;
    // Keep the same widget structure whatever the state so the child is
    // never remounted.
    return AnimatedBuilder(
      animation: _pop,
      child: widget.child,
      builder: (context, child) {
        final t = _hidden ? 1.0 : _pop.value;
        final scale = 0.85 + 0.15 * Curves.elasticOut.transform(t);
        final glow = (1 - t) * 0.35;
        return Opacity(
          opacity: _hidden ? 0 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: glow),
            ),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
