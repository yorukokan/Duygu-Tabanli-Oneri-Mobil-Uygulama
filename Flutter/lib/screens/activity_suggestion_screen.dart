import 'package:flutter/material.dart';
import 'activity_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class ActivitySuggestionScreen extends StatefulWidget {
  final List<dynamic> activityRecommendations;
  final String finalEmotion;

  const ActivitySuggestionScreen({
    super.key,
    required this.activityRecommendations,
    required this.finalEmotion,
  });

  @override
  State<ActivitySuggestionScreen> createState() =>
      _ActivitySuggestionScreenState();
}

class _ActivitySuggestionScreenState extends State<ActivitySuggestionScreen> {
  int currentIndex = 0;

  String _safeText(dynamic value, String fallback) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  String _imageFromActivity(dynamic item) {
    return _safeText(item["gorsel_url"], "");
  }

  String _activityBadgeText(dynamic item) {
    final dynamic warnings = item["ozel_durum_uyarisi"];
    final dynamic risks = item["riskli_hastaliklar"];

    if (warnings is List && warnings.isNotEmpty) {
      return warnings.first.toString();
    }

    if (risks is List && risks.isNotEmpty) {
      return "Dikkat Gerektirebilir";
    }

    return "Senin İçin Önerildi";
  }

  Color _activityBadgeColor(String text) {
    final t = text.toLowerCase();

    if (t.contains("dikkat") || t.contains("uyarı") || t.contains("uyari")) {
      return const Color(0xFFF59E0B);
    }

    return AppColors.primary;
  }

  IconData _activityBadgeIcon(String text) {
    final t = text.toLowerCase();

    if (t.contains("dikkat") || t.contains("uyarı") || t.contains("uyari")) {
      return Icons.warning_amber_rounded;
    }

    return Icons.star;
  }

  void _goNext() {
    if (widget.activityRecommendations.isEmpty) return;

    setState(() {
      currentIndex = (currentIndex + 1) % widget.activityRecommendations.length;
    });
  }

  Future<void> _completeCurrentActivity() async {
    if (widget.activityRecommendations.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final item = widget.activityRecommendations[currentIndex];

    await FirebaseFirestore.instance
        .collection("completedRecommendations")
        .add({
      "uid": user.uid,
      "itemId": item["id"],
      "type": "activity",
      "title": item["isim"],
      "emotion": widget.finalEmotion,
      "date": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aktivite önerisi tamamlandı")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = widget.activityRecommendations.isNotEmpty;
    final dynamic item =
        hasData ? widget.activityRecommendations[currentIndex] : null;

    final String title = hasData
        ? _safeText(item["isim"], "Aktivite Önerisi")
        : "Aktivite Önerisi";

    final String scientificBenefit = hasData
        ? _safeText(
            item["bilimsel_fayda_detay"],
            "Bu aktivite stresin azalmasına ve zihinsel rahatlamaya yardımcı olur.",
          )
        : "Bu aktivite stresin azalmasına ve zihinsel rahatlamaya yardımcı olur.";

    final String applicationText = hasData
        ? _safeText(
            item["uygulama_onerisi"],
            "Bu aktiviteyi sakin ve kontrollü şekilde uygulayabilirsin.",
          )
        : "Bu aktiviteyi sakin ve kontrollü şekilde uygulayabilirsin.";

    final String imageUrl = hasData ? _imageFromActivity(item) : "";
    final String badgeText =
        hasData ? _activityBadgeText(item) : "ÖNERİLEN AKTİVİTE";
    final Color badgeColor = _activityBadgeColor(badgeText);
    final IconData badgeIcon = _activityBadgeIcon(badgeText);

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
                      "Moduna Uygun\nAktivite Önerileri",
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
                      height: 470,
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
                              height: 440,
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
                                                    image:
                                                        NetworkImage(imageUrl),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        Positioned(
                                          top: 14,
                                          right: 14,
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: 220,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: badgeColor,
                                              borderRadius:
                                                  BorderRadius.circular(999),
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w900,
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
                                      padding: const EdgeInsets.fromLTRB(
                                        22,
                                        18,
                                        22,
                                        20,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            title,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppColors.textMain,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              height: 1.25,
                                            ),
                                          ),
                                          const Spacer(),
                                          Center(
                                            child: GestureDetector(
                                              onTap: hasData
                                                  ? () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ActivityDetailScreen(
                                                            id: item["id"] ?? 0,
                                                            type: "activity",
                                                            title: title,
                                                            scientificBenefit:
                                                                scientificBenefit,
                                                            howToApply:
                                                                applicationText,
                                                            imageUrl: imageUrl,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  : null,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 26,
                                                  vertical: 13,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    999,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.primary
                                                          .withOpacity(0.25),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Nasıl Uygulanır?",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons.play_circle_fill,
                                                      color: Colors.white,
                                                      size: 20,
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
                          onTap: _completeCurrentActivity,
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