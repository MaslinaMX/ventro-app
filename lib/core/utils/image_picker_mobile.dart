import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<(Uint8List, String)?> pickImageFile({
  required int maxSizeBytes,
  required List<String> allowedTypes,
}) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1200,
    maxHeight: 1200,
    imageQuality: 85,
  );
  if (file == null) return null;

  final bytes = await file.readAsBytes();
  if (bytes.length > maxSizeBytes) return null;

  return (bytes, file.name);
}
