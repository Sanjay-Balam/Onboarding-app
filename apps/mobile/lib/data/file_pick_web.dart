import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class PickedFile {
  PickedFile(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
}

// Web: native <input type=file> — reliable dialog + jpg/png/pdf filter.
Future<PickedFile?> pickFile() async {
  final input = html.FileUploadInputElement()
    ..accept = '.jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf'
    ..style.display = 'none';
  html.document.body?.append(input); // some browsers need it in the DOM
  input.click();
  await input.onChange.first;
  final files = input.files;
  input.remove();
  if (files == null || files.isEmpty) return null;

  final file = files.first;
  final reader = html.FileReader();
  final done = Completer<void>();
  // onLoadEnd fires on success OR error → never hangs.
  reader.onLoadEnd.listen((_) => done.complete());
  reader.readAsArrayBuffer(file);
  await done.future;

  final res = reader.result;
  final Uint8List bytes;
  if (res is ByteBuffer) {
    bytes = res.asUint8List();
  } else if (res is Uint8List) {
    bytes = res;
  } else if (res is List<int>) {
    bytes = Uint8List.fromList(res);
  } else {
    return null;
  }
  return PickedFile(bytes, file.name);
}
