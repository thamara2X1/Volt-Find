import 'package:volt_find/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(String userId);
  Future<void> updateUser(User user);
  Future<void> updateProfilePhoto(String userId, String photoUrl);
  Future<void> updateVehicleInfo({
    required String userId,
    String? vehicleModel,
    String? vehicleType,
  });
}