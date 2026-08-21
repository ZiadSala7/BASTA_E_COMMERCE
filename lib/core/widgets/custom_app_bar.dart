// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../features/notifications/domain/services/notifications_controller.dart';
import '../di/service_locator.dart';
import '../extensions/app_localizations_x.dart';
import '../utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onFilterPressed;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchTap;
  final String? storeName;
  final String storeCode;
  final String logoAsset;
  final String? searchHint;
  final String? title;
  final Widget? titleWidget;
  final bool showSearch;
  final bool showLogo;
  final bool showNotificationButton;
  final bool showMenuButton;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onFilterPressed,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchTap,
    this.storeName,
    this.storeCode = 'BS6A',
    this.logoAsset = 'assets/images/app_logo.png',
    this.searchHint,
    this.title,
    this.titleWidget,
    this.showSearch = true,
    this.showLogo = true,
    this.showNotificationButton = true,
    this.showMenuButton = true,
    this.showBackButton = false,
  });

  static const _fullHeight = 156.0;
  static const _compactHeight = 100.0;
  static const _purple = AppColors.primary;

  @override
  Size get preferredSize =>
      Size.fromHeight(showSearch ? _fullHeight : _compactHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.18,
              ),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: Column(
                  children: [
                    _AppBarTopRow(
                      title: title,
                      titleWidget: titleWidget,
                      storeName: storeName ?? l10n.storeName,
                      storeCode: storeCode,
                      logoAsset: logoAsset,
                      textDirection: l10n.inverseAppBarDirection,
                      onMenuPressed: onMenuPressed,
                      onNotificationPressed: onNotificationPressed,
                      showLogo: showLogo,
                      showNotificationButton: showNotificationButton,
                      showMenuButton: showMenuButton,
                      showBackButton: showBackButton,
                    ),
                    if (showSearch) ...[
                      const SizedBox(height: 10),
                      Row(
                        textDirection: l10n.inverseAppBarDirection,
                        children: [
                          Expanded(
                            child: _AppSearchField(
                              controller: searchController,
                              hintText: searchHint ?? l10n.searchHint,
                              onChanged: onSearchChanged,
                              onSubmitted: onSearchSubmitted,
                              onTap: onSearchTap,
                              onFilterTap: onFilterPressed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarTopRow extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final String storeName;
  final String storeCode;
  final String logoAsset;
  final TextDirection textDirection;
  final bool showLogo;
  final bool showNotificationButton;
  final bool showMenuButton;
  final bool showBackButton;

  const _AppBarTopRow({
    required this.title,
    required this.titleWidget,
    required this.storeName,
    required this.storeCode,
    required this.logoAsset,
    required this.textDirection,
    required this.showLogo,
    required this.showNotificationButton,
    required this.showMenuButton,
    required this.showBackButton,
    this.onMenuPressed,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: textDirection,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showMenuButton) _MenuButton(onTap: onMenuPressed),
        if (showNotificationButton) ...[
          if (showMenuButton) const SizedBox(width: 10),
          _NotificationButton(onTap: onNotificationPressed),
        ],
        const Spacer(),
        if (titleWidget != null) ...[
          Flexible(child: titleWidget!),
          if (showBackButton) ...[
            const SizedBox(width: 10),
            _BackButton(onTap: onNotificationPressed),
          ],
        ] else if (title != null) ...[
          Flexible(
            child: Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
          if (showBackButton) ...[
            const SizedBox(width: 10),
            _BackButton(onTap: onNotificationPressed),
          ],
        ] else ...[
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: Text(
                    storeCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.86),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showLogo) ...[
            const SizedBox(width: 8),
            _LogoBadge(assetName: logoAsset),
          ],
        ],
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MenuButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.menu_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _NotificationButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    if (sl.isRegistered<NotificationsController>()) {
      final controller = sl<NotificationsController>();
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return _NotificationButtonShell(
            onTap: onTap,
            unreadCount: controller.unreadCount,
          );
        },
      );
    }

    return _NotificationButtonShell(onTap: onTap, unreadCount: 0);
  }
}

class _NotificationButtonShell extends StatelessWidget {
  final VoidCallback? onTap;
  final int unreadCount;

  const _NotificationButtonShell({
    required this.onTap,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    final icon = SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 22,
          ),
          if (hasUnread)
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16),
                height: 16,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.badgeRed,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: onTap == null
          ? icon
          : InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: icon,
            ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final String assetName;

  const _LogoBadge({required this.assetName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: ClipOval(child: Image.asset(assetName, fit: BoxFit.cover)),
    );
  }
}

class _AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  const _AppSearchField({
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        readOnly: onTap != null,
        enableInteractiveSelection: onTap == null,
        textInputAction: TextInputAction.search,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.96),
          hintText: hintText,
          hintTextDirection: TextDirection.rtl,
          hintStyle: GoogleFonts.cairo(
            color: const Color(0xFF9E9AA8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 21,
          ),
          suffixIcon: IconButton(
            onPressed: onFilterTap ?? onTap,
            tooltip: AppLocalizations.of(
              context,
            )!.pick(ar: 'تصفية', en: 'Filter'),
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }
}
