import 'package:flutter_test/flutter_test.dart';
import 'package:smartapply_india/models/job_model.dart';
import 'package:smartapply_india/services/bookmark_service.dart';

void main() {
  group('BookmarkService', () {
    late BookmarkService service;

    setUp(() {
      service = BookmarkService();
      // Clear any state from previous tests
      for (final job in [...service.bookmarkedJobs]) {
        service.removeBookmark(job.id);
      }
      for (final job in [...service.appliedJobs]) {
        service.removeApplied(job.id);
      }
    });

    Job createTestJob(String id, String title) {
      return Job(
        id: id,
        title: title,
        company: 'Test Company',
        location: 'Mumbai, India',
        description: 'Test job description for $title',
        salaryMin: '5L',
        salaryMax: '8L',
        postedDate: DateTime.now(),
        tags: ['Test'],
        source: 'mock',
      );
    }

    test('initial state has zero bookmarks and applied', () {
      expect(service.bookmarkCount, 0);
      expect(service.appliedCount, 0);
    });

    test('toggleBookmark adds and removes bookmark', () {
      final job = createTestJob('job1', 'Flutter Dev');

      service.toggleBookmark(job);
      expect(service.bookmarkCount, 1);
      expect(service.isBookmarked('job1'), isTrue);

      service.toggleBookmark(job);
      expect(service.bookmarkCount, 0);
      expect(service.isBookmarked('job1'), isFalse);
    });

    test('markApplied adds job to applied list', () {
      final job = createTestJob('job2', 'React Dev');

      service.markApplied(job);
      expect(service.appliedCount, 1);
      expect(service.isApplied('job2'), isTrue);
    });

    test('markApplied does not duplicate', () {
      final job = createTestJob('job3', 'Python Dev');

      service.markApplied(job);
      service.markApplied(job);
      expect(service.appliedCount, 1);
    });

    test('removeApplied removes job', () {
      final job = createTestJob('job4', 'Java Dev');

      service.markApplied(job);
      expect(service.appliedCount, 1);

      service.removeApplied('job4');
      expect(service.appliedCount, 0);
      expect(service.isApplied('job4'), isFalse);
    });

    test('removeBookmark removes job', () {
      final job = createTestJob('job5', 'Go Dev');

      service.toggleBookmark(job);
      expect(service.bookmarkCount, 1);

      service.removeBookmark('job5');
      expect(service.bookmarkCount, 0);
    });

    test('bookmarkedJobs returns list of bookmarked jobs', () {
      final job1 = createTestJob('a1', 'Job A');
      final job2 = createTestJob('a2', 'Job B');

      service.toggleBookmark(job1);
      service.toggleBookmark(job2);

      final jobs = service.bookmarkedJobs;
      expect(jobs.length, 2);
    });

    test('appliedJobs returns list of applied jobs', () {
      final job1 = createTestJob('b1', 'Job X');
      final job2 = createTestJob('b2', 'Job Y');

      service.markApplied(job1);
      service.markApplied(job2);

      final jobs = service.appliedJobs;
      expect(jobs.length, 2);
    });
  });
}
