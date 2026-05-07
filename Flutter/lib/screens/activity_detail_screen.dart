import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class ActivityDetailScreen extends StatelessWidget {
  final int id;
  final String type;
  final String title;
  final String scientificBenefit;
  final String howToApply;
  final String imageUrl;

  const ActivityDetailScreen({
    super.key,
    required this.id,
    this.type = "activity",
    required this.title,
    required this.scientificBenefit,
    required this.howToApply,
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
        {
          "id": id,
          "type": type,
          "title": title,
          "completed": false,
        }
      ]),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Planıma eklendi")),
    );
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
                height: 320,
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
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.softBorder),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.favorite,
                              title: "Bilimsel Faydası",
                              text: scientificBenefit,
                            ),
                            const SizedBox(height: 22),
                            Container(
                              height: 1,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              color: AppColors.divider,
                            ),
                            const SizedBox(height: 22),
                            _InfoRow(
                              icon: Icons.directions_walk_rounded,
                              title: "Uygulama Önerisi",
                              text: howToApply,
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
                    color: AppColors.card.withOpacity(0.90),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.soft,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textDark,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bg.withOpacity(0.0),
                    AppColors.bg.withOpacity(0.92),
                    AppColors.bg,
                  ],
                ),
              ),
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
                      borderRadius: BorderRadius.circular(999),
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

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 26,
          ),
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
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textMain,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}