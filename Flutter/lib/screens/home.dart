import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'mood_selection.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await _userService.getCurrentUserData();

    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  String getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return "Kullanıcı";
    }
    return fullName.trim().split(" ").first;
  }

  @override
  Widget build(BuildContext context) {
    final String userName = getFirstName(userData?['name']);
    final int streakCount = userData?['streakCount'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hoşgeldin, $userName",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Bugün kendin için ne yapacaksın?",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),

                        /// LOGOUT BUTTON
                        GestureDetector(
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();

                            if (!context.mounted) return;

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: AppShadows.soft,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// BÜYÜK KART
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.creamCard,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppShadows.medium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            child: SizedBox(
                              height: 240,
                              width: double.infinity,
                              child: Image.asset(
                                "assets/images/home_welcome.jpg",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: AppColors.primary.withOpacity(0.10),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Fiziksel ve zihinsel dengeni bulman için yanındayız.",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Sana özel tavsiyeleri keşfetmeye başla.",
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// STREAK
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.creamCard,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Harika Gidiyorsun! 🔥",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  streakCount > 0
                                      ? "$streakCount gündür serini devam ettiriyorsun."
                                      : "Bugün modunu keşfetmeye başla.",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MoodSelectionScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          shadowColor:
                              AppColors.primary.withOpacity(0.25),
                        ),
                        child: const Text(
                          "Modumu Bul",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}