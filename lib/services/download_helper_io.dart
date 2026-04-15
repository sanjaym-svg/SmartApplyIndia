import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Mobile/Desktop implementation: saves PDF to app documents directory.
Future<void> downloadPdfBytes(Uint8List bytes, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes);
}
