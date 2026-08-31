import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/coupons_cubit.dart';
import '../widgets/coupon_card.dart';
import '../widgets/empty_coupons_view.dart';

class MyCouponsPage extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final bool isTab;

  const MyCouponsPage({
    super.key,
    this.onMenuPressed,
    this.isTab = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CouponsCubit>()..getMyCoupons(),
      child: _MyCouponsView(
        onMenuPressed: onMenuPressed,
        isTab: isTab,
      ),
    );
  }
}

class _MyCouponsView extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final bool isTab;

  const _MyCouponsView({
    this.onMenuPressed,
    this.isTab = false,
  });

  @override
  State<_MyCouponsView> createState() => _MyCouponsViewState();
}

class _MyCouponsViewState extends State<_MyCouponsView> {
  int _selectedFilterIndex = 0; // 0: All, 1: Active, 2: Inactive

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.pick(ar: 'مكافآتي وكوبوناتي', en: 'My Rewards & Coupons'),
        showSearch: false,
        showNotificationButton: widget.isTab,
        showBackButton: !widget.isTab,
        showMenuButton: widget.isTab,
        onMenuPressed: widget.onMenuPressed,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.mainNavigation);
          }
        },
        onNotificationPressed: () => context.push(AppRoutes.notifications),
      ),
      body: BlocConsumer<CouponsCubit, CouponsState>(
        listener: (context, state) {
          if (state is CouponsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CouponsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CouponsError && state is! CouponsLoaded) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 54,
                      color: AppColors.badgeRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CouponsCubit>().getMyCoupons(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.tryAgain),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CouponsLoaded) {
            final allCoupons = state.coupons;
            final activeCoupons = state.activeCoupons;
            final inactiveCoupons = state.inactiveCoupons;

            if (allCoupons.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<CouponsCubit>().getMyCoupons(showLoading: false),
                child: EmptyCouponsView(
                  onRefresh: () => context.read<CouponsCubit>().getMyCoupons(),
                ),
              );
            }

            final displayedCoupons = switch (_selectedFilterIndex) {
              1 => activeCoupons,
              2 => inactiveCoupons,
              _ => allCoupons,
            };

            return RefreshIndicator(
              onRefresh: () => context.read<CouponsCubit>().getMyCoupons(showLoading: false),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Referral Info Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.card_giftcard_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.pick(
                                      ar: 'اكسب المزيد من الكوبونات!',
                                      en: 'Earn more coupons!',
                                    ),
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.pick(
                                      ar: 'ادعُ أصدقاءك واحصل على 5 د.أ لكل صديق يطلب!',
                                      en: 'Invite friends & get 5 JOD for every order!',
                                    ),
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => context.push(AppRoutes.inviteFriends),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                l10n.pick(ar: 'دعوة', en: 'Invite'),
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context,
                            index: 0,
                            label: l10n.pick(ar: 'الكل', en: 'All'),
                            count: allCoupons.length,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            index: 1,
                            label: l10n.pick(ar: 'نشطة', en: 'Active'),
                            count: activeCoupons.length,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            index: 2,
                            label: l10n.pick(ar: 'غير نشطة', en: 'Inactive'),
                            count: inactiveCoupons.length,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Coupon list or empty filter message
                  if (displayedCoupons.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.pick(
                                  ar: 'لا توجد كوبونات في هذا القسم',
                                  en: 'No coupons in this section',
                                ),
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final coupon = displayedCoupons[index];
                          return CouponCard(coupon: coupon);
                        },
                        childCount: displayedCoupons.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required int index,
    required String label,
    required int count,
  }) {
    final isSelected = _selectedFilterIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
