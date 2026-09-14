import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_state.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/restaurant_config.dart';

class RestaurantInfoPage extends StatelessWidget {
  const RestaurantInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<RestaurantCubit, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is RestaurantError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 54,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.space20),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<RestaurantCubit>().loadRestaurantInfo(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is RestaurantLoaded) {
          final config = state.config;
          final branches = state.branches;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final restaurantName = LocalizedValues.selectForContext(
            context,
            ar: config.storeNameAr,
            en: config.storeNameEn,
          );
          final restaurantDescription = LocalizedValues.selectForContext(
            context,
            ar: config.storeDescriptionAr,
            en: config.storeDescriptionEn,
          );

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      restaurantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                      ),
                    ),
                    centerTitle: true,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (config.logoUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: config.logoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.primaryDark),
                            errorWidget: (_, __, ___) =>
                                Container(color: AppColors.primaryDark),
                          )
                        else
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryDark,
                                  AppColors.primary,
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Restaurant Description & Quick Badges
                            FadeSlideIn(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusLarge,
                                  ),
                                  side: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppDimensions.space20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 28,
                                            backgroundColor:
                                                AppColors.primaryContainer,
                                            backgroundImage:
                                                config.logoUrl.isNotEmpty
                                                ? CachedNetworkImageProvider(
                                                    config.logoUrl,
                                                  )
                                                : null,
                                            child: config.logoUrl.isEmpty
                                                ? const Icon(
                                                    Icons.restaurant,
                                                    color: AppColors.primary,
                                                    size: 28,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(
                                            width: AppDimensions.space16,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  restaurantName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                if (config
                                                        .storeNameEn
                                                        .isNotEmpty &&
                                                    config.storeNameEn !=
                                                        restaurantName) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    config.storeNameEn,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (restaurantDescription.isNotEmpty) ...[
                                        const SizedBox(
                                          height: AppDimensions.space16,
                                        ),
                                        Text(
                                          restaurantDescription,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(height: 1.6),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.space20),

                            // Quick Contact Actions Bar
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 80),
                              child: Text(
                                l10n.contactUs,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space12),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 110),
                              child: _buildContactGrid(context, config),
                            ),

                            const SizedBox(height: AppDimensions.space24),

                            // Social Media Section
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 150),
                              child: Text(
                                l10n.followUs,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space12),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 180),
                              child: _buildSocialMediaRow(context, config),
                            ),

                            const SizedBox(height: AppDimensions.space24),

                            // Branches Section
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 220),
                              child: Text(
                                '${l10n.branches} (${branches.length})',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space12),
                            ...branches.asMap().entries.map((entry) {
                              return FadeSlideIn(
                                key: ValueKey(entry.value.id),
                                delay: Duration(
                                  milliseconds: 250 + (entry.key % 5) * 35,
                                ),
                                child: _buildBranchCard(
                                  context,
                                  entry.value,
                                  isDark,
                                ),
                              );
                            }),

                            const SizedBox(height: AppDimensions.space24),

                            // Delivery & Settings Info Card
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 260),
                              child: _buildAppSettingsCard(context, isDark),
                            ),

                            const SizedBox(height: AppDimensions.space40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContactGrid(BuildContext context, RestaurantConfig config) {
    final urlService = sl<UrlLauncherService>();

    return Row(
      children: [
        if (config.whatsappNumber.isNotEmpty)
          Expanded(
            child: _buildContactButton(
              context: context,
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 24,
              ),
              backgroundColor: AppColors.whatsApp,
              label: AppLocalizations.of(context)!.whatsapp,
              onTap: () {
                urlService.openUrl(
                  'https://wa.me/${config.whatsappNumber.replaceAll(RegExp(r'[^\d]'), '')}',
                );
              },
            ),
          ),
        const SizedBox(width: AppDimensions.space12),
        if (config.supportPhone.isNotEmpty)
          Expanded(
            child: _buildContactButton(
              context: context,
              icon: const Icon(
                Icons.phone_in_talk_rounded,
                color: Colors.white,
                size: 24,
              ),
              backgroundColor: AppColors.primary,
              label: AppLocalizations.of(context)!.directCall,
              onTap: () {
                urlService.makePhoneCall(config.supportPhone);
              },
            ),
          ),
        const SizedBox(width: AppDimensions.space12),
        if (config.supportEmail.isNotEmpty)
          Expanded(
            child: _buildContactButton(
              context: context,
              icon: const Icon(
                Icons.email_rounded,
                color: Colors.white,
                size: 24,
              ),
              backgroundColor: const Color(0xFF455A64),
              label: AppLocalizations.of(context)!.emailLabel,
              onTap: () {
                urlService.sendEmail(config.supportEmail);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required Widget icon,
    required Color backgroundColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: AppDimensions.space8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaRow(BuildContext context, RestaurantConfig config) {
    final urlService = sl<UrlLauncherService>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (config.facebookUrl.isNotEmpty)
          _buildSocialIcon(
            icon: const FaIcon(
              FontAwesomeIcons.facebookF,
              color: Color(0xFF1877F2),
              size: 22,
            ),
            color: const Color(0xFF1877F2),
            onTap: () => urlService.openUrl(config.facebookUrl),
          ),
        if (config.instagramUrl.isNotEmpty)
          _buildSocialIcon(
            icon: const FaIcon(
              FontAwesomeIcons.instagram,
              color: Color(0xFFE4405F),
              size: 22,
            ),
            color: const Color(0xFFE4405F),
            onTap: () => urlService.openUrl(config.instagramUrl),
          ),
        if (config.tiktokUrl.isNotEmpty)
          _buildSocialIcon(
            icon: const FaIcon(
              FontAwesomeIcons.tiktok,
              color: Color(0xFF000000),
              size: 22,
            ),
            color: const Color(0xFF000000),
            onTap: () => urlService.openUrl(config.tiktokUrl),
          ),
      ],
    );
  }

  Widget _buildSocialIcon({
    required Widget icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, Branch branch, bool isDark) {
    final urlService = sl<UrlLauncherService>();
    final branchName = LocalizedValues.selectForContext(
      context,
      ar: branch.nameAr,
      en: branch.nameEn,
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
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Text(
                    branchName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (branch.locationText.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.space12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      branch.locationText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            if (branch.phoneNumbers.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.space12),
              Wrap(
                spacing: 8,
                children: branch.phoneNumbers.map((phone) {
                  return ActionChip(
                    avatar: const Icon(
                      Icons.phone,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    label: Text(phone, style: const TextStyle(fontSize: 12)),
                    onPressed: () => urlService.makePhoneCall(phone),
                    backgroundColor: isDark
                        ? AppColors.cardDark
                        : AppColors.backgroundLight,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: AppDimensions.space16),
            if (branch.locationUrl.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => urlService.openUrl(branch.locationUrl),
                icon: const Icon(Icons.map_rounded, size: 18),
                label: Text(AppLocalizations.of(context)!.openGoogleMaps),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsCard(BuildContext context, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.dark_mode_outlined,
                color: AppColors.primary,
              ),
              title: Text(AppLocalizations.of(context)!.darkAppearance),
              trailing: Switch(
                value: context.watch<ThemeCubit>().state.isDarkMode,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
