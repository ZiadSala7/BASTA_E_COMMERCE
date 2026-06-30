part of '../profile_header_background.dart';

class _AccountTitleBlock extends StatelessWidget {
  const _AccountTitleBlock();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.myAccount,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          l10n.editAccount,
          style: GoogleFonts.cairo(
            color: Colors.white.withOpacity(0.78),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}
