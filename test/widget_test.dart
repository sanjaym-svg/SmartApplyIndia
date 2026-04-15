import 'package:flutter_test/flutter_test.dart';
import 'package:smartapply_india/services/auth_service.dart';
import 'package:smartapply_india/models/job_model.dart';

void main() {
  test('SmartApply AppUser model works correctly', () {
    final user = AppUser.mock(email: 'test@smartapply.in', name: 'Tester');
    expect(user.email, 'test@smartapply.in');
    expect(user.displayName, 'Tester');
  });

  test('Job model getMockJobs returns non-empty list', () {
    final jobs = Job.getMockJobs();
    expect(jobs, isNotEmpty);
    expect(jobs.length, 8);
    expect(jobs.first.title, 'Flutter Developer');
  });

  test('Job serialization roundtrip works', () {
    final job = Job.getMockJobs().first;
    final json = job.toJson();
    final restored = Job.fromJson(json);
    expect(restored.id, job.id);
    expect(restored.title, job.title);
    expect(restored.company, job.company);
  });
}
