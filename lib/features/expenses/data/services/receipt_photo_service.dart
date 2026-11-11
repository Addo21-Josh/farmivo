import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';

/// Service managing local photographic receipt capture, compression, and file storage.
class ReceiptPhotoService {
  final ImagePicker _picker;
  final Uuid _uuid;

  ReceiptPhotoService({ImagePicker? picker, Uuid? uuid})
    : _picker = picker ?? ImagePicker(),
      _uuid = uuid ?? const Uuid();

  /// Captures a photo using the device camera with automatic hardware-accelerated
  /// compression (JPEG 80% quality, max 1280px dimensions).
  Future<String?> captureFromCamera() async {
    return _pickAndSave(ImageSource.camera);
  }

  /// Selects a receipt image from device storage / gallery with compression.
  Future<String?> pickFromGallery() async {
    return _pickAndSave(ImageSource.gallery);
  }

  /// Internal helper to pick, compress, and persist to app's receipts/ folder.
  Future<String?> _pickAndSave(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        return null; // User cancelled capture
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory receiptsDir = Directory(p.join(appDir.path, 'receipts'));
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final String extension = p.extension(pickedFile.path).isNotEmpty
          ? p.extension(pickedFile.path)
          : '.jpg';
      final String fileName = 'receipt_${_uuid.v4()}$extension';
      final String destinationPath = p.join(receiptsDir.path, fileName);

      // Save picked compressed image to target app directory
      await pickedFile.saveTo(destinationPath);
      AppLogger.info('Receipt photo saved to: $destinationPath');
      return destinationPath;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to capture receipt photo', e, stackTrace);
      throw ValidationFailure('Unable to capture or save receipt photo: $e');
    }
  }

  /// Deletes an existing receipt photo file from local storage if it exists.
  Future<bool> deleteReceiptPhoto(String? path) async {
    if (path == null || path.trim().isEmpty) return false;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Receipt photo deleted: $path');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete receipt photo: $path', e, stackTrace);
      return false;
    }
  }
}
