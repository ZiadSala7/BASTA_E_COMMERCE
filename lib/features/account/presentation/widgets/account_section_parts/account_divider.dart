part of '../account_section.dart';

class AccountDivider extends StatelessWidget {
  const AccountDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 1,
      color: colorScheme.outlineVariant,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
