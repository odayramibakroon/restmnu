import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';

class LocationPickerSection extends StatelessWidget {
  final String formattedAddress;
  final String deliveryMapLink;
  final double latitude;
  final double longitude;
  final bool isLoadingLocation;
  final TextEditingController mapLinkController;
  final VoidCallback onUseCurrentLocation;
  final ValueChanged<String> onMapLinkChanged;

  const LocationPickerSection({
    super.key,
    required this.formattedAddress,
    required this.deliveryMapLink,
    required this.latitude,
    required this.longitude,
    required this.isLoadingLocation,
    required this.mapLinkController,
    required this.onUseCurrentLocation,
    required this.onMapLinkChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final hasCoordinates = latitude != 0.0 && longitude != 0.0;

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
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  l10n.deliveryLocation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Use Current Location Button
            ElevatedButton.icon(
              onPressed: isLoadingLocation ? null : onUseCurrentLocation,
              icon: isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded, size: 20),
              label: Text(
                isLoadingLocation
                    ? l10n.locatingAccurately
                    : '📍 ${l10n.useCurrentLocation}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: AppDimensions.space12),

            TextField(
              controller: mapLinkController,
              onChanged: onMapLinkChanged,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l10n.mapLinkOption,
                hintText: 'https://maps.app.goo.gl/...',
                prefixIcon: const Icon(Icons.link_rounded),
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // Selected Location Preview Box
            if (formattedAddress.isNotEmpty ||
                hasCoordinates ||
                deliveryMapLink.trim().isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(
                    alpha: isDark ? 0.2 : 0.6,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.selectedLocation,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            deliveryMapLink.trim().isNotEmpty
                                ? deliveryMapLink.trim()
                                : formattedAddress.isNotEmpty
                                ? formattedAddress
                                : '${l10n.coordinates}: ($latitude, $longitude)',
                            textDirection: deliveryMapLink.trim().isNotEmpty
                                ? TextDirection.ltr
                                : null,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              l10n.locationPrivacyNotice,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
