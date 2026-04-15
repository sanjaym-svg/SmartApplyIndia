import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/login_screen.dart';
import '../../services/auth_state.dart';
import '../../services/bookmark_service.dart';
import '../../services/resume_service.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final bookmarkService = context.watch<BookmarkService>();
    final resumeService = context.watch<ResumeService>();
    final user = authState.user;
    final initial = (user?.displayName ?? 'U').substring(0, 1).toUpperCase();
    final name = user?.displayName ?? 'Guest User';
    final email = user?.email ?? 'Not signed in';

    // Real stats from services
    final appliedCount = bookmarkService.appliedCount.toString();
    final savedCount = bookmarkService.bookmarkCount.toString();
    final avgMatch = resumeService.hasResume
        ? '${resumeService.atsScore.toInt()}%'
        : '—';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Avatar
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Center(child: Text(initial, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white))),
              ).animate().scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 14),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)).animate(delay: 300.ms).fadeIn(),

              // Phone & bio if available
              if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(user.phone!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)).animate(delay: 350.ms).fadeIn(),
              ],

              const SizedBox(height: 24),

              // Stats row — real data
              Row(
                children: [
                  _statCard(appliedCount, 'Applied', AppColors.primary, Iconsax.send_2),
                  const SizedBox(width: 10),
                  _statCard(savedCount, 'Saved', AppColors.accent, Iconsax.bookmark_2),
                  const SizedBox(width: 10),
                  _statCard(avgMatch, 'ATS Score', AppColors.success, Iconsax.chart_2),
                ],
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
              const SizedBox(height: 28),

              // Menu items — all wired up
              _menuItem(Iconsax.user_edit, 'Edit Profile', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              }),
              _menuItem(Iconsax.document_text, 'My Resume', () {
                // Navigate to Resume tab (index 1) via parent AppShell
                // Find the nearest AppShell ancestor and switch tabs
                _navigateToTab(context, 1);
              }),
              _menuItem(Iconsax.notification, 'Notifications', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              }),
              _menuItem(Iconsax.shield_tick, 'Privacy & Security', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()));
              }),
              _menuItem(Iconsax.message_question, 'Help & Support', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
              }),
              _menuItem(Iconsax.info_circle, 'About SmartApply', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              }),
              const SizedBox(height: 12),
              _menuItem(Iconsax.logout, 'Sign Out', () async {
                await context.read<AuthState>().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              }, isDestructive: true),
              const SizedBox(height: 40),
              const Text('SmartApply India v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to a specific tab in the parent AppShell
  void _navigateToTab(BuildContext context, int tabIndex) {
    // Pop back to AppShell and switch to the desired tab
    // We use a callback approach since AppShell manages its own state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Iconsax.document_text, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Switch to the Resume tab from the bottom navigation'),
        ]),
        backgroundColor: AppColors.info.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textSecondary, size: 22),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDestructive ? AppColors.error : AppColors.textPrimary)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDestructive ? AppColors.error : AppColors.textMuted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
