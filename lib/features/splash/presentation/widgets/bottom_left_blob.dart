import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import 'blob_widget.dart';

class BottomLeftBlob extends StatelessWidget {
  const BottomLeftBlob({
    super.key,
    required this.size,
    required Animation<Offset> bottomBlobSlide,
    required Animation<double> bottomBlobOpacity,
    required Animation<double> bottomBlobScale,
  }) : _bottomBlobSlide = bottomBlobSlide,
       _bottomBlobOpacity = bottomBlobOpacity,
       _bottomBlobScale = bottomBlobScale;

  final Size size;
  final Animation<Offset> _bottomBlobSlide;
  final Animation<double> _bottomBlobOpacity;
  final Animation<double> _bottomBlobScale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -size.height * 0.1,
      left: -size.width * 0.18,
      child: SlideTransition(
        position: _bottomBlobSlide,
        child: FadeTransition(
          opacity: _bottomBlobOpacity,
          child: ScaleTransition(
            scale: _bottomBlobScale,
            child: BlobWidget(
              size: size.width * 0.82,
              colors: const [
                AppColors.blobBottomStart,
                AppColors.blobBottomMid,
                AppColors.blobBottomEnd,
              ],
              stops: const [0.0, 0.35, 0.75],
              center: const Alignment(0.2, 0.2),
            ),
          ),
        ),
      ),
    );
  }
}
