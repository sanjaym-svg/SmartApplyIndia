import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../navigation/app_shell.dart';
import '../../services/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthState>().clearError();
    });
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthState>();
    final success = await authState.signUpWithEmail(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    }
  }

  void _googleSignup() async {
    final authState = context.read<AuthState>();
    final success = await authState.signInWithGoogle();
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
                    ),
                    child: const Icon(Iconsax.user_add, color: Colors.white, size: 32),
                  ).animate().scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 22),
                  const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5))
                      .animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 6),
                  const Text('Join SmartApply and find your dream job', style: TextStyle(fontSize: 14, color: AppColors.textMuted))
                      .animate(delay: 300.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 32),

                  // Name
                  _field(_nameController, 'Full Name', Iconsax.user, delay: 400,
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 14),
                  // Email
                  _field(_emailController, 'Email address', Iconsax.sms, delay: 500,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Password
                  _field(_passwordController, 'Password', Iconsax.lock, delay: 600,
                    obscure: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye, color: AppColors.textMuted, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter a password';
                      if (v.length < 6) return 'Password must be 6+ characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Confirm
                  _field(_confirmController, 'Confirm Password', Iconsax.lock, delay: 700,
                    obscure: _obscureConfirm,
                    suffix: IconButton(
                      icon: Icon(_obscureConfirm ? Iconsax.eye_slash : Iconsax.eye, color: AppColors.textMuted, size: 20),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirm your password';
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Error
                  Consumer<AuthState>(
                    builder: (context, auth, _) {
                      if (auth.errorMessage == null) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity, margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
                        child: Text(auth.errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                      );
                    },
                  ),

                  // Signup button
                  Consumer<AuthState>(
                    builder: (context, auth, _) => GradientButton(
                      text: 'Create Account',
                      icon: Iconsax.tick_circle,
                      isLoading: auth.isLoading,
                      onPressed: _signup,
                      width: double.infinity,
                      gradient: AppColors.accentGradient,
                    ),
                  ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),

                  // Divider
                  Row(children: [
                    Expanded(child: Divider(color: AppColors.border)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('or', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
                    Expanded(child: Divider(color: AppColors.border)),
                  ]).animate(delay: 850.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 20),

                  // Google
                  GestureDetector(
                    onTap: _googleSignup,
                    child: Container(
                      width: double.infinity, height: 52,
                      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text('Continue with Google', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 28),

                  // Login link
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Already have an account? ', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Sign In', style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ]).animate(delay: 950.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {
    int delay = 0, TextInputType? keyboardType, bool obscure = false,
    Widget? suffix, String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl, keyboardType: keyboardType, obscureText: obscure, validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20), suffixIcon: suffix),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0, duration: 400.ms);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
