part of '../home_ad_carousel.dart';

class _AdBannerCard extends StatelessWidget {
  final HomeAdBanner banner;
  final VoidCallback? onTap;

  const _AdBannerCard({required this.banner, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF101735),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 180;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      _BannerImage(banner: banner),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0x15000000),
                              Color(0x26000000),
                              Color(0x9C071038),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 18 : 22,
                          compact ? 16 : 20,
                          compact ? 20 : 28,
                          compact ? 16 : 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              banner.title,
                              textAlign: TextAlign.right,
                              maxLines: compact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: compact ? 15 : 20,
                                fontWeight: FontWeight.w800,
                                height: 1.32,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IntrinsicWidth(
                                child: Container(
                                  height: compact ? 34 : 46,
                                  constraints: BoxConstraints(
                                    minWidth: compact ? 92 : 124,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 18 : 26,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                  child: Text(
                                    banner.buttonText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: compact ? 12 : 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
