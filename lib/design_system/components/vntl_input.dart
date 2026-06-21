import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ventro_app/design_system/vntl.dart';

class VntlInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? error;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const VntlInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<VntlInput> createState() => _VntlInputState();
}

class _VntlInputState extends State<VntlInput> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.error != null;
    final isDisabled = widget.readOnly || !widget.enabled;

    final borderColor = hasError
        ? colors.error
        : isDisabled
            ? colors.border
            : _isFocused
                ? colors.primary
                : colors.border;

    final backgroundColor = isDisabled ? colors.surfaceSecondary : colors.glassSurface;
    final textColor = isDisabled ? colors.textTertiary : colors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: VntlText.labelSmall.copyWith(color: colors.textSecondary)),
          const SizedBox(height: VntlSpacing.xs),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: VntlRadius.mdBorderRadius,
            border: Border.all(color: borderColor, width: _isFocused ? 1.5 : 0.5),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            validator: widget.validator,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            style: VntlText.body.copyWith(color: textColor),
            cursorColor: colors.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: VntlText.body.copyWith(color: colors.textTertiary),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: colors.textTertiary, size: 18)
                  : null,
              suffix: widget.suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: VntlSpacing.lg,
                vertical: VntlSpacing.md,
              ),
              counterText: '',
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: VntlSpacing.xs),
          Text(widget.error!, style: VntlText.caption.copyWith(color: colors.error)),
        ],
      ],
    );
  }
}
