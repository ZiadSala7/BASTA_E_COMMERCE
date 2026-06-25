import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/responsive/responsive_utils.dart';

class AuthTextField extends StatefulWidget {
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
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

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
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText && _isObscured,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: inputTheme.hintStyle,
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSize(context, 18),
            vertical: ResponsiveUtils.getResponsiveSize(context, 18),
          ),
          prefixIcon: widget.prefixIcon == null
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
                    child: widget.prefixIcon!,
                  ),
                ),
          prefixIconConstraints: BoxConstraints(
            minWidth: ResponsiveUtils.getResponsiveSize(context, 48),
          ),
          suffixIcon: widget.suffixIcon ?? _passwordVisibilityButton(context),
          suffixIconConstraints: BoxConstraints(
            minWidth: ResponsiveUtils.getResponsiveSize(context, 48),
          ),
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

  Widget? _passwordVisibilityButton(BuildContext context) {
    if (!widget.obscureText) return null;

    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: _togglePasswordVisibility,
      tooltip: _isObscured ? 'Show password' : 'Hide password',
      icon: Icon(
        _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: colorScheme.onSurfaceVariant,
        size: ResponsiveUtils.getResponsiveSize(context, 21),
      ),
    );
  }
}
