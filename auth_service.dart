import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> register(Map<String, dynamic> data) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: data['email'],
      password: data['password'],
    );

    final uid = userCredential.user?.uid;
    if (uid != null) {
      await _db.collection('athletes').doc(uid).set({
        "name": data['name'],
        "age": data['age'],
        "gender": data['gender'],
        "height": data['height'],
        "weight": data['weight'],
        "sport": data['sport'],
        "experienceLevel": data['experienceLevel'],
        "email": data['email'],
      });
    }

    return userCredential.user;
  }
}

// ✅ Riverpod provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});