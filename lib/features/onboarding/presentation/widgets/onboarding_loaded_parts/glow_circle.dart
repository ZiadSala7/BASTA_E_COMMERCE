part of '../onboarding_loaded.dart';

class _GlowCircle extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowCircle({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
