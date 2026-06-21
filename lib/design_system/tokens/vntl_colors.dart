import 'package:flutter/material.dart';
import 'vntl_color_scheme.dart';
import 'vntl_colors_dark.dart';
import 'vntl_colors_light.dart';

export 'vntl_color_scheme.dart';
export 'vntl_colors_dark.dart';
export 'vntl_colors_light.dart';

class VntlColors {
  VntlColors._();

  static VntlColorScheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const VntlColorsDark()
        : const VntlColorsLight();
  }
}
