import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';
import 'mood_selection.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import 'end_day_review_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();

  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool hasEndDayReview = false;

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    await loadUserData();
    await loadEndDayReviewStatus();
  }

  Future<void> loadUserData() async {
    final data = await _userService.getCurrentUserData();

    if (!mounted) return;

    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  Future<void> loadEndDayReviewStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayKey = DateTime.now().toIso8601String().split("T")[0];

    final doc = await FirebaseFirestore.instance
        .collection("dailyEvaluations")
        .doc("${user.uid}_$todayKey")
        .get();

    if (!mounted) return;

    setState(() {
      hasEndDayReview = doc.exists;
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
                    _header(userName),
                    const SizedBox(height: 24),
                    _welcomeCard(),
                    const SizedBox(height: 20),
                    _streakCard(streakCount),
                    const SizedBox(height: 20),
                    _endDayReviewCard(),
                    const SizedBox(height: 28),
                    _moodButton(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _header(String userName) {
    return Row(
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
      ],
    );
  }

  Widget _welcomeCard() {
    return Container(
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
    );
  }

  Widget _streakCard(int streakCount) {
    return Container(
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
    );
  }

  Widget _endDayReviewCard() {
    return Container(
      width: double.infinity,
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
              color: hasEndDayReview
                  ? Colors.green.withOpacity(0.12)
                  : AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              hasEndDayReview
                  ? Icons.check_circle_outline
                  : Icons.nightlight_round,
              color: hasEndDayReview ? Colors.green : AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasEndDayReview
                      ? "Bugünkü Değerlendirme Tamamlandı"
                      : "Gün Sonu Değerlendirmesi",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasEndDayReview
                      ? "Bugünkü ruh halin kaydedildi."
                      : "Bugünün nasıl geçtiğini kaydet.",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              hasEndDayReview ? Icons.done_rounded : Icons.chevron_right,
              color: hasEndDayReview ? Colors.green : AppColors.primary,
            ),
            onPressed: hasEndDayReview
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EndDayReviewScreen(),
                      ),
                    );

                    await loadEndDayReviewStatus();
                  },
          ),
        ],
      ),
    );
  }

  Widget _moodButton() {
    return SizedBox(
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
          shadowColor: AppColors.primary.withOpacity(0.25),
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
    );
  }
}