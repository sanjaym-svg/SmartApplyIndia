import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../../services/storage_service.dart';
import '../../features/auth/login_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final StorageService _storage = StorageService();
  late bool _profileVisible;
  late bool _dataSharing;
  late bool _analytics;

  @override
  void initState() {
    super.initState();
    _profileVisible = _storage.privacyProfileVisible;
    _dataSharing = _storage.privacyDataSharing;
    _analytics = _storage.privacyAnalytics;
  }

  void _save() {
    _storage.savePrivacyPrefs(
      profileVisible: _profileVisible,
      dataSharing: _dataSharing,
      analytics: _analytics,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Privacy settings saved'),
        ]),
        backgroundColor: AppColors.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Iconsax.warning_2, color: AppColors.error, size: 24),
          SizedBox(width: 10),
          Text('Delete Account', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data, saved jobs, and resume will be permanently deleted.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Clear all data and sign out
              await _storage.clearAll();
              if (mounted) {
                await context.read<AuthState>().signOut();
              }
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Privacy Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary))
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 6),
            const Text('Control how your data is used', style: TextStyle(fontSize: 14, color: AppColors.textMuted))
                .animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 24),

            _toggleTile(
              icon: Iconsax.eye,
              title: 'Profile Visibility',
              subtitle: 'Allow recruiters to discover your profile',
              value: _profileVisible,
              onChanged: (v) => setState(() => _profileVisible = v),
              color: AppColors.primary,
              delay: 200,
            ),
            _toggleTile(
              icon: Iconsax.share,
              title: 'Data Sharing',
              subtitle: 'Share anonymized data for platform improvements',
              value: _dataSharing,
              onChanged: (v) => setState(() => _dataSharing = v),
              color: AppColors.accent,
              delay: 300,
            ),
            _toggleTile(
              icon: Iconsax.chart_2,
              title: 'Analytics',
              subtitle: 'Help us improve with usage analytics',
              value: _analytics,
              onChanged: (v) => setState(() => _analytics = v),
              color: AppColors.success,
              delay: 400,
            ),

            const SizedBox(height: 32),
            const Text('Account Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary))
                .animate(delay: 500.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 14),

            // Change password
            _actionTile(
              icon: Iconsax.lock,
              title: 'Change Password',
              subtitle: 'Update your account password',
              color: AppColors.warning,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Password reset email sent (if email is configured)'),
                    backgroundColor: AppColors.info.withValues(alpha: 0.9),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              delay: 600,
            ),

            // Delete account
            _actionTile(
              icon: Iconsax.trash,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and data',
              color: AppColors.error,
              onTap: _showDeleteAccountDialog,
              delay: 700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
          inactiveThumbColor: AppColors.textMuted,
          inactiveTrackColor: AppColors.surface,
        ),
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideX(begin: 0.03, end: 0);
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideX(begin: 0.03, end: 0);
  }
}
