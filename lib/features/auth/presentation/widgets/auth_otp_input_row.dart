import 'package:flutter/material.dart';

class AuthOtpInputRow extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const AuthOtpInputRow({
    super.key,
    required this.onChanged,
  });

  @override
  State<AuthOtpInputRow> createState() => _AuthOtpInputRowState();
}

class _AuthOtpInputRowState extends State<AuthOtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleChanged(String value, int index) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    widget.onChanged(_controllers.map((controller) => controller.text).join());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_controllers.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == _controllers.length - 1 ? 0 : 12,
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              maxLength: 1,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF26263A),
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE7E7F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF5B6BFF),
                    width: 1.3,
                  ),
                ),
              ),
              onChanged: (value) => _handleChanged(value, index),
            ),
          ),
        );
      }),
    );
  }
}
