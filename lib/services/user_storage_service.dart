import 'dart:convert';
import 'package:celebray/models/app_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class UserStorageService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _userKey = 'user';

  /// Save user to secure storage
  static Future<void> saveUser(AppUser? user) async {
    if (user == null) {
      await _storage.delete(key: _userKey);
    } else {
      final jsonString = jsonEncode(user.toJson());
      await _storage.write(key: _userKey, value: jsonString);
    }
  }

  /// Load user from secure storage
  static Future<AppUser?> loadUser() async {
    final jsonString = await _storage.read(key: _userKey);
    if (jsonString == null) return null;
    return AppUser.fromJson(jsonDecode(jsonString));
  }

  /// Delete user from secure storage
  static Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
}