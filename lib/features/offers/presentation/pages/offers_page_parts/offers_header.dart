part of '../offers_page.dart';

class _OffersHeader extends StatelessWidget {
  final double topPadding;
  final String title;
  final String hintText;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSearchChanged;

  const _OffersHeader({
    required this.topPadding,
    required this.title,
    required this.hintText,
    required this.onMenuTap,
    required this.onNotificationTap,
    required this.onFilterTap,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 14,
            left: 20,
            right: 20,
            bottom: 16,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary],
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.coupons,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1.18,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.78),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: onNotificationTap,
                      showDot: true,
                    ),
                    const SizedBox(width: 10),
                    _HeaderIconButton(
                      icon: Icons.menu_rounded,
                      onTap: onMenuTap,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextField(
                        onChanged: onSearchChanged,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: GoogleFonts.cairo(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.72,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 21,
                          ),
                          filled: true,
                          fillColor: colorScheme.surface.withOpacity(0.96),
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: onFilterTap,
                      borderRadius: BorderRadius.circular(14),
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                          size: 23,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
