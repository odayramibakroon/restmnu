import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import '../config/supabase_config.dart';
import '../constants/app_constants.dart';
import '../errors/error_messages.dart';
import '../errors/exceptions.dart';

abstract class ImageStorageService {
  Future<String> uploadImage({
    required dynamic imageFile, // File or Uint8List (for web)
    required String folder,
    String? customFileName,
  });

  Future<void> deleteImageByUrl(String imageUrl);
}

class SupabaseImageStorageServiceImpl implements ImageStorageService {
  final SupabaseClient _supabaseClient;

  SupabaseImageStorageServiceImpl({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<String> uploadImage({
    required dynamic imageFile,
    required String folder,
    String? customFileName,
  }) async {
    try {
      final originalBytes = await _readImageBytes(imageFile);
      final uploadBytes = _compressToLimit(originalBytes);
      final fileName = _ensureJpgFileName(
        customFileName ?? 'img_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final path = '$folder/$fileName';

      await _supabaseClient.storage
          .from(SupabaseConfig.bucketName)
          .uploadBinary(
            path,
            uploadBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      final publicUrl = _supabaseClient.storage
          .from(SupabaseConfig.bucketName)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        ErrorMessages.withDetails(AppErrorKey.uploadImageToSupabase, e),
      );
    }
  }

  @override
  Future<void> deleteImageByUrl(String imageUrl) async {
    final path = _extractStoragePathFromUrl(imageUrl);
    if (path == null || path.isEmpty) return;

    try {
      await _supabaseClient.storage.from(SupabaseConfig.bucketName).remove([
        path,
      ]);
    } catch (e) {
      throw StorageException(
        ErrorMessages.withDetails(AppErrorKey.deleteImageFromSupabase, e),
      );
    }
  }

  Future<Uint8List> _readImageBytes(dynamic imageFile) async {
    if (imageFile is Uint8List) {
      return imageFile;
    }

    try {
      final bytes = await imageFile.readAsBytes();
      if (bytes is Uint8List) {
        return bytes;
      }
      if (bytes is List<int>) {
        return Uint8List.fromList(bytes);
      }
    } catch (_) {
      // Fall through to the readable app exception below.
    }

    throw StorageException(
      ErrorMessages.message(AppErrorKey.imageReadUnsupported),
    );
  }

  Uint8List _compressToLimit(Uint8List originalBytes) {
    final decoded = img.decodeImage(originalBytes);

    if (decoded == null) {
      if (originalBytes.lengthInBytes <= AppConstants.maxImageSizeBytes) {
        return originalBytes;
      }
      throw StorageException(
        ErrorMessages.message(AppErrorKey.imageCompressChooseSmaller),
      );
    }

    img.Image workingImage = img.bakeOrientation(decoded);
    var maxSide = math.max(workingImage.width, workingImage.height);

    if (maxSide > 1600) {
      final scale = 1600 / maxSide;
      workingImage = img.copyResize(
        workingImage,
        width: (workingImage.width * scale).round(),
        height: (workingImage.height * scale).round(),
        interpolation: img.Interpolation.average,
      );
      maxSide = math.max(workingImage.width, workingImage.height);
    }

    for (final quality in [88, 82, 76, 70, 64, 58, 52, 46, 40]) {
      final encoded = Uint8List.fromList(
        img.encodeJpg(workingImage, quality: quality),
      );
      if (encoded.lengthInBytes <= AppConstants.maxImageSizeBytes) {
        return encoded;
      }
    }

    while (maxSide > 640) {
      final nextMaxSide = (maxSide * 0.85).round();
      final scale = nextMaxSide / maxSide;
      workingImage = img.copyResize(
        workingImage,
        width: (workingImage.width * scale).round(),
        height: (workingImage.height * scale).round(),
        interpolation: img.Interpolation.average,
      );
      maxSide = nextMaxSide;

      for (final quality in [76, 64, 52, 40]) {
        final encoded = Uint8List.fromList(
          img.encodeJpg(workingImage, quality: quality),
        );
        if (encoded.lengthInBytes <= AppConstants.maxImageSizeBytes) {
          return encoded;
        }
      }
    }

    debugPrint(
      'Unable to compress image below ${AppConstants.maxImageSizeBytes} bytes',
    );
    throw StorageException(
      ErrorMessages.message(AppErrorKey.imageCompressBelowLimitFailed),
    );
  }

  String _ensureJpgFileName(String fileName) {
    final normalized = fileName.trim().isEmpty
        ? 'img_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : fileName.trim();

    final withoutExtension = normalized.replaceFirst(
      RegExp(r'\.(jpg|jpeg|png|webp)$', caseSensitive: false),
      '',
    );

    return '$withoutExtension.jpg';
  }

  String? _extractStoragePathFromUrl(String imageUrl) {
    if (imageUrl.trim().isEmpty) return null;

    final uri = Uri.tryParse(imageUrl);
    final supabaseUri = Uri.tryParse(SupabaseConfig.supabaseUrl);
    if (uri == null || supabaseUri == null) return null;
    if (uri.host != supabaseUri.host) return null;

    final marker = '/object/public/${SupabaseConfig.bucketName}/';
    final index = uri.path.indexOf(marker);
    if (index == -1) return null;

    return Uri.decodeComponent(uri.path.substring(index + marker.length));
  }
}
