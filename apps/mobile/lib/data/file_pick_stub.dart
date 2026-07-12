import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class PickedFile {
  PickedFile(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
}

// Native (mobile/desktop): file_picker.
Future<PickedFile?> pickFile() async {
  final r = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    withData: true,
  );
  final f = r?.files.firstOrNull;
  if (f?.bytes == null) return null;
  return PickedFile(f!.bytes!, f.name);
}
