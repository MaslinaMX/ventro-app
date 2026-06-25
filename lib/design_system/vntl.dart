// ✅ Ventro Design System V1 — Barrel export

import 'package:flutter/material.dart';

import 'tokens/vntl_colors.dart';

export 'tokens/vntl_colors.dart';
export 'tokens/vntl_text.dart';
export 'tokens/vntl_spacing.dart';
export 'tokens/vntl_radius.dart';
export 'components/vntl_card.dart';
export 'components/vntl_button.dart';
export 'components/vntl_input.dart';
export 'components/vntl_toast.dart';
export 'components/vntl_badge.dart';
export 'components/vntl_sidebar.dart';
export 'components/vntl_appbar.dart';
export 'components/vntl_layout.dart';
export 'components/vntl_dialog.dart';
export 'components/vntl_modal.dart';
export 'components/vntl_tooltip.dart';
export 'components/vntl_product_card.dart';
export 'components/vntl_table.dart';
export 'components/vntl_switch.dart';

export 'helpers/vntl_category_style.dart';

extension VntlTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  VntlColorScheme get colors => VntlColors.of(this);
  LinearGradient get backgroundGradient => colors.backgroundGradient;
}
