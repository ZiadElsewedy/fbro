import 'package:fbro/features/auth/domain/entities/user_entity.dart';
import 'package:fbro/features/auth/domain/repositories/auth_repository.dart';

class VerifyPhoneNumber {
  final AuthRepository _repository;
  const VerifyPhoneNumber(this._repository);

  Future<void> call({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onFailed,
    void Function(UserEntity user)? onAutoVerified,
  }) =>
      _repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onFailed: onFailed,
        onAutoVerified: onAutoVerified,
      );
}
