import 'package:flutter/material.dart';
import 'package:ddgyaosproje/services/auth_service.dart';
import 'register_screen.dart';
import 'home.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool rememberMe = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        AppColors.primary.withOpacity(0.18),
                        AppColors.primary.withOpacity(0.36),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.contrast,
                    color: AppColors.primary,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Tekrar Hoşgeldin!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 48),

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
                  isPassword: true,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? true;
                        });
                      },
                    ),
                    const Text(
                      "Beni hatırla",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Şifremi Unuttum?",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: AppColors.primary.withOpacity(0.30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Giriş Yap",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Hesabın yok mu?",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Kayıt Ol",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
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

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-posta ve şifre boş olamaz.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final user = await AuthService().login(email, password);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giriş bilgileri hatalı!")),
      );
    }
  }
}