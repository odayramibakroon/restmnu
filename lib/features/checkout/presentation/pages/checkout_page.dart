import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/navigation/app_page_route.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/whatsapp_message_builder.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../restaurant_info/domain/entities/branch.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_cubit.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_state.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../widgets/customer_info_form.dart';
import '../widgets/location_picker_section.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mapLinkController;

  @override
  void initState() {
    super.initState();
    final checkoutCubit = context.read<CheckoutCubit>();
    _nameController = TextEditingController(
      text: checkoutCubit.state.customerName,
    );
    _phoneController = TextEditingController(text: checkoutCubit.state.phone);
    _mapLinkController = TextEditingController(
      text: checkoutCubit.state.deliveryMapLink,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _mapLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, checkoutState) {
        if (checkoutState.status == CheckoutStatus.error &&
            checkoutState.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(checkoutState.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (checkoutState.status == CheckoutStatus.success &&
            checkoutState.createdOrder != null) {
          // Clear cart on success
          context.read<CartCubit>().clearCart();

          // Push success page
          Navigator.of(context).pushReplacement(
            AppPageRoute(
              page: OrderSuccessPage(order: checkoutState.createdOrder!),
            ),
          );
        }
      },
      builder: (context, checkoutState) {
        return BlocBuilder<RestaurantCubit, RestaurantState>(
          builder: (context, restaurantState) {
            if (restaurantState is! RestaurantLoaded) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final config = restaurantState.config;
            final branches = restaurantState.branches;

            return BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                return Scaffold(
                  appBar: AppBar(title: Text(l10n.checkoutTitle)),
                  body: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: ResponsiveLayout.isDesktop(context)
                          ? _buildDesktopLayout(
                              context,
                              checkoutState,
                              cartState,
                              config,
                              branches,
                              isDark,
                            )
                          : _buildMobileLayout(
                              context,
                              checkoutState,
                              cartState,
                              config,
                              branches,
                              isDark,
                            ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CheckoutState checkoutState,
    CartState cartState,
    dynamic config,
    List<Branch> branches,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: CustomerInfoForm(
              nameController: _nameController,
              phoneController: _phoneController,
              onNameChanged: (val) =>
                  context.read<CheckoutCubit>().setCustomerName(val),
              onPhoneChanged: (val) =>
                  context.read<CheckoutCubit>().setPhone(val),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 50),
            child: _buildBranchSelectorSection(
              context,
              checkoutState,
              branches,
              isDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 70),
            child: LocationPickerSection(
              formattedAddress: checkoutState.formattedAddress,
              deliveryMapLink: checkoutState.deliveryMapLink,
              latitude: checkoutState.latitude,
              longitude: checkoutState.longitude,
              isLoadingLocation:
                  checkoutState.status == CheckoutStatus.loadingLocation,
              mapLinkController: _mapLinkController,
              onUseCurrentLocation: () =>
                  context.read<CheckoutCubit>().fetchCurrentLocation(),
              onMapLinkChanged: (value) =>
                  context.read<CheckoutCubit>().setDeliveryMapLink(value),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: _buildOrderSummarySection(
              context,
              cartState,
              config.currency,
              isDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 170),
            child: _buildSubmitButton(
              context,
              checkoutState,
              cartState,
              config,
              branches,
            ),
          ),
          const SizedBox(height: AppDimensions.space40),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CheckoutState checkoutState,
    CartState cartState,
    dynamic config,
    List<Branch> branches,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Customer & Location forms (60%)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                FadeSlideIn(
                  child: CustomerInfoForm(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    onNameChanged: (val) =>
                        context.read<CheckoutCubit>().setCustomerName(val),
                    onPhoneChanged: (val) =>
                        context.read<CheckoutCubit>().setPhone(val),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 50),
                  child: _buildBranchSelectorSection(
                    context,
                    checkoutState,
                    branches,
                    isDark,
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 70),
                  child: LocationPickerSection(
                    formattedAddress: checkoutState.formattedAddress,
                    deliveryMapLink: checkoutState.deliveryMapLink,
                    latitude: checkoutState.latitude,
                    longitude: checkoutState.longitude,
                    isLoadingLocation:
                        checkoutState.status == CheckoutStatus.loadingLocation,
                    mapLinkController: _mapLinkController,
                    onUseCurrentLocation: () =>
                        context.read<CheckoutCubit>().fetchCurrentLocation(),
                    onMapLinkChanged: (value) =>
                        context.read<CheckoutCubit>().setDeliveryMapLink(value),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.space24),

          // Right side: Order Summary & Submit CTA (40%)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                FadeSlideIn(
                  delay: const Duration(milliseconds: 110),
                  child: _buildOrderSummarySection(
                    context,
                    cartState,
                    config.currency,
                    isDark,
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: _buildSubmitButton(
                    context,
                    checkoutState,
                    cartState,
                    config,
                    branches,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelectorSection(
    BuildContext context,
    CheckoutState checkoutState,
    List<Branch> branches,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final selectedBranchId =
        branches.any((branch) => branch.id == checkoutState.selectedBranchId)
        ? checkoutState.selectedBranchId
        : '';

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
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  l10n.branch,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),
            DropdownButtonFormField<String>(
              initialValue: selectedBranchId,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_city_rounded),
                errorText:
                    checkoutState.status == CheckoutStatus.error &&
                        checkoutState.errorMessage ==
                            ErrorMessages.message(AppErrorKey.selectBranch)
                    ? ErrorMessages.message(AppErrorKey.selectBranch)
                    : null,
              ),
              items: [
                DropdownMenuItem(value: '', child: Text(l10n.chooseBranch)),
                ...branches.map((branch) {
                  final name = LocalizedValues.selectForContext(
                    context,
                    ar: branch.nameAr,
                    en: branch.nameEn,
                  );
                  return DropdownMenuItem(value: branch.id, child: Text(name));
                }),
              ],
              onChanged: (value) => context
                  .read<CheckoutCubit>()
                  .setSelectedBranchId(value ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection(
    BuildContext context,
    CartState cartState,
    String currency,
    bool isDark,
  ) {
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
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  l10n.reviewOrder,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Items list
            ...cartState.items.map((cartItem) {
              final quantityLabel = Formatters.formatQuantity(
                cartItem.quantity,
                isWeight: cartItem.item.isSoldByWeight,
              );
              final unitSuffix = cartItem.item.isSoldByWeight
                  ? ' ${l10n.kiloShort}'
                  : '';
              final itemName = LocalizedValues.selectForContext(
                context,
                ar: cartItem.item.nameAr,
                en: cartItem.item.nameEn,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$quantityLabel$unitSuffix × $itemName${cartItem.selectedSize == null || cartItem.selectedSize!.isEmpty ? '' : ' - ${cartItem.selectedSize}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      Formatters.formatPrice(
                        cartItem.totalPrice,
                        currency: currency,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 24),

            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.subtotal,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  Formatters.formatPrice(
                    cartState.subtotal,
                    currency: currency,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Delivery
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.deliveryFees,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  Formatters.formatPrice(
                    cartState.deliveryPrice,
                    currency: currency,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const Divider(height: 24),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.finalTotal,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Formatters.formatPrice(cartState.total, currency: currency),
                  style: const TextStyle(
                    color: AppColors.price,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    CheckoutState checkoutState,
    CartState cartState,
    dynamic config,
    List<Branch> branches,
  ) {
    final isSubmitting = checkoutState.status == CheckoutStatus.submitting;
    final l10n = AppLocalizations.of(context)!;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.whatsApp,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      onPressed: isSubmitting
          ? null
          : () {
              context.read<CheckoutCubit>().submitOrderAndOpenWhatsApp(
                cartItems: cartState.items,
                subtotal: cartState.subtotal,
                deliveryPrice: cartState.deliveryPrice,
                total: cartState.total,
                config: config,
                branches: branches,
                whatsAppLabels: _whatsAppLabels(context),
              );
            },
      child: isSubmitting
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(width: 12),
                Text(l10n.preparingOrderWhatsapp),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.whatsapp, size: 22),
                const SizedBox(width: 10),
                Text(
                  l10n.sendOrderWhatsapp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}

WhatsAppOrderMessageLabels _whatsAppLabels(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return WhatsAppOrderMessageLabels(
    languageCode: Localizations.localeOf(context).languageCode,
    newOrderFrom: l10n.whatsappNewOrderFrom,
    referenceNumber: l10n.whatsappReferenceNumber,
    selectedBranch: l10n.whatsappSelectedBranch,
    customerInfo: l10n.whatsappCustomerInfo,
    customerName: l10n.whatsappCustomerName,
    customerPhone: l10n.whatsappCustomerPhone,
    deliveryLocation: l10n.whatsappDeliveryLocation,
    address: l10n.whatsappAddress,
    notSet: l10n.notSet,
    customMapLocation: l10n.customMapLocation,
    currentLocationLink: l10n.whatsappCurrentLocationLink,
    sentMapLink: l10n.whatsappSentMapLink,
    orderDetails: l10n.whatsappOrderDetails,
    kiloUnit: l10n.kiloUnit,
    pieceUnit: l10n.pieceUnit,
    kiloShort: l10n.kiloShort,
    sizeLabel: l10n.sizeLabel,
    itemType: l10n.whatsappItemType,
    quantity: l10n.whatsappQuantity,
    subtotal: l10n.whatsappSubtotal,
    deliveryPrice: l10n.whatsappDeliveryPrice,
    finalTotal: l10n.whatsappFinalTotal,
    thanksForChoosing: l10n.whatsappThanksForChoosing,
  );
}
