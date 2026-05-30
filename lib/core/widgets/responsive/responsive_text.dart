import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';

/// Responsive text widget that automatically scales based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final double? lineHeight;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
    this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize =
        ResponsiveUtils.getResponsiveFontSize(context, fontSize);

    final textStyle = style ??
        TextStyle(
          fontSize: responsiveFontSize,
          fontWeight: fontWeight,
          color: color,
          height: lineHeight,
        );

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }
}