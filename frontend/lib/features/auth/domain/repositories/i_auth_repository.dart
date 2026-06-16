import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserEntity> fetchProfile();
}
