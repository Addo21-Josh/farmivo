import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Centralized diagnostic and forensic audit logger for Farmivo with disk rotation.
class AppLogger {
  AppLogger._();

  static Logger? _instance;
  static Directory? _logDirectory;
  static RotatingFileOutput? _fileOutput;

  /// Initializes the file-based rotating logger.
  static Future<void> init({Directory? directory}) async {
    try {
      if (directory != null) {
        _logDirectory = directory;
      } else {
        final docs = await getApplicationDocumentsDirectory();
        _logDirectory = Directory(p.join(docs.path, 'logs'));
      }

      if (!_logDirectory!.existsSync()) {
        _logDirectory!.createSync(recursive: true);
      }

      final logFile = File(p.join(_logDirectory!.path, 'farmivo.log'));
      _fileOutput = RotatingFileOutput(
        file: logFile,
        maxBytes: 1024 * 1024, // 1 MB per log file
        maxRotatedFiles: 3, // Keep up to 3 rotated backup files
      );

      _instance = Logger(
        printer: SimplePrinter(printTime: true, colors: false),
        output: _DualOutput(_fileOutput!),
      );

      info(
        'AppLogger initialized with disk rotation at: ${_logDirectory!.path}',
      );
    } catch (e) {
      // Fallback to console logger if file storage fails
      _instance = Logger(printer: PrettyPrinter(methodCount: 2, colors: true));
    }
  }

  static Logger get _logger {
    _instance ??= Logger(printer: PrettyPrinter(methodCount: 2, colors: true));
    return _instance!;
  }

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Returns all active and rotated log files on disk (for export or support).
  static List<File> getLogFiles() {
    if (_logDirectory == null || !_logDirectory!.existsSync()) return [];
    return _logDirectory!
        .listSync()
        .whereType<File>()
        .where(
          (f) =>
              p.basename(f.path).startsWith('farmivo') &&
              p.extension(f.path) == '.log',
        )
        .toList();
  }
}

/// Output destination writing simultaneously to debug console and rotating disk files.
class _DualOutput extends LogOutput {
  final RotatingFileOutput fileOutput;
  final ConsoleOutput consoleOutput = ConsoleOutput();

  _DualOutput(this.fileOutput);

  @override
  void output(OutputEvent event) {
    if (kDebugMode) {
      consoleOutput.output(event);
    }
    fileOutput.output(event);
  }
}

/// Automatically manages size-based disk log rotation.
class RotatingFileOutput extends LogOutput {
  final File file;
  final int maxBytes;
  final int maxRotatedFiles;

  RotatingFileOutput({
    required this.file,
    this.maxBytes = 1048576, // 1 MB
    this.maxRotatedFiles = 3,
  });

  @override
  void output(OutputEvent event) {
    try {
      _rotateIfNeeded();
      final content = '${event.lines.join('\n')}\n';
      file.writeAsStringSync(content, mode: FileMode.append, flush: true);
    } catch (_) {}
  }

  void _rotateIfNeeded() {
    if (!file.existsSync()) return;
    if (file.lengthSync() < maxBytes) return;

    // Rotate existing backup files: .2 -> delete, .1 -> .2, primary -> .1
    final dir = file.parent.path;
    final baseName = p.basenameWithoutExtension(file.path);
    final ext = p.extension(file.path);

    for (int i = maxRotatedFiles - 1; i >= 1; i--) {
      final current = File(p.join(dir, '$baseName.$i$ext'));
      if (current.existsSync()) {
        if (i == maxRotatedFiles - 1) {
          current.deleteSync();
        } else {
          current.renameSync(p.join(dir, '$baseName.${i + 1}$ext'));
        }
      }
    }

    // Rename primary file to .1
    file.renameSync(p.join(dir, '$baseName.1$ext'));
  }
}
