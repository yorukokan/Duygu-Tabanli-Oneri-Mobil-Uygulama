import 'package:flutter/material.dart';
import 'recommendations_screen.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final String aiEmotion;
  final String selectedEmotion;
  final String selectedEmoji;
  final String finalEmotion;
  final List<dynamic> foodRecommendations;
  final List<dynamic> activityRecommendations;

  const ResultScreen({
    super.key,
    required this.aiEmotion,
    required this.selectedEmotion,
    required this.selectedEmoji,
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
        .replaceAll("düşük enerji yorgunluk", "Düşük Enerji / Yorgunluk")
        .replaceAll("uyku huzursuzluk", "Uyku / Huzursuzluk")
        .replaceAll("motivasyon eksikliği", "Motivasyon Eksikliği")
        .replaceAll("mutluluk", "Mutluluk");
  }

  IconData _iconForEmotion(String emotion) {
    final e = emotion.toLowerCase();

    if (e.contains("mutluluk")) return Icons.sentiment_very_satisfied_rounded;
    if (e.contains("heyecan")) return Icons.local_fire_department_rounded;
    if (e.contains("kaygı") || e.contains("anksiyete")) {
      return Icons.psychology_alt_rounded;
    }
    if (e.contains("depresif") || e.contains("hüzünlü")) {
      return Icons.cloud_rounded;
    }
    if (e.contains("öfke") || e.contains("gerginlik")) {
      return Icons.whatshot_rounded;
    }
    if (e.contains("odak")) return Icons.center_focus_strong_rounded;
    if (e.contains("yüksek stres")) return Icons.bolt_rounded;
    if (e.contains("yorgunluk")) return Icons.bedtime_rounded;
    if (e.contains("uyku")) return Icons.nightlight_round_rounded;
    if (e.contains("motivasyon")) return Icons.trending_down_rounded;
    if (e.contains("nötr")) return Icons.self_improvement_rounded;

    return Icons.self_improvement_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedAiEmotion =
        aiEmotion == "AI Analizi Yok" ? "AI Analizi Yok" : _formatEmotionText(aiEmotion);

    final String formattedSelectedEmotion = _formatEmotionText(selectedEmotion);
    final String formattedFinalEmotion = _formatEmotionText(finalEmotion);
    final IconData finalIcon = _iconForEmotion(formattedFinalEmotion);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.75),
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
                    child: Center(
                      child: Text(
                        "Duygu Doğrulama",
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildEmotionCard(
                            title: "AI Analizi",
                            emotion: formattedAiEmotion,
                            icon: aiEmotion == "AI Analizi Yok"
                                ? Icons.image_not_supported_outlined
                                : _iconForEmotion(formattedAiEmotion),
                            iconBg: AppColors.primary.withOpacity(0.10),
                            iconColor: AppColors.primary,
                            borderColor: AppColors.primary.withOpacity(0.25),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildEmotionCard(
                            title: "Seçilen",
                            emotion: formattedSelectedEmotion,
                            icon: _iconForEmotion(formattedSelectedEmotion),
                            iconBg: const Color(0xFFFFF7E8),
                            iconColor: const Color(0xFFF59E0B),
                            borderColor: const Color(0xFFFFE6B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Column(
                      children: [
                        Container(
                          width: 1.5,
                          height: 32,
                          color: AppColors.primary.withOpacity(0.35),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Veri Birleşimi Sonucu",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.textDark),
                        children: [
                          const TextSpan(
                            text: "Kesinleşen Durum:\n",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                          ),
                          TextSpan(
                            text: formattedFinalEmotion,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Icon(
                      finalIcon,
                      size: 92,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Verileriniz analiz edildi ve durumunuz \"$formattedFinalEmotion\" olarak doğrulandı.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecommendationsScreen(
                                finalEmotion: formattedFinalEmotion,
                                foodRecommendations: foodRecommendations,
                                activityRecommendations: activityRecommendations,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Önerileri Getir",
                          style: TextStyle(
                            fontSize: 18,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionCard({
    required String title,
    required String emotion,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color borderColor,
  }) {
    return Container(
      height: 290,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Text(
                emotion,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}