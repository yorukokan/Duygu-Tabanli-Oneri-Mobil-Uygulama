import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;

      print("AUTH USER: ${user?.uid}");

      if (user == null) {
        print("Giriş yapan kullanıcı yok");
        return null;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      print("DOC EXISTS: ${doc.exists}");
      print("DOC DATA: ${doc.data()}");

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      print("Kullanıcı verisi çekme hatası: $e");
      return null;
    }
  }
}