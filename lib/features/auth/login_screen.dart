import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../navigation/app_shell.dart';
import '../../services/auth_state.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthState>().clearError();
    });
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthState>();
    final success = await authState.signInWithEmail(
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

  void _googleLogin() async {
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
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 38),
                  ).animate().scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5))
                      .animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 6),
                  const Text('Sign in to continue your job search', style: TextStyle(fontSize: 14, color: AppColors.textMuted))
                      .animate(delay: 300.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 36),

                  // Mock mode badge
                  Consumer<AuthState>(
                    builder: (context, auth, _) {
                      if (!auth.isMockMode) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.info_circle, color: AppColors.info, size: 16),
                            SizedBox(width: 8),
                            Text('Demo Mode — any email/password works', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.info)),
                          ],
                        ),
                      ).animate(delay: 350.ms).fadeIn(duration: 300.ms);
                    },
                  ),

                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email address',
                    icon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0, duration: 400.ms),
                  const SizedBox(height: 14),

                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Iconsax.lock,
                    obscure: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye, color: AppColors.textMuted, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your password';
                      if (v.length < 6) return 'Password must be 6+ characters';
                      return null;
                    },
                  ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0, duration: 400.ms),
                  const SizedBox(height: 8),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Error message
                  Consumer<AuthState>(
                    builder: (context, auth, _) {
                      if (auth.errorMessage == null) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Text(auth.errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                      );
                    },
                  ),

                  // Login button
                  Consumer<AuthState>(
                    builder: (context, auth, _) {
                      return GradientButton(
                        text: 'Sign In',
                        icon: Iconsax.login,
                        isLoading: auth.isLoading,
                        onPressed: _login,
                        width: double.infinity,
                      );
                    },
                  ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
                  const SizedBox(height: 20),

                  // Divider
                  Row(children: [
                    Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('or', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
                    Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                  ]).animate(delay: 700.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 20),

                  // Google sign in
                  _buildSocialButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata_rounded,
                    onTap: _googleLogin,
                  ).animate(delay: 800.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
                  const SizedBox(height: 32),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
                        child: const Text('Sign Up', style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
