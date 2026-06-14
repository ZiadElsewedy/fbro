import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fbro/core/routes/route_names.dart';
import 'package:fbro/core/theme/app_colors.dart';
import 'package:fbro/core/theme/app_spacing.dart';
import 'package:fbro/core/theme/app_typography.dart';
import 'package:fbro/core/widgets/fbro_logo.dart';
import 'package:fbro/features/auth/presentation/animations/fade_slide_transition.dart';
import 'package:fbro/features/auth/presentation/widgets/app_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),

                  // Logo mark
                  const FadeSlideTransition(
                    delay: Duration(milliseconds: 100),
                    child: FbroLogo(fontSize: 28),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Headline
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 200),
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.display.copyWith(
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textDark,
                        ),
                        children: [
                          const TextSpan(text: 'Your world,\nbeautifully\n'),
                          const TextSpan(text: 'connected.'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'Share moments, follow the people you love,\nand make every connection count.',
                      style: AppTypography.bodyLarge,
                    ),
                  ),

                  const Spacer(),

                  // CTA buttons
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 450),
                    beginOffset: const Offset(0, 16),
                    child: AppButton(
                      label: 'Get Started',
                      onPressed: () => context.push(RouteNames.register),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 520),
                    beginOffset: const Offset(0, 16),
                    child: AppButton.ghost(
                      label: 'Already have an account?  Sign In',
                      onPressed: () => context.push(RouteNames.login),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
