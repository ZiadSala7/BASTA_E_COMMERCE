part of '../auth_page_scaffold.dart';

class AuthPageScaffold extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const AuthPageScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const _AuthBackgroundGlow(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 46,
                          child: showBackButton
                              ? Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Material(
                                    color: colorScheme.surface.withValues(
                                      alpha: 0.9,
                                    ),
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: () =>
                                          Navigator.of(context).maybePop(),
                                      customBorder: const CircleBorder(),
                                      child: const SizedBox(
                                        width: 42,
                                        height: 42,
                                        child: Icon(
                                          Icons.arrow_back_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(
                              alpha:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 0.94
                                  : 0.98,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.70,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 0.24
                                      : 0.08,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
