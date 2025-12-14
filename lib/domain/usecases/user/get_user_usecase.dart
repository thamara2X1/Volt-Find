import 'package:volt_find/domain/entities/user.dart';
import 'package:volt_find/domain/repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<User> call(String userId) async {
    return await repository.getUser(userId);
  }
}