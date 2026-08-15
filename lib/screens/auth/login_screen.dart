import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _loading     = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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
              const SizedBox(height: 36),

              // ── Brand header ─────────────────────────────────────
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/gada.jpg',
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ANGAD',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Your Digital Kavach',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gold,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              Text('Welcome back',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('Sign in to continue protecting your device',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textMuted)),

              const SizedBox(height: 36),

              // ── Email ────────────────────────────────────────────
              _InputLabel('Email address'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15),
                decoration: _inputDecor(
                  hint: 'you@example.com',
                  prefix: const Icon(Icons.mail_outline_rounded,
                      color: AppColors.textMuted, size: 18),
                ),
              ),

              const SizedBox(height: 18),

              // ── Password ─────────────────────────────────────────
              _InputLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15),
                decoration: _inputDecor(
                  hint: '••••••••',
                  prefix: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.textMuted, size: 18),
                  suffix: GestureDetector(
                    onTap: () => setState(() => _obscurePass = !_obscurePass),
                    child: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed('/forgot-password'),
                  child: Text('Forgot password?',
                      style: TextStyle(
                          color: AppColors.saffron,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 28),

              // ── Sign In button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
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
                      : const Text('Sign In',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),

              // ── Divider ──────────────────────────────────────────
              Row(children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ]),

              const SizedBox(height: 20),

              // ── Social logins ────────────────────────────────────
              Row(children: [
                Expanded(
                    child: _SocialBtn(
                        label: 'Google', icon: Icons.g_mobiledata_rounded)),
                const SizedBox(width: 12),
                Expanded(
                    child: _SocialBtn(
                        label: 'Phone', icon: Icons.phone_android_rounded)),
              ]),

              const SizedBox(height: 32),

              // ── Sign up link ─────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushReplacementNamed('/signup'),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account?  ",
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
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

  InputDecoration _inputDecor({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: AppColors.textHint, fontSize: 14),
      prefixIcon: prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: prefix),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffix == null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: suffix),
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SocialBtn({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: AppColors.textSecondary),
      label: Text(label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 13),
        side: const BorderSide(color: AppColors.border),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
