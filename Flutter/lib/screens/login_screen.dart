import 'package:flutter/material.dart';
import 'package:ddgyaosproje/services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Kontrolcüler
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Renkler
  final Color primaryColor = const Color(0xFFEC5B13);
  final Color bgColor = const Color(0xFFF8F6F6);
  final Color slate600 = const Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // SafeArea, uygulamanın donanımsal alanlarının altında kalmasını engelliyoruz.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  // Kutunun görsel özelliklerini şeklini ve rengini ayarlıyoruz.
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Dairenin zeminine renk geçişi uyguluyoruz.
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        primaryColor.withOpacity(0.2),
                        Colors.orange.shade200,
                      ],
                    ),
                  ),
                  // Dairenin tam ortasına bir ikon yerleştiriyoruz. (İleride uygulama logosu olabilir.)
                  child: Icon(Icons.contrast, color: primaryColor, size: 50),
                ),
                const SizedBox(height: 24),
                // Başlık
                const Text(
                  'Tekrar Hoşgeldin!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -1, // Harfler arasındaki boşluğu birbirine biraz daha yaklaştırıyoruz.
                  ),
                ),
                const SizedBox(height: 48),

                // Inputlar 
                _buildInputLabel("E-posta"),
                _buildTextField(
                  controller: _emailController,
                  hint: "example@mail.com",
                  icon: Icons.mail_outline,
                ),
                const SizedBox(height: 20),
                _buildInputLabel("Şifre"),
                _buildTextField(
                  controller: _passwordController,
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  isPassword: true, // Yazılan karakterlerin gizlenmesi için  true yapıyoruz.
                ),

                // Şifremi Unuttum 
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    // Şu an için boş ileride gerekli bağlantı ile sıfırlama olacak.
                    onPressed: () {},
                    child: Text(
                      'Şifremi Unuttum?',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Giriş Yap
                SizedBox(
                  width: double.infinity, // Butonun genişliğini bulunduğu ekranın izin verdiği en geniş alana yayıyoruz.
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _handleLogin, // Tıklandığında çalışacak fonksiyon
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 10, //Butona dış gölge ekleyerek onu sayfadan yükseltilmiş gibi gösteriyoruz.
                      shadowColor: primaryColor.withOpacity(0.3),
                      // Butonun köşelerini yuvarlatıyoruz.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Kayıt ol
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hesabın yok mu?', style: TextStyle(color: slate600)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Label yazılarının tasarımı 
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        // Dışarıdan gelen 'label' değişkenini ekrana basıyoruz.
        child: Text(
          label,
          style: TextStyle(
            color: slate600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Input kutusu tasarımı
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint, // Metin kutusu boşken görünecek olan yazı.
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4), // Gölgeyi yatayda değiştirmeyip, dikeyde kaydırıyoruz.
          ),
        ],
        // Kutunun çevresine ince bir çizgi çiziyoruz.
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none, // Biz zaten dışarıdaki Container'da çizgi çizdiğimiz için standart TextField çizgisini gizliyoruz.
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Yazılan metnin kutu kenarlarına yapışmaması için dikey ve yatayda iç boşluk bırakıyoruz.
        ),
      ),
    );
  }

  // Giriş Mantığı
  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      // AuthService sınıfından bir nesne üretip, login metodunu e-posta ve şifre çağırıyoruz.
      // Firebase'den cevap gelene kadar bu satırda beklemek için await kullanıyoruz.
      var user = await AuthService().login(email, password);
      // Giriş başarılı ise
      if (user != null) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()), // !! Ana Sayfaya gidicek ama ileride tasarlanacak.
  );
}else { // Eğer giriş işlemi başarısız sonuçlandıysa
        // Ekranın alt kısmında kullanıcıya bilgilendirme kutusu yani SnackBar için ScaffoldMessenger kullanıyoruz.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş bilgileri hatalı!")),
        );
      }
    }
  }
}