import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service managing offline CSV file creation and OS system share sheet distribution (Milestone 8.3).
class CsvExportService {
  const CsvExportService();

  /// Writes a CSV string to a temporary local file.
  Future<File> writeCsvToFile(String filename, String content) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    return file.writeAsString(content, flush: true);
  }

  /// Shares a single CSV ledger via the OS system share sheet (WhatsApp, Email, Drive, etc.).
  Future<ShareResult> shareSingleLedger({
    required String filename,
    required String content,
    String? subject,
    String? text,
  }) async {
    final file = await writeCsvToFile(filename, content);
    final xFile = XFile(file.path, mimeType: 'text/csv', name: filename);

    return Share.shareXFiles(
      [xFile],
      subject: subject ?? 'Farmivo Export - $filename',
      text: text ?? 'Exported agricultural financial ledger from Farmivo.',
    );
  }

  /// Shares multiple CSV ledgers concurrently (All Ledgers pack).
  Future<ShareResult> shareMultipleLedgers({
    required Map<String, String> files,
    String? subject,
    String? text,
  }) async {
    final xFiles = <XFile>[];

    for (final entry in files.entries) {
      final file = await writeCsvToFile(entry.key, entry.value);
      xFiles.add(XFile(file.path, mimeType: 'text/csv', name: entry.key));
    }

    return Share.shareXFiles(
      xFiles,
      subject: subject ?? 'Farmivo - Complete Project Audit Pack (CSV Ledgers)',
      text:
          text ??
          'Attached are the official raw CSV audit ledgers exported from Farmivo.',
    );
  }
}
