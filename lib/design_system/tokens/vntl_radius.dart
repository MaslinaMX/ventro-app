import 'package:flutter/material.dart';

// ✅ Ventro Design System V1 — Border Radius
class VntlRadius {
  VntlRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double full = 999.0;

  static const BorderRadius xsBorderRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBorderRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorderRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorderRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorderRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xl2BorderRadius = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius fullBorderRadius = BorderRadius.all(Radius.circular(full));
}
