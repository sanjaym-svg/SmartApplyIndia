import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../services/resume_service.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final TextEditingController _pasteController = TextEditingController();
  bool _showPasteField = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      context.read<ResumeService>().setResumeFile(
        fileName: file.name,
        bytes: file.bytes!,
      );
    }
  }

  void _submitPastedText() {
    final text = _pasteController.text.trim();
    if (text.isNotEmpty) {
      context.read<ResumeService>().setResumeText(text);
      _pasteController.clear();
      setState(() => _showPasteField = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.watch<ResumeService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Resume & ATS',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 4),
              Text(
                rs.hasResume
                    ? 'Resume loaded • ${rs.extractedSkills.length} skills found'
                    : 'Upload your resume to get AI-powered ATS analysis',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              // AI badge
              if (rs.isAiAvailable) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.magic_star, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('AI Powered (Llama 3)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              if (!rs.hasResume) ...[
                // Upload card
                _buildUploadCard(),
                const SizedBox(height: 16),
                // Paste option
                _buildPasteCard(),
              ] else ...[
                // Resume status card
                _buildResumeStatusCard(rs),
                const SizedBox(height: 16),
                // AI Analysis section
                if (rs.isAnalyzing)
                  _buildAnalyzingCard()
                else if (rs.hasAiAnalysis)
                  _buildAiAnalysisCard(rs)
                else
                  _buildAtsReadinessCard(rs),
                const SizedBox(height: 16),
                // Skills section
                _buildSkillsSection(rs),
                // AI strengths & weaknesses
                if (rs.hasAiAnalysis) ...[
                  const SizedBox(height: 16),
                  _buildStrengthsWeaknessCard(rs),
                  const SizedBox(height: 16),
                  _buildImprovementTips(rs),
                ],
              ],

              // Error display
              if (rs.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.warning_2, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(rs.error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildPasteCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20)],
        ),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Iconsax.document_upload, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            const Text('Upload Your Resume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('PDF, TXT, DOC • Max 5MB', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildPasteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPasteField = !_showPasteField),
            child: Row(
              children: [
                const Icon(Iconsax.clipboard_text, color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Or paste your resume text', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
                Icon(_showPasteField ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1, size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
          if (_showPasteField) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _pasteController,
              maxLines: 6,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Paste your entire resume content here...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitPastedText,
                icon: const Icon(Iconsax.tick_circle, size: 18),
                label: const Text('Analyze Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildResumeStatusCard(ResumeService rs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.document_text, color: AppColors.success, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rs.fileName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${rs.extractedSkills.length} skills • ${rs.resumeText.split(RegExp(r'\\s+')).length} words',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => rs.clearResume(),
            icon: const Icon(Iconsax.trash, color: AppColors.error, size: 20),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('AI is analyzing your resume...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Extracting skills, evaluating ATS readiness,\nand generating insights', style: TextStyle(fontSize: 13, color: AppColors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).shimmer(duration: 1500.ms, color: AppColors.primary.withValues(alpha: 0.1));
  }

  Widget _buildAiAnalysisCard(ResumeService rs) {
    final analysis = rs.aiAnalysis!;
    final score = analysis.atsScore;
    final color = score >= 70 ? AppColors.success : score >= 40 ? AppColors.accent : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score header
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Center(
                  child: Text(
                    '${score.round()}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ATS Readiness Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      score >= 70 ? 'Excellent! Your resume is ATS-optimized' :
                      score >= 40 ? 'Good. Some improvements recommended' :
                      'Needs work. Follow the tips below',
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ],
                ),
              ),
              // Re-analyze button
              IconButton(
                onPressed: () => rs.reanalyze(),
                icon: const Icon(Iconsax.refresh, color: AppColors.textMuted, size: 20),
                tooltip: 'Re-analyze',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 16),
          // Experience + Education
          Row(
            children: [
              _infoTag(Iconsax.user_tag, analysis.experienceLevel.toUpperCase()),
              const SizedBox(width: 8),
              if (analysis.education.isNotEmpty)
                Expanded(child: _infoTag(Iconsax.teacher, analysis.education)),
            ],
          ),
          // Summary
          if (analysis.summary.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                analysis.summary,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildAtsReadinessCard(ResumeService rs) {
    final score = rs.atsScore;
    final color = score >= 70 ? AppColors.success : score >= 40 ? AppColors.accent : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.shield_tick, color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
              const Text('ATS Readiness', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              if (rs.isAiAvailable)
                TextButton.icon(
                  onPressed: () => rs.reanalyze(),
                  icon: const Icon(Iconsax.magic_star, size: 16),
                  label: const Text('AI Analyze', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${score.round()}% — ${rs.extractedSkills.length} skills detected from your resume',
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildSkillsSection(ResumeService rs) {
    if (rs.extractedSkills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(
          rs.hasAiAnalysis ? 'Extracted by AI' : 'Extracted from your resume',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: rs.extractedSkills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                skill,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildStrengthsWeaknessCard(ResumeService rs) {
    final analysis = rs.aiAnalysis!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          // Strengths
          if (analysis.strengths.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Iconsax.tick_circle, color: AppColors.success, size: 18),
                SizedBox(width: 6),
                Text('Strengths', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 8),
            ...analysis.strengths.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 24),
              child: Text('• $s', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3)),
            )),
            const SizedBox(height: 14),
          ],
          // Weaknesses
          if (analysis.weaknesses.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Iconsax.warning_2, color: AppColors.error, size: 18),
                SizedBox(width: 6),
                Text('Areas to Improve', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
              ],
            ),
            const SizedBox(height: 8),
            ...analysis.weaknesses.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 24),
              child: Text('• $w', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3)),
            )),
          ],
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildImprovementTips(ResumeService rs) {
    final tips = rs.aiAnalysis!.improvementTips;
    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.lamp_on, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text('Actionable Tips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(entry.value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3)),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }

  Widget _infoTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }
}
