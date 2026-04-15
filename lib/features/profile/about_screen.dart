import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('About SmartApply', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App logo
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 48),
            ).animate().scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text('SmartApply India', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary))
                .animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
              child: const Text('v1.0.0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'SmartApply India is an AI-powered job matching platform designed specifically for Indian freshers and job seekers. '
                'Using advanced ATS (Applicant Tracking System) analysis and AI, we help you find the perfect job match, '
                'optimize your resume, and increase your chances of getting hired.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            // Features
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Key Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 14),

            _featureTile(Iconsax.cpu, 'AI-Powered Matching', 'Smart job recommendations based on your skills', AppColors.primary, 600),
            _featureTile(Iconsax.document_text, 'ATS Resume Analysis', 'Score and optimize your resume for each job', AppColors.accent, 700),
            _featureTile(Iconsax.briefcase, 'Live Job Feed', 'Real-time jobs from across India via Adzuna API', AppColors.success, 800),
            _featureTile(Iconsax.magic_star, 'AI Resume Tailoring', 'Get AI suggestions to customize your resume', AppColors.warning, 900),

            const SizedBox(height: 28),

            // Tech & Credits
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Built With', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _techRow('Framework', 'Flutter & Dart'),
                  _divider(),
                  _techRow('AI Engine', 'Groq (Llama 3)'),
                  _divider(),
                  _techRow('Job Data', 'Adzuna API'),
                  _divider(),
                  _techRow('PDF Engine', 'Syncfusion'),
                  _divider(),
                  _techRow('Backend', 'Supabase'),
                  _divider(),
                  _techRow('Auth', 'Firebase Auth'),
                ],
              ),
            ).animate(delay: 1100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            // Legal links
            _linkTile(Iconsax.shield_tick, 'Privacy Policy', AppColors.primary, 1200),
            _linkTile(Iconsax.document, 'Terms of Service', AppColors.accent, 1300),
            _linkTile(Iconsax.code, 'Open Source Licenses', AppColors.success, 1400),

            const SizedBox(height: 24),
            const Text('Made with ❤️ in India', style: TextStyle(fontSize: 13, color: AppColors.textMuted))
                .animate(delay: 1500.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 6),
            const Text('© 2026 SmartApply India', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                .animate(delay: 1600.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _featureTile(IconData icon, String title, String subtitle, Color color, int delay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0);
  }

  static Widget _techRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  static Widget _divider() {
    return Divider(color: AppColors.border.withValues(alpha: 0.5), height: 1, thickness: 0.5);
  }

  static Widget _linkTile(IconData icon, String title, Color color, int delay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        onTap: () {},
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideX(begin: 0.03, end: 0);
  }
}
