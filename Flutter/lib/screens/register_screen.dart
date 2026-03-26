import 'package:flutter/material.dart';
import 'package:ddgyaosproje/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final Color primaryColor = const Color(0xFFEC5B13);
  final Color bgColor = const Color(0xFFF8F6F6); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // Klavye açıldığında ekranın bozulmasın diye true yaptık.
      // Aynı zamanda ekranın kendini yeniden boyutlandırması için bu özelliği yapıyoruz.
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Her şeyi dikeyde ortalar
            children: [
              // Logo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite_border, color: primaryColor, size: 35),
              ),
              const SizedBox(height: 16),
              
              // Başlıklar
              const Text(
                'Hesap Oluştur',
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5, // Harfler arasındaki boşluğu hafifçe daraltıyoruz.
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sağlık yolculuğuna bugün başla.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Form Kısmı
              _buildTextField(controller: _nameController, hint: 'Ad Soyad', icon: Icons.person_outline),
              const SizedBox(height: 10),
              _buildTextField(controller: _emailController, hint: 'E-posta', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildTextField(controller: _passwordController, hint: 'Şifre', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 10),
              _buildTextField(controller: _confirmPasswordController, hint: 'Şifreyi Onayla', icon: Icons.lock_outline, isPassword: true),
              
              const SizedBox(height: 24),

              // Kayıt ol
              SizedBox(
                width: double.infinity, // Butonun yatayda ekranı tam kaplamasını sağlıyoruz.
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kayıt Ol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1),
              
              // Giriş yap
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Zaten hesabın var mı?', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Uygulama içindeki tüm Textfield widget'larının aynı tasarıma sahip olması için.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 55, // Input yüksekliği sabitlendi
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Çok hafif bir dış gölge efekti ekliyoruz.
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.6), size: 20),
          border: InputBorder.none,
          // Yazının kutu içinde ortalı durması için sadece dikeyde iç boşluk veriyoruz.
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  void _handleRegister() async {
  // Boş alan kontrolü yapıyoruz.
  if (_nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lütfen adınızı ve soyadınızı girin!")),
    );
    return;
  }

  // Şifrelerin uyuşup uyuşmadığını kontrol ediyoruz.
  if (_passwordController.text != _confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Şifreler uyuşmuyor!")),
    );
    return;
  }

  // Firebase'e name parametresini gönderiyoruz.
  var user = await AuthService().register(
    _emailController.text.trim(), 
    _passwordController.text.trim(),
    _nameController.text.trim(), // Firestore'a gidiyor.
  );

  if (user != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Başarıyla kayıt oldun!")),
    );
    Navigator.pop(context); 
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kayıt sırasında bir hata oluştu.")),
    );
  }
}
}