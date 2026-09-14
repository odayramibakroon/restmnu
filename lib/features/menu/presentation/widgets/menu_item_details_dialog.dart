import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/menu_item.dart';

class MenuItemDetailsDialog extends StatefulWidget {
  final MenuItemEntity item;
  final String currency;
  final Function(MenuItemEntity item, double quantity, String? selectedSize)
  onAddToCart;

  const MenuItemDetailsDialog({
    super.key,
    required this.item,
    required this.currency,
    required this.onAddToCart,
  });

  static Future<void> show(
    BuildContext context, {
    required MenuItemEntity item,
    required String currency,
    required Function(
      MenuItemEntity item,
      double quantity,
      String? selectedSize,
    )
    onAddToCart,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuItemDetailsDialog(
        item: item,
        currency: currency,
        onAddToCart: onAddToCart,
      ),
    );
  }

  @override
  State<MenuItemDetailsDialog> createState() => _MenuItemDetailsDialogState();
}

class _MenuItemDetailsDialogState extends State<MenuItemDetailsDialog> {
  static const double _weightStep = 1.0;
  static const double _minimumWeight = 0.25;

  double _quantity = 1;
  String? _selectedSize;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() => _quantity += 1);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity -= 1);
    }
  }

  void _incrementWeight() {
    final current = _currentQuantity();
    _setWeight(current <= 0 ? _weightStep : current + _weightStep);
  }

  void _decrementWeight() {
    final current = _currentQuantity();
    final next = current <= _minimumWeight
        ? _minimumWeight
        : current - _weightStep;
    _setWeight(next < _minimumWeight ? _minimumWeight : next);
  }

  void _setWeight(double value) {
    final text = Formatters.formatQuantity(value, isWeight: true);
    _weightController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final selectedSize =
        _selectedSize ??
        (widget.item.sizes.isNotEmpty ? widget.item.sizes.first : null);
    final unitPrice = widget.item.priceForSize(selectedSize);
    final quantity = _currentQuantity();
    final totalPrice = unitPrice * quantity;
    final itemName = LocalizedValues.selectForContext(
      context,
      ar: widget.item.nameAr,
      en: widget.item.nameEn,
    );
    final itemDescription = LocalizedValues.selectForContext(
      context,
      ar: widget.item.descriptionAr,
      en: widget.item.descriptionEn,
    );
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 10),
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: widget.item.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.item.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: isDark
                                        ? AppColors.shimmerBaseDark
                                        : AppColors.shimmerBaseLight,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.primaryContainer,
                                    child: const Icon(
                                      Icons.fastfood_rounded,
                                      size: 50,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.primaryContainer,
                                  child: const Icon(
                                    Icons.fastfood_rounded,
                                    size: 50,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space16),

                      // Title & Badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemName,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                ),
                                if (widget.item.nameEn.isNotEmpty &&
                                    widget.item.nameEn != itemName) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.item.nameEn,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          _buildDetailsPrice(context, isDark, unitPrice),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.space16),

                      // Description
                      if (itemDescription.isNotEmpty) ...[
                        Text(
                          l10n.description,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          itemDescription,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.6),
                        ),
                      ],

                      if (widget.item.sizes.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space20),
                        Text(
                          l10n.sizeLabel,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Wrap(
                          spacing: AppDimensions.space8,
                          runSpacing: AppDimensions.space8,
                          children: widget.item.sizes.map((size) {
                            final isSelected =
                                (_selectedSize ?? widget.item.sizes.first) ==
                                size;
                            final sizePrice = widget.item.priceForSize(size);
                            return ChoiceChip(
                              label: Text(
                                '$size - ${Formatters.formatPrice(sizePrice, currency: widget.currency)}',
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() => _selectedSize = size);
                              },
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.space24),

                      // Quantity Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.item.isSoldByWeight
                                ? l10n.weightInKilo
                                : l10n.quantity,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          widget.item.isSoldByWeight
                              ? _buildWeightQuantityControl(isDark, l10n)
                              : Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.cardDark
                                        : AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusFull,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: _decrement,
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 20,
                                        ),
                                        color: _quantity > 1
                                            ? AppColors.primary
                                            : Colors.grey,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          Formatters.formatQuantity(_quantity),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _increment,
                                        icon: const Icon(Icons.add, size: 20),
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.space24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: () {
                    final quantity = _currentQuantity();
                    if (quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ErrorMessages.message(
                              AppErrorKey.validWeightRequired,
                            ),
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    widget.onAddToCart(widget.item, quantity, selectedSize);
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.addToCart),
                      Text(
                        Formatters.formatPrice(
                          totalPrice,
                          currency: widget.currency,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _currentQuantity() {
    if (!widget.item.isSoldByWeight) return _quantity;

    return double.tryParse(
          _weightController.text.trim().replaceAll(',', '.'),
        ) ??
        0;
  }

  Widget _buildWeightQuantityControl(bool isDark, AppLocalizations l10n) {
    return Container(
      width: 210,
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.decreaseWeight,
            onPressed: _decrementWeight,
            icon: const Icon(Icons.remove_rounded, size: 20),
            color: AppColors.primary,
          ),
          Expanded(
            child: TextField(
              controller: _weightController,
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
                suffixText: l10n.kiloShort,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            tooltip: l10n.increaseWeight,
            onPressed: _incrementWeight,
            icon: const Icon(Icons.add_rounded, size: 20),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPrice(
    BuildContext context,
    bool isDark,
    double unitPrice,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          Formatters.formatPrice(unitPrice, currency: widget.currency),
          style: const TextStyle(
            color: AppColors.price,
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
        if (widget.item.hasDiscount && widget.item.oldPrice != null) ...[
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.discountBadge.withValues(
                alpha: isDark ? 0.18 : 0.10,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(
                color: AppColors.discountBadge.withValues(
                  alpha: isDark ? 0.42 : 0.26,
                ),
              ),
            ),
            child: Text(
              '${AppLocalizations.of(context)!.insteadOf} ${Formatters.formatPrice(widget.item.oldPrice!, currency: widget.currency)}',
              style: const TextStyle(
                color: AppColors.discountBadge,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.discountBadge,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
