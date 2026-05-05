import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:stylesync/core/theme/app_typography.dart";
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/responsive_helper.dart';
import 'dart:math';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Background animation (8s continuous)
    _bgCtrl = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Page controller with proper initial settings
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_onPageChanged);
  }

  /// Handle page change events
  void _onPageChanged() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  /// Navigate to next page
  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to previous page (for back button)
  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to login page
  void _goToLogin() {
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _bgCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: _currentPage == 0, // Allow back navigation only on first page
      onPopInvoked: (didPop) {
        if (!didPop && _currentPage > 0) {
          // Handle back navigation within carousel
          _goToPreviousPage();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.kBg,
        body: Stack(
          children: [
            // Layer 1: Animated background with orbs + grid
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BackgroundPainter(
                      progress: _bgCtrl.value,
                      size: size,
                    ),
                  );
                },
              ),
            ),

            // Layer 2: PageView Carousel
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              children: [
                // Page 1: Hero Intro
                _buildPage1(context),
                // Page 2: Key Features
                _buildPage2(context),
                // Page 3: Stats + CTA
                _buildPage3(context),
              ],
            ),

            // Layer 3: Bottom pagination + buttons
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pagination dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 28 : 8,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.kPrimary
                                  : AppColors.kBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action buttons (only on last page)
                      if (_currentPage == 2) ...[
                        ElevatedButton(
                          onPressed: _goToLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimary,
                            foregroundColor: AppColors.kBg,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Get Started →',
                            style: AppTypography.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _goToNextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kPrimary,
                              foregroundColor: AppColors.kBg,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Next →',
                              style: AppTypography.orbitron(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build StyleSync Logo with icon and text
  Widget _buildStyleSyncLogo(double logoDimension) {
    return Container(
      width: logoDimension,
      height: logoDimension,
      padding: EdgeInsets.all(logoDimension * 0.15),
      decoration: BoxDecoration(
        color: AppColors.kCard.withOpacity(0.4),
        borderRadius: BorderRadius.circular(logoDimension * 0.15),
        border: Border.all(
          color: AppColors.kGold.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.kGold.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.content_cut,
            size: logoDimension * 0.35,
            color: AppColors.kGold,
          ),
          SizedBox(height: logoDimension * 0.12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'StyleSync',
              textAlign: TextAlign.center,
              style: AppTypography.orbitron(
                fontSize: logoDimension * 0.28,
                fontWeight: FontWeight.w900,
                color: AppColors.kGold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 1: Hero Intro
  Widget _buildPage1(BuildContext context) {
    final logoDimension = ResponsiveHelper.isSmallDevice(context) ? 240.0 : 300.0;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Venture badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.kTeal.withOpacity(0.08),
                border: Border.all(
                  color: AppColors.kTeal.withOpacity(0.25),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.kTeal,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.kTeal.withOpacity(0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AR-Powered Barber Discovery',
                    style: AppTypography.inter(
                      fontSize: 10,
                      color: AppColors.kTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Complete StyleSync Logo with text - LARGE AND PROMINENT
            _buildStyleSyncLogo(logoDimension),
            const SizedBox(height: 16),
            // Hero headline and description
            Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Your Cut,\n',
                        style: AppTypography.orbitron(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.kText,
                        ),
                      ),
                      TextSpan(
                        text: 'Your Time.',
                        style: AppTypography.orbitron(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Skip the guessing game.\nDiscover top barbers near you instantly.',
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    fontSize: 14,
                    color: AppColors.kMuted,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // PAGE 2: Key Features
  Widget _buildPage2(BuildContext context) {
    final logoDimension = ResponsiveHelper.isSmallDevice(context) ? 240.0 : 300.0;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Complete StyleSync Logo with text - LARGE AND PROMINENT
            _buildStyleSyncLogo(logoDimension),
            const SizedBox(height: 16),
            // Title and subtitle
            Column(
              children: [
                Text(
                  'Powerful Features',
                  style: AppTypography.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.kText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Everything you need for the perfect cut',
                  style: AppTypography.inter(
                    fontSize: 13,
                    color: AppColors.kMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Features list
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFeatureItem(
                    emoji: '⏱',
                    title: 'Live Queue Info',
                    description: 'Know exactly how long you\'ll wait before you arrive',
                    bgColor: AppColors.kPrimary,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    emoji: '✂',
                    title: 'Book in Seconds',
                    description: 'Secure your spot with one tap. No more phone calls.',
                    bgColor: AppColors.kTeal,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    emoji: '📷',
                    title: 'AR Try-On Magic',
                    description: 'See how a style looks on YOU before you commit',
                    bgColor: AppColors.kGold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE 3: Stats + CTA
  Widget _buildPage3(BuildContext context) {
    final logoDimension = ResponsiveHelper.isSmallDevice(context) ? 240.0 : 300.0;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Complete StyleSync Logo with text - LARGE AND PROMINENT
            _buildStyleSyncLogo(logoDimension),
            const SizedBox(height: 16),
            // Title and subtitle
            Column(
              children: [
                Text(
                  'Join Our Community',
                  style: AppTypography.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.kText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Trusted by thousands in Davao',
                  style: AppTypography.inter(
                    fontSize: 13,
                    color: AppColors.kMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats and badges
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('500+', 'Barbers'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('4.9★', 'Rating'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Live', 'Queue'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Feature item
  Widget _buildFeatureItem({
    required String emoji,
    required String title,
    required String description,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kCard.withOpacity(0.6),
        border: Border.all(
          color: bgColor.withOpacity(0.4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.15),
              border: Border.all(
                color: bgColor.withOpacity(0.4),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: bgColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.inter(
                    fontSize: 11,
                    color: AppColors.kMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Stat card
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kCard.withOpacity(0.5),
        border: Border.all(
          color: AppColors.kBorder.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.kGold.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.kGold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.inter(
              fontSize: 11,
              color: AppColors.kMuted,
            ),
          ),
        ],
      ),
    );
  }
}



/// Background painter with orbs + grid
class BackgroundPainter extends CustomPainter {
  final double progress;
  final Size size;

  BackgroundPainter({required this.progress, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Orb 1: top-left, magenta (increased visibility)
    final orb1X = size.width * 0.15 + sin(progress * 2 * pi) * 25;
    final orb1Y = size.height * 0.25 + cos(progress * 2 * pi) * 25;
    canvas.drawCircle(
      Offset(orb1X, orb1Y),
      80,
      Paint()
        ..color = AppColors.kPrimary.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
    );

    // Orb 2: bottom-right, teal (increased visibility)
    final orb2X = size.width * 0.85 + sin(progress * 2 * pi + pi) * 25;
    final orb2Y = size.height * 0.75 + cos(progress * 2 * pi + pi) * 25;
    canvas.drawCircle(
      Offset(orb2X, orb2Y),
      100,
      Paint()
        ..color = AppColors.kTeal.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
    );

    // Orb 3: center, gold (increased visibility)
    final orb3X = size.width * 0.5 + sin(progress * 2 * pi + pi / 2) * 20;
    final orb3Y = size.height * 0.5 + cos(progress * 2 * pi + pi / 2) * 20;
    canvas.drawCircle(
      Offset(orb3X, orb3Y),
      70,
      Paint()
        ..color = AppColors.kGold.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );

    // Diagonal grid lines (45deg, 48px spacing) - increased visibility
    const gridSpacing = 48.0;
    final gridPaint = Paint()
      ..color = AppColors.kPrimary.withOpacity(0.08)
      ..strokeWidth = 1.2;

    // Draw diagonal grid
    for (double i = -size.height;
        i < size.width + size.height;
        i += gridSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
