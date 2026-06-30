part of '../edit_profile_sheet.dart';

class EditProfileSheet extends StatefulWidget {
  final UserEntity? user;

  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}
