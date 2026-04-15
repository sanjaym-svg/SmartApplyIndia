import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/job_card.dart';
import '../../models/job_model.dart';
import '../../services/bookmark_service.dart';
import '../../services/job_service.dart';
import '../../services/resume_service.dart';
import 'job_detail_screen.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final JobService _jobService = JobService();

  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _selectedFilter = 'All';
  String _selectedCity = 'All India';
  String _searchQuery = '';
  String _sortBy = 'latest'; // latest, match, salary

  final List<String> _filters = [
    'All', 'Remote', 'Fresher', 'Full Stack', 'Flutter', 'Python', 'React',
  ];
  final List<String> _cities = [
    'All India', 'Bangalore', 'Mumbai', 'Delhi', 'Hyderabad', 'Chennai', 'Pune',
  ];

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        _jobService.isLiveMode) {
      _loadMoreJobs();
    }
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });

    final location = _selectedCity == 'All India' ? '' : _selectedCity;
    final query = _searchQuery.isEmpty ? 'software developer' : _searchQuery;

    final jobs = await _jobService.fetchJobs(
      query: query,
      location: location,
      page: 1,
    );

    if (mounted) {
      // Apply ATS scores if resume is uploaded
      final resumeService = context.read<ResumeService>();
      final scoredJobs = resumeService.hasResume
          ? resumeService.scoreJobs(jobs)
          : jobs;

      setState(() {
        _jobs = scoredJobs;
        _applyFilters();
        _isLoading = false;
        _hasMore = _jobService.isLiveMode && jobs.length >= 15;
      });
    }
  }

  Future<void> _loadMoreJobs() async {
    if (!_jobService.isLiveMode) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    final location = _selectedCity == 'All India' ? '' : _selectedCity;
    final query = _searchQuery.isEmpty ? 'software developer' : _searchQuery;

    final moreJobs = await _jobService.fetchJobs(
      query: query,
      location: location,
      page: _currentPage,
    );

    if (mounted) {
      setState(() {
        _jobs.addAll(moreJobs);
        _applyFilters();
        _isLoadingMore = false;
        _hasMore = moreJobs.length >= 15;
      });
    }
  }

  void _applyFilters() {
    List<Job> result = List.from(_jobs);

    // Apply category filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Remote') {
        result = result.where((j) => j.isRemote).toList();
      } else if (_selectedFilter == 'Fresher') {
        result = result.where((j) => j.isFresher).toList();
      } else {
        result = result
            .where((j) =>
                j.tags.any((t) => t.toLowerCase().contains(_selectedFilter.toLowerCase())) ||
                j.title.toLowerCase().contains(_selectedFilter.toLowerCase()))
            .toList();
      }
    }

    // Sort
    switch (_sortBy) {
      case 'match':
        result.sort((a, b) => b.matchScore.compareTo(a.matchScore));
        break;
      case 'salary':
        result.sort((a, b) {
          final aVal = double.tryParse(a.salaryMax.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          final bVal = double.tryParse(b.salaryMax.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          return bVal.compareTo(aVal);
        });
        break;
      default: // latest
        result.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    }

    _filteredJobs = result;
  }

  void _filterJobs(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _searchJobs(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      setState(() => _applyFilters());
      return;
    }

    // For live mode, debounce and refetch from API
    if (_jobService.isLiveMode) {
      _loadJobs();
    } else {
      // For mock mode, filter locally
      setState(() {
        _filteredJobs = _jobs
            .where((j) =>
                j.title.toLowerCase().contains(query.toLowerCase()) ||
                j.company.toLowerCase().contains(query.toLowerCase()) ||
                j.location.toLowerCase().contains(query.toLowerCase()) ||
                j.tags.any((t) => t.toLowerCase().contains(query.toLowerCase())))
            .toList();
      });
    }
  }

  void _selectCity(String city) {
    setState(() => _selectedCity = city);
    _loadJobs();
  }

  void _toggleBookmark(int index) {
    final job = _filteredJobs[index];
    context.read<BookmarkService>().toggleBookmark(job);
    setState(() {
      final mainIndex = _jobs.indexWhere((j) => j.id == job.id);
      if (mainIndex >= 0) {
        _jobs[mainIndex] = job.copyWith(isBookmarked: !job.isBookmarked);
      }
      _applyFilters();
    });
  }

  void _changeSortBy(String sort) {
    setState(() {
      _sortBy = sort;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadJobs,
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SmartApply',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
                              ).animate().fadeIn(duration: 400.ms),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: _jobService.isLiveMode ? AppColors.success : AppColors.warning,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _jobService.isLiveMode
                                        ? '${_jobs.length} live jobs • Powered by Adzuna'
                                        : '${_jobs.length} jobs • Demo Data',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                            ],
                          ),
                          // Notification bell
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Stack(
                              children: [
                                const Center(child: Icon(Iconsax.notification, color: AppColors.textSecondary, size: 22)),
                                Positioned(
                                  top: 10, right: 12,
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.error, shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).scale(
                                begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _searchJobs,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Search jobs, companies, skills...',
                            hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.8), fontSize: 14),
                            prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textMuted, size: 20),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Iconsax.setting_4, color: Colors.white, size: 18),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            filled: false,
                          ),
                        ),
                      ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // City filter chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      final isSelected = _selectedCity == city;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _selectCity(city),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.accentGradient : null,
                              color: isSelected ? null : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: isSelected ? Colors.transparent : AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(Iconsax.location, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ).animate(delay: 450.ms).fadeIn(duration: 400.ms),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // Category filter chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _filterJobs(filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.primaryGradient : null,
                              color: isSelected ? null : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.transparent : AppColors.border),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Stats bar
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_filteredJobs.length} jobs', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: _changeSortBy,
                      initialValue: _sortBy,
                      color: AppColors.card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Iconsax.sort, size: 16, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          _sortBy == 'match' ? 'Best match' : _sortBy == 'salary' ? 'Top salary' : 'Latest first',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accent),
                        ),
                      ]),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'latest', child: Text('Latest first', style: TextStyle(color: AppColors.textPrimary))),
                        const PopupMenuItem(value: 'match', child: Text('Best match', style: TextStyle(color: AppColors.textPrimary))),
                        const PopupMenuItem(value: 'salary', child: Text('Top salary', style: TextStyle(color: AppColors.textPrimary))),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn(duration: 300.ms),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Job list
            _isLoading
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : _filteredJobs.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Iconsax.search_status, size: 56, color: AppColors.textMuted.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              const Text('No jobs found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              const Text('Try adjusting your filters or search query',
                                  style: TextStyle(fontSize: 14, color: AppColors.textMuted), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final job = _filteredJobs[index];
                              final bookmarkService = context.watch<BookmarkService>();
                              final displayJob = job.copyWith(
                                isBookmarked: bookmarkService.isBookmarked(job.id),
                              );
                              return JobCard(
                                job: displayJob,
                                index: index,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => JobDetailScreen(job: displayJob)),
                                  );
                                },
                                onBookmark: () => _toggleBookmark(index),
                              );
                            },
                            childCount: _filteredJobs.length,
                          ),
                        ),
                      ),

            // Loading more indicator
            if (_isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
