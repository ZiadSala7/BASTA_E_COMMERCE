import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import 'blob_widget.dart';

class TopRightBlob extends StatelessWidget {
  const TopRightBlob({
    super.key,
    required this.size,
    required Animation<Offset> topBlobSlide,
    required Animation<double> topBlobOpacity,
    required Animation<double> topBlobScale,
  }) : _topBlobSlide = topBlobSlide,
       _topBlobOpacity = topBlobOpacity,
       _topBlobScale = topBlobScale;

  final Size size;
  final Animation<Offset> _topBlobSlide;
  final Animation<double> _topBlobOpacity;
  final Animation<double> _topBlobScale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -size.height * 0.12,
      right: -size.width * 0.18,
      child: SlideTransition(
        position: _topBlobSlide,
        child: FadeTransition(
          opacity: _topBlobOpacity,
          child: ScaleTransition(
            scale: _topBlobScale,
            child: BlobWidget(
              size: size.width * 0.85,
              colors: const [
                AppColors.blobTopStart,
                AppColors.blobTopMid,
                AppColors.blobTopEnd,
              ],
              stops: const [0.0, 0.35, 0.75],
              center: const Alignment(-0.2, -0.2),
            ),
          ),
        ),
      ),
    );
  }
}
