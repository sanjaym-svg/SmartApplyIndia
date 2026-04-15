import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/score_badge.dart';
import '../../models/job_model.dart';
import '../../services/bookmark_service.dart';
import '../../services/ai_service.dart';
import '../../services/resume_service.dart';
import '../../services/pdf_service.dart';
import '../../services/download_helper.dart';
import '../../services/auth_service.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Job get job => widget.job;

  @override
  Widget build(BuildContext context) {
    final resumeService = context.watch<ResumeService>();
    final analysis = resumeService.hasResume
        ? resumeService.analyzeJob(job)
        : null;
    final matchedKeywords = analysis?.matchedKeywords ?? job.tags;
    final missingKeywords = analysis?.missingKeywords ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.surface,
            pinned: true,
            expandedHeight: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Iconsax.share, color: AppColors.textSecondary),
              ),
              Consumer<BookmarkService>(
                builder: (context, bs, _) {
                  final saved = bs.isBookmarked(job.id);
                  return IconButton(
                    onPressed: () => bs.toggleBookmark(job),
                    icon: Icon(
                      saved ? Iconsax.bookmark_25 : Iconsax.bookmark,
                      color: saved ? AppColors.accent : AppColors.textSecondary,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            job.company.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job.company,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),

                  // Info chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _infoChip(Iconsax.location, job.location),
                      _infoChip(Iconsax.money_2, job.salaryRange),
                      _infoChip(Iconsax.clock, job.timeAgo),
                      if (job.isRemote)
                        _infoChip(Iconsax.global, 'Remote', isHighlight: true),
                      if (job.isFresher)
                        _infoChip(Iconsax.user, 'Fresher Friendly',
                            isHighlight: true),
                    ],
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),

                  // ATS Match Score Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.accent.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Iconsax.chart_2,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ATS Match Analysis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            ScoreBadge(
                              score: job.matchScore,
                              radius: 30,
                              lineWidth: 5,
                              showLabel: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Matched keywords
                        const Text(
                          'Matched Skills',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: matchedKeywords
                              .map((k) => _keywordChip(k, AppColors.success))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        // Missing keywords
                        const Text(
                          'Missing Keywords',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: missingKeywords
                              .map((k) => _keywordChip(k, AppColors.error))
                              .toList(),
                        ),
                      ],
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                      ),
                  const SizedBox(height: 24),

                  // AI Tailor Resume button
                  if (resumeService.hasResume && resumeService.isAiAvailable)
                    GestureDetector(
                      onTap: () => _showTailorSheet(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.magic_star, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('AI Tailor Resume for This Job', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ).animate(delay: 500.ms).fadeIn(duration: 400.ms).shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.15)),
                  const SizedBox(height: 24),

                  // Job Description
                  const Text(
                    'Job Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  const Text(
                    'Skills Required',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom action bar
      bottomNavigationBar: Consumer<BookmarkService>(
        builder: (context, bs, _) {
          final isSaved = bs.isBookmarked(job.id);
          final isApplied = bs.isApplied(job.id);

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => bs.toggleBookmark(job),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSaved
                          ? AppColors.accent.withValues(alpha: 0.1)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSaved ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      isSaved ? Iconsax.bookmark_25 : Iconsax.bookmark,
                      color: isSaved ? AppColors.accent : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isApplied
                      ? Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.tick_circle, color: AppColors.success, size: 20),
                              SizedBox(width: 8),
                              Text('Applied ✓', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                        )
                      : GradientButton(
                          text: 'Apply Now',
                          icon: Iconsax.send_2,
                          onPressed: () {
                            bs.markApplied(job);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Marked as applied! 🎉'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.accent.withValues(alpha: 0.1)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight
              ? AppColors.accent.withValues(alpha: 0.25)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlight ? AppColors.accent : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isHighlight ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _keywordChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showTailorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _TailorBottomSheet(job: job),
    );
  }
}

/// Bottom sheet that loads and displays AI-tailored resume suggestions
class _TailorBottomSheet extends StatefulWidget {
  final Job job;
  const _TailorBottomSheet({required this.job});

  @override
  State<_TailorBottomSheet> createState() => _TailorBottomSheetState();
}

class _TailorBottomSheetState extends State<_TailorBottomSheet> {
  TailoredResume? _result;
  bool _loading = true;
  bool _downloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTailor();
  }

  Future<void> _loadTailor() async {
    try {
      final rs = context.read<ResumeService>();
      final result = await rs.getTailoredResume(widget.job);
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (e) {
      print('TailorBottomSheet error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_result == null || _result!.isEmpty) return;
    setState(() => _downloading = true);

    try {
      final user = AuthService().currentUser;
      final userName = user?.displayName ?? 'candidate';
      final safeUserName = userName.replaceAll(' ', '_').toLowerCase();
      final safeJobRole = widget.job.title.replaceAll(' ', '_').toLowerCase();
      final fileName = '${safeUserName}_${safeJobRole}_resume.pdf'.replaceAll(RegExp(r'[^a-z0-9_.]'), '');

      final bytes = PdfService.generate(
        resume: _result!,
        jobTitle: widget.job.title,
        candidateName: user?.displayName ?? 'Your Name',
      );

      await downloadPdfBytes(bytes, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('\u2705 PDF downloaded: $fileName'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }

    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              // Title
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.magic_star, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI Resume Tailor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text('For: ${widget.job.title}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Content
              Expanded(
                child: _loading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF6366F1)),
                            SizedBox(height: 16),
                            Text('AI is analyzing...', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                            SizedBox(height: 4),
                            Text('Tailoring your resume for this role', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Iconsax.warning_2, color: AppColors.error, size: 40),
                                  const SizedBox(height: 12),
                                  Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14), textAlign: TextAlign.center),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _loading = true;
                                        _error = null;
                                      });
                                      // Clear cache so it retries fresh
                                      context.read<ResumeService>().clearTailorCache(widget.job.id);
                                      _loadTailor();
                                    },
                                    icon: const Icon(Iconsax.refresh, size: 18),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _buildContent(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController controller) {
    final r = _result!;
    if (r.isEmpty) {
      return const Center(child: Text('No suggestions available', style: TextStyle(color: AppColors.textMuted)));
    }

    return ListView(
      controller: controller,
      children: [
        // ── Download PDF Button ────────────────────────────
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton.icon(
            onPressed: _downloading ? null : _downloadPdf,
            icon: _downloading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Iconsax.document_download, size: 20),
            label: Text(_downloading ? 'Generating PDF...' : 'Download as PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              elevation: 4,
              shadowColor: const Color(0xFF00C853).withValues(alpha: 0.4),
            ),
          ),
        ),

        // Tailored Summary
        if (r.tailoredSummary.isNotEmpty) ...[
          _sectionTitle(Iconsax.document_text, 'Tailored Summary', AppColors.primary),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: SelectableText(
              r.tailoredSummary,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Tailored Skills
        if (r.tailoredSkills.isNotEmpty) ...[
          _sectionTitle(Iconsax.code_1, 'Optimized Skill Order', AppColors.accent),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: r.tailoredSkills.asMap().entries.map((e) {
              final isPriority = e.key < 5;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: isPriority ? AppColors.primaryGradient : null,
                  color: isPriority ? null : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: isPriority ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isPriority ? FontWeight.w600 : FontWeight.w500,
                    color: isPriority ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Key Achievements
        if (r.keyAchievements.isNotEmpty) ...[
          _sectionTitle(Iconsax.medal_star, 'Key Achievements to Highlight', AppColors.success),
          const SizedBox(height: 8),
          ...r.keyAchievements.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.tick_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(child: SelectableText(a, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3))),
              ],
            ),
          )),
          const SizedBox(height: 20),
        ],

        // Keywords to Add
        if (r.keywordsToAdd.isNotEmpty) ...[
          _sectionTitle(Iconsax.add_circle, 'Keywords to Add', AppColors.error),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: r.keywordsToAdd.map((k) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Cover Letter Points
        if (r.coverLetterPoints.isNotEmpty) ...[
          _sectionTitle(Iconsax.note_1, 'Cover Letter Points', const Color(0xFF6366F1)),
          const SizedBox(height: 8),
          ...r.coverLetterPoints.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
                const SizedBox(width: 8),
                Expanded(child: SelectableText(entry.value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3))),
              ],
            ),
          )),
          const SizedBox(height: 20),
        ],

        // Overall Tips
        if (r.overallTips.isNotEmpty) ...[
          _sectionTitle(Iconsax.lamp_on, 'Overall Advice', AppColors.accent),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: SelectableText(
              r.overallTips,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Full Tailored Resume Preview ───────────────────
        if (r.fullResumeText.isNotEmpty) ...[
          const Divider(color: AppColors.border, height: 32),
          _sectionTitle(Iconsax.document_text_1, 'Full Tailored Resume', const Color(0xFF6366F1)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
            ),
            child: SelectableText(
              r.fullResumeText,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.6, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
