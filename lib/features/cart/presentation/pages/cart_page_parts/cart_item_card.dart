part of '../cart_page.dart';

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.isUpdating,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onFavoriteTap,
  });

  final _CartProduct item;
  final bool isUpdating;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Future<bool> Function() onRemove;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 148,
      child: Dismissible(
        key: ValueKey<String>(item.id),
        direction: DismissDirection.endToStart,
        background: const SizedBox.shrink(),
        secondaryBackground: const _SwipeDeleteBackground(),
        confirmDismiss: (_) async {
          await onRemove();
          return false;
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(item: item),
              const SizedBox(width: 12),
              Expanded(child: _CartItemDetails(item: item)),
              const SizedBox(width: 8),
              SizedBox(
                width: 94,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _RoundIconButton(
                      icon: item.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: item.isFavorite
                          ? AppColors.badgeRed
                          : colorScheme.onSurfaceVariant,
                      onTap: onFavoriteTap,
                    ),
                    const SizedBox(height: 8),
                    _RoundIconButton(
                      icon: Icons.delete_outline_rounded,
                      color: colorScheme.onSurfaceVariant,
                      onTap: isUpdating ? null : () async => onRemove(),
                    ),
                    const SizedBox(height: 8),
                    isUpdating
                        ? const SizedBox(
                            width: 34,
                            height: 34,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _QuantityStepper(
                            quantity: item.quantity,
                            onIncrement: onIncrement,
                            onDecrement: onDecrement,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
