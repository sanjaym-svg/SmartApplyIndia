import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

/// Web implementation: triggers a browser file download.
Future<void> downloadPdfBytes(Uint8List bytes, String fileName) async {
  final jsArray = bytes.toJS;
  final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'application/pdf'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
