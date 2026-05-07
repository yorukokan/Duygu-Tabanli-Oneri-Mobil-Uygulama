import 'package:flutter/material.dart';
import '../screens/daily_plan_screen.dart';
import '../screens/mood_selection.dart';
import '../screens/statistics_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool showSuggestionButton;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    this.showSuggestionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, showSuggestionButton ? 10 : 14, 18, 18),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSuggestionButton) ...[
            Transform.translate(
              offset: const Offset(0, -8),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MoodSelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 10,
                    shadowColor: AppColors.primary.withOpacity(0.30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Öneriler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                context,
                Icons.home_outlined,
                "Ana Sayfa",
                currentIndex == 0,
                () {
                  if (currentIndex != 0) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
              ),
              _navItem(
                context,
                Icons.calendar_today,
                "Planım",
                currentIndex == 1,
                () {
                  if (currentIndex != 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DailyPlanScreen(),
                      ),
                    );
                  }
                },
              ),
              _navItem(
                context,
                Icons.bar_chart_outlined,
                "İstatistik",
                currentIndex == 2,
                () {
                  if (currentIndex != 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StatisticsScreen(),
                      ),
                    );
                  }
                },
              ),
              _navItem(
                context,
                Icons.person_outline,
                "Profil",
                currentIndex == 3,
                () {
                  if (currentIndex != 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.textLight,
                fontSize: 11,
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
