import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

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

class _AuthBackgroundGlow extends StatelessWidget {
  const _AuthBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -110,
          child: _GlowCircle(
            size: 290,
            colors: [
              isDark ? const Color(0x335B5BD6) : const Color(0x245B5BD6),
              const Color(0x00FFFFFF),
            ],
          ),
        ),
        Positioned(
          bottom: -150,
          left: -120,
          child: _GlowCircle(
            size: 320,
            colors: [
              isDark ? const Color(0x3320B7A8) : const Color(0x2220B7A8),
              const Color(0x00FFFFFF),
            ],
          ),
        ),
        Positioned(
          top: 140,
          left: -80,
          child: _GlowCircle(
            size: 190,
            colors: [
              isDark ? const Color(0x22FF6B35) : const Color(0x18FF6B35),
              const Color(0x00FFFFFF),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowCircle({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
