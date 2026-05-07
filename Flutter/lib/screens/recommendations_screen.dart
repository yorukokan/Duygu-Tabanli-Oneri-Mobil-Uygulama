import 'package:flutter/material.dart';
import 'food_suggestion_screen.dart';
import 'activity_suggestion_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../theme/app_theme.dart';

class RecommendationsScreen extends StatelessWidget {
  final String finalEmotion;
  final List<dynamic> foodRecommendations;
  final List<dynamic> activityRecommendations;

  const RecommendationsScreen({
    super.key,
    required this.finalEmotion,
    required this.foodRecommendations,
    required this.activityRecommendations,
  });

  String _formatEmotionText(String text) {
    if (text.trim().isEmpty) return "Bilinmiyor";

    return text
        .replaceAll("_", " ")
        .replaceAll("nötr", "Nötr")
        .replaceAll("notr", "Nötr")
        .replaceAll("genel denge", "Genel Denge")
        .replaceAll("heyecan yüksek enerji", "Heyecan / Yüksek Enerji")
        .replaceAll("kaygı anksiyete", "Kaygı / Anksiyete")
        .replaceAll("kaygi anksiyete", "Kaygı / Anksiyete")
        .replaceAll("depresif hüzünlü", "Depresif / Hüzünlü")
        .replaceAll("depresif huzunlu", "Depresif / Hüzünlü")
        .replaceAll("öfke gerginlik", "Öfke / Gerginlik")
        .replaceAll("ofke gerginlik", "Öfke / Gerginlik")
        .replaceAll("odak eksikliği", "Odak Eksikliği")
        .replaceAll("yüksek stres", "Yüksek Stres")
        .replaceAll("dusuk enerji yorgunluk", "Düşük Enerji / Yorgunluk")
        .replaceAll("düşük enerji yorgunluk", "Düşük Enerji / Yorgunluk")
        .replaceAll("uyku huzursuzluk", "Uyku / Huzursuzluk")
        .replaceAll("motivasyon eksikliği", "Motivasyon Eksikliği")
        .replaceAll("mutluluk", "Mutluluk");
  }

  String _headerText(String emotion) {
    final e = _formatEmotionText(emotion);
    return "Bugün $e görünüyorsun, senin için seçtiklerimiz";
  }

  String _safeText(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  String _getFoodShortText(Map item) {
    return _safeText(
      item["kart_kisa_aciklama"],
      "Bu besin önerisi mevcut duygu durumuna destek olması için seçildi.",
    );
  }

  String _getActivityShortText(Map item) {
    return _safeText(
      item["kart_kisa_aciklama"],
      "Bu aktivite mevcut duygu durumuna destek olması için seçildi.",
    );
  }

  String _getTitle(Map item, String fallback) {
    return _safeText(item["isim"], fallback);
  }

  String _getImageUrl(Map item) {
    return _safeText(item["gorsel_url"], "");
  }

  @override
  Widget build(BuildContext context) {
    final String formattedEmotion = _formatEmotionText(finalEmotion);

    final Map<String, dynamic>? firstFood =
        foodRecommendations.isNotEmpty ? foodRecommendations.first : null;

    final Map<String, dynamic>? firstActivity =
        activityRecommendations.isNotEmpty ? activityRecommendations.first : null;

    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              decoration: BoxDecoration(
                color: AppColors.textDark,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(34),
                ),
                boxShadow: AppShadows.medium,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.divider,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _headerText(formattedEmotion),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodSuggestionScreen(
                              foodRecommendations: foodRecommendations,
                              finalEmotion: finalEmotion,
                            ),
                          ),
                        );
                      },
                      child: _buildFoodCard(
                        title: firstFood != null
                            ? _getTitle(firstFood, "Beslenme Önerisi")
                            : "Beslenme Önerisi",
                        shortText: firstFood != null
                            ? _getFoodShortText(firstFood)
                            : "Bu duygu durumu için şu an beslenme önerisi bulunamadı.",
                        imageUrl: firstFood != null ? _getImageUrl(firstFood) : "",
                        isEmpty: firstFood == null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivitySuggestionScreen(
                              activityRecommendations: activityRecommendations,
                              finalEmotion: finalEmotion,
                            ),
                          ),
                        );
                      },
                      child: _buildActivityCard(
                        title: firstActivity != null
                            ? _getTitle(firstActivity, "Aktivite Önerisi")
                            : "Aktivite Önerisi",
                        shortText: firstActivity != null
                            ? _getActivityShortText(firstActivity)
                            : "Bu duygu durumu için şu an aktivite önerisi bulunamadı.",
                        imageUrl:
                            firstActivity != null ? _getImageUrl(firstActivity) : "",
                        isEmpty: firstActivity == null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildFoodCard({
    required String title,
    required String shortText,
    required String imageUrl,
    required bool isEmpty,
  }) {
    return _RecommendationCard(
      tag: "BESLENME",
      heading: "BESLENME ÖNERİSİ",
      shortText: shortText,
      imageUrl: imageUrl,
      isEmpty: isEmpty,
      prefix: "Kısa Bilimsel Açıklama: ",
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String shortText,
    required String imageUrl,
    required bool isEmpty,
  }) {
    return _RecommendationCard(
      tag: "AKTİVİTE",
      heading: "AKTİVİTE ÖNERİSİ",
      shortText: shortText,
      imageUrl: imageUrl,
      isEmpty: isEmpty,
      prefix: "",
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String tag;
  final String heading;
  final String shortText;
  final String imageUrl;
  final bool isEmpty;
  final String prefix;

  const _RecommendationCard({
    required this.tag,
    required this.heading,
    required this.shortText,
    required this.imageUrl,
    required this.isEmpty,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppShadows.soft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: AppColors.textMuted,
                    ),
                    children: [
                      TextSpan(
                        text: isEmpty ? "" : prefix,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(text: shortText),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Text(
                      "Detayları Gör",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}