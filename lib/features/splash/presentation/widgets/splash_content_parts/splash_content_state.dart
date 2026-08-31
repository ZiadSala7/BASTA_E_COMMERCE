part of '../splash_content.dart';

class _SplashContentState extends State<SplashContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mainCtrl;

  // Background Ambience Animation
  late final Animation<double> _blobOpacity;
  late final Animation<double> _blobScale;

  // Logo Animations
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  // Text Animations
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // Bottom Loading / Footer Animation
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _mainCtrl.forward();
  }

  void _setupAnimations() {
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // ── Ambient Background Glow (0% -> 50%) ──────────────────────────────
    _blobOpacity = Tween<double>(begin: 0.0, end: 0.55).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _blobScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // ── Logo Reveal (0% -> 60%) ──────────────────────────────────────────
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.05, 0.45, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.05, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // ── Typography Slide & Fade (35% -> 80%) ─────────────────────────────
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // ── Footer / Loader Reveal (55% -> 100%) ─────────────────────────────
    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFD),
              Color(0xFFEFF4FC),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Top-Right Ambient Blob ──────────────────────────────────
            TopRightBlob(
              size: size,
              topBlobSlide: const AlwaysStoppedAnimation(Offset.zero),
              topBlobOpacity: _blobOpacity,
              topBlobScale: _blobScale,
            ),

            // ── Bottom-Left Ambient Blob ────────────────────────────────
            BottomLeftBlob(
              size: size,
              bottomBlobSlide: const AlwaysStoppedAnimation(Offset.zero),
              bottomBlobOpacity: _blobOpacity,
              bottomBlobScale: _blobScale,
            ),

            // ── Center Content (Logo + Brand Text) ──────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Card with Spring Entrance
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const LogoWidget(size: 138),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Brand Typography with Smooth Slide & Fade
                    FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'بسطة  |  BASTA',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.6,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'تجربة تسوق فريدة وسريعة',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Loading Indicator & Brand Promise ────────────────
            Positioned(
              bottom: 44,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _footerOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'تسوق آمن وموثوق • الإصدار 1.0',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
