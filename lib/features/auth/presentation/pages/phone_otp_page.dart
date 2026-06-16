import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_spacing.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/drop_logo.dart';
import 'package:fbro/features/auth/presentation/animations/fade_slide_transition.dart';
import 'package:fbro/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fbro/features/auth/presentation/cubit/auth_state.dart';
import 'package:fbro/features/auth/presentation/widgets/app_button.dart';
import 'package:fbro/features/auth/presentation/widgets/app_text_field.dart';

/// Phone-number country code. Egypt (+20) is the single supported region; the
/// picker is a visual stub for now. Centralised so the prefix used to build the
/// E.164 number and the one shown in the UI can never drift apart.
const String _kDialCode = '+20';
const String _kFlag = '🇪🇬';

class PhoneOtpPage extends StatefulWidget {
  const PhoneOtpPage({super.key});

  @override
  State<PhoneOtpPage> createState() => _PhoneOtpPageState();
}

class _PhoneOtpPageState extends State<PhoneOtpPage> {
  final _phoneController = TextEditingController();
  String? _verificationId;
  int _resendCount = 0;

  // Resend cooldown timer.
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _e164 => '$_kDialCode${_phoneController.text.trim()}';

  void _sendCode() => context.read<AuthCubit>().verifyPhone(_e164);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            otpSent: (id) {
              setState(() => _verificationId = id);
              _startResendTimer();
            },
            error: (msg) => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
          );
        },
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0.08, 0), end: Offset.zero)
                    .animate(anim),
                child: child,
              ),
            ),
            child: _verificationId == null
                ? _PhoneStep(
                    key: const ValueKey('phone'),
                    controller: _phoneController,
                    isDark: isDark,
                    onSubmit: _sendCode,
                  )
                : _OtpStep(
                    key: const ValueKey('otp'),
                    phone: '$_kDialCode ${_phoneController.text.trim()}',
                    secondsLeft: _secondsLeft,
                    timerLabel: _timerLabel,
                    verificationId: _verificationId!,
                    resendCount: _resendCount,
                    isDark: isDark,
                    onResend: () {
                      setState(() => _resendCount++);
                      _sendCode();
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSubmit;

  const _PhoneStep({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          const FadeSlideTransition(
            delay: Duration(milliseconds: 30),
            child: DropLogo(height: 60),
          ),

          const SizedBox(height: AppSpacing.xxl),

          FadeSlideTransition(
            delay: const Duration(milliseconds: 60),
            child: Text(
              'Your Phone\nNumber',
              style: AppTypography.displayMedium.copyWith(
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FadeSlideTransition(
            delay: const Duration(milliseconds: 120),
            child: const Text(
              "We'll text you a 6-digit code to verify it's you.",
              style: AppTypography.bodyLarge,
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Country code + phone number.
          FadeSlideTransition(
            delay: const Duration(milliseconds: 200),
            child: Row(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(_kFlag, style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        _kDialCode,
                        style: AppTypography.label.copyWith(
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: controller,
                    label: 'Phone Number',
                    hint: '100 000 0000',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          FadeSlideTransition(
            delay: const Duration(milliseconds: 280),
            beginOffset: const Offset(0, 16),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final action =
                    state.maybeWhen(loading: (a) => a, orElse: () => null);
                return AppButton(
                  label: 'Continue',
                  isLoading: action == AuthAction.phoneVerify,
                  onPressed: action != null
                      ? null
                      : () {
                          if (controller.text.trim().isEmpty) return;
                          FocusScope.of(context).unfocus();
                          onSubmit();
                        },
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _OtpStep extends StatefulWidget {
  final String phone;
  final int secondsLeft;
  final String timerLabel;
  final String verificationId;
  final int resendCount;
  final VoidCallback onResend;
  final bool isDark;

  const _OtpStep({
    super.key,
    required this.phone,
    required this.secondsLeft,
    required this.timerLabel,
    required this.verificationId,
    required this.resendCount,
    required this.onResend,
    required this.isDark,
  });

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  final _pinController = TextEditingController();
  final _pinFocus = FocusNode();
  String _pin = '';
  bool _hasError = false;

  @override
  void didUpdateWidget(covariant _OtpStep old) {
    super.didUpdateWidget(old);
    // A new code was requested — clear the field and let the user start over.
    if (old.resendCount != widget.resendCount) {
      _pinController.clear();
      setState(() {
        _pin = '';
        _hasError = false;
      });
      _pinFocus.requestFocus();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _verify() {
    if (_pin.length != 6) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().verifyOtp(widget.verificationId, _pin);
  }

  // Monochrome Pinput themes built from the design system.
  PinTheme get _defaultTheme => PinTheme(
        width: 52,
        height: 60,
        textStyle: AppTypography.h2.copyWith(
          color: widget.isDark ? AppColors.textPrimary : AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      );

  PinTheme get _focusedTheme => PinTheme(
        width: 52,
        height: 60,
        textStyle: AppTypography.h2.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      );

  PinTheme get _submittedTheme => PinTheme(
        width: 52,
        height: 60,
        textStyle: AppTypography.h2.copyWith(
          color: widget.isDark ? AppColors.textPrimary : AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.textSecondary),
        ),
      );

  PinTheme get _errorTheme => PinTheme(
        width: 52,
        height: 60,
        textStyle: AppTypography.h2.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // Drive the inline error animation off the cubit so a rejected /
      // expired code paints every cell red (the snackbar copy explains why).
      listenWhen: (prev, curr) => curr.maybeWhen(
        error: (_) => true,
        loading: (_) => true,
        orElse: () => false,
      ),
      listener: (context, state) {
        state.maybeWhen(
          error: (_) {
            HapticFeedback.heavyImpact();
            setState(() => _hasError = true);
          },
          orElse: () {},
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            const FadeSlideTransition(
              delay: Duration(milliseconds: 30),
              child: DropLogo(height: 60),
            ),

            const SizedBox(height: AppSpacing.xxl),

            FadeSlideTransition(
              delay: const Duration(milliseconds: 60),
              child: Text(
                'Enter the\nCode',
                style: AppTypography.displayMedium.copyWith(
                  color:
                      widget.isDark ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FadeSlideTransition(
              delay: const Duration(milliseconds: 120),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodyLarge,
                  children: [
                    const TextSpan(text: 'Sent to '),
                    TextSpan(
                      text: widget.phone,
                      style: AppTypography.bodyLarge.copyWith(
                        color: widget.isDark
                            ? AppColors.textPrimary
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            FadeSlideTransition(
              delay: const Duration(milliseconds: 200),
              child: Pinput(
                length: 6,
                controller: _pinController,
                focusNode: _pinFocus,
                autofocus: true,
                defaultPinTheme: _defaultTheme,
                focusedPinTheme: _focusedTheme,
                submittedPinTheme: _submittedTheme,
                errorPinTheme: _errorTheme,
                forceErrorState: _hasError,
                // System SMS autofill (iOS QuickType one-time-code; Android
                // also auto-verifies via Firebase's verificationCompleted).
                keyboardType: TextInputType.number,
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                closeKeyboardWhenCompleted: true,
                separatorBuilder: (_) => const SizedBox(width: 8),
                onChanged: (value) {
                  setState(() {
                    _pin = value;
                    if (_hasError) _hasError = false;
                  });
                },
                // Auto-submit the moment all 6 digits are entered / autofilled.
                onCompleted: (_) => _verify(),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Resend cooldown / action.
            FadeSlideTransition(
              delay: const Duration(milliseconds: 260),
              child: Center(
                child: widget.secondsLeft > 0
                    ? Text(
                        'Resend code in ${widget.timerLabel}',
                        style: AppTypography.body,
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Didn't get it?  ",
                            style: AppTypography.body,
                          ),
                          GestureDetector(
                            onTap: widget.onResend,
                            child: Text(
                              'Resend code',
                              style: AppTypography.label
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            FadeSlideTransition(
              delay: const Duration(milliseconds: 320),
              beginOffset: const Offset(0, 16),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final action =
                      state.maybeWhen(loading: (a) => a, orElse: () => null);
                  final canVerify = _pin.length == 6 && action == null;
                  return AppButton(
                    label: 'Verify',
                    isLoading: action == AuthAction.otpVerify,
                    onPressed: canVerify ? _verify : null,
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
