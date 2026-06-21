// lib/design_system/components/vntl_tooltip.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

/// Tooltip informativo del design system. Se activa con hover en web/desktop
/// y con tap en móvil, detectado automáticamente según la plataforma.
///
/// Uso:
/// ```dart
/// VntlTooltip(
///   message: 'El stock se ajusta desde la sección de Inventario',
///   child: Icon(Icons.info_outline_rounded, size: 14),
/// )
/// ```
class VntlTooltip extends StatefulWidget {
  const VntlTooltip({
    super.key,
    required this.message,
    required this.child,
    this.maxWidth = 220,
  });

  /// Texto a mostrar dentro del tooltip.
  final String message;

  /// El widget que dispara el tooltip (ícono, texto, etc.).
  final Widget child;

  /// Ancho máximo del globo de texto.
  final double maxWidth;

  /// true si la plataforma actual debe usar tap en vez de hover
  /// (móvil táctil: Android/iOS). Web y desktop usan hover.
  static bool get _usaTap {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      // Platform no disponible (p. ej. algunos entornos de test) → default hover.
      return false;
    }
  }

  @override
  State<VntlTooltip> createState() => _VntlTooltipState();
}

class _VntlTooltipState extends State<VntlTooltip> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _visible = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final colors = context.colors;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: widget.maxWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 22),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: VntlSpacing.md,
                vertical: VntlSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceTertiary,
                borderRadius: VntlRadius.smBorderRadius,
                border: Border.all(color: colors.border, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: VntlText.caption.copyWith(color: colors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _visible = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _visible = false);
  }

  void _toggleOverlay() {
    if (_visible) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );

    if (VntlTooltip._usaTap) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleOverlay,
        child: child,
      );
    }

    return MouseRegion(
      onEnter: (_) => _showOverlay(),
      onExit: (_) => _removeOverlay(),
      child: child,
    );
  }
}
