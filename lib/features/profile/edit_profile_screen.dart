import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../services/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthState>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    await context.read<AuthState>().updateProfile(
      displayName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  Consumer<AuthState>(
                    builder: (context, auth, _) {
                      final initial = (auth.user?.displayName ?? 'U').substring(0, 1).toUpperCase();
                      return Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20)],
                        ),
                        child: Center(child: Text(initial, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white))),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Tap fields below to edit', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            _buildField('Display Name', _nameController, Iconsax.user, delay: 200),
            const SizedBox(height: 16),
            _buildField('Email', _emailController, Iconsax.sms, delay: 300, readOnly: true),
            const SizedBox(height: 16),
            _buildField('Phone Number', _phoneController, Iconsax.call, delay: 400, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildField('Bio', _bioController, Iconsax.edit_2, delay: 500, maxLines: 3),
            const SizedBox(height: 32),

            GradientButton(
              text: 'Save Changes',
              icon: Iconsax.tick_circle,
              isLoading: _isSaving,
              onPressed: _save,
              width: double.infinity,
            ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {
    int delay = 0, bool readOnly = false, TextInputType? keyboardType, int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: readOnly ? AppColors.textMuted : AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: readOnly ? AppColors.surface : AppColors.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
            suffixIcon: readOnly
                ? const Tooltip(message: 'Email cannot be changed', child: Icon(Iconsax.lock, color: AppColors.textMuted, size: 16))
                : null,
          ),
        ),
      ],
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideX(begin: -0.03, end: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
