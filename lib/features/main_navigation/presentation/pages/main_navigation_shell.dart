import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../menu/presentation/pages/menu_page.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_cubit.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_state.dart';
import '../../../restaurant_info/presentation/pages/restaurant_info_page.dart';
import '../../../settings/presentation/pages/user_settings_page.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      MenuPage(onNavigateToCart: () => _onTabTapped(1)),
      CartPage(onNavigateToMenu: () => _onTabTapped(0)),
      const RestaurantInfoPage(),
      const UserSettingsPage(),
    ];

    return BlocListener<RestaurantCubit, RestaurantState>(
      listener: (context, restaurantState) {
        if (restaurantState is RestaurantLoaded) {
          context.read<CartCubit>().setDeliveryPrice(
            restaurantState.config.defaultDeliveryPrice,
          );
        }
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          final cartCount = cartState.totalItemCount;

          return ResponsiveLayout(
            mobile: _buildMobileScaffold(context, pages, cartCount, isDark),
            tablet: _buildTabletScaffold(context, pages, cartCount, isDark),
            desktop: _buildDesktopScaffold(context, pages, cartCount, isDark),
          );
        },
      ),
    );
  }

  Widget _buildMobileScaffold(
    BuildContext context,
    List<Widget> pages,
    int cartCount,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _buildPageStack(pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primaryContainer.withValues(
            alpha: isDark ? 0.3 : 0.8,
          ),
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.restaurant_menu_outlined),
              selectedIcon: const Icon(
                Icons.restaurant_menu,
                color: AppColors.primary,
              ),
              label: l10n.navMenu,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: AppColors.price,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: AppColors.price,
                child: const Icon(Icons.shopping_bag, color: AppColors.primary),
              ),
              label: l10n.navCart,
            ),
            NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(
                Icons.storefront,
                color: AppColors.primary,
              ),
              label: l10n.navRestaurant,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(
                Icons.settings,
                color: AppColors.primary,
              ),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletScaffold(
    BuildContext context,
    List<Widget> pages,
    int cartCount,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            indicatorColor: AppColors.primaryContainer.withValues(
              alpha: isDark ? 0.3 : 0.8,
            ),
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.restaurant_menu_outlined),
                selectedIcon: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.primary,
                ),
                label: Text(l10n.navMenu),
              ),
              NavigationRailDestination(
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  backgroundColor: AppColors.price,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  backgroundColor: AppColors.price,
                  child: const Icon(
                    Icons.shopping_bag,
                    color: AppColors.primary,
                  ),
                ),
                label: Text(l10n.navCart),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.storefront_outlined),
                selectedIcon: const Icon(
                  Icons.storefront,
                  color: AppColors.primary,
                ),
                label: Text(l10n.navRestaurant),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(
                  Icons.settings,
                  color: AppColors.primary,
                ),
                label: Text(l10n.navSettings),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildPageStack(pages)),
        ],
      ),
    );
  }

  Widget _buildDesktopScaffold(
    BuildContext context,
    List<Widget> pages,
    int cartCount,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 200,
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            indicatorColor: AppColors.primaryContainer.withValues(
              alpha: isDark ? 0.3 : 0.8,
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.restaurant_menu_outlined),
                selectedIcon: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.primary,
                ),
                label: Text(l10n.navMainMenu),
              ),
              NavigationRailDestination(
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  backgroundColor: AppColors.price,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  backgroundColor: AppColors.price,
                  child: const Icon(
                    Icons.shopping_bag,
                    color: AppColors.primary,
                  ),
                ),
                label: Text(l10n.navShoppingCart),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.storefront_outlined),
                selectedIcon: const Icon(
                  Icons.storefront,
                  color: AppColors.primary,
                ),
                label: Text(l10n.navRestaurantInfo),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(
                  Icons.settings,
                  color: AppColors.primary,
                ),
                label: Text(l10n.navSettings),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildPageStack(pages)),
        ],
      ),
    );
  }

  Widget _buildPageStack(List<Widget> pages) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        for (int index = 0; index < pages.length; index++)
          TickerMode(enabled: _currentIndex == index, child: pages[index]),
      ],
    );
  }
}
