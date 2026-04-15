import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/job_card.dart';
import '../../models/job_model.dart';
import '../../services/bookmark_service.dart';
import '../jobs/job_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkService = context.watch<BookmarkService>();
    final bookmarkedJobs = bookmarkService.bookmarkedJobs;
    final appliedJobs = bookmarkService.appliedJobs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Saved Jobs',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ).animate().fadeIn(duration: 400.ms),
            ),
            const SizedBox(height: 16),
            _buildTabBar(bookmarkedJobs.length, appliedJobs.length),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(bookmarkedJobs, true),
                  _buildList(appliedJobs, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(int bookmarkCount, int appliedCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.bookmark_2, size: 18),
                const SizedBox(width: 6),
                Text('Saved ($bookmarkCount)'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.send_2, size: 18),
                const SizedBox(width: 6),
                Text('Applied ($appliedCount)'),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildList(List<Job> jobs, bool isBookmark) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBookmark ? Iconsax.bookmark : Iconsax.send_2,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              isBookmark ? 'No saved jobs yet' : 'No applications yet',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isBookmark
                  ? 'Tap the bookmark icon on any job to save it here'
                  : 'Jobs you apply to will appear here',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Dismissible(
          key: Key(job.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Iconsax.trash, color: AppColors.error),
          ),
          onDismissed: (_) {
            final bookmarkService = context.read<BookmarkService>();
            if (isBookmark) {
              bookmarkService.removeBookmark(job.id);
            } else {
              bookmarkService.removeApplied(job.id);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${job.title} removed'),
                backgroundColor: AppColors.surface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: AppColors.accent,
                  onPressed: () {
                    if (isBookmark) {
                      bookmarkService.toggleBookmark(job);
                    } else {
                      bookmarkService.markApplied(job);
                    }
                  },
                ),
              ),
            );
          },
          child: JobCard(
            job: job,
            index: index,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
            ),
            onBookmark: () {
              context.read<BookmarkService>().toggleBookmark(job);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
