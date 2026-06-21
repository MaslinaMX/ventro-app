import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

enum VntlToastType { success, error, warning, info }

class VntlToast {
  static void show(
    BuildContext context, {
    required String message,
    VntlToastType type = VntlToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = context.colors;
    final (color, icon) = switch (type) {
      VntlToastType.success => (colors.success, Icons.check_circle_outline_rounded),
      VntlToastType.error => (colors.error, Icons.error_outline_rounded),
      VntlToastType.warning => (colors.warning, Icons.warning_amber_rounded),
      VntlToastType.info => (colors.primary, Icons.info_outline_rounded),
    };
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        color: color,
        icon: icon,
        duration: duration,
        surfaceColor: colors.surfaceSecondary,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final Duration duration;
  final Color surfaceColor;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.duration,
    required this.surfaceColor,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 48,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: VntlSpacing.xl2),
              padding:
                  const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
              decoration: BoxDecoration(
                color: widget.surfaceColor,
                borderRadius: VntlRadius.lgBorderRadius,
                border: Border.all(color: widget.color.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: widget.color, size: 18),
                  const SizedBox(width: VntlSpacing.sm),
                  Flexible(child: Text(widget.message, style: VntlText.body)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
