import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Web
import 'image_picker_web.dart' if (dart.library.io) 'image_picker_mobile.dart';

class ImagePickerService {
  static Future<(Uint8List bytes, String fileName)?> pickImage({
    int maxSizeBytes = 2 * 1024 * 1024, // 2MB default
    List<String> allowedTypes = const ['image/png', 'image/jpeg'],
  }) async {
    return pickImageFile(
      maxSizeBytes: maxSizeBytes,
      allowedTypes: allowedTypes,
    );
  }
}
