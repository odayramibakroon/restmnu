import 'package:shared_preferences/shared_preferences.dart';

import '../errors/error_messages.dart';
import '../errors/exceptions.dart';

abstract class LocalStorageService {
  Future<String?> readString(
    String key, {
    AppErrorKey errorKey = AppErrorKey.loadLocalStorage,
  });

  Future<void> writeString(
    String key,
    String value, {
    AppErrorKey errorKey = AppErrorKey.saveLocalStorage,
  });

  Future<void> remove(
    String key, {
    AppErrorKey errorKey = AppErrorKey.clearLocalStorage,
  });

  Future<void> removeMany(
    Iterable<String> keys, {
    AppErrorKey errorKey = AppErrorKey.clearLocalStorage,
  });
}

class SharedPreferencesLocalStorageService implements LocalStorageService {
  final SharedPreferences _preferences;

  const SharedPreferencesLocalStorageService(this._preferences);

  @override
  Future<String?> readString(
    String key, {
    AppErrorKey errorKey = AppErrorKey.loadLocalStorage,
  }) async {
    try {
      return _preferences.getString(key);
    } catch (e) {
      throw StorageException(ErrorMessages.withDetails(errorKey, e));
    }
  }

  @override
  Future<void> writeString(
    String key,
    String value, {
    AppErrorKey errorKey = AppErrorKey.saveLocalStorage,
  }) async {
    try {
      final didSave = await _preferences.setString(key, value);
      if (!didSave) {
        throw StorageException(ErrorMessages.message(errorKey));
      }
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(ErrorMessages.withDetails(errorKey, e));
    }
  }

  @override
  Future<void> remove(
    String key, {
    AppErrorKey errorKey = AppErrorKey.clearLocalStorage,
  }) async {
    try {
      final didRemove = await _preferences.remove(key);
      if (!didRemove) {
        throw StorageException(ErrorMessages.message(errorKey));
      }
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(ErrorMessages.withDetails(errorKey, e));
    }
  }

  @override
  Future<void> removeMany(
    Iterable<String> keys, {
    AppErrorKey errorKey = AppErrorKey.clearLocalStorage,
  }) async {
    try {
      for (final key in keys) {
        await _preferences.remove(key);
      }
    } catch (e) {
      throw StorageException(ErrorMessages.withDetails(errorKey, e));
    }
  }
}
