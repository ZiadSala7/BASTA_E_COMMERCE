part of '../profile_header.dart';

class _ProfileDetails extends StatelessWidget {
  final String displayName;
  final String email;
  final String phone;
  final String role;
  final Color textColor;
  final Color mutedTextColor;

  const _ProfileDetails({
    required this.displayName,
    required this.email,
    required this.phone,
    required this.role,
    required this.textColor,
    required this.mutedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: mutedTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (phone.isNotEmpty)
              ProfileInfoChip(icon: Icons.phone_outlined, label: phone),
            if (role.isNotEmpty)
              ProfileInfoChip(icon: Icons.badge_outlined, label: role),
          ],
        ),
      ],
    );
  }
}
