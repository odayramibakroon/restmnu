import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_item.dart';

class CartItemTile extends StatefulWidget {
  final CartItem cartItem;
  final String currency;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.currency,
    required this.onIncrease,
    required this.onDecrease,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile> {
  late final TextEditingController _quantityController;
  late final FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: _quantityText());
    _quantityFocusNode = FocusNode()..addListener(_commitQuantityOnBlur);
  }

  @override
  void didUpdateWidget(covariant CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.cartItem.key != widget.cartItem.key ||
            oldWidget.cartItem.quantity != widget.cartItem.quantity) &&
        !_quantityFocusNode.hasFocus) {
      _quantityController.text = _quantityText();
    }
  }

  @override
  void dispose() {
    _quantityFocusNode.removeListener(_commitQuantityOnBlur);
    _quantityFocusNode.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final item = widget.cartItem.item;
    final itemName = LocalizedValues.selectForContext(
      context,
      ar: item.nameAr,
      en: item.nameEn,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space12),
        child: Row(
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryContainer,
                          child: const Icon(
                            Icons.fastfood,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.primaryContainer,
                        child: const Icon(
                          Icons.fastfood,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: AppDimensions.space12),

            // Info & Quantity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          itemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.error,
                        ),
                        onPressed: widget.onRemove,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.formatPrice(widget.cartItem.unitPrice, currency: widget.currency)} ${item.isSoldByWeight ? l10n.perKilo : l10n.pieceUnit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (widget.cartItem.selectedSize != null &&
                      widget.cartItem.selectedSize!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${l10n.sizeLabel}: ${widget.cartItem.selectedSize}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      item.isSoldByWeight
                          ? _buildWeightQuantityControl(isDark)
                          : _buildPieceQuantityControl(isDark),

                      // Total for this item
                      Text(
                        Formatters.formatPrice(
                          widget.cartItem.totalPrice,
                          currency: widget.currency,
                        ),
                        style: const TextStyle(
                          color: AppColors.price,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceQuantityControl(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: widget.onDecrease,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.remove, size: 16, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              Formatters.formatQuantity(widget.cartItem.quantity),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          InkWell(
            onTap: widget.onIncrease,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.add, size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightQuantityControl(bool isDark) {
    return Container(
      width: 156,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onDecrease,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: const SizedBox(
              width: 32,
              height: 36,
              child: Icon(
                Icons.remove_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _quantityController,
              focusNode: _quantityFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: AppLocalizations.of(context)!.kiloShort,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => _commitQuantity(),
            ),
          ),
          InkWell(
            onTap: widget.onIncrease,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: const SizedBox(
              width: 32,
              height: 36,
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _quantityText() {
    return Formatters.formatQuantity(
      widget.cartItem.quantity,
      isWeight: widget.cartItem.item.isSoldByWeight,
    );
  }

  void _commitQuantityOnBlur() {
    if (!_quantityFocusNode.hasFocus) _commitQuantity();
  }

  void _commitQuantity() {
    final quantity = double.tryParse(
      _quantityController.text.trim().replaceAll(',', '.'),
    );

    if (quantity == null || quantity <= 0) {
      _quantityController.text = _quantityText();
      return;
    }

    widget.onQuantityChanged(quantity);
  }
}
