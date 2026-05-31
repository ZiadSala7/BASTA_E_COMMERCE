import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

class LogoutButton extends StatelessWidget {
  final bool isLoading;

  const LogoutButton({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OutlinedButton.icon(
      onPressed: isLoading ? null : () => context.read<AuthCubit>().logout(),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red.shade600,
              ),
            )
          : Icon(Icons.logout, color: Colors.red.shade600),
      label: Text(
        l10n.logout,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.red.shade600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.red.shade600),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
