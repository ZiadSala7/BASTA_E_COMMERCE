part of '../splash_content.dart';

class _SplashContentState extends State<SplashContent>
    with TickerProviderStateMixin {
  // Top-right blob controller
  late final AnimationController _topBlobCtrl;
  late final Animation<double> _topBlobOpacity;
  late final Animation<double> _topBlobScale;
  late final Animation<Offset> _topBlobSlide;

  // Bottom-left blob controller
  late final AnimationController _bottomBlobCtrl;
  late final Animation<double> _bottomBlobOpacity;
  late final Animation<double> _bottomBlobScale;
  late final Animation<Offset> _bottomBlobSlide;

  // Logo controller
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    const blobDuration = Duration(milliseconds: 900);
    const logoDuration = Duration(milliseconds: 800);
    const overshootCurve = ElasticOutCurve(0.8);

    // ── Top blob ────────────────────────────────────────────────────────────
    _topBlobCtrl = AnimationController(vsync: this, duration: blobDuration);
    _topBlobOpacity = Tween<double>(
      begin: 0,
      end: 0.39,
    ).animate(CurvedAnimation(parent: _topBlobCtrl, curve: Curves.easeOut));
    _topBlobScale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _topBlobCtrl, curve: overshootCurve));
    _topBlobSlide =
        Tween<Offset>(begin: const Offset(0.3, -0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _topBlobCtrl, curve: Curves.easeOutCubic),
        );

    // ── Bottom blob ─────────────────────────────────────────────────────────
    _bottomBlobCtrl = AnimationController(vsync: this, duration: blobDuration);
    _bottomBlobOpacity = Tween<double>(
      begin: 0,
      end: 0.39,
    ).animate(CurvedAnimation(parent: _bottomBlobCtrl, curve: Curves.easeOut));
    _bottomBlobScale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bottomBlobCtrl, curve: overshootCurve));
    _bottomBlobSlide =
        Tween<Offset>(begin: const Offset(-0.3, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _bottomBlobCtrl, curve: Curves.easeOutCubic),
        );

    // ── Logo ────────────────────────────────────────────────────────────────
    _logoCtrl = AnimationController(vsync: this, duration: logoDuration);
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const ElasticOutCurve(0.75)),
    );
  }

  Future<void> _startSequence() async {
    // Step 1 — top-right blob
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _topBlobCtrl.forward();

    // Step 2 — bottom-left blob
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _bottomBlobCtrl.forward();

    // Step 3 — logo
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _logoCtrl.forward();
  }

  @override
  void dispose() {
    _topBlobCtrl.dispose();
    _bottomBlobCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Top-right blob ───────────────────────────────────────────────
          TopRightBlob(
            size: size,
            topBlobSlide: _topBlobSlide,
            topBlobOpacity: _topBlobOpacity,
            topBlobScale: _topBlobScale,
          ),

          // ── Bottom-left blob ─────────────────────────────────────────────
          BottomLeftBlob(
            size: size,
            bottomBlobSlide: _bottomBlobSlide,
            bottomBlobOpacity: _bottomBlobOpacity,
            bottomBlobScale: _bottomBlobScale,
          ),

          // ── Logo ─────────────────────────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: const LogoWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
