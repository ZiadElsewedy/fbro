import 'package:fbro/features/auth/domain/entities/user_entity.dart';
import 'package:fbro/features/auth/domain/repositories/auth_repository.dart';

class SignInWithOtp {
  final AuthRepository _repository;
  const SignInWithOtp(this._repository);

  Future<UserEntity> call({
    required String verificationId,
    required String smsCode,
  }) =>
      _repository.signInWithOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
}
