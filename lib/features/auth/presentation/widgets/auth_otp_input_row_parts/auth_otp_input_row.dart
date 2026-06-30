part of '../auth_otp_input_row.dart';

class AuthOtpInputRow extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const AuthOtpInputRow({super.key, required this.onChanged});

  @override
  State<AuthOtpInputRow> createState() => _AuthOtpInputRowState();
}
