import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/menu_item.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItemEntity item;
  final String currency;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.currency,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final item = widget.item;
    final itemName = LocalizedValues.selectForContext(
      context,
      ar: item.nameAr,
      en: item.nameEn,
    );
    final itemDescription = LocalizedValues.selectForContext(
      context,
      ar: item.descriptionAr,
      en: item.descriptionEn,
    );
    final priceLabel = item.sizes.isEmpty ? '' : l10n.accordingToSize;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (value) => setState(() => _isPressed = value),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with Badges
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: isDark
                              ? AppColors.shimmerBaseDark
                              : AppColors.shimmerBaseLight,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          child: const Center(
                            child: Icon(
                              Icons.fastfood_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        child: const Center(
                          child: Icon(
                            Icons.fastfood_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                    // Top badges
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (item.isPopular)
                            _buildBadge(
                              text: l10n.popularBadge,
                              backgroundColor: AppColors.popularBadge,
                            ),
                          if (item.isNew)
                            _buildBadge(
                              text: l10n.newBadge,
                              backgroundColor: AppColors.newBadge,
                            ),
                          if (item.hasDiscount)
                            _buildBadge(
                              text: l10n.discountBadge,
                              backgroundColor: AppColors.discountBadge,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content info
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 3),
                          if (itemDescription.isNotEmpty)
                            Text(
                              itemDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(height: 1.3, fontSize: 11),
                            ),
                        ],
                      ),

                      // Price & Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildPriceBlock(
                              isDark: isDark,
                              priceLabel: priceLabel,
                            ),
                          ),
                          InkWell(
                            onTap: widget.onAddToCart,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOutCubic,
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: _isPressed ? 0.2 : 0.35,
                                    ),
                                    blurRadius: _isPressed ? 4 : 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBlock({required bool isDark, required String priceLabel}) {
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Formatters.formatPrice(item.displayPrice, currency: widget.currency),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.price,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          priceLabel.isEmpty
              ? (item.isSoldByWeight
                    ? AppLocalizations.of(context)!.kiloUnit
                    : AppLocalizations.of(context)!.pieceUnit)
              : priceLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        if (item.hasDiscount && item.oldPrice != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.discountBadge.withValues(
                    alpha: isDark ? 0.18 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: AppColors.discountBadge.withValues(
                      alpha: isDark ? 0.40 : 0.25,
                    ),
                  ),
                ),
                child: Text(
                  '${AppLocalizations.of(context)!.insteadOf} ${Formatters.formatPrice(item.oldPrice!, currency: widget.currency)}',
                  style: const TextStyle(
                    color: AppColors.discountBadge,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.discountBadge,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadge({required String text, required Color backgroundColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
