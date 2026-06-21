import 'package:flutter/material.dart';

class VntlText {
  VntlText._();
  static const String _font = 'Inter';

  static const TextStyle display = TextStyle(
      fontFamily: _font,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      height: 1.1);
  static const TextStyle h1 = TextStyle(
      fontFamily: _font,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2);
  static const TextStyle h2 = TextStyle(
      fontFamily: _font,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.3);
  static const TextStyle h3 =
      TextStyle(fontFamily: _font, fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle h4 =
      TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle bodyLarge =
      TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle body =
      TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodySmall =
      TextStyle(fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle label =
      TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle labelSmall = TextStyle(
      fontFamily: _font,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4);
  static const TextStyle caption =
      TextStyle(fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle mono =
      TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle monoLarge =
      TextStyle(fontFamily: 'monospace', fontSize: 24, fontWeight: FontWeight.w700, height: 1.2);
}
