import 'package:flutter/material.dart';
import 'food_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class FoodSuggestionScreen extends StatefulWidget {
  final List<dynamic> foodRecommendations;
  final String finalEmotion;

  const FoodSuggestionScreen({
    super.key,
    required this.foodRecommendations,
    required this.finalEmotion,
  });

  @override
  State<FoodSuggestionScreen> createState() => _FoodSuggestionScreenState();
}

class _FoodSuggestionScreenState extends State<FoodSuggestionScreen> {
  int currentIndex = 0;

  String _safeText(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  String _imageFromFood(dynamic item) {
    return _safeText(item["gorsel_url"], "");
  }

  String _foodBadgeText(dynamic item) {
    final dynamic warnings = item["ozel_durum_uyarisi"];
    final dynamic tags = item["icerik_etiketleri"];
    final dynamic risks = item["riskli_hastaliklar"];

    if (warnings is List && warnings.isNotEmpty) return warnings.first.toString();

    if (tags is List && tags.isNotEmpty) {
      final lowered = tags.map((e) => e.toString().toLowerCase()).toList();

      if (lowered.any((e) => e.contains("alerjen içermez") || e.contains("alerjen icermez"))) return "Alerjen İçermez";
      if (lowered.any((e) => e.contains("glutensiz"))) return "Glutensiz";
      if (lowered.any((e) => e.contains("şekersiz") || e.contains("sekersiz"))) return "Şekersiz";
      if (lowered.any((e) => e.contains("vegan"))) return "Vegan";
      if (lowered.any((e) => e.contains("yüksek protein") || e.contains("yuksek protein"))) return "Yüksek Protein";

      return tags.first.toString();
    }

    if (risks is List && risks.isNotEmpty) return "Dikkatli Tüket";

    return "Senin İçin Uygun";
  }

  Color _foodBadgeColor(String text) {
    final t = text.toLowerCase();

    if (t.contains("dikkat") || t.contains("uyarı") || t.contains("uyari")) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }

  IconData _foodBadgeIcon(String text) {
    final t = text.toLowerCase();

    if (t.contains("dikkat") || t.contains("uyarı") || t.contains("uyari")) {
      return Icons.warning_amber_rounded;
    }
    return Icons.verified_rounded;
  }

  void _goNext() {
    if (widget.foodRecommendations.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex + 1) % widget.foodRecommendations.length;
    });
  }

  Future<void> _completeCurrentFood() async {
    if (widget.foodRecommendations.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final item = widget.foodRecommendations[currentIndex];

    await FirebaseFirestore.instance.collection("completedRecommendations").add({
      "uid": user.uid,
      "itemId": item["id"],
      "type": "food",
      "title": item["isim"],
      "emotion": widget.finalEmotion,
      "date": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Besin önerisi tamamlandı")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = widget.foodRecommendations.isNotEmpty;
    final dynamic item = hasData ? widget.foodRecommendations[currentIndex] : null;

    final String title = hasData
        ? _safeText(item["isim"], "Beslenme Önerisi")
        : "Beslenme Önerisi";

    final String scientificText = hasData
        ? _safeText(
            item["kart_kisa_aciklama"],
            "Bu öneri mevcut duygu durumuna destek olması için seçildi.",
          )
        : "Bu duygu durumu için şu an beslenme önerisi bulunamadı.";

    final String imageUrl = hasData ? _imageFromFood(item) : "";
    final String badgeText = hasData ? _foodBadgeText(item) : "ÖNERİLEN BESİN";
    final Color badgeColor = _foodBadgeColor(badgeText);
    final IconData badgeIcon = _foodBadgeIcon(badgeText);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.chevron_left,
                        color: AppColors.textDark,
                        size: 28,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Moduna Uygun\nBesin Önerileri",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 490,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: 18,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: 400,
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.82,
                              height: 410,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: AppShadows.soft,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 48,
                              height: 460,
                              decoration: BoxDecoration(
                                color: AppColors.creamCard,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: AppColors.border),
                                boxShadow: AppShadows.medium,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Stack(
                                      children: [
                                        Container(
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
                                          left: 14,
                                          child: Container(
                                            constraints: const BoxConstraints(maxWidth: 240),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: badgeColor,
                                              borderRadius: BorderRadius.circular(999),
                                              boxShadow: AppShadows.soft,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  badgeIcon,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    badgeText.toUpperCase(),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w900,
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
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "HAFTALIK ÖNERİ",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            "Neden Bu?",
                                            style: TextStyle(
                                              color: AppColors.textMain,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Expanded(
                                            child: Text(
                                              "($scientificText)",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 14,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Center(
                                            child: GestureDetector(
                                              onTap: hasData
                                                  ? () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FoodDetailScreen(
                                                            id: item["id"] ?? 0,
                                                            type: "food",
                                                            title: title,
                                                            scientificBenefit: _safeText(
                                                              item["bilimsel_fayda_detay"],
                                                              scientificText,
                                                            ),
                                                            consumptionAdvice: _safeText(
                                                              item["tuketim_onerisi"],
                                                              "Bu besini dengeli şekilde tüketebilirsin.",
                                                            ),
                                                            imageUrl: imageUrl,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  : null,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 11,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withOpacity(0.10),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Tüketim Önerisini Gör",
                                                      style: TextStyle(
                                                        color: AppColors.primary,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons.visibility_outlined,
                                                      color: AppColors.primary,
                                                      size: 18,
                                                    ),
                                                  ],
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ActionButton(
                          icon: Icons.check,
                          bgColor: AppColors.primary,
                          iconColor: Colors.white,
                          label: "TAMAMLADIM",
                          labelColor: AppColors.primary,
                          onTap: _completeCurrentFood,
                        ),
                        const SizedBox(width: 56),
                        _ActionButton(
                          icon: Icons.arrow_forward,
                          bgColor: AppColors.border,
                          iconColor: AppColors.textMuted,
                          label: "SIRADAKİ ÖNERİ",
                          labelColor: AppColors.textMuted,
                          onTap: _goNext,
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Öneriyi tamamladıysan 'Tamamladım' (✓) butonuna, farklı bir öneri görmek için 'Sıradaki Öneri' (→) butonuna basabilirsin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 13,
                          height: 1.55,
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: AppShadows.soft,
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}