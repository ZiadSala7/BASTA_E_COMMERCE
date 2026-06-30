part of '../account_page.dart';

class AccountPage extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const AccountPage({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()..getCurrentUser()),
        BlocProvider(create: (_) => sl<AccountCubit>()..getAccountStats()),
      ],
      child: _AccountContent(onMenuPressed: onMenuPressed),
    );
  }
}
