import 'package:fbro/features/auth/domain/entities/user_entity.dart';
import 'package:fbro/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmail {
  final AuthRepository _repository;
  const RegisterWithEmail(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) =>
      _repository.registerWithEmail(email: email, password: password);
}
