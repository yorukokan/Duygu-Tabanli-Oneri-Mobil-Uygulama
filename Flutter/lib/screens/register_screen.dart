import 'package:flutter/material.dart';
import 'package:ddgyaosproje/services/auth_service.dart';
import '../theme/app_theme.dart';

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

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.soft,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Hesap Oluştur",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Sağlık yolculuğuna bugün başla.",
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),

                _buildTextField(
                  controller: _nameController,
                  hint: "Ad Soyad",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  hint: "E-posta",
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _passwordController,
                  hint: "Şifre",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: "Şifreyi Onayla",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppColors.primary.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Kayıt Ol",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 22),
                const Divider(thickness: 1, color: AppColors.border),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Zaten hesabın var mı?",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showMessage("Lütfen adınızı ve soyadınızı girin!");
      return;
    }

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Lütfen tüm alanları doldurun!");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Şifreler uyuşmuyor!");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await AuthService().register(email, password, name);

      if (!mounted) return;

      setState(() => isLoading = false);

      if (user != null) {
        _showMessage("Başarıyla kayıt oldun!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      _showMessage(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}