import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool isLoading = true;
  bool isSaving = false;

  bool moodReminder = true;
  bool planReminder = true;
  bool endDayReminder = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final currentUser = user;

    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await _firestore.collection("users").doc(currentUser.uid).get();
    final data = doc.data();

    final settings = data?["notificationSettings"];

    if (settings is Map) {
      moodReminder = settings["moodReminder"] ?? true;
      planReminder = settings["planReminder"] ?? true;
      endDayReminder = settings["endDayReminder"] ?? true;
    }

    if (!mounted) return;

    setState(() => isLoading = false);
  }

  Future<void> saveSettings() async {
    final currentUser = user;
    if (currentUser == null) return;

    setState(() => isSaving = true);

    await _firestore.collection("users").doc(currentUser.uid).set({
      "notificationSettings": {
        "moodReminder": moodReminder,
        "planReminder": planReminder,
        "endDayReminder": endDayReminder,
      }
    }, SetOptions(merge: true));

    await NotificationService.cancelAll();

    if (moodReminder) {
      await NotificationService.scheduleDailyMoodReminder();
    }

    if (planReminder) {
      await NotificationService.schedulePlanReminder();
    }

    if (endDayReminder) {
      await NotificationService.scheduleEndDayReminder();
    }

    if (!mounted) return;

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bildirim ayarları kaydedildi")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoCard(),
                          const SizedBox(height: 22),
                          _settingCard(
                            icon: Icons.wb_sunny_outlined,
                            title: "Sabah Mood Hatırlatması",
                            subtitle: "Her gün 10:00’da modunu kontrol etmeni hatırlatır.",
                            value: moodReminder,
                            onChanged: (value) {
                              setState(() => moodReminder = value);
                            },
                          ),
                          const SizedBox(height: 14),
                          _settingCard(
                            icon: Icons.check_circle_outline,
                            title: "Plan Hatırlatması",
                            subtitle: "Her gün 18:00’da günlük planını kontrol etmeni hatırlatır.",
                            value: planReminder,
                            onChanged: (value) {
                              setState(() => planReminder = value);
                            },
                          ),
                          const SizedBox(height: 14),
                          _settingCard(
                            icon: Icons.nightlight_round,
                            title: "Gün Sonu Değerlendirmesi",
                            subtitle: "Her gün 21:00’da gün sonu değerlendirmeni hatırlatır.",
                            value: endDayReminder,
                            onChanged: (value) {
                              setState(() => endDayReminder = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isSaving ? null : saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Ayarları Kaydet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textMain,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              "Bildirim Ayarları",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppShadows.soft,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              "Hatırlatmaları açıp kapatabilirsin. Ayarları kaydettiğinde bildirim planı yeniden oluşturulur.",
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}