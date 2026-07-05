import 'package:flutter/foundation.dart';

class Env {
  Env._();
  static const String _prodUrl = 'https://api.ventro.com.mx/api';
  static const String _devUrl = 'http://127.0.0.1:8000/api';

  static String get baseUrl => kReleaseMode ? _prodUrl : _devUrl;
}
