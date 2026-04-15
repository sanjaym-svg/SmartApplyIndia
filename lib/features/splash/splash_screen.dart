import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/app_shell.dart';
import '../../features/auth/login_screen.dart';
import '../../services/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final authState = context.read<AuthState>();
      final destination = authState.isAuthenticated
          ? const AppShell()
          : const LoginScreen();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 48),
            ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut).fadeIn(duration: 400.ms),
            const SizedBox(height: 28),
            const Text('SmartApply', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1))
                .animate(delay: 300.ms).fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0, duration: 500.ms),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
              child: const Text('INDIA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 8)),
            ).animate(delay: 500.ms).fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0, duration: 500.ms),
            const SizedBox(height: 16),
            const Text('AI-Powered Job Matching for Freshers', style: TextStyle(fontSize: 14, color: AppColors.textMuted))
                .animate(delay: 700.ms).fadeIn(duration: 500.ms),
            const SizedBox(height: 48),
            SizedBox(
              width: 32, height: 32,
              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2.5, backgroundColor: AppColors.surfaceLight),
            ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
