import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum _OtpStep { email, otp, reset }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _OtpStep _step  = _OtpStep.email;
  bool _loading   = false;
  final _emailCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _obscure   = true;

  Future<void> _next() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _step = switch (_step) {
        _OtpStep.email => _OtpStep.otp,
        _OtpStep.otp   => _OtpStep.reset,
        _OtpStep.reset => _OtpStep.reset,
      };
    });
    if (_step == _OtpStep.reset && mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── Back ─────────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  if (_step == _OtpStep.email) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() => _step = _OtpStep.email);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text('Back',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Step indicator ────────────────────────────────────
              Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _step.index == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _step.index >= i
                            ? AppColors.saffron
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 6),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // ── Content switches per step ────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),

              const Spacer(),

              // ── CTA button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor:
                        AppColors.saffron.withValues(alpha: 0.4),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(_btnLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case _OtpStep.email:
        return Column(
          key: const ValueKey('email'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forgot Password?',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Enter your registered email. We\'ll send you a verification code.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted, height: 1.5)),
            const SizedBox(height: 32),
            _FieldLabel('Email address'),
            const SizedBox(height: 8),
            _StyledField(
              controller: _emailCtrl,
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
              keyboard: TextInputType.emailAddress,
            ),
          ],
        );

      case _OtpStep.otp:
        return Column(
          key: const ValueKey('otp'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter OTP',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.5),
                children: [
                  const TextSpan(text: 'Code sent to  '),
                  TextSpan(
                    text: _emailCtrl.text.isEmpty
                        ? 'your email'
                        : _emailCtrl.text,
                    style: const TextStyle(
                        color: AppColors.saffron,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _FieldLabel('6-digit OTP'),
            const SizedBox(height: 8),
            _StyledField(
              controller: _otpCtrl,
              hint: '• • • • • •',
              icon: Icons.verified_outlined,
              keyboard: TextInputType.number,
              maxLen: 6,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {},
              child: Text('Resend code',
                  style: TextStyle(
                      color: AppColors.saffron,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        );

      case _OtpStep.reset:
        return Column(
          key: const ValueKey('reset'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Password',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Choose a strong password for your account.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 32),
            _FieldLabel('New password'),
            const SizedBox(height: 8),
            TextField(
              controller: _newPassCtrl,
              obscureText: _obscure,
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
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure
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
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.saffron, width: 1.5)),
              ),
            ),
          ],
        );
    }
  }

  String get _btnLabel => switch (_step) {
        _OtpStep.email => 'Send OTP',
        _OtpStep.otp   => 'Verify OTP',
        _OtpStep.reset => 'Reset Password',
      };
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600));
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final int? maxLen;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.maxLen,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLength: maxLen,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
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
