// lib/presentation/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:volt_find/domain/entities/user.dart';
import 'package:volt_find/domain/usecases/user/get_user_usecase.dart';
import 'package:volt_find/domain/usecases/user/update_user_usecase.dart';

class UserProvider extends ChangeNotifier {
  final GetUserUseCase _getUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final firebase_auth.FirebaseAuth _auth;  // Use alias

  UserProvider({
    required GetUserUseCase getUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required firebase_auth.FirebaseAuth auth,  // Use alias
  })  : _getUserUseCase = getUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        _auth = auth;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId != null) {
        _user = await _getUserUseCase(currentUserId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _updateUserUseCase(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateName(String name) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(name: name);
      await updateUser(updatedUser);
    }
  }

  Future<void> updatePhone(String phone) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(phone: phone);
      await updateUser(updatedUser);
    }
  }

  Future<void> updateVehicleInfo({
    String? vehicleModel,
    String? vehicleType,
  }) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(
        vehicleModel: vehicleModel,
        vehicleType: vehicleType,
      );
      await updateUser(updatedUser);
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(photoUrl: photoUrl);
      await updateUser(updatedUser);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}