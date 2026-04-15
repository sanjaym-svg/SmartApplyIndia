import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme/app_colors.dart';
import '../features/jobs/job_feed_screen.dart';
import '../features/resume/resume_screen.dart';
import '../features/bookmarks/bookmarks_screen.dart';
import '../features/profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    JobFeedScreen(),
    ResumeScreen(),
    BookmarksScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Iconsax.briefcase, Iconsax.briefcase5, 'Jobs'),
                _navItem(1, Iconsax.document_text, Iconsax.document_text_1, 'Resume'),
                _navItem(2, Iconsax.bookmark, Iconsax.bookmark_25, 'Saved'),
                _navItem(3, Iconsax.user, Iconsax.user, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.accent : AppColors.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? AppColors.accent : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
