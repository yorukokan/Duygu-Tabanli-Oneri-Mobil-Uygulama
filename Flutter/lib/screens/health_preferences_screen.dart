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

  final List<String> allergies = [
    "Laktoz",
    "Gluten",
    "Fıstık",
    "Yumurta",
    "Deniz Ürünleri",
  ];

  final List<String> sensitivities = [
    "Polen",
    "Toz",
    "Kafein",
    "Şeker",
    "Baharat",
  ];

  final List<String> diseases = [
    "Astım",
    "Diyabet",
    "Hipertansiyon",
    "Kalp Rahatsızlığı",
    "Reflü",
  ];

  final List<String> specialConditions = [
    "Hamilelik",
    "Düzenli İlaç",
    "Sporcu",
    "Uyku Problemi",
  ];

  final List<String> favoriteActivities = [
    "Yoga",
    "Yüzme",
    "Koşu",
    "Yürüyüş",
    "Meditasyon",
    "Bisiklet",
  ];

  Set<String> selectedAllergies = {};
  Set<String> selectedSensitivities = {};
  Set<String> selectedDiseases = {};
  Set<String> selectedSpecialConditions = {};
  Set<String> selectedFavoriteActivities = {};

  List<String> customAllergies = [];
  List<String> customSensitivities = [];
  List<String> customDiseases = [];
  List<String> customSpecialConditions = [];
  List<String> customFavoriteActivities = [];

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
      final custom =
          data["customHealthOptions"] as Map<String, dynamic>?;

      if (health != null) {
        selectedAllergies = Set<String>.from(health["allergies"] ?? []);
        selectedSensitivities =
            Set<String>.from(health["sensitivities"] ?? []);
        selectedDiseases = Set<String>.from(health["diseases"] ?? []);
        selectedSpecialConditions =
            Set<String>.from(health["specialConditions"] ?? []);
        selectedFavoriteActivities =
            Set<String>.from(health["favoriteActivities"] ?? []);
      }

      if (custom != null) {
        customAllergies = List<String>.from(custom["allergies"] ?? []);
        customSensitivities =
            List<String>.from(custom["sensitivities"] ?? []);
        customDiseases = List<String>.from(custom["diseases"] ?? []);
        customSpecialConditions =
            List<String>.from(custom["specialConditions"] ?? []);
        customFavoriteActivities =
            List<String>.from(custom["favoriteActivities"] ?? []);
      }
    }

    if (!mounted) return;

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
      },
      "customHealthOptions": {
        "allergies": customAllergies,
        "sensitivities": customSensitivities,
        "diseases": customDiseases,
        "specialConditions": customSpecialConditions,
        "favoriteActivities": customFavoriteActivities,
      },
    }, SetOptions(merge: true));

    if (!mounted) return;

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sağlık tercihleri güncellendi")),
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

  void removeCustomItem({
    required String item,
    required List<String> customItems,
    required Set<String> selectedItems,
  }) {
    setState(() {
      customItems.remove(item);
      selectedItems.remove(item);
    });
  }

  void addCustomItem({
    required String title,
    required Set<String> selectedSet,
    required List<String> customItems,
    required List<String> defaultItems,
  }) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 22,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                "$title Ekle",
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Listede olmayan bir değeri manuel olarak ekleyebilirsin.",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.card,
                  hintText: "Yeni değer gir",
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final value = controller.text.trim();

                    if (value.isEmpty) return;

                    final existsInDefault = defaultItems
                        .map((e) => e.toLowerCase())
                        .contains(value.toLowerCase());

                    final existsInCustom = customItems
                        .map((e) => e.toLowerCase())
                        .contains(value.toLowerCase());

                    setState(() {
                      if (!existsInDefault && !existsInCustom) {
                        customItems.add(value);
                      }

                      selectedSet.add(value);
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 8,
                    shadowColor: AppColors.primary.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Ekle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "İptal",
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _topBar(context),
                        const SizedBox(height: 28),
                        _section(
                          title: "Alerjiler",
                          items: allergies,
                          customItems: customAllergies,
                          selectedItems: selectedAllergies,
                        ),
                        _section(
                          title: "Hassasiyetler",
                          items: sensitivities,
                          customItems: customSensitivities,
                          selectedItems: selectedSensitivities,
                        ),
                        _section(
                          title: "Hastalıklar",
                          items: diseases,
                          customItems: customDiseases,
                          selectedItems: selectedDiseases,
                        ),
                        _section(
                          title: "Özel Durumlar",
                          items: specialConditions,
                          customItems: customSpecialConditions,
                          selectedItems: selectedSpecialConditions,
                        ),
                        _section(
                          title: "Favori Aktiviteler",
                          items: favoriteActivities,
                          customItems: customFavoriteActivities,
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
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: AppShadows.soft,
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
    required List<String> customItems,
    required Set<String> selectedItems,
  }) {
    final allItems = {
      ...items,
      ...customItems,
    }.toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.creamCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.softBorder),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    addCustomItem(
                      title: title,
                      selectedSet: selectedItems,
                      customItems: customItems,
                      defaultItems: items,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Ekle",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: allItems.map((item) {
                final selected = selectedItems.contains(item);
                final isCustom = customItems.contains(item);

                return GestureDetector(
                  onTap: () => toggleItem(selectedItems, item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: selected ? AppShadows.soft : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: TextStyle(
                            color:
                                selected ? Colors.white : AppColors.textMain,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                        if (isCustom) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              removeCustomItem(
                                item: item,
                                customItems: customItems,
                                selectedItems: selectedItems,
                              );
                            },
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}