import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';

class CartSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String currency;
  final VoidCallback onProceedToCheckout;

  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.currency,
    required this.onProceedToCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space20),
        child: Column(
          children: [
            Text(
              l10n.orderSummary,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.subtotal,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  Formatters.formatPrice(subtotal, currency: currency),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),

            // Delivery Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.deliveryFees,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  Formatters.formatPrice(deliveryFee, currency: currency),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.space12),
              child: Divider(),
            ),

            // Grand Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.grandTotal,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Formatters.formatPrice(total, currency: currency),
                  style: const TextStyle(
                    color: AppColors.price,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.space20),

            // Proceed Button
            ElevatedButton(
              onPressed: onProceedToCheckout,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                  const SizedBox(width: AppDimensions.space8),
                  Text(l10n.continueToCheckout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
