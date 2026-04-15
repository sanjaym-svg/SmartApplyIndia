import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartapply_india/features/profile/about_screen.dart';
import 'package:smartapply_india/features/profile/help_screen.dart';

void main() {
  // Disable flutter_animate in tests so animations complete instantly
  setUp(() {
    Animate.restartOnHotReload = false;
  });

  group('HelpScreen', () {
    testWidgets('renders FAQ title and questions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const HelpScreen(),
        ),
      );
      // Use pump with a long duration to flush all animations
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('Find answers to common questions'), findsOneWidget);
      expect(find.text('How does SmartApply match me with jobs?'), findsOneWidget);
      expect(find.text('How do I upload my resume?'), findsOneWidget);
    });

    testWidgets('renders contact support section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const HelpScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('Contact Support'), findsOneWidget);
      expect(find.text('Email Support'), findsOneWidget);
    });
  });

  group('AboutScreen', () {
    testWidgets('renders app name and version', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const AboutScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('SmartApply India'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('renders features and tech info', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const AboutScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('Key Features'), findsOneWidget);
      expect(find.text('Built With'), findsOneWidget);
      expect(find.text('Flutter & Dart'), findsOneWidget);
    });

    testWidgets('renders legal links', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const AboutScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Open Source Licenses'), findsOneWidget);
    });

    testWidgets('renders footer text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const AboutScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 5));

      expect(find.textContaining('Made with'), findsOneWidget);
      expect(find.text('© 2026 SmartApply India'), findsOneWidget);
    });
  });
}
