import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class FoodDetailScreen extends StatelessWidget {
  final int id;
  final String type;
  final String title;
  final String scientificBenefit;
  final String consumptionAdvice;
  final String imageUrl;

  const FoodDetailScreen({
    super.key,
    required this.id,
    this.type = "food",
    required this.title,
    required this.scientificBenefit,
    required this.consumptionAdvice,
    required this.imageUrl,
  });

  Future<void> _addToDailyPlan(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plan eklemek için giriş yapmalısın.")),
      );
      return;
    }

    final today = DateTime.now().toIso8601String().split("T")[0];

    final docRef = FirebaseFirestore.instance
        .collection("dailyPlans")
        .doc("${user.uid}_$today");

    await docRef.set({
      "uid": user.uid,
      "date": today,
      "items": FieldValue.arrayUnion([
        {"id": id, "type": type, "title": title, "completed": false},
      ]),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Planıma eklendi")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.40,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                  color: AppColors.divider,
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.creamCard,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.softBorder),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.science_outlined,
                              title: "Bilimsel Faydası",
                              text: scientificBenefit,
                            ),
                            const SizedBox(height: 28),
                            _InfoRow(
                              icon: Icons.restaurant_menu_rounded,
                              title: "Tüketim Önerisi",
                              text: consumptionAdvice,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => _addToDailyPlan(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 10,
                  shadowColor: AppColors.primary.withOpacity(0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                icon: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "Planıma Ekle",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoRow({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textLight,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textMain,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
