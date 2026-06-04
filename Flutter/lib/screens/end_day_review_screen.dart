import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class EndDayReviewScreen extends StatefulWidget {
  const EndDayReviewScreen({super.key});

  @override
  State<EndDayReviewScreen> createState() => _EndDayReviewScreenState();
}

class _EndDayReviewScreenState extends State<EndDayReviewScreen> {
  int selectedIndex = 1;
  bool isSaving = false;
  bool alreadyReviewed = false;

  int completedCount = 0;
  int totalCount = 0;

  late String todayKey;

  final List<Map<String, String>> moods = [
    {"label": "Harika", "emoji": "🤩", "emotion": "harika"},
    {"label": "Mutlu", "emoji": "😊", "emotion": "mutlu"},
    {"label": "Normal", "emoji": "🙂", "emotion": "normal"},
    {"label": "Üzgün", "emoji": "😞", "emotion": "uzgun"},
    {"label": "Kızgın", "emoji": "😠", "emotion": "kizgin"},
    {"label": "Yorgun", "emoji": "🥱", "emotion": "yorgun"},
    {"label": "Heyecanlı", "emoji": "😃", "emotion": "heyecanli"},
    {"label": "Sakin", "emoji": "😌", "emotion": "sakin"},
    {"label": "Kaygılı", "emoji": "😟", "emotion": "kaygili"},
  ];

  @override
  void initState() {
    super.initState();
    todayKey = DateTime.now().toIso8601String().split("T")[0];
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await loadTodayPlanSummary();
    await checkAlreadyReviewed();
  }

  Future<void> loadTodayPlanSummary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("dailyPlans")
        .doc("${user.uid}_$todayKey")
        .get();

    final items = doc.data()?["items"] ?? [];

    if (!mounted) return;

    setState(() {
      totalCount = items.length;
      completedCount = items.where((e) => e["completed"] == true).length;
    });
  }

  Future<void> checkAlreadyReviewed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("dailyEvaluations")
        .doc("${user.uid}_$todayKey")
        .get();

    if (!mounted) return;

    if (doc.exists) {
      final data = doc.data();
      final savedEmotion = data?["endDayEmotion"]?.toString();

      final foundIndex = moods.indexWhere(
        (mood) => mood["emotion"] == savedEmotion,
      );

      setState(() {
        alreadyReviewed = true;
        if (foundIndex != -1) {
          selectedIndex = foundIndex;
        }
      });
    }
  }

  String getYesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.toIso8601String().split("T")[0];
  }

  int calculateNewStreak({
    required int currentStreak,
    required String lastReviewDate,
  }) {
    final yesterdayKey = getYesterdayKey();

    if (lastReviewDate == todayKey) {
      return currentStreak;
    }

    if (lastReviewDate == yesterdayKey) {
      return currentStreak + 1;
    }

    return 1;
  }

  Future<void> saveReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (alreadyReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bugünkü değerlendirmeyi zaten tamamladın."),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final selectedMood = moods[selectedIndex];

    final evaluationRef = FirebaseFirestore.instance
        .collection("dailyEvaluations")
        .doc("${user.uid}_$todayKey");

    final userRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final evaluationSnapshot = await transaction.get(evaluationRef);
        final userSnapshot = await transaction.get(userRef);

        if (evaluationSnapshot.exists) {
          return;
        }

        final userData = userSnapshot.data() ?? {};

        final currentStreak = (userData["streakCount"] ?? 0) as int;
        final lastReviewDate =
            userData["lastEndDayReviewDate"]?.toString() ?? "";

        final newStreak = calculateNewStreak(
          currentStreak: currentStreak,
          lastReviewDate: lastReviewDate,
        );

        transaction.set(evaluationRef, {
          "uid": user.uid,
          "dateKey": todayKey,
          "endDayMoodLabel": selectedMood["label"],
          "endDayEmotion": selectedMood["emotion"],
          "endDayEmoji": selectedMood["emoji"],
          "completedCount": completedCount,
          "totalCount": totalCount,
          "completedRate": totalCount == 0 ? 0 : completedCount / totalCount,
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        });

        transaction.set(
          userRef,
          {
            "streakCount": newStreak,
            "lastEndDayReviewDate": todayKey,
          },
          SetOptions(merge: true),
        );
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
        alreadyReviewed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gün sonu değerlendirmesi kaydedildi"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kayıt hatası: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMood = moods[selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              child: Column(
                children: [
                  _topBar(),
                  const SizedBox(height: 30),
                  const Text(
                    "Bugün nasıl hissediyorsun?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Günün sonunda ruh halini en iyi yansıtan emojiyi seç.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _summaryCard(),
                  if (alreadyReviewed) ...[
                    const SizedBox(height: 16),
                    _alreadyReviewedCard(),
                  ],
                  const SizedBox(height: 26),
                  _emojiGrid(),
                  const SizedBox(height: 18),
                  Text(
                    "Seçilen: ${selectedMood["label"]}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: isSaving || alreadyReviewed ? null : saveReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alreadyReviewed
                        ? AppColors.textLight
                        : AppColors.primary,
                    elevation: alreadyReviewed ? 0 : 10,
                    shadowColor: AppColors.primary.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          alreadyReviewed
                              ? "Bugün Tamamlandı"
                              : "Değerlendirmeyi Tamamla",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textDark,
              size: 22,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            "Gün Sonu Değerlendirmesi",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }

  Widget _summaryCard() {
    final rate =
        totalCount == 0 ? 0 : ((completedCount / totalCount) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softBorder),
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
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              totalCount == 0
                  ? "Bugün planına eklenmiş öneri yok."
                  : "Bugün $totalCount öneriden $completedCount tanesini tamamladın. Günlük ilerleme: %$rate",
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alreadyReviewedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_rounded,
            color: Colors.green,
            size: 26,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Bugünkü değerlendirme kaydedilmiş. Ana sayfada tamamlandı olarak görünecek.",
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emojiGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: moods.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 18,
        mainAxisSpacing: 22,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final mood = moods[index];
        final selected = selectedIndex == index;

        return GestureDetector(
          onTap: alreadyReviewed
              ? null
              : () {
                  setState(() => selectedIndex = index);
                },
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 3 : 1,
                  ),
                  boxShadow: selected ? AppShadows.medium : AppShadows.soft,
                ),
                child: Center(
                  child: Text(
                    mood["emoji"]!,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                mood["label"]!.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}