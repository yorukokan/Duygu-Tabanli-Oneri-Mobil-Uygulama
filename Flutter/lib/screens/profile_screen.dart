import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'login_screen.dart';
import 'health_preferences_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  User? get user => _auth.currentUser;

  final List<String> avatarUrls = [
    "https://api.dicebear.com/9.x/adventurer/png?seed=Okan1",
    "https://api.dicebear.com/9.x/adventurer/png?seed=Okan2",
    "https://api.dicebear.com/9.x/adventurer/png?seed=Okan3",
    "https://api.dicebear.com/9.x/adventurer/png?seed=Okan4",
    "https://api.dicebear.com/9.x/adventurer/png?seed=Okan5",
    "https://api.dicebear.com/9.x/adventurer/png?seed=Okan6",
    "https://api.dicebear.com/9.x/bottts/png?seed=Bot1",
    "https://api.dicebear.com/9.x/bottts/png?seed=Bot2",
    "https://api.dicebear.com/9.x/thumbs/png?seed=User1",
  ];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final currentUser = user;

    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await _firestore.collection("users").doc(currentUser.uid).get();

    if (!mounted) return;

    setState(() {
      userData = doc.data();
      isLoading = false;
    });
  }

  Future<void> selectAvatar(String avatarUrl) async {
    final currentUser = user;
    if (currentUser == null) return;

    await _firestore.collection("users").doc(currentUser.uid).update({
      "avatarUrl": avatarUrl,
    });

    if (!mounted) return;

    setState(() {
      userData ??= {};
      userData!["avatarUrl"] = avatarUrl;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Avatar güncellendi")));
  }

  void showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Avatar Seç",
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 270,
                  child: GridView.builder(
                    itemCount: avatarUrls.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final avatarUrl = avatarUrls[index];

                      return GestureDetector(
                        onTap: () => selectAvatar(avatarUrl),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.card,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.18),
                              width: 2,
                            ),
                            boxShadow: AppShadows.soft,
                            image: DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updateField(String field, String value) async {
    final currentUser = user;
    if (currentUser == null || value.trim().isEmpty) return;

    await _firestore.collection("users").doc(currentUser.uid).update({
      field: value.trim(),
    });

    await loadUser();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Bilgi güncellendi")));
  }

  void showEditDialog({
    required String title,
    required String field,
    required String currentValue,
  }) {
    final controller = TextEditingController(text: currentValue);

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
                title,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
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
                  onPressed: () async {
                    final value = controller.text.trim();
                    if (value.isEmpty) return;

                    Navigator.pop(context);
                    await updateField(field, value);
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
                    "Kaydet",
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

  Future<void> sendPasswordReset() async {
    final email = user?.email;

    if (email == null || email.isEmpty) return;

    await _auth.sendPasswordResetEmail(email: email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Şifre yenileme e-postası gönderildi")),
    );
  }

  Future<void> logout() async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Çıkış Yap",
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Hesabından çıkmak istediğine emin misin?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text(
                      "Çıkış Yap",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 8,
                      shadowColor: Colors.red.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      "Vazgeç",
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
          ),
        );
      },
    );

    if (confirm != true) return;

    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = userData?["name"]?.toString() ?? "Kullanıcı";
    final email = user?.email ?? userData?["email"]?.toString() ?? "-";

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 28),
                    _profileAvatar(name, email),
                    const SizedBox(height: 30),
                    _sectionTitle("Kişisel Bilgiler"),
                    _infoCard(name, email),
                    const SizedBox(height: 22),
                    _settingsCard(),
                    const SizedBox(height: 24),
                    _logoutButton(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _header() {
    return const Center(
      child: Text(
        "Profilim",
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w900,
          color: AppColors.textMain,
        ),
      ),
    );
  }

  Widget _profileAvatar(String name, String email) {
    final avatarUrl = userData?["avatarUrl"]?.toString();

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.border,
                  border: Border.all(color: AppColors.card, width: 4),
                  boxShadow: AppShadows.medium,
                  image: avatarUrl != null && avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 56,
                        color: AppColors.textLight,
                      )
                    : null,
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: GestureDetector(
                  onTap: showAvatarPicker,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 3),
                      boxShadow: AppShadows.soft,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _infoCard(String name, String email) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(
            label: "Ad Soyad",
            value: name,
            icon: Icons.edit_rounded,
            editable: true,
            onTap: () => showEditDialog(
              title: "Ad Soyad Güncelle",
              field: "name",
              currentValue: name,
            ),
          ),
          _divider(),
          _infoRow(
            label: "E-posta",
            value: email,
            icon: Icons.lock_outline_rounded,
            editable: false,
            onTap: null,
          ),
          _divider(),
          _infoRow(
            label: "Şifre",
            value: "Yenileme bağlantısı gönder",
            icon: Icons.mail_outline_rounded,
            editable: true,
            onTap: sendPasswordReset,
          ),
        ],
      ),
    );
  }

  Widget _settingsCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _navRow(
            icon: Icons.favorite,
            title: "Sağlık ve Tercih Detayları",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HealthPreferencesScreen(),
                ),
              );
            },
          ),
          _divider(),
          _navRow(
            icon: Icons.notifications,
            title: "Bildirim Ayarları",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    required IconData icon,
    required bool editable,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: editable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: editable
                          ? AppColors.textMain
                          : AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: editable
                    ? AppColors.primary.withOpacity(0.10)
                    : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: editable ? AppColors.primary : AppColors.textLight,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: logout,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Çıkış Yap",
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.creamCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.softBorder),
      boxShadow: AppShadows.soft,
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.border,
    );
  }
}
