import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // Uygulamanın Giriş Yap Ekranı ile başlaması için.

void main() async {
  // Flutter ve Firebase'i başlatabilmek için gerekli bağlantıları kurduk.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki Debug yazısını kaldırdık.
      title: 'DDGYAOS',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange, // Uygulama ana renk paletini Turuncu ayarladık.
        elevatedButtonTheme: ElevatedButtonThemeData( // Butonlarında tek bir yerden teması gibi özellikleri ayarlıyoruz.
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      home: const LoginScreen(), // Uygulama açılınca Giriş ekranına gidecek şekilde ayarladık.
    );
  }
}