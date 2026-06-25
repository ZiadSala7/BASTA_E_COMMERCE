import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthOtpInputRow extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const AuthOtpInputRow({super.key, required this.onChanged});

  @override
  State<AuthOtpInputRow> createState() => _AuthOtpInputRowState();
}

class _AuthOtpInputRowState extends State<AuthOtpInputRow> {
  static const int _codeLength = 6;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  void _handleChanged(String value) {
    setState(() {});
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final code = _controller.text;
    final isRtlOtp =
        Localizations.localeOf(context).languageCode == 'ar' ||
        Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      textField: true,
      label: 'Verification code',
      value: code,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focusNode.requestFocus,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.01,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textDirection: TextDirection.ltr,
                  maxLength: _codeLength,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_codeLength),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _handleChanged,
                ),
              ),
            ),
            Row(
              textDirection: isRtlOtp ? TextDirection.rtl : TextDirection.ltr,
              children: List.generate(_codeLength, (index) {
                final digit = index < code.length ? code[index] : '';
                final isActive = _focusNode.hasFocus && index == code.length;
                final isFilled = digit.isNotEmpty;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == _codeLength - 1 ? 0 : 12,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: inputTheme.fillColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive || isFilled
                              ? theme.colorScheme.primary
                              : const Color(0xFFE1E3EC),
                          width: isActive ? 1.8 : 1,
                        ),
                      ),
                      child: Text(
                        digit,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
