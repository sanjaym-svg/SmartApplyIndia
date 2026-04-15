import 'package:flutter_test/flutter_test.dart';
import 'package:smartapply_india/services/resume_service.dart';

void main() {
  group('ResumeService', () {
    late ResumeService service;

    setUp(() {
      service = ResumeService();
      service.clearResume();
    });

    test('initial state has no resume', () {
      expect(service.hasResume, isFalse);
      expect(service.resumeText, isEmpty);
      expect(service.fileName, isEmpty);
      expect(service.extractedSkills, isEmpty);
    });

    test('setResumeText sets text and extracts skills', () {
      service.setResumeText(
        'Experienced Flutter and Dart developer with Python and Machine Learning skills. '
        'Expert in Firebase, REST API, and Git. Good at React and JavaScript.',
      );
      expect(service.hasResume, isTrue);
      expect(service.fileName, 'Pasted Resume');
      expect(service.extractedSkills, isNotEmpty);
      expect(service.extractedSkills, contains('Flutter'));
      expect(service.extractedSkills, contains('Dart'));
      expect(service.extractedSkills, contains('Python'));
      expect(service.extractedSkills, contains('Firebase'));
    });

    test('clearResume resets all data', () {
      service.setResumeText('Flutter developer resume with Dart and Python');
      expect(service.hasResume, isTrue);

      service.clearResume();
      expect(service.hasResume, isFalse);
      expect(service.resumeText, isEmpty);
      expect(service.fileName, isEmpty);
      expect(service.extractedSkills, isEmpty);
    });

    test('skill extraction is case insensitive', () {
      service.setResumeText('I know flutter, PYTHON, and javaScript');
      expect(service.extractedSkills, contains('Flutter'));
      expect(service.extractedSkills, contains('Python'));
      expect(service.extractedSkills, contains('JavaScript'));
    });

    test('atsScore returns reasonable value', () {
      service.setResumeText(
        'Flutter Dart Python Java React Angular Node.js JavaScript TypeScript Docker Kubernetes AWS',
      );
      expect(service.atsScore, greaterThan(0));
      expect(service.atsScore, lessThanOrEqualTo(100));
    });

    test('atsScore is 0 when no resume', () {
      expect(service.atsScore, 0);
    });

    test('isAiAvailable reflects Groq API key state', () {
      // Groq key is configured in env.dart so should be available
      expect(service.isAiAvailable, isTrue);
    });
  });
}
