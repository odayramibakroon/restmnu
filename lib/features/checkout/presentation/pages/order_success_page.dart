import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../core/utils/whatsapp_message_builder.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_cubit.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_state.dart';
import '../../domain/entities/order_entity.dart';

class OrderSuccessPage extends StatelessWidget {
  final OrderEntity order;

  const OrderSuccessPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<RestaurantCubit, RestaurantState>(
      builder: (context, restaurantState) {
        String currency = '';
        if (restaurantState is RestaurantLoaded) {
          currency = restaurantState.config.currency;
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.orderReceived),
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.space24),
                  child: Column(
                    children: [
                      // Success Animation / Icon
                      FadeSlideIn(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 64,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space20),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 70),
                        child: Text(
                          l10n.orderReadyThanks,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space8),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          l10n.orderSentToBranchInfo,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space24),

                      // Order Summary Card
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 140),
                        child: Card(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.referenceNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                if (order.branchName.isNotEmpty) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${l10n.branch}:'),
                                      Text(
                                        order.branchName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${l10n.nameLabel}:'),
                                    Text(
                                      order.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${l10n.phoneLabel}:'),
                                    Text(
                                      order.phone,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${l10n.addressLabel}:'),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        order.formattedAddress.isNotEmpty
                                            ? order.formattedAddress
                                            : order.address,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (order.deliveryMapLink.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(l10n.mapLinkLabel),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          order.deliveryMapLink,
                                          textAlign: TextAlign.end,
                                          textDirection: TextDirection.ltr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(height: 24),
                                Text(
                                  l10n.orderedItems,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...order.items.map((item) {
                                  final quantityLabel =
                                      Formatters.formatQuantity(
                                        item.quantity,
                                        isWeight: item.unitType == 'weight',
                                      );
                                  final unitSuffix = item.unitType == 'weight'
                                      ? ' ${l10n.kiloShort}'
                                      : '';
                                  final itemName =
                                      LocalizedValues.selectForContext(
                                        context,
                                        ar: item.itemNameAr,
                                        en: item.itemNameEn,
                                      );

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '$quantityLabel$unitSuffix × $itemName${item.selectedSize == null || item.selectedSize!.isEmpty ? '' : ' - ${item.selectedSize}'}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          Formatters.formatPrice(
                                            item.total,
                                            currency: currency,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${l10n.grandTotal}:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      Formatters.formatPrice(
                                        order.total,
                                        currency: currency,
                                      ),
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
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space24),

                      // Re-open WhatsApp Action
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 190),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whatsApp,
                          ),
                          onPressed: () {
                            if (restaurantState is RestaurantLoaded) {
                              final phoneNumber = order
                                  .branchOrdersWhatsappNumber
                                  .trim();
                              if (phoneNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ErrorMessages.message(
                                        AppErrorKey.branchOrdersWhatsappMissing,
                                      ),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final msg =
                                  WhatsAppMessageBuilder.buildOrderMessage(
                                    order: order,
                                    config: restaurantState.config,
                                    labels: _whatsAppLabels(context),
                                  );
                              sl<WhatsAppService>().sendOrder(
                                phoneNumber: phoneNumber,
                                message: msg,
                              );
                            }
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            size: 20,
                          ),
                          label: Text(l10n.reopenWhatsapp),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space12),

                      // Return to Menu Action
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 230),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.home_rounded),
                          label: Text(l10n.backToMainMenu),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.space32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
