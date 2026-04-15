import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary))
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 6),
            const Text('Find answers to common questions', style: TextStyle(fontSize: 14, color: AppColors.textMuted))
                .animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 20),

            _faqTile(
              question: 'How does SmartApply match me with jobs?',
              answer: 'SmartApply uses AI-powered ATS (Applicant Tracking System) analysis to compare your resume with job descriptions. It extracts skills, keywords, and experience to calculate a match score.',
              delay: 200,
            ),
            _faqTile(
              question: 'How do I upload my resume?',
              answer: 'Go to the Resume tab, tap "Upload Resume" and select your PDF file. You can also paste your resume text directly. SmartApply will analyze it automatically.',
              delay: 300,
            ),
            _faqTile(
              question: 'What does the ATS score mean?',
              answer: 'The ATS score (0-100%) indicates how well your resume matches a specific job description. A higher score means better alignment with the job requirements. 70%+ is considered a strong match.',
              delay: 400,
            ),
            _faqTile(
              question: 'Is my data secure?',
              answer: 'Yes! Your resume data is stored locally on your device. When cloud sync is enabled, data is encrypted and stored securely using industry-standard practices.',
              delay: 500,
            ),
            _faqTile(
              question: 'Can I apply to jobs directly through SmartApply?',
              answer: 'SmartApply helps you find and match with jobs. Job application links redirect you to the original posting where you can apply directly with your optimized resume.',
              delay: 600,
            ),
            _faqTile(
              question: 'How do I improve my ATS score?',
              answer: 'Use the AI-powered suggestions in the Resume tab. Add relevant keywords, tailor your resume for specific roles, and ensure proper formatting. The app provides specific recommendations for improvement.',
              delay: 700,
            ),

            const SizedBox(height: 32),
            const Text('Contact Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary))
                .animate(delay: 800.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 14),

            _contactTile(
              icon: Iconsax.sms,
              title: 'Email Support',
              subtitle: 'support@smartapply.in',
              color: AppColors.primary,
              delay: 900,
            ),
            _contactTile(
              icon: Iconsax.message,
              title: 'Live Chat',
              subtitle: 'Available Mon-Fri, 9 AM - 6 PM IST',
              color: AppColors.accent,
              delay: 1000,
            ),
            _contactTile(
              icon: Iconsax.document_text,
              title: 'Documentation',
              subtitle: 'Browse detailed guides and tutorials',
              color: AppColors.success,
              delay: 1100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqTile({
    required String question,
    required String answer,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.message_question, color: AppColors.primary, size: 18),
          ),
          title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          children: [
            Text(answer, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          ],
        ),
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0);
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
  }) {
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
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideX(begin: 0.03, end: 0);
  }
}
