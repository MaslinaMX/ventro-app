import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:async';

Future<(Uint8List, String)?> pickImageFile({
  required int maxSizeBytes,
  required List<String> allowedTypes,
}) async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = allowedTypes.join(',');

  input.click();
  await input.onChange.first;

  final files = input.files;
  if (files == null || files.length == 0) return null;

  final file = files.item(0)!;
  if (file.size > maxSizeBytes) return null;

  final reader = web.FileReader();
  final completer = Completer<void>();

  reader.addEventListener(
      'load',
      (web.Event _) {
        completer.complete();
      }.toJS);

  reader.readAsArrayBuffer(file);
  await completer.future;

  final result = reader.result as JSArrayBuffer;
  final bytes = Uint8List.view(result.toDart);

  return (bytes, file.name);
}
