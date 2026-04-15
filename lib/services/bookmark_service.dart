import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import '../models/job_model.dart';

/// Manages bookmarked and applied job state.
/// Persists to SharedPreferences for data persistence across restarts.
class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._();
  factory BookmarkService() => _instance;
  BookmarkService._() {
    _restoreBookmarks();
  }

  final StorageService _storage = StorageService();
  final Map<String, Job> _bookmarked = {};
  final Map<String, Job> _applied = {};

  // ─── Getters ──────────────────────────────────────────

  List<Job> get bookmarkedJobs => _bookmarked.values.toList()
    ..sort((a, b) => b.postedDate.compareTo(a.postedDate));

  List<Job> get appliedJobs => _applied.values.toList()
    ..sort((a, b) => b.postedDate.compareTo(a.postedDate));

  int get bookmarkCount => _bookmarked.length;
  int get appliedCount => _applied.length;

  bool isBookmarked(String jobId) => _bookmarked.containsKey(jobId);
  bool isApplied(String jobId) => _applied.containsKey(jobId);

  // ─── Restore from Storage ─────────────────────────────

  void _restoreBookmarks() {
    if (!_storage.isReady) return;

    final bookmarkData = _storage.loadBookmarks();
    if (bookmarkData != null) {
      for (final entry in bookmarkData.entries) {
        try {
          _bookmarked[entry.key] = Job.fromJson(entry.value as Map<String, dynamic>);
        } catch (_) {}
      }
    }

    final appliedData = _storage.loadApplied();
    if (appliedData != null) {
      for (final entry in appliedData.entries) {
        try {
          _applied[entry.key] = Job.fromJson(entry.value as Map<String, dynamic>);
        } catch (_) {}
      }
    }
  }

  /// Save bookmarks to local storage
  Future<void> _persistBookmarks() async {
    final bookmarkMap = <String, dynamic>{};
    for (final entry in _bookmarked.entries) {
      bookmarkMap[entry.key] = entry.value.toJson();
    }
    await _storage.saveBookmarks(bookmarkMap);
  }

  /// Save applied jobs to local storage
  Future<void> _persistApplied() async {
    final appliedMap = <String, dynamic>{};
    for (final entry in _applied.entries) {
      appliedMap[entry.key] = entry.value.toJson();
    }
    await _storage.saveApplied(appliedMap);
  }

  // ─── Actions ──────────────────────────────────────────

  void toggleBookmark(Job job) {
    if (_bookmarked.containsKey(job.id)) {
      _bookmarked.remove(job.id);
    } else {
      _bookmarked[job.id] = job.copyWith(isBookmarked: true);
    }
    notifyListeners();
    _persistBookmarks();
  }

  void markApplied(Job job) {
    if (!_applied.containsKey(job.id)) {
      _applied[job.id] = job.copyWith(isApplied: true);
      notifyListeners();
      _persistApplied();
    }
  }

  void removeApplied(String jobId) {
    _applied.remove(jobId);
    notifyListeners();
    _persistApplied();
  }

  void removeBookmark(String jobId) {
    _bookmarked.remove(jobId);
    notifyListeners();
    _persistBookmarks();
  }

  /// Update job data (e.g. when ATS scores change)
  void updateJobData(Job job) {
    if (_bookmarked.containsKey(job.id)) {
      _bookmarked[job.id] = job.copyWith(isBookmarked: true);
    }
    if (_applied.containsKey(job.id)) {
      _applied[job.id] = job.copyWith(isApplied: true);
    }
  }
}
