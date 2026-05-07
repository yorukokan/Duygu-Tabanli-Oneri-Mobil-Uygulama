import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../theme/app_theme.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  List<dynamic> items = [];
  bool isLoading = true;
  late String todayKey;

  @override
  void initState() {
    super.initState();
    todayKey = DateTime.now().toIso8601String().split("T")[0];
    loadPlan();
  }

  Future<void> loadPlan() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("dailyPlans")
        .doc("${user.uid}_$todayKey")
        .get();

    setState(() {
      items = doc.data()?["items"] ?? [];
      isLoading = false;
    });
  }

  Future<void> updateItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("dailyPlans")
        .doc("${user.uid}_$todayKey")
        .set({
      "uid": user.uid,
      "date": todayKey,
      "items": items,
    }, SetOptions(merge: true));
  }

  Future<void> toggleComplete(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final item = items[index];
    final newValue = !(item["completed"] ?? false);

    setState(() {
      items[index]["completed"] = newValue;
    });

    await FirebaseFirestore.instance
        .collection("dailyPlans")
        .doc("${user.uid}_$todayKey")
        .update({"items": items});

    if (newValue == true) {
      await FirebaseFirestore.instance
          .collection("completedRecommendations")
          .add({
        "uid": user.uid,
        "itemId": item["id"],
        "type": item["type"],
        "title": item["title"],
        "date": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteItem(int index) async {
    setState(() {
      items.removeAt(index);
    });
    await updateItems();
  }

  double get progress {
    if (items.isEmpty) return 0;
    final completed = items.where((e) => e["completed"] == true).length;
    return completed / items.length;
  }

  String get formattedDate {
    const months = [
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık",
    ];

    const days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar",
    ];

    final now = DateTime.now();
    return "${now.day} ${months[now.month - 1]}, ${days[now.weekday - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 150),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BUGÜN",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (items.isEmpty)
                            _emptyCard()
                          else
                            ...List.generate(
                              items.length,
                              (index) => _planItem(index),
                            ),
                          const SizedBox(height: 20),
                          _progressCard(percent),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 1,
        showSuggestionButton: true,
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textMain,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              "Günlük Planım",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _planItem(int index) {
    final item = items[index];
    final completed = item["completed"] == true;
    final title = item["title"]?.toString() ?? "Plan öğesi";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => toggleComplete(index),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: completed ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.35),
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: completed
                    ? AppColors.textLight
                    : AppColors.textMain,
                decoration: completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => deleteItem(index),
            icon: const Icon(Icons.delete_outline,
                color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: const Text(
        "Bugün için planına eklenmiş öneri yok.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 15,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _progressCard(int percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Günlük İlerleme",
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "$percent%",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              color: AppColors.primary,
              backgroundColor: AppColors.divider,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            percent == 100
                ? "Bugünkü planını tamamladın!"
                : "Bugün yapacak daha çok şeyin var!",
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}