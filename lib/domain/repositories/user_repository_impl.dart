import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:volt_find/domain/entities/user.dart' as app_user;  // Add alias
import 'package:volt_find/domain/repositories/user_repository.dart';
import 'package:volt_find/data/models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepositoryImpl(this._firestore, this._auth);

  @override
  Future<app_user.User> getUser(String userId) async {  // Use alias
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        // Create user document if it doesn't exist
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          await _createUserDocument(currentUser);
          return app_user.User(  // Use alias
            id: currentUser.uid,
            email: currentUser.email ?? '',
            name: currentUser.displayName,
            photoUrl: currentUser.photoURL,
          );
        }
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> _createUserDocument(User firebaseUser) async {  // This is Firebase User
    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'email': firebaseUser.email,
      'name': firebaseUser.displayName,
      'photoUrl': firebaseUser.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateUser(app_user.User user) async {  // Use alias
    try {
      final userModel = UserModel.fromUser(user);
      await _firestore.collection('users').doc(user.id).update(
            userModel.toFirestore(),
          );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update profile photo: $e');
    }
  }

  @override
  Future<void> updateVehicleInfo({
    required String userId,
    String? vehicleModel,
    String? vehicleType,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (vehicleModel != null) updateData['vehicleModel'] = vehicleModel;
      if (vehicleType != null) updateData['vehicleType'] = vehicleType;
      
      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update vehicle info: $e');
    }
  }
}