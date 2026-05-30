// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/responsive/responsive_text.dart';
import '../../../../core/widgets/responsive/responsive_sized_box.dart';
import '../../../../core/widgets/responsive/responsive_logo.dart';
import '../../../../core/responsive/responsive_utils.dart';

class EnhancedSplashPage extends StatefulWidget {
  const EnhancedSplashPage({super.key});

  @override
  State<EnhancedSplashPage> createState() => _EnhancedSplashPageState();
}

class _EnhancedSplashPageState extends State<EnhancedSplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Simulate loading and navigate to next screen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Background Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      Color(0xFF7C86FF),
                      Color(0xFF9D8EFF),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // Animated Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with animation - using responsive logo
                    const ResponsiveLogo(
                      icon: Icons.shopping_bag,
                      baseSize: 120.0,
                      color: AppColors.primary,
                      backgroundColor: Colors.white,
                      minWidth: 80.0,
                      maxWidth: 150.0,
                    ),
                    const ResponsiveSizedBox(height: 24),

                    // App Name - using responsive text
                    const ResponsiveText(
                      'Busta',
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      lineHeight: 1.2,
                    ),
                    const ResponsiveSizedBox(height: 8),

                    // Tagline - using responsive text
                    ResponsiveText(
                      'Your Shopping Destination',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Indicator
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSize(context, 30),
                  height: ResponsiveUtils.getResponsiveSize(context, 30),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                    strokeWidth: ResponsiveUtils.getResponsiveSize(context, 2),
                  ),
                ),
                const ResponsiveSizedBox(height: 16),
                ResponsiveText(
                  'Loading...',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),

          // Version Info
          Positioned(
            bottom: ResponsiveUtils.getResponsiveSize(context, 20),
            left: 0,
            right: 0,
            child: ResponsiveText(
              'Version 1.0.0',
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
