import 'package:celebray/features/auth/data/user_storage_service.dart';
import 'package:celebray/features/auth/domain/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = FutureProvider<AppUser?>((ref) {
  return UserStorageService.loadUser();
});
