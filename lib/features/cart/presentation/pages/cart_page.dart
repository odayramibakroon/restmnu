import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/navigation/app_page_route.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_cubit.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_state.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';

class CartPage extends StatelessWidget {
  final VoidCallback onNavigateToMenu;

  const CartPage({super.key, required this.onNavigateToMenu});

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

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.cartTitle),
            actions: [
              BlocBuilder<CartCubit, CartState>(
                builder: (context, cartState) {
                  if (cartState.isNotEmpty) {
                    return TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.clearCart),
                            content: Text(l10n.clearCartQuestion),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l10n.cancel),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () {
                                  context.read<CartCubit>().clearCart();
                                  Navigator.pop(ctx);
                                },
                                child: Text(l10n.clear),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        size: 20,
                        color: AppColors.error,
                      ),
                      label: Text(
                        l10n.clear,
                        style: TextStyle(color: AppColors.error),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              if (cartState.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(
                              alpha: isDark ? 0.2 : 0.6,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space20),
                        Text(
                          l10n.emptyCartTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Text(
                          l10n.emptyCartDescription,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppDimensions.space24),
                        ElevatedButton.icon(
                          onPressed: onNavigateToMenu,
                          icon: const Icon(Icons.restaurant_menu),
                          label: Text(l10n.browseMenuNow),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(
                              220,
                              AppDimensions.buttonHeight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: ResponsiveLayout.isDesktop(context)
                      ? _buildDesktopLayout(context, cartState, currency)
                      : _buildMobileLayout(context, cartState, currency),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CartState cartState,
    String currency,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        children: [
          ...cartState.items.asMap().entries.map((entry) {
            final index = entry.key;
            final cartItem = entry.value;
            return FadeSlideIn(
              key: ValueKey(cartItem.key),
              delay: Duration(milliseconds: (index % 6) * 40),
              child: CartItemTile(
                cartItem: cartItem,
                currency: currency,
                onIncrease: () {
                  context.read<CartCubit>().increaseQuantity(cartItem.key);
                },
                onDecrease: () {
                  context.read<CartCubit>().decreaseQuantity(cartItem.key);
                },
                onQuantityChanged: (quantity) {
                  context.read<CartCubit>().updateQuantity(
                    cartItem.key,
                    quantity,
                  );
                },
                onRemove: () {
                  context.read<CartCubit>().removeItem(cartItem.key);
                },
              ),
            );
          }),
          const SizedBox(height: AppDimensions.space16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 140),
            child: CartSummaryCard(
              subtotal: cartState.subtotal,
              deliveryFee: cartState.deliveryPrice,
              total: cartState.total,
              currency: currency,
              onProceedToCheckout: () => _navigateToCheckout(context),
            ),
          ),
          const SizedBox(height: AppDimensions.space40),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CartState cartState,
    String currency,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items List (60% width)
          Expanded(
            flex: 6,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final cartItem = cartState.items[index];
                return FadeSlideIn(
                  key: ValueKey(cartItem.key),
                  delay: Duration(milliseconds: (index % 6) * 40),
                  child: CartItemTile(
                    cartItem: cartItem,
                    currency: currency,
                    onIncrease: () {
                      context.read<CartCubit>().increaseQuantity(cartItem.key);
                    },
                    onDecrease: () {
                      context.read<CartCubit>().decreaseQuantity(cartItem.key);
                    },
                    onQuantityChanged: (quantity) {
                      context.read<CartCubit>().updateQuantity(
                        cartItem.key,
                        quantity,
                      );
                    },
                    onRemove: () {
                      context.read<CartCubit>().removeItem(cartItem.key);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: AppDimensions.space24),

          // Order Summary Card (40% width)
          Expanded(
            flex: 4,
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: CartSummaryCard(
                subtotal: cartState.subtotal,
                deliveryFee: cartState.deliveryPrice,
                total: cartState.total,
                currency: currency,
                onProceedToCheckout: () => _navigateToCheckout(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    Navigator.of(context).push(AppPageRoute(page: const CheckoutPage()));
  }
}
