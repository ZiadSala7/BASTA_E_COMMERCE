part of '../addresses_page.dart';

class _AddressTextField extends StatelessWidget {
  const _AddressTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.minLines = 1,
    this.keyboardType,
    this.requiredField = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int minLines;
  final TextInputType? keyboardType;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines > 1 ? 3 : 1,
        keyboardType: keyboardType,
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pick(
                    ar: 'هذا الحقل مطلوب',
                    en: 'This field is required',
                  );
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
