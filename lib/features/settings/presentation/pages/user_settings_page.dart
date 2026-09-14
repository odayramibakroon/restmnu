import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../checkout/presentation/cubit/checkout_cubit.dart';
import '../../../checkout/presentation/cubit/checkout_state.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userSettings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, checkoutState) {
                  return ListView(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    children: [
                      _settingsCard(
                        context: context,
                        icon: Icons.language_rounded,
                        title: l10n.language,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: 'ar',
                                label: Text(l10n.arabicLanguage),
                              ),
                              ButtonSegment(
                                value: 'en',
                                label: Text(l10n.englishLanguage),
                              ),
                            ],
                            selected: {themeState.locale.languageCode},
                            onSelectionChanged: (selection) {
                              context.read<ThemeCubit>().setLocale(
                                Locale(selection.first),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      _settingsCard(
                        context: context,
                        icon: Icons.dark_mode_outlined,
                        title: l10n.appearance,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text(l10n.lightMode),
                                icon: const Icon(Icons.light_mode_outlined),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text(l10n.darkMode),
                                icon: const Icon(Icons.dark_mode_outlined),
                              ),
                            ],
                            selected: {themeState.themeMode},
                            onSelectionChanged: (selection) {
                              context.read<ThemeCubit>().setThemeMode(
                                selection.first,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      _settingsCard(
                        context: context,
                        icon: Icons.person_pin_circle_outlined,
                        title: l10n.savedCheckoutInfo,
                        child: _SavedCheckoutInfoSection(state: checkoutState),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _settingsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SavedCheckoutInfoSection extends StatelessWidget {
  final CheckoutState state;

  const _SavedCheckoutInfoSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = _locationLabel();
    final hasInfo =
        state.customerName.trim().isNotEmpty ||
        state.phone.trim().isNotEmpty ||
        location.trim().isNotEmpty;

    if (!hasInfo) {
      return Text(
        l10n.noSavedCheckoutInfo,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.customerName.trim().isNotEmpty)
          _infoRow(context, l10n.nameLabel, state.customerName),
        if (state.phone.trim().isNotEmpty)
          _infoRow(context, l10n.phoneLabel, state.phone),
        if (location.trim().isNotEmpty)
          _infoRow(context, l10n.deliveryLocation, location),
        const SizedBox(height: AppDimensions.space12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: () => _confirmClear(context),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.clearSavedCheckoutInfo),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Text(
              value,
              textDirection: _isUrl(value) ? TextDirection.ltr : null,
            ),
          ),
        ],
      ),
    );
  }

  String _locationLabel() {
    if (state.deliveryMapLink.trim().isNotEmpty) {
      return state.deliveryMapLink.trim();
    }
    if (state.formattedAddress.trim().isNotEmpty) {
      return state.formattedAddress.trim();
    }
    if (state.address.trim().isNotEmpty) {
      return state.address.trim();
    }
    if (state.latitude != 0.0 && state.longitude != 0.0) {
      return '${state.latitude.toStringAsFixed(4)}, ${state.longitude.toStringAsFixed(4)}';
    }
    return '';
  }

  bool _isUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> _confirmClear(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearSavedCheckoutInfo),
        content: Text(l10n.clearSavedCheckoutInfoQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await context.read<CheckoutCubit>().clearSavedCustomerInfo();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.savedDataCleared),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
