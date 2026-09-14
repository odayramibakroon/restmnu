import 'error_messages.dart';

class ServerException implements Exception {
  final String message;
  ServerException([String? message])
    : message = message ?? ErrorMessages.message(AppErrorKey.server);

  @override
  String toString() => message;
}

class LocationException implements Exception {
  final String message;
  LocationException([String? message])
    : message = message ?? ErrorMessages.message(AppErrorKey.location);

  @override
  String toString() => message;
}

class WhatsAppException implements Exception {
  final String message;
  WhatsAppException([String? message])
    : message = message ?? ErrorMessages.message(AppErrorKey.whatsappOpen);

  @override
  String toString() => message;
}

class StorageException implements Exception {
  final String message;
  StorageException([String? message])
    : message = message ?? ErrorMessages.message(AppErrorKey.storageUpload);

  @override
  String toString() => message;
}
