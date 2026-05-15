import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? titleWidget;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final bool showSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.titleWidget,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = false,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.searchHint,
  });

  @override
  Size get preferredSize => Size.fromHeight(showSearch ? 148 : 72);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: preferredSize,
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? AppColors.primary).withValues(
                  alpha: isDark ? 0.18 : 0.14,
                ),
                blurRadius: 22 + elevation,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor ?? AppColors.primaryDark,
                    backgroundColor ?? AppColors.primary,
                    backgroundColor ?? const Color(0xFF20B7A8),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, showSearch ? 14 : 12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            _AppBarIconSlot(child: leading),
                            Expanded(
                              child:
                                  titleWidget ??
                                  (title != null
                                      ? Text(
                                          title!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: centerTitle
                                              ? TextAlign.center
                                              : TextAlign.start,
                                          style: GoogleFonts.cairo(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: colorScheme.onPrimary,
                                            height: 1.1,
                                          ),
                                        )
                                      : const SizedBox.shrink()),
                            ),
                            _AppBarActionsSlot(actions: actions),
                          ],
                        ),
                      ),
                      if (showSearch) ...[
                        const SizedBox(height: 12),
                        _SearchField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          hint: searchHint ?? 'Search...',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarActionsSlot extends StatelessWidget {
  const _AppBarActionsSlot({required this.actions});

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    if (actions == null || actions!.isEmpty) {
      return const SizedBox(width: 48);
    }

    return IconTheme.merge(
      data: const IconThemeData(color: Colors.white),
      child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
    );
  }
}

class _AppBarIconSlot extends StatelessWidget {
  const _AppBarIconSlot({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return const SizedBox(width: 48);
    }

    return SizedBox(width: 48, height: 48, child: child);
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;

  const _SearchField({this.controller, this.onChanged, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(
            color: const Color(0xFF9E9AA8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
        ),
      ),
    );
  }
}
