import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';

class CustomerInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhoneChanged;

  const CustomerInfoForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.onNameChanged,
    required this.onPhoneChanged,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_pin_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  l10n.customerInfo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Customer Name
            Text(
              l10n.fullNameRequired,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              onChanged: onNameChanged,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.fullNameHint,
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // Phone Number
            Text(
              l10n.phoneRequired,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: phoneController,
              onChanged: onPhoneChanged,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: l10n.phoneHint,
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
