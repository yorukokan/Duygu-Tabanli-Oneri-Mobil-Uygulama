import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),

          'streakCount': 0,
          'lastMoodCheckDate': "",
          'createdAt': FieldValue.serverTimestamp(),

          // PROFİL
          'profilePhotoUrl': "",

          // KRİTİK KISIM (SİSTEMİN BEYNİ)
          'healthPreferences': {
            'allergies': [],
            'sensitivities': [],
            'diseases': [],
            'specialConditions': [],
            'favoriteActivities': [],
          },
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw Exception("Firestore hatası: ${e.message}");
    } catch (e) {
      throw Exception("Beklenmeyen hata: $e");
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (e) {
      throw Exception("Giriş hatası: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Bu e-posta zaten kullanılıyor.";
      case 'invalid-email':
        return "Geçersiz e-posta adresi.";
      case 'weak-password':
        return "Şifre çok zayıf. En az 6 karakter gir.";
      case 'operation-not-allowed':
        return "E-posta/şifre ile kayıt Firebase'de aktif değil.";
      case 'user-not-found':
        return "Kullanıcı bulunamadı.";
      case 'wrong-password':
        return "Şifre hatalı.";
      default:
        return e.message ?? "Bilinmeyen hata.";
    }
  }
}