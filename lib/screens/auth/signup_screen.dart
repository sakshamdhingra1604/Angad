import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _loading     = false;
  double _strength  = 0;

  void _onPasswordChanged(String val) {
    double s = 0;
    if (val.length >= 8) s += 0.25;
    if (val.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (val.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (val.contains(RegExp(r'[!@#\$%^&*]'))) s += 0.25;
    setState(() => _strength = s);
  }

  Future<void> _signup() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return AppColors.threatRed;
    if (_strength <= 0.5)  return AppColors.amber;
    if (_strength <= 0.75) return AppColors.gold;
    return AppColors.safeGreen;
  }

  String get _strengthLabel {
    if (_strength <= 0.25) return 'Weak';
    if (_strength <= 0.5)  return 'Fair';
    if (_strength <= 0.75) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── Back + Brand ──────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textSecondary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/images/gada.jpg',
                        width: 38, height: 38, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  const Text('ANGAD',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: AppColors.textPrimary)),
                ],
              ),

              const SizedBox(height: 36),

              Text('Create account',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('Set up your Digital Kavach',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textMuted)),

              const SizedBox(height: 32),

              // ── Full Name ─────────────────────────────────────────
              _InputLabel('Full Name'),
              const SizedBox(height: 8),
              _Field(
                controller: _nameCtrl,
                hint: 'Your name',
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 18),

              // ── Email ─────────────────────────────────────────────
              _InputLabel('Email address'),
              const SizedBox(height: 8),
              _Field(
                controller: _emailCtrl,
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // ── Password ──────────────────────────────────────────
              _InputLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                onChanged: _onPasswordChanged,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Min 8 characters',
                  hintStyle: const TextStyle(
                      color: AppColors.textHint, fontSize: 14),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.lock_outline_rounded,
                        color: AppColors.textMuted, size: 18),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      child: Icon(
                        _obscurePass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  filled: true,
                  fillColor: AppColors.charcoalLight,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.saffron, width: 1.5)),
                ),
              ),

              // ── Password strength meter ───────────────────────────
              if (_passCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _strength,
                          minHeight: 4,
                          backgroundColor: AppColors.charcoalLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _strengthColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(_strengthLabel,
                        style: TextStyle(
                            color: _strengthColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],

              const SizedBox(height: 28),

              // ── Sign Up button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor:
                        AppColors.saffron.withValues(alpha: 0.5),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Create Account',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 28),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushReplacementNamed('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account?  ',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                              color: AppColors.saffron,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(icon, color: AppColors.textMuted, size: 18),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.charcoalLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.saffron, width: 1.5)),
      ),
    );
  }
}
