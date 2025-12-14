import 'package:volt_find/domain/entities/user.dart';
import 'package:volt_find/domain/repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<void> call(User user) async {
    return await repository.updateUser(user);
  }
}