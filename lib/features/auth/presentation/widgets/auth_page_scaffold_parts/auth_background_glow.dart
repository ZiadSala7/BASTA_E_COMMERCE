part of '../auth_page_scaffold.dart';

class _AuthBackgroundGlow extends StatelessWidget {
  const _AuthBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -110,
          child: _GlowCircle(
            size: 290,
            colors: [
              isDark ? const Color(0x335B5BD6) : const Color(0x245B5BD6),
              const Color(0x00FFFFFF),
            ],
          ),
        ),
        Positioned(
          bottom: -150,
          left: -120,
          child: _GlowCircle(
            size: 320,
            colors: [
              isDark ? const Color(0x3320B7A8) : const Color(0x2220B7A8),
              const Color(0x00FFFFFF),
            ],
          ),
        ),
        Positioned(
          top: 140,
          left: -80,
          child: _GlowCircle(
            size: 190,
            colors: [
              isDark ? const Color(0x22FF6B35) : const Color(0x18FF6B35),
              const Color(0x00FFFFFF),
            ],
          ),
        ),
      ],
    );
  }
}
