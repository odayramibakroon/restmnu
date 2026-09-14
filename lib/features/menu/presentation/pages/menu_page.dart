import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_cubit.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_state.dart';
import '../../domain/entities/menu_item.dart';
import '../cubit/menu_cubit.dart';
import '../cubit/menu_state.dart';
import '../widgets/category_selector.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_item_details_dialog.dart';
import '../widgets/menu_search_bar.dart';
import '../widgets/promo_banner.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback onNavigateToCart;

  const MenuPage({super.key, required this.onNavigateToCart});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<RestaurantCubit, RestaurantState>(
      builder: (context, restaurantState) {
        String restaurantName = l10n.foodMenu;
        String restaurantDesc = '';
        String currency = '';
        String logoUrl = '';

        if (restaurantState is RestaurantLoaded) {
          restaurantName = LocalizedValues.selectForContext(
            context,
            ar: restaurantState.config.storeNameAr,
            en: restaurantState.config.storeNameEn,
          );
          restaurantDesc = LocalizedValues.selectForContext(
            context,
            ar: restaurantState.config.storeDescriptionAr,
            en: restaurantState.config.storeDescriptionEn,
          );
          currency = restaurantState.config.currency;
          logoUrl = restaurantState.config.logoUrl;
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: innerBoxIsScrolled ? 2 : 0,
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  title: Row(
                    children: [
                      if (logoUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: logoUrl,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.restaurant_menu,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.restaurant_menu,
                          color: AppColors.primary,
                        ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Text(
                          restaurantName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    // Cart Icon with Badge
                    BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        final totalCount = cartState.totalItemCount;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.primary,
                                size: 26,
                              ),
                              onPressed: widget.onNavigateToCart,
                            ),
                            if (totalCount > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.price,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '$totalCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(width: AppDimensions.space8),
                  ],
                ),
              ];
            },
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: BlocBuilder<MenuCubit, MenuState>(
                  builder: (context, state) {
                    if (state is MenuLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is MenuError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.space24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.restaurant_rounded,
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
                                    context.read<MenuCubit>().loadMenuData(),
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.retry),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is MenuLoaded) {
                      return CustomScrollView(
                        slivers: [
                          // Search & Promo Banner
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: AppDimensions.space12),
                                FadeSlideIn(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.space16,
                                    ),
                                    child: MenuSearchBar(
                                      controller: _searchController,
                                      onChanged: (query) {
                                        context.read<MenuCubit>().searchItems(
                                          query,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 70),
                                  child: PromoBanner(
                                    restaurantName: restaurantName,
                                    description: restaurantDesc,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space20),
                                FadeSlideIn(
                                  delay: const Duration(milliseconds: 120),
                                  child: CategorySelector(
                                    categories: state.categories,
                                    selectedCategoryId:
                                        state.selectedCategoryId,
                                    onSelectCategory: (catId) {
                                      context.read<MenuCubit>().selectCategory(
                                        catId,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space16),
                              ],
                            ),
                          ),

                          // Menu items count & section header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.space16,
                                vertical: AppDimensions.space8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${l10n.availableMeals} (${state.filteredItems.length})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (state.searchQuery.isNotEmpty)
                                    Text(
                                      '${l10n.searchResultsFor} "${state.searchQuery}"',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Empty items state
                          if (state.filteredItems.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 60,
                                  horizontal: 24,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 64,
                                      color: isDark
                                          ? AppColors.textDisabledDark
                                          : AppColors.textDisabledLight,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space16,
                                    ),
                                    Text(
                                      l10n.noMealsMatchSearch,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    Text(
                                      l10n.tryOtherSearch,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            // Responsive Grid of Items
                            SliverPadding(
                              padding: const EdgeInsets.all(
                                AppDimensions.space16,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          ResponsiveLayout.getGridColumnCount(
                                            context,
                                          ),
                                      crossAxisSpacing: AppDimensions.space16,
                                      mainAxisSpacing: AppDimensions.space16,
                                      childAspectRatio:
                                          ResponsiveLayout.isMobile(context)
                                          ? 0.76
                                          : 0.82,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final item = state.filteredItems[index];
                                  return FadeSlideIn(
                                    key: ValueKey(item.id),
                                    delay: Duration(
                                      milliseconds: (index % 8) * 35,
                                    ),
                                    child: MenuItemCard(
                                      item: item,
                                      currency: currency,
                                      onAddToCart: () {
                                        if (item.sizes.isNotEmpty ||
                                            item.isSoldByWeight) {
                                          _showItemDetails(
                                            context,
                                            item,
                                            currency,
                                          );
                                        } else {
                                          context.read<CartCubit>().addItem(
                                            item,
                                          );
                                          _showAddedToCartMessage(
                                            context,
                                            LocalizedValues.selectForContext(
                                              context,
                                              ar: item.nameAr,
                                              en: item.nameEn,
                                            ),
                                          );
                                        }
                                      },
                                      onTap: () {
                                        _showItemDetails(
                                          context,
                                          item,
                                          currency,
                                        );
                                      },
                                    ),
                                  );
                                }, childCount: state.filteredItems.length),
                              ),
                            ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppDimensions.space40),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showItemDetails(
    BuildContext context,
    MenuItemEntity item,
    String currency,
  ) {
    MenuItemDetailsDialog.show(
      context,
      item: item,
      currency: currency,
      onAddToCart: (selectedItem, qty, selectedSize) {
        context.read<CartCubit>().addItem(
          selectedItem,
          quantity: qty,
          selectedSize: selectedSize,
        );
        final sizeSuffix = selectedSize == null || selectedSize.isEmpty
            ? ''
            : ' - $selectedSize';
        final quantityLabel = Formatters.formatQuantity(
          qty,
          isWeight: selectedItem.isSoldByWeight,
        );
        final unitSuffix = selectedItem.isSoldByWeight
            ? ' ${AppLocalizations.of(context)!.kiloShort}'
            : '';
        final itemName = LocalizedValues.selectForContext(
          context,
          ar: selectedItem.nameAr,
          en: selectedItem.nameEn,
        );
        _showAddedToCartMessage(
          context,
          '$quantityLabel$unitSuffix × "$itemName"$sizeSuffix',
        );
      },
    );
  }

  void _showAddedToCartMessage(BuildContext context, String itemLabel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$itemLabel ${AppLocalizations.of(context)!.addedToCartSuffix} 🛒',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.viewCart,
          textColor: Colors.white,
          onPressed: widget.onNavigateToCart,
        ),
      ),
    );
  }
}
