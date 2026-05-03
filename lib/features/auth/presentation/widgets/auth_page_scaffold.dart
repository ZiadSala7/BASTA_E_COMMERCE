import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const _AuthBackgroundGlow(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 42,
                          child: showBackButton
                              ? Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).maybePop(),
                                    icon: const Icon(Icons.arrow_back_rounded),
                                    splashRadius: 22,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        child,
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
    return Stack(
      children: [
        Positioned(
          top: -140,
          right: -120,
          child: _GlowCircle(
            size: 280,
            colors: const [Color(0x1AF4B8C8), Color(0x00FFFFFF)],
          ),
        ),
        Positioned(
          bottom: -160,
          left: -120,
          child: _GlowCircle(
            size: 300,
            colors: const [Color(0x145B6BFF), Color(0x00FFFFFF)],
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
