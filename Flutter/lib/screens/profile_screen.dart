import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'login_screen.dart';
import 'health_preferences_screen.dart';

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

    setState(() {
      userData ??= {};
      userData!["avatarUrl"] = avatarUrl;
    });

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Avatar güncellendi")),
    );
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bilgi güncellendi")),
    );
  }

  void showEditDialog({
    required String title,
    required String field,
    required String currentValue,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () async {
              final value = controller.text.trim();
              Navigator.pop(context);
              await updateField(field, value);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Future<void> sendPasswordReset() async {
    final email = userData?["email"]?.toString() ?? user?.email;

    if (email == null || email.isEmpty) return;

    await _auth.sendPasswordResetEmail(email: email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Şifre yenileme e-postası gönderildi")),
    );
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Hesabından çıkmak istiyor musun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hayır"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Evet"),
          ),
        ],
      ),
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
    final email = userData?["email"]?.toString() ?? user?.email ?? "-";

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Profilim",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.textMain,
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft,
          ),
          child: const Icon(
            Icons.settings,
            color: AppColors.textMain,
          ),
        ),
      ],
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
            onTap: () => showEditDialog(
              title: "E-posta Güncelle",
              field: "email",
              currentValue: email,
            ),
          ),
          _divider(),
          _infoRow(
            label: "Şifre",
            value: "••••••••••••",
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Bildirim ayarları sonra eklenecek"),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit,
              color: AppColors.primary,
              size: 21,
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
            ),
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