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
                  color: AppColors.primaryDark.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
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
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xE6071038),
                              Color(0x99071038),
                              Color(0x00071038),
                            ],
                            stops: [0, 0.38, 1],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          compact ? 16 : 22,
                          compact ? 14 : 20,
                          compact ? 16 : 22,
                          compact ? 14 : 18,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              banner.title,
                              textAlign: TextAlign.end,
                              maxLines: compact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: compact ? 14 : 18,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x66000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: compact ? 8 : 12),
                            Align(
                              alignment: AlignmentDirectional.bottomEnd,
                              child: IntrinsicWidth(
                                child: Container(
                                  height: compact ? 32 : 40,
                                  constraints: BoxConstraints(
                                    minWidth: compact ? 96 : 118,
                                  ),
                                  padding: EdgeInsetsDirectional.symmetric(
                                    horizontal: compact ? 14 : 18,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.14),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          banner.buttonText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                            color: AppColors.primaryDark,
                                            fontSize: compact ? 11 : 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: compact ? 14 : 16,
                                        color: AppColors.primaryDark,
                                      ),
                                    ],
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
