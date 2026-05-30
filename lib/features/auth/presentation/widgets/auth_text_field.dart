import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/responsive/responsive_utils.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.16
                  : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: inputTheme.hintStyle,
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSize(context, 18),
            vertical: ResponsiveUtils.getResponsiveSize(context, 18),
          ),
          prefixIcon: prefixIcon == null
              ? null
              : Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: ResponsiveUtils.getResponsiveSize(context, 10),
                    end: ResponsiveUtils.getResponsiveSize(context, 8),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: AppColors.primary,
                      size: ResponsiveUtils.getResponsiveSize(context, 21),
                    ),
                    child: prefixIcon!,
                  ),
                ),
          prefixIconConstraints: BoxConstraints(
            minWidth: ResponsiveUtils.getResponsiveSize(context, 48),
          ),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveSize(context, 18),
            ),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.82),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveSize(context, 18),
            ),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: ResponsiveUtils.getResponsiveSize(context, 1.3),
            ),
          ),
          errorBorder: inputTheme.errorBorder,
          focusedErrorBorder: inputTheme.focusedErrorBorder,
        ),
      ),
    );
  }
}
