import 'dart:typed_data';

/// Platform-agnostic download interface.
/// Stub implementation — does nothing.
Future<void> downloadPdfBytes(Uint8List bytes, String fileName) async {
  throw UnsupportedError('PDF download not supported on this platform');
}
