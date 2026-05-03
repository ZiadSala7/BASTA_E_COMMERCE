import 'package:flutter/material.dart';

/// A soft radial-gradient circle used as the splash background blob.
class BlobWidget extends StatelessWidget {
  const BlobWidget({
    required this.size,
    required this.colors,
    required this.stops,
    super.key,
    this.center = Alignment.center,
  });

  final double size;
  final List<Color> colors;
  final List<double> stops;
  final AlignmentGeometry center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: center,
            radius: 0.8,
            colors: [...colors, colors.last.withAlpha(0)],
            stops: [...stops, 1.0],
          ),
        ),
      ),
    );
  }
}
