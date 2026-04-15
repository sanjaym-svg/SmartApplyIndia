import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../services/storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final StorageService _storage = StorageService();
  late bool _jobAlerts;
  late bool _appUpdates;
  late bool _resumeTips;
  late bool _promotional;

  @override
  void initState() {
    super.initState();
    _jobAlerts = _storage.notifJobAlerts;
    _appUpdates = _storage.notifAppUpdates;
    _resumeTips = _storage.notifResumeTips;
    _promotional = _storage.notifPromotional;
  }

  void _save() {
    _storage.saveNotificationPrefs(
      jobAlerts: _jobAlerts,
      appUpdates: _appUpdates,
      resumeTips: _resumeTips,
      promotional: _promotional,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Preferences saved'),
        ]),
        backgroundColor: AppColors.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
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
            const Text('Manage Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary))
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 6),
            const Text('Choose which notifications you want to receive', style: TextStyle(fontSize: 14, color: AppColors.textMuted))
                .animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 24),

            _toggleTile(
              icon: Iconsax.briefcase,
              title: 'Job Alerts',
              subtitle: 'Get notified about new job matches',
              value: _jobAlerts,
              onChanged: (v) => setState(() => _jobAlerts = v),
              color: AppColors.primary,
              delay: 200,
            ),
            _toggleTile(
              icon: Iconsax.notification_status,
              title: 'Application Updates',
              subtitle: 'Track your application status changes',
              value: _appUpdates,
              onChanged: (v) => setState(() => _appUpdates = v),
              color: AppColors.accent,
              delay: 300,
            ),
            _toggleTile(
              icon: Iconsax.document_text,
              title: 'Resume Tips',
              subtitle: 'Receive tips to improve your resume',
              value: _resumeTips,
              onChanged: (v) => setState(() => _resumeTips = v),
              color: AppColors.success,
              delay: 400,
            ),
            _toggleTile(
              icon: Iconsax.discount_shape,
              title: 'Promotional',
              subtitle: 'Special offers and updates from SmartApply',
              value: _promotional,
              onChanged: (v) => setState(() => _promotional = v),
              color: AppColors.warning,
              delay: 500,
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
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
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
}
