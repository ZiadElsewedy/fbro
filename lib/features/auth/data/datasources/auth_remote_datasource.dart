import 'package:firebase_auth/firebase_auth.dart';
import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> registerWithEmail({required String email, required String password});
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onFailed,
    void Function(UserModel user)? onAutoVerified,
  });
  Future<UserModel> signInWithOtp({required String verificationId, required String smsCode});
  Future<void> signOut();
  UserModel? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  AuthRemoteDataSourceImpl(this._auth);

  @override
  Stream<UserModel?> get authStateChanges => _auth
      .authStateChanges()
      .map((u) => u == null ? null : UserModel.fromFirebaseUser(u));

  @override
  UserModel? get currentUser => _auth.currentUser == null
      ? null
      : UserModel.fromFirebaseUser(_auth.currentUser!);

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onFailed,
    void Function(UserModel user)? onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          final result = await _auth.signInWithCredential(credential);
          if (result.user != null) {
            onAutoVerified?.call(UserModel.fromFirebaseUser(result.user!));
          }
        } on FirebaseAuthException catch (e) {
          onFailed(e.message ?? 'Auto-verification failed');
        }
      },
      verificationFailed: (e) => onFailed(e.message ?? 'Verification failed'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<UserModel> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'OTP verification failed');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
