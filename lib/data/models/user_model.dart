import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volt_find/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.photoUrl,
    super.vehicleModel,
    super.vehicleType,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      vehicleModel: data['vehicleModel'],
      vehicleType: data['vehicleType'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'vehicleModel': vehicleModel,
      'vehicleType': vehicleType,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      photoUrl: user.photoUrl,
      vehicleModel: user.vehicleModel,
      vehicleType: user.vehicleType,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}