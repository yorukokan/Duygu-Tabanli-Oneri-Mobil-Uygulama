import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  // Kayıt Ol Fonksiyonu
  Future<User?> register(String email, String password, String name) async {
    try {
      // Firebase Auth hesabı açıyoruz.
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      User? user = result.user;

      if (user != null) {
        // Hesap açıldıysa, kullanıcının adını tutmak için yeni doküman oluşturuyoruz.
        await _firestore.collection('Users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': DateTime.now(),
          'uid': user.uid,
        });
      }
      return user;
    } catch (e) {
      print("Kayıt veya Firestore hatası: $e");
      return null;
    }
  }
  
   // Giriş Yap Fonksiyonu
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Giriş hatası: $e");
      return null;
    }
  }
}

 
