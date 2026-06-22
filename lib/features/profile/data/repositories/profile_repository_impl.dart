import 'dart:io';

import 'package:fbro/core/cache/cache_manager.dart';
import 'package:fbro/core/cache/cache_policy.dart';
import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fbro/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:fbro/features/profile/domain/entities/profile_entity.dart';
import 'package:fbro/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _profileRemote;
  final AuthRemoteDataSource _authRemote;
  final CacheManager _cache;

  ProfileRepositoryImpl(this._profileRemote, this._authRemote, this._cache);

  @override
  Future<ProfileEntity?> getProfile(String uid) async {
    try {
      // The profile (`users/{uid}`) was re-read on every Profile-tab visit even
      // though it changes rarely. Cache it (stable); `updateProfile` refreshes
      // the entry, and sign-out clears the whole cache.
      final cached = _cache.read<ProfileEntity>(CacheKeys.profile(uid));
      if (cached != null) return cached;
      final model = await _profileRemote.getProfile(uid);
      final entity = model?.toEntity();
      if (entity != null) {
        _cache.write(CacheKeys.profile(uid), entity, CachePolicy.stable);
      }
      return entity;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String uid,
    String? fullName,
    String? username,
    String? bio,
    String? phoneNumber,
    String? country,
    String? city,
    String? website,
    String? gender,
    DateTime? birthDate,
    String? profileImage,
    String? coverImage,
  }) async {
    try {
      await _profileRemote.updateProfile(
        uid: uid,
        fullName: fullName,
        username: username?.toLowerCase(),
        bio: bio,
        phoneNumber: phoneNumber,
        country: country,
        city: city,
        website: website,
        gender: gender,
        birthDate: birthDate,
        profileImage: profileImage,
        coverImage: coverImage,
      );

      // Keep the Firebase Auth profile in sync so the auth session / Home
      // reflect the new name and avatar without a re-login. Best-effort:
      // a sync failure shouldn't fail the whole save.
      if (fullName != null && fullName.trim().isNotEmpty) {
        try {
          await _authRemote.updateDisplayName(fullName.trim());
        } on AuthException {/* non-fatal */}
      }
      if (profileImage != null && profileImage.trim().isNotEmpty) {
        try {
          await _authRemote.updatePhotoUrl(profileImage.trim());
        } on AuthException {/* non-fatal */}
      }

      final updated = await _profileRemote.getProfile(uid);
      if (updated == null) {
        throw const AuthFailure('Profile not found after update.');
      }
      // Write-through: refresh the cached profile with the just-saved truth so
      // the next read serves the update, not a stale copy.
      final entity = updated.toEntity();
      _cache.write(CacheKeys.profile(uid), entity, CachePolicy.stable);
      return entity;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<String> uploadProfileImage(String uid, File file,
      {void Function(double progress)? onProgress}) async {
    try {
      return await _profileRemote.uploadProfileImage(uid, file,
          onProgress: onProgress);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<String> uploadCoverImage(String uid, File file,
      {void Function(double progress)? onProgress}) async {
    try {
      return await _profileRemote.uploadCoverImage(uid, file,
          onProgress: onProgress);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username, {required String forUid}) =>
      _profileRemote.isUsernameAvailable(username.toLowerCase(), forUid: forUid);
}
