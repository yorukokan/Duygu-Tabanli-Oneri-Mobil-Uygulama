import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'result_screen.dart';
import '../theme/app_theme.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  int selectedMoodIndex = 0;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  final String baseUrl = "http://127.0.0.1:8000";

  final List<Map<String, String>> moods = [
    {"title": "Nötr", "emoji": "🙂", "emotion": "Nötr / Genel Denge"},
    {"title": "Heyecanlı", "emoji": "😃", "emotion": "Heyecan / Yüksek Enerji"},
    {"title": "Kaygılı", "emoji": "😕", "emotion": "Kaygı / Anksiyete"},
    {"title": "Kaygılı", "emoji": "🥺", "emotion": "Kaygı / Anksiyete"},
    {"title": "Üzgün", "emoji": "😞", "emotion": "Depresif / Hüzünlü"},
    {"title": "Kızgın", "emoji": "😠", "emotion": "Öfke / Gerginlik"},
    {"title": "Odaksız", "emoji": "🤯", "emotion": "Odak Eksikliği"},
    {"title": "Stresli", "emoji": "😬", "emotion": "Yüksek Stres"},
    {"title": "Yorgun", "emoji": "🫩", "emotion": "Düşük Enerji / Yorgunluk"},
    {"title": "Uykulu", "emoji": "🥱", "emotion": "Uyku / Huzursuzluk"},
    {"title": "Mutlu", "emoji": "☺️", "emotion": "Mutluluk"},
    {
      "title": "Motivasyonsuz",
      "emoji": "🫠",
      "emotion": "Motivasyon Eksikliği",
    },
  ];

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fotoğraf çekilmedi.")),
        );
        return;
      }

      setState(() {
        selectedImage = File(pickedFile.path);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fotoğraf başarıyla alındı.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kamera açılamadı: $e")),
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Galeriden görsel seçilmedi.")),
        );
        return;
      }

      setState(() {
        selectedImage = File(pickedFile.path);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Görsel seçildi.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Galeri açılamadı: $e")),
      );
    }
  }

  Future<void> analyzeEmotion() async {
    final selectedMood = moods[selectedMoodIndex];
    final selectedEmoji = selectedMood["emoji"] ?? "";
    final selectedEmotion = selectedMood["emotion"] ?? "Bilinmiyor";

    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse("$baseUrl/analyze-emotion");
      final request = http.MultipartRequest("POST", uri);

      request.fields["emoji"] = selectedEmoji;

      Map<String, dynamic> healthData = {};

final user = FirebaseAuth.instance.currentUser;

if (user != null) {
  final userDoc = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .get();

  healthData = userDoc.data()?["healthPreferences"] ?? {};
}

request.fields["health_data"] = jsonEncode(healthData);

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("file", selectedImage!.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Sunucu hatası: ${response.statusCode} - ${response.body}",
        );
      }

      final data = jsonDecode(response.body);

      if (data["success"] != true) {
        throw Exception(data["error"] ?? "Bilinmeyen bir hata oluştu.");
      }

      final modelResult = data["model_result"] ?? {};
      final String aiEmotion =
          modelResult["emotion"]?.toString() ?? "Bilinmiyor";
      final String finalEmotion =
          data["final_emotion"]?.toString() ?? "Bilinmiyor";

      final List<dynamic> foods = data["food_recommendations"] ?? [];
      final List<dynamic> activities = data["activity_recommendations"] ?? [];

      if (user != null) {
        await FirebaseFirestore.instance.collection("moodHistory").add({
          "uid": user.uid,
          "date": FieldValue.serverTimestamp(),
          "selectedEmoji": selectedEmoji,
          "selectedEmotion": selectedEmotion,
          "aiEmotion": selectedImage != null ? aiEmotion : "AI Analizi Yok",
          "finalEmotion": finalEmotion,
          "foodIds": foods.map((e) => e["id"]).toList(),
          "activityIds": activities.map((e) => e["id"]).toList(),
        });
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            aiEmotion: selectedImage != null ? aiEmotion : "AI Analizi Yok",
            selectedEmotion: selectedEmotion,
            selectedEmoji: selectedEmoji,
            finalEmotion: finalEmotion,
            foodRecommendations: foods,
            activityRecommendations: activities,
          ),
        ),
      );
    } catch (e) {
      print("ANALYZE ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Analiz hatası: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP BAR
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new),
                          color: AppColors.textDark,
                          iconSize: 20,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Nasıl Hissediyorsun?",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// MOOD LIST
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: moods.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 18),
                      itemBuilder: (context, index) {
                        final mood = moods[index];
                        final isSelected = selectedMoodIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMoodIndex = index;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 86,
                                height: 86,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.10)
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.20)
                                        : AppColors.divider,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    mood["emoji"]!,
                                    style: const TextStyle(fontSize: 38),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                mood["title"]!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  const SizedBox(height: 34),

                  /// CAMERA CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        selectedImage == null
                            ? Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  shape: BoxShape.circle,
                                  boxShadow: AppShadows.medium,
                                ),
                                child: const Icon(
                                  Icons.photo_camera_front,
                                  color: AppColors.primary,
                                  size: 38,
                                ),
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: FileImage(selectedImage!),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: AppShadows.medium,
                                ),
                              ),

                        const SizedBox(height: 22),

                        const Text(
                          "Yüzünü Tara",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "İstersen kamerayla duygu analizi yap, istemezsen sadece emoji ile devam et.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textMuted,
                          ),
                        ),

                        const SizedBox(height: 24),

                        OutlinedButton.icon(
                          onPressed: pickImageFromCamera,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.card,
                            foregroundColor: AppColors.textDark,
                            side: const BorderSide(color: AppColors.divider),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text(
                            "Kamerayı Aç",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextButton.icon(
                          onPressed: pickImageFromGallery,
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            "Galeriden Seç",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (selectedImage != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedImage = null;
                              });
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.textMuted,
                            ),
                            label: const Text(
                              "Fotoğrafı Kaldır",
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// INFO CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: AppColors.primary,
                          size: 26,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Duygularını takip etmek, stres seviyeni azaltmana yardımcı olabilir.",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// BOTTOM BUTTON
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : analyzeEmotion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shadowColor: AppColors.primary.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 10,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Kaydet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
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
}