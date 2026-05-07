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
  int totalCompleted = 0;
  int foodCount = 0;
  int activityCount = 0;

  List<String> weeklyEmotions = List.filled(7, "nötr_genel_denge");
  List<Map<String, dynamic>> goodItems = [];

  bool isLoading = true;

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

    await loadCompleted(user.uid);
    await loadMoodHistory(user.uid);

    setState(() => isLoading = false);
  }

  Future<void> loadCompleted(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("completedRecommendations")
        .where("uid", isEqualTo: uid)
        .get();

    int food = 0;
    int activity = 0;

    final docs = snapshot.docs;

    for (final doc in docs) {
      final data = doc.data();
      if (data["type"] == "food") food++;
      if (data["type"] == "activity") activity++;
    }

    docs.sort((a, b) {
      final aDate = (a.data()["date"] as Timestamp?)?.toDate();
      final bDate = (b.data()["date"] as Timestamp?)?.toDate();

      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    setState(() {
      totalCompleted = docs.length;
      foodCount = food;
      activityCount = activity;
      goodItems = docs.take(2).map((e) => e.data()).toList();
    });
  }

  Future<void> loadMoodHistory(String uid) async {
    final now = DateTime.now();

    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final snapshot = await FirebaseFirestore.instance
        .collection("moodHistory")
        .where("uid", isEqualTo: uid)
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .orderBy("date")
        .get();

    final emotions = List<String>.filled(7, "nötr_genel_denge");

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final date = (data["date"] as Timestamp?)?.toDate();
      if (date == null) continue;

      final index = date.weekday - 1;
      emotions[index] =
          data["finalEmotion"]?.toString() ?? "nötr_genel_denge";
    }

    setState(() {
      weeklyEmotions = emotions;
    });
  }

  String normalizeEmotion(String emotion) {
    return emotion
        .trim()
        .toLowerCase()
        .replaceAll(" ", "_")
        .replaceAll("/", "_")
        .replaceAll("__", "_");
  }

  double emotionToY(String emotion) {
    final e = normalizeEmotion(emotion);

    switch (e) {
      case "mutluluk":
        return 18;
      case "heyecan_yüksek_enerji":
      case "heyecan_yuksek_enerji":
      case "yuksek_enerji":
        return 28;
      case "nötr_genel_denge":
      case "notr_genel_denge":
        return 50;
      case "odak_eksikliği":
      case "odak_eksikligi":
        return 55;
      case "motivasyon_eksikliği":
      case "motivasyon_eksikligi":
        return 65;
      case "düşük_enerji_yorgunluk":
      case "dusuk_enerji_yorgunluk":
        return 70;
      case "uyku_huzursuzluk":
        return 72;
      case "kaygı_anksiyete":
      case "kaygi_anksiyete":
        return 78;
      case "depresif_hüzünlü":
      case "depresif_huzunlu":
        return 84;
      case "öfke_gerginlik":
      case "ofke_gerginlik":
        return 88;
      case "yüksek_stres":
      case "yuksek_stres":
        return 92;
      default:
        return 50;
    }
  }

  IconData iconForType(String? type) {
    if (type == "food") return Icons.restaurant_rounded;
    if (type == "activity") return Icons.directions_walk_rounded;
    return Icons.auto_awesome_rounded;
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
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildChart(days),
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

  Widget _buildChart(List<String> days) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  "Haftalık Duygu Analizi",
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                "Bu Hafta",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                    Icon(Icons.sentiment_very_satisfied_rounded,
                        size: 18, color: AppColors.textLight),
                    Icon(Icons.sentiment_satisfied_alt_rounded,
                        size: 18, color: AppColors.textLight),
                    Icon(Icons.sentiment_neutral_rounded,
                        size: 18, color: AppColors.textLight),
                    Icon(Icons.sentiment_dissatisfied_rounded,
                        size: 18, color: AppColors.textLight),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomPaint(
                    painter: ChartPainter(
                      emotions: weeklyEmotions,
                      map: emotionToY,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days
                  .map(
                    (day) => Text(
                      day,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                  .toList(),
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Toplam $totalCompleted Öneri Tamamlandı",
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
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
                fontSize: 16,
                fontWeight: FontWeight.w800,
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
                  fontWeight: FontWeight.w500,
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
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
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textLight,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
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
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.soft,
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<String> emotions;
  final double Function(String) map;

  ChartPainter({
    required this.emotions,
    required this.map,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

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

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 4, pointBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.emotions != emotions;
  }
}