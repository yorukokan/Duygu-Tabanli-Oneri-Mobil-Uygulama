import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class HealthPreferencesScreen extends StatefulWidget {
  const HealthPreferencesScreen({super.key});

  @override
  State<HealthPreferencesScreen> createState() =>
      _HealthPreferencesScreenState();
}

class _HealthPreferencesScreenState extends State<HealthPreferencesScreen> {
  bool isLoading = true;
  bool isSaving = false;

  final List<String> allergies = ["Laktoz", "Gluten", "Fıstık", "Yumurta", "Deniz Ürünleri"];
  final List<String> sensitivities = ["Polen", "Toz", "Kafein", "Şeker", "Baharat"];
  final List<String> diseases = ["Astım", "Diyabet", "Hipertansiyon", "Kalp Rahatsızlığı", "Reflü"];
  final List<String> specialConditions = ["Hamilelik", "Düzenli İlaç", "Sporcu", "Uyku Problemi"];
  final List<String> favoriteActivities = ["Yoga", "Yüzme", "Koşu", "Yürüyüş", "Meditasyon", "Bisiklet"];

  Set<String> selectedAllergies = {};
  Set<String> selectedSensitivities = {};
  Set<String> selectedDiseases = {};
  Set<String> selectedSpecialConditions = {};
  Set<String> selectedFavoriteActivities = {};

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (data != null) {
      final health = data["healthPreferences"] as Map<String, dynamic>?;

      if (health != null) {
        selectedAllergies = Set<String>.from(health["allergies"] ?? []);
        selectedSensitivities = Set<String>.from(health["sensitivities"] ?? []);
        selectedDiseases = Set<String>.from(health["diseases"] ?? []);
        selectedSpecialConditions =
            Set<String>.from(health["specialConditions"] ?? []);
        selectedFavoriteActivities =
            Set<String>.from(health["favoriteActivities"] ?? []);
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "healthPreferences": {
        "allergies": selectedAllergies.toList(),
        "sensitivities": selectedSensitivities.toList(),
        "diseases": selectedDiseases.toList(),
        "specialConditions": selectedSpecialConditions.toList(),
        "favoriteActivities": selectedFavoriteActivities.toList(),
      }
    }, SetOptions(merge: true));

    if (!mounted) return;

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sağlık tercihleri kaydedildi")),
    );
  }

  void toggleItem(Set<String> selectedSet, String item) {
    setState(() {
      if (selectedSet.contains(item)) {
        selectedSet.remove(item);
      } else {
        selectedSet.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _topBar(context),
                        const SizedBox(height: 24),
                        _section(
                          title: "Alerjiler",
                          items: allergies,
                          selectedItems: selectedAllergies,
                        ),
                        _section(
                          title: "Hassasiyetler",
                          items: sensitivities,
                          selectedItems: selectedSensitivities,
                        ),
                        _section(
                          title: "Hastalıklar",
                          items: diseases,
                          selectedItems: selectedDiseases,
                        ),
                        _section(
                          title: "Özel Durumlar",
                          items: specialConditions,
                          selectedItems: selectedSpecialConditions,
                        ),
                        _section(
                          title: "Favori Aktiviteler",
                          items: favoriteActivities,
                          selectedItems: selectedFavoriteActivities,
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : savePreferences,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 10,
                          shadowColor: AppColors.primary.withOpacity(0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Bilgileri Kaydet",
                                style: TextStyle(
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

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textDark,
              size: 20,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            "Sağlık ve Tercihler",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }

  Widget _section({
    required String title,
    required List<String> items,
    required Set<String> selectedItems,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.10),
              ),
            ),
            child: Wrap(
              spacing: 9,
              runSpacing: 10,
              children: items.map((item) {
                final selected = selectedItems.contains(item);

                return GestureDetector(
                  onTap: () => toggleItem(selectedItems, item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: selected ? AppShadows.soft : [],
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}