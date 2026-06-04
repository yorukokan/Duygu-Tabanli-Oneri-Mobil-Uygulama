import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_bottom_nav_bar.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isLoading = true;

  int totalCompleted = 0;
  int foodCount = 0;
  int activityCount = 0;

  int weeklyCompleted = 0;
  int weeklyTotal = 0;

  int todayMoodCheckCount = 0;
  String latestMoodCheck = "Yok";

  String todayMoodLabel = "Normal";

  List<String> weeklyMoodHistoryEmotions = List.filled(7, "normal");
  List<String> weeklyEndDayEmotions = List.filled(7, "normal");

  List<Map<String, dynamic>> goodItems = [];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    await Future.wait([
      loadCompleted(user.uid),
      loadWeeklyEndDayEvaluations(user.uid),
      loadWeeklyMoodHistory(user.uid),
      loadTodayMoodChecks(user.uid),
    ]);

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> loadCompleted(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("completedRecommendations")
        .where("uid", isEqualTo: uid)
        .get();

    int foods = 0;
    int activities = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (data["type"] == "food") foods++;
      if (data["type"] == "activity") activities++;
    }

    final docs = snapshot.docs;

    docs.sort((a, b) {
      final aDate = (a.data()["date"] as Timestamp?)?.toDate();
      final bDate = (b.data()["date"] as Timestamp?)?.toDate();

      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    if (!mounted) return;

    setState(() {
      totalCompleted = docs.length;
      foodCount = foods;
      activityCount = activities;
      goodItems = docs.take(3).map((e) => e.data()).toList();
    });
  }

  Future<void> loadWeeklyEndDayEvaluations(String uid) async {
    final now = DateTime.now();

    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection("dailyEvaluations")
        .where("uid", isEqualTo: uid)
        .where(
          "createdAt",
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek),
        )
        .where(
          "createdAt",
          isLessThan: Timestamp.fromDate(endOfWeek),
        )
        .orderBy("createdAt")
        .get();

    final emotions = List<String>.filled(7, "normal");

    int completed = 0;
    int total = 0;

    String latestLabel = "Normal";

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final createdAt = (data["createdAt"] as Timestamp?)?.toDate();
      if (createdAt == null) continue;

      final index = createdAt.weekday - 1;
      if (index < 0 || index > 6) continue;

      emotions[index] = data["endDayEmotion"]?.toString() ?? "normal";

      completed += (data["completedCount"] ?? 0) as int;
      total += (data["totalCount"] ?? 0) as int;

      latestLabel = data["endDayMoodLabel"]?.toString() ?? "Normal";
    }

    if (!mounted) return;

    setState(() {
      weeklyEndDayEmotions = emotions;
      weeklyCompleted = completed;
      weeklyTotal = total;
      todayMoodLabel = latestLabel;
    });
  }

  Future<void> loadWeeklyMoodHistory(String uid) async {
    final now = DateTime.now();

    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection("moodHistory")
        .where("uid", isEqualTo: uid)
        .where(
          "date",
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek),
        )
        .where(
          "date",
          isLessThan: Timestamp.fromDate(endOfWeek),
        )
        .orderBy("date", descending: true)
        .get();

    final emotions = List<String>.filled(7, "normal");
    final filledDays = <int>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final date = (data["date"] as Timestamp?)?.toDate();
      if (date == null) continue;

      final index = date.weekday - 1;
      if (index < 0 || index > 6) continue;

      if (filledDays.contains(index)) continue;

      emotions[index] = data["finalEmotion"]?.toString() ?? "normal";
      filledDays.add(index);
    }

    if (!mounted) return;

    setState(() {
      weeklyMoodHistoryEmotions = emotions;
    });
  }

  Future<void> loadTodayMoodChecks(String uid) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await FirebaseFirestore.instance
        .collection("moodHistory")
        .where("uid", isEqualTo: uid)
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy("date", descending: true)
        .get();

    String latest = "Yok";

    if (snapshot.docs.isNotEmpty) {
      latest = snapshot.docs.first.data()["finalEmotion"]?.toString() ?? "Yok";
    }

    if (!mounted) return;

    setState(() {
      todayMoodCheckCount = snapshot.docs.length;
      latestMoodCheck = formatMoodText(latest);
    });
  }

  String formatMoodText(String value) {
    final clean = value.trim().toLowerCase();

    if (clean.isEmpty) return "Yok";

    switch (clean) {
      case "yok":
        return "Yok";
      case "harika":
        return "Harika";
      case "mutlu":
        return "Mutlu";
      case "normal":
        return "Normal";
      case "uzgun":
      case "üzgün":
        return "Üzgün";
      case "kizgin":
      case "kızgın":
        return "Kızgın";
      case "yorgun":
        return "Yorgun";
      case "heyecanli":
      case "heyecanlı":
        return "Heyecanlı";
      case "sakin":
        return "Sakin";
      case "kaygili":
      case "kaygılı":
        return "Kaygılı";
    }

    return clean
        .replaceAll("_", " ")
        .replaceAll("nötr", "Nötr")
        .replaceAll("notr", "Nötr")
        .replaceAll("genel denge", "Genel Denge")
        .replaceAll("heyecan yüksek enerji", "Heyecan / Yüksek Enerji")
        .replaceAll("heyecan yuksek enerji", "Heyecan / Yüksek Enerji")
        .replaceAll("kaygı anksiyete", "Kaygı / Anksiyete")
        .replaceAll("kaygi anksiyete", "Kaygı / Anksiyete")
        .replaceAll("depresif hüzünlü", "Depresif / Hüzünlü")
        .replaceAll("depresif huzunlu", "Depresif / Hüzünlü")
        .replaceAll("öfke gerginlik", "Öfke / Gerginlik")
        .replaceAll("ofke gerginlik", "Öfke / Gerginlik")
        .replaceAll("odak eksikliği", "Odak Eksikliği")
        .replaceAll("odak eksikligi", "Odak Eksikliği")
        .replaceAll("yüksek stres", "Yüksek Stres")
        .replaceAll("yuksek stres", "Yüksek Stres")
        .replaceAll("düşük enerji yorgunluk", "Düşük Enerji / Yorgunluk")
        .replaceAll("dusuk enerji yorgunluk", "Düşük Enerji / Yorgunluk")
        .replaceAll("uyku huzursuzluk", "Uyku / Huzursuzluk")
        .replaceAll("motivasyon eksikliği", "Motivasyon Eksikliği")
        .replaceAll("motivasyon eksikligi", "Motivasyon Eksikliği")
        .replaceAll("mutluluk", "Mutluluk");
  }

  double emotionToY(String emotion) {
    final e = emotion
        .trim()
        .toLowerCase()
        .replaceAll(" ", "_")
        .replaceAll("/", "_");

    switch (e) {
      case "harika":
      case "mutluluk":
        return 10;

      case "mutlu":
        return 18;

      case "heyecanli":
      case "heyecanlı":
      case "heyecan_yüksek_enerji":
      case "heyecan_yuksek_enerji":
        return 25;

      case "sakin":
        return 36;

      case "normal":
      case "nötr_genel_denge":
      case "notr_genel_denge":
        return 50;

      case "odak_eksikliği":
      case "odak_eksikligi":
        return 58;

      case "motivasyon_eksikliği":
      case "motivasyon_eksikligi":
        return 66;

      case "yorgun":
      case "düşük_enerji_yorgunluk":
      case "dusuk_enerji_yorgunluk":
        return 72;

      case "uyku_huzursuzluk":
        return 76;

      case "kaygili":
      case "kaygılı":
      case "kaygı_anksiyete":
      case "kaygi_anksiyete":
        return 82;

      case "uzgun":
      case "üzgün":
      case "depresif_hüzünlü":
      case "depresif_huzunlu":
        return 88;

      case "kizgin":
      case "kızgın":
      case "öfke_gerginlik":
      case "ofke_gerginlik":
        return 94;

      case "yüksek_stres":
      case "yuksek_stres":
        return 98;

      default:
        return 50;
    }
  }

  IconData iconForType(String? type) {
    if (type == "food") return Icons.restaurant_rounded;
    if (type == "activity") return Icons.directions_walk_rounded;
    return Icons.auto_awesome_rounded;
  }

  double get weeklyRate {
    if (weeklyTotal == 0) return 0;
    return weeklyCompleted / weeklyTotal;
  }

  @override
  Widget build(BuildContext context) {
    final days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "İstatistikler",
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildWeeklyChart(days),
                    const SizedBox(height: 18),
                    _buildTodayMood(),
                    const SizedBox(height: 18),
                    _buildMoodCheckSummary(),
                    const SizedBox(height: 18),
                    _buildWeeklySuccess(),
                    const SizedBox(height: 18),
                    _buildCompleted(),
                    const SizedBox(height: 18),
                    _buildGoodItems(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildWeeklyChart(List<String> days) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Haftalık Ruh Hali",
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(AppColors.primary, "Gün içi analiz"),
              const SizedBox(width: 14),
              _legendDot(AppColors.textMuted, "Gün sonu"),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            child: Row(
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.sentiment_very_satisfied_rounded,
                      color: AppColors.textLight,
                    ),
                    Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      color: AppColors.textLight,
                    ),
                    Icon(
                      Icons.sentiment_neutral_rounded,
                      color: AppColors.textLight,
                    ),
                    Icon(
                      Icons.sentiment_dissatisfied_rounded,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomPaint(
                    painter: ChartPainter(
                      moodEmotions: weeklyMoodHistoryEmotions,
                      endDayEmotions: weeklyEndDayEmotions,
                      map: emotionToY,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                return Text(
                  day,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayMood() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.nightlight_round,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bugünkü Gün Sonu Mood",
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayMoodLabel,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCheckSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bugünkü Mood Kontrolü",
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$todayMoodCheckCount kez modunu kontrol ettin",
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Son analiz: $latestMoodCheck",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySuccess() {
    final percent = (weeklyRate * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Haftalık Başarı Oranı",
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: weeklyRate,
              minHeight: 10,
              color: AppColors.primary,
              backgroundColor: AppColors.divider,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "%$percent görev tamamlama başarısı",
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tamamlanan Öneriler",
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$totalCompleted öneri tamamlandı",
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _chip(Icons.restaurant_rounded, "$foodCount Besin"),
              const SizedBox(width: 10),
              _chip(Icons.fitness_center_rounded, "$activityCount Aktivite"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoodItems() {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Text(
              "Sana İyi Gelenler",
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (goodItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Henüz tamamlanan öneri yok.",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...goodItems.map((item) {
              final type = item["type"]?.toString();
              final title = item["title"]?.toString() ?? "Öneri";

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconForType(type),
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.soft,
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<String> moodEmotions;
  final List<String> endDayEmotions;
  final double Function(String) map;

  ChartPainter({
    required this.moodEmotions,
    required this.endDayEmotions,
    required this.map,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    _drawLine(
      canvas: canvas,
      size: size,
      emotions: endDayEmotions,
      color: AppColors.textMuted,
      strokeWidth: 2.2,
      pointRadius: 3.5,
    );

    _drawLine(
      canvas: canvas,
      size: size,
      emotions: moodEmotions,
      color: AppColors.primary,
      strokeWidth: 3,
      pointRadius: 4.2,
    );
  }

  void _drawLine({
    required Canvas canvas,
    required Size size,
    required List<String> emotions,
    required Color color,
    required double strokeWidth,
    required double pointRadius,
  }) {
    if (emotions.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    for (int i = 0; i < emotions.length; i++) {
      final x = i * (size.width / (emotions.length - 1));
      final y = (map(emotions[i]) / 100) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    for (int i = 0; i < emotions.length; i++) {
      final x = i * (size.width / (emotions.length - 1));
      final y = (map(emotions[i]) / 100) * size.height;

      canvas.drawCircle(Offset(x, y), pointRadius, pointPaint);
      canvas.drawCircle(Offset(x, y), pointRadius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.moodEmotions != moodEmotions ||
        oldDelegate.endDayEmotions != endDayEmotions;
  }
}