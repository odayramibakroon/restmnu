import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/admin_user_model.dart';
import '../../../menu/data/models/category_model.dart';
import '../../../menu/data/models/menu_item_model.dart';
import '../../../menu/presentation/cubit/menu_cubit.dart';
import '../../../restaurant_info/data/models/branch_model.dart';
import '../../../restaurant_info/data/models/restaurant_config_model.dart';
import '../../../restaurant_info/presentation/cubit/restaurant_cubit.dart';
import '../cubit/admin_auth_cubit.dart';
import '../cubit/admin_auth_state.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/admin_dashboard_state.dart';

const _decimalKeyboardType = TextInputType.numberWithOptions(decimal: true);

final _decimalInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminAuthCubit, AdminAuthState>(
      listener: (context, state) {
        if (state.status == AdminAuthStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == AdminAuthStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state.isAuthenticated) {
          return BlocProvider<AdminDashboardCubit>(
            create: (_) => sl<AdminDashboardCubit>()..load(),
            child: _AdminDashboardPage(userEmail: state.user?.email ?? ''),
          );
        }

        return _AdminLoginPage(
          isSubmitting: state.status == AdminAuthStatus.submitting,
        );
      },
    );
  }
}

class _AdminLoginPage extends StatefulWidget {
  final bool isSubmitting;

  const _AdminLoginPage({required this.isSubmitting});

  @override
  State<_AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<_AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminSettings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Card(
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
                          Icons.admin_panel_settings_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Text(
                          l10n.adminLogin,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space20),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: l10n.adminEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppDimensions.space20),
                    ElevatedButton.icon(
                      onPressed: widget.isSubmitting ? null : _submit,
                      icon: widget.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(
                        widget.isSubmitting ? l10n.loggingIn : l10n.login,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (widget.isSubmitting) return;

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorMessages.message(AppErrorKey.emailPasswordRequired),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AdminAuthCubit>().signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}

class _AdminDashboardPage extends StatelessWidget {
  final String userEmail;

  const _AdminDashboardPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AdminDashboardCubit, AdminDashboardState>(
      listener: (context, state) {
        if (state.success != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_adminSuccessMessage(l10n, state.success!)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<RestaurantCubit>().loadRestaurantInfo();
          context.read<MenuCubit>().loadMenuData();
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == AdminDashboardStatus.loading &&
            state.config == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state.status == AdminDashboardStatus.error &&
            state.config == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.adminDashboard)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Text(
                      state.errorMessage ??
                          ErrorMessages.message(
                            AppErrorKey.dashboardLoadFailed,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<AdminDashboardCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final config = state.config;
        if (config == null) return const SizedBox.shrink();

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.adminDashboard),
              actions: [
                if (userEmail.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space8,
                      ),
                      child: Text(
                        userEmail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: l10n.logout,
                  onPressed: () => context.read<AdminAuthCubit>().signOut(),
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.storefront_rounded),
                    text: l10n.restaurantTab,
                  ),
                  Tab(
                    icon: const Icon(Icons.category_rounded),
                    text: l10n.categoriesTab,
                  ),
                  Tab(
                    icon: const Icon(Icons.restaurant_menu_rounded),
                    text: l10n.itemsTab,
                  ),
                  Tab(
                    icon: const Icon(Icons.location_city_rounded),
                    text: l10n.branchesTab,
                  ),
                  Tab(
                    icon: const Icon(Icons.people_alt_rounded),
                    text: l10n.usersManagement,
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                TabBarView(
                  children: [
                    _RestaurantSettingsForm(
                      key: ValueKey(config.updatedAt.toIso8601String()),
                      config: config,
                    ),
                    _CategoriesAdminTab(
                      categories: state.categories,
                      menuItems: state.menuItems,
                    ),
                    _MenuItemsAdminTab(
                      categories: state.categories,
                      items: state.menuItems,
                    ),
                    _BranchesAdminTab(branches: state.branches),
                    _AdminUsersTab(
                      adminUsers: state.adminUsers,
                      currentUserEmail: userEmail,
                    ),
                  ],
                ),
                if (state.status == AdminDashboardStatus.saving)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.18),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RestaurantSettingsForm extends StatefulWidget {
  final RestaurantConfigModel config;

  const _RestaurantSettingsForm({super.key, required this.config});

  @override
  State<_RestaurantSettingsForm> createState() =>
      _RestaurantSettingsFormState();
}

class _RestaurantSettingsFormState extends State<_RestaurantSettingsForm> {
  late final TextEditingController _storeNameAr;
  late final TextEditingController _storeNameEn;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _descriptionEn;
  late final TextEditingController _whatsapp;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _facebook;
  late final TextEditingController _instagram;
  late final TextEditingController _tiktok;
  late final TextEditingController _delivery;
  late final TextEditingController _currency;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late final TextEditingController _savedAddress;
  bool _enableDarkMode = true;
  bool _removeLogo = false;
  XFile? _logoFile;

  @override
  void initState() {
    super.initState();
    final config = widget.config;
    _storeNameAr = TextEditingController(text: config.storeNameAr);
    _storeNameEn = TextEditingController(text: config.storeNameEn);
    _descriptionAr = TextEditingController(text: config.storeDescriptionAr);
    _descriptionEn = TextEditingController(text: config.storeDescriptionEn);
    _whatsapp = TextEditingController(text: config.whatsappNumber);
    _phone = TextEditingController(text: config.supportPhone);
    _email = TextEditingController(text: config.supportEmail);
    _facebook = TextEditingController(text: config.facebookUrl);
    _instagram = TextEditingController(text: config.instagramUrl);
    _tiktok = TextEditingController(text: config.tiktokUrl);
    _delivery = TextEditingController(
      text: config.defaultDeliveryPrice.toStringAsFixed(2),
    );
    _currency = TextEditingController(text: config.currency);
    _latitude = TextEditingController(
      text: config.savedDeliveryLocation.latitude.toString(),
    );
    _longitude = TextEditingController(
      text: config.savedDeliveryLocation.longitude.toString(),
    );
    _savedAddress = TextEditingController(
      text: config.savedDeliveryLocation.formattedAddress,
    );
    _enableDarkMode = config.enableDarkMode;
  }

  @override
  void dispose() {
    _storeNameAr.dispose();
    _storeNameEn.dispose();
    _descriptionAr.dispose();
    _descriptionEn.dispose();
    _whatsapp.dispose();
    _phone.dispose();
    _email.dispose();
    _facebook.dispose();
    _instagram.dispose();
    _tiktok.dispose();
    _delivery.dispose();
    _currency.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _savedAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, l10n.restaurantData),
              _responsiveFields([
                _textField(_storeNameAr, l10n.storeNameArabic),
                _textField(_storeNameEn, l10n.storeNameEnglish),
              ]),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _descriptionAr,
                l10n.storeDescriptionArabic,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _descriptionEn,
                l10n.storeDescriptionEnglish,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.space20),
              _imageControl(
                context: context,
                title: l10n.restaurantImage,
                imageUrl: _removeLogo ? '' : widget.config.logoUrl,
                selectedFile: _logoFile,
                onPick: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      _logoFile = picked;
                      _removeLogo = false;
                    });
                  }
                },
                onRemove: () {
                  setState(() {
                    _logoFile = null;
                    _removeLogo = true;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.space24),
              _sectionTitle(context, l10n.contactSocial),
              _responsiveFields([
                _textField(
                  _whatsapp,
                  l10n.supportWhatsapp,
                  textDirection: TextDirection.ltr,
                ),
                _textField(
                  _phone,
                  l10n.phoneNumber,
                  textDirection: TextDirection.ltr,
                ),
              ]),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _email,
                l10n.emailLabel,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: AppDimensions.space12),
              _responsiveFields([
                _textField(
                  _facebook,
                  l10n.facebookUrl,
                  textDirection: TextDirection.ltr,
                ),
                _textField(
                  _instagram,
                  l10n.instagramUrl,
                  textDirection: TextDirection.ltr,
                ),
                _textField(
                  _tiktok,
                  l10n.tiktokUrl,
                  textDirection: TextDirection.ltr,
                ),
              ]),
              const SizedBox(height: AppDimensions.space24),
              _sectionTitle(context, l10n.deliverySettings),
              _responsiveFields([
                _textField(
                  _delivery,
                  l10n.defaultDeliveryPrice,
                  keyboardType: TextInputType.number,
                ),
                _textField(_currency, l10n.currency),
              ]),
              const SizedBox(height: AppDimensions.space12),
              _responsiveFields([
                _textField(
                  _latitude,
                  l10n.savedRestaurantLatitude,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
                _textField(
                  _longitude,
                  l10n.savedRestaurantLongitude,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
              ]),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _savedAddress,
                l10n.savedRestaurantAddress,
                maxLines: 2,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _enableDarkMode,
                onChanged: (value) => setState(() => _enableDarkMode = value),
                title: Text(l10n.enableDarkMode),
              ),
              const SizedBox(height: AppDimensions.space20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.saveRestaurantData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final config = RestaurantConfigModel(
      storeNameAr: _storeNameAr.text.trim(),
      storeNameEn: _storeNameEn.text.trim(),
      storeDescriptionAr: _descriptionAr.text.trim(),
      storeDescriptionEn: _descriptionEn.text.trim(),
      logoUrl: _removeLogo ? '' : widget.config.logoUrl,
      whatsappNumber: _whatsapp.text.trim(),
      supportPhone: _phone.text.trim(),
      supportEmail: _email.text.trim(),
      facebookUrl: _facebook.text.trim(),
      instagramUrl: _instagram.text.trim(),
      tiktokUrl: _tiktok.text.trim(),
      defaultDeliveryPrice: _parseDouble(_delivery.text),
      savedDeliveryLocation: DeliveryLocationModel(
        latitude: _parseDouble(_latitude.text),
        longitude: _parseDouble(_longitude.text),
        formattedAddress: _savedAddress.text.trim(),
      ),
      currency: _currency.text.trim(),
      enableDarkMode: _enableDarkMode,
      updatedAt: DateTime.now(),
    );

    context.read<AdminDashboardCubit>().saveRestaurantConfig(
      config,
      logoFile: _logoFile,
      oldLogoUrl: widget.config.logoUrl,
    );
  }
}

class _CategoriesAdminTab extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<MenuItemModel> menuItems;

  const _CategoriesAdminTab({
    required this.categories,
    required this.menuItems,
  });

  @override
  State<_CategoriesAdminTab> createState() => _CategoriesAdminTabState();
}

class _CategoriesAdminTabState extends State<_CategoriesAdminTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _normalizeSearchText(_searchController.text);
    final filteredCategories = query.isEmpty
        ? widget.categories
        : widget.categories.where((category) {
            final haystack = _normalizeSearchText(
              [
                category.nameAr,
                category.nameEn,
                category.sortOrder.toString(),
                category.isActive ? l10n.active : l10n.inactive,
                category.isActive ? 'active' : 'hidden',
              ].join(' '),
            );
            return haystack.contains(query);
          }).toList();

    return _AdminListLayout(
      title: l10n.categories,
      actionLabel: l10n.addCategory,
      onAdd: () => _showCategoryDialog(context),
      filter: _adminSearchField(
        controller: _searchController,
        clearTooltip: l10n.searchClear,
        label: l10n.searchCategories,
        hintText: l10n.searchCategoriesHint,
        onChanged: (_) => setState(() {}),
        onClear: () {
          _searchController.clear();
          setState(() {});
        },
      ),
      isEmpty: widget.categories.isEmpty,
      emptyMessage: l10n.noCategoriesYet,
      children: filteredCategories.isEmpty
          ? [_adminEmptySearchResult(l10n.noCategoriesMatchSearch)]
          : filteredCategories.map((category) {
              final categoryName = LocalizedValues.selectForContext(
                context,
                ar: category.nameAr,
                en: category.nameEn,
              );
              final status = category.isActive ? l10n.active : l10n.inactive;

              return Card(
                margin: const EdgeInsets.only(bottom: AppDimensions.space12),
                child: ListTile(
                  leading: _adminImageThumb(
                    category.imageUrl,
                    Icons.category_rounded,
                  ),
                  title: Text(categoryName),
                  subtitle: Text(
                    '${l10n.order}: ${category.sortOrder} - $status',
                  ),
                  trailing: Wrap(
                    spacing: AppDimensions.space4,
                    children: [
                      IconButton(
                        tooltip: l10n.edit,
                        onPressed: () =>
                            _showCategoryDialog(context, category: category),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        onPressed: () async {
                          final hasLinkedItems = widget.menuItems.any(
                            (item) => item.categoryId == category.id,
                          );
                          if (hasLinkedItems) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ErrorMessages.message(
                                    AppErrorKey.cannotDeleteCategoryWithItems,
                                  ),
                                ),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final confirmed = await _confirmDelete(
                            context,
                            l10n.deleteCategoryQuestion,
                          );
                          if (confirmed && context.mounted) {
                            context.read<AdminDashboardCubit>().deleteCategory(
                              category,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final cubit = context.read<AdminDashboardCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _CategoryFormDialog(category: category),
      ),
    );
  }
}

class _MenuItemsAdminTab extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<MenuItemModel> items;

  const _MenuItemsAdminTab({required this.categories, required this.items});

  @override
  State<_MenuItemsAdminTab> createState() => _MenuItemsAdminTabState();
}

class _MenuItemsAdminTabState extends State<_MenuItemsAdminTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _normalizeSearchText(_searchController.text);
    final filteredItems = query.isEmpty
        ? widget.items
        : widget.items.where((item) {
            final categoryName = _categoryNameFor(context, item);
            final unitLabel = item.isSoldByWeight
                ? l10n.kiloUnit
                : l10n.pieceUnit;
            final haystack = _normalizeSearchText(
              [
                item.nameAr,
                item.nameEn,
                item.descriptionAr,
                item.descriptionEn,
                categoryName,
                unitLabel,
                item.sizes.join(' '),
                item.price.toString(),
                item.displayPrice.toString(),
              ].join(' '),
            );
            return haystack.contains(query);
          }).toList();

    return _AdminListLayout(
      title: l10n.items,
      actionLabel: l10n.addItem,
      onAdd: widget.categories.isEmpty ? null : () => _showItemDialog(context),
      filter: _adminSearchField(
        controller: _searchController,
        clearTooltip: l10n.searchClear,
        label: l10n.searchItems,
        hintText: l10n.searchItemsHint,
        onChanged: (_) => setState(() {}),
        onClear: () {
          _searchController.clear();
          setState(() {});
        },
      ),
      isEmpty: widget.items.isEmpty,
      emptyMessage: l10n.noItemsYet,
      children: filteredItems.isEmpty
          ? [_adminEmptySearchResult(l10n.noItemsMatchSearch)]
          : filteredItems.map((item) {
              final categoryName = _categoryNameFor(context, item);
              final itemName = LocalizedValues.selectForContext(
                context,
                ar: item.nameAr,
                en: item.nameEn,
              );
              final unitLabel = item.isSoldByWeight
                  ? l10n.kiloUnit
                  : l10n.pieceUnit;
              final sizesLabel = item.sizes.isEmpty
                  ? ''
                  : ' - ${l10n.sizes}: ${item.sizes.map((size) {
                      final sizePrice = item.sizePrices[size];
                      if (sizePrice == null) return size;
                      return '$size (${sizePrice.toStringAsFixed(2)})';
                    }).join(', ')}';

              return Card(
                margin: const EdgeInsets.only(bottom: AppDimensions.space12),
                child: ListTile(
                  leading: _adminImageThumb(
                    item.imageUrl,
                    Icons.fastfood_rounded,
                  ),
                  title: Text(itemName),
                  subtitle: Text(
                    '$categoryName - ${item.displayPrice.toStringAsFixed(2)} - $unitLabel$sizesLabel',
                  ),
                  trailing: Wrap(
                    spacing: AppDimensions.space4,
                    children: [
                      IconButton(
                        tooltip: l10n.edit,
                        onPressed: () => _showItemDialog(context, item: item),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        onPressed: () async {
                          final confirmed = await _confirmDelete(
                            context,
                            l10n.deleteItemQuestion,
                          );
                          if (confirmed && context.mounted) {
                            context.read<AdminDashboardCubit>().deleteMenuItem(
                              item,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
    );
  }

  void _showItemDialog(BuildContext context, {MenuItemModel? item}) {
    final cubit = context.read<AdminDashboardCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _MenuItemFormDialog(item: item, categories: widget.categories),
      ),
    );
  }

  String _categoryNameFor(BuildContext context, MenuItemModel item) {
    final l10n = AppLocalizations.of(context)!;
    final matchingCategories = widget.categories.where(
      (category) => category.id == item.categoryId,
    );
    if (matchingCategories.isEmpty) return l10n.noCategory;

    final category = matchingCategories.first;
    return LocalizedValues.selectForContext(
      context,
      ar: category.nameAr,
      en: category.nameEn,
    );
  }
}

class _BranchesAdminTab extends StatelessWidget {
  final List<BranchModel> branches;

  const _BranchesAdminTab({required this.branches});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _AdminListLayout(
      title: l10n.branchesAdmin,
      actionLabel: l10n.addBranch,
      onAdd: () => _showBranchDialog(context),
      isEmpty: branches.isEmpty,
      emptyMessage: l10n.noBranchesYet,
      children: branches.map((branch) {
        final branchName = LocalizedValues.selectForContext(
          context,
          ar: branch.nameAr,
          en: branch.nameEn,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.space12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.storefront_rounded, color: AppColors.primary),
            ),
            title: Text(branchName),
            subtitle: Text(
              '${branch.locationText}\n${l10n.phoneLabel}: ${branch.phoneNumbers.join(' - ')} | ${l10n.ordersWhatsapp}: ${branch.ordersWhatsappNumber.isEmpty ? l10n.notSet : branch.ordersWhatsappNumber}',
            ),
            isThreeLine: true,
            trailing: Wrap(
              spacing: AppDimensions.space4,
              children: [
                IconButton(
                  tooltip: l10n.edit,
                  onPressed: () => _showBranchDialog(context, branch: branch),
                  icon: const Icon(Icons.edit_rounded),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: () async {
                    final confirmed = await _confirmDelete(
                      context,
                      l10n.deleteBranchQuestion,
                    );
                    if (confirmed && context.mounted) {
                      context.read<AdminDashboardCubit>().deleteBranch(branch);
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showBranchDialog(BuildContext context, {BranchModel? branch}) {
    final cubit = context.read<AdminDashboardCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _BranchFormDialog(branch: branch),
      ),
    );
  }
}

class _AdminUsersTab extends StatelessWidget {
  final List<AdminUserModel> adminUsers;
  final String currentUserEmail;

  const _AdminUsersTab({
    required this.adminUsers,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _AdminListLayout(
      title: l10n.usersManagement,
      actionLabel: l10n.addAdmin,
      onAdd: () => _showAdminUserDialog(context),
      isEmpty: adminUsers.isEmpty,
      emptyMessage: l10n.noUsersYet,
      children: adminUsers.map((adminUser) {
        final title = adminUser.displayName.isEmpty
            ? adminUser.email
            : adminUser.displayName;
        final isCurrentUser = adminUser.email == currentUserEmail;

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.space12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: adminUser.isActive
                  ? AppColors.primaryContainer
                  : AppColors.borderLight,
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: adminUser.isActive
                    ? AppColors.primary
                    : AppColors.textSecondaryLight,
              ),
            ),
            title: Text(title),
            subtitle: Text(
              '${adminUser.email}\n'
              '${l10n.phoneLabel}: ${adminUser.phone.isEmpty ? l10n.notSet : adminUser.phone} | '
              '${adminUser.isActive ? l10n.active : l10n.disabled}'
              '${isCurrentUser ? ' | ${l10n.currentAccount}' : ''}',
            ),
            isThreeLine: true,
            trailing: Wrap(
              spacing: AppDimensions.space4,
              children: [
                IconButton(
                  tooltip: l10n.edit,
                  onPressed: () =>
                      _showAdminUserDialog(context, adminUser: adminUser),
                  icon: const Icon(Icons.edit_rounded),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: isCurrentUser
                      ? null
                      : () async {
                          final confirmed = await _confirmDelete(
                            context,
                            l10n.deleteAdminQuestion,
                          );
                          if (confirmed && context.mounted) {
                            context.read<AdminDashboardCubit>().deleteAdminUser(
                              adminUser,
                            );
                          }
                        },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAdminUserDialog(BuildContext context, {AdminUserModel? adminUser}) {
    final cubit = context.read<AdminDashboardCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _AdminUserFormDialog(adminUser: adminUser),
      ),
    );
  }
}

class _AdminUserFormDialog extends StatefulWidget {
  final AdminUserModel? adminUser;

  const _AdminUserFormDialog({this.adminUser});

  @override
  State<_AdminUserFormDialog> createState() => _AdminUserFormDialogState();
}

class _AdminUserFormDialogState extends State<_AdminUserFormDialog> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _displayName;
  late final TextEditingController _phone;
  bool _isActive = true;

  bool get _isEditing => widget.adminUser != null;

  @override
  void initState() {
    super.initState();
    final adminUser = widget.adminUser;
    _email = TextEditingController(text: adminUser?.email ?? '');
    _password = TextEditingController();
    _displayName = TextEditingController(text: adminUser?.displayName ?? '');
    _phone = TextEditingController(text: adminUser?.phone ?? '');
    _isActive = adminUser?.isActive ?? true;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(_isEditing ? l10n.editAdmin : l10n.addAdmin),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _email,
                enabled: !_isEditing,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l10n.adminEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              if (!_isEditing) ...[
                const SizedBox(height: AppDimensions.space12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.space12),
              _textField(_displayName, l10n.adminName),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _phone,
                l10n.phoneNumber,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: Text(l10n.accountActive),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  void _save() {
    final email = _email.text.trim();
    final password = _password.text;
    final displayName = _displayName.text.trim();

    if (!_isValidEmail(email)) {
      _showError(ErrorMessages.message(AppErrorKey.validAdminEmailRequired));
      return;
    }

    if (!_isEditing && password.length < 6) {
      _showError(ErrorMessages.message(AppErrorKey.adminPasswordMinLength));
      return;
    }

    if (displayName.length < 2) {
      _showError(ErrorMessages.message(AppErrorKey.adminNameRequired));
      return;
    }

    final cubit = context.read<AdminDashboardCubit>();
    final adminUser = widget.adminUser;

    if (adminUser == null) {
      cubit.createAdminUser(
        email: email,
        password: password,
        displayName: displayName,
        phone: _phone.text.trim(),
        isActive: _isActive,
      );
    } else {
      cubit.saveAdminUser(
        adminUser.copyWith(
          displayName: displayName,
          phone: _phone.text.trim(),
          isActive: _isActive,
          updatedAt: DateTime.now(),
        ),
      );
    }

    Navigator.pop(context);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;

  const _CategoryFormDialog({this.category});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late final TextEditingController _nameAr;
  late final TextEditingController _nameEn;
  late final TextEditingController _sortOrder;
  bool _isActive = true;
  bool _removeImage = false;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameAr = TextEditingController(text: category?.nameAr ?? '');
    _nameEn = TextEditingController(text: category?.nameEn ?? '');
    _sortOrder = TextEditingController(
      text: (category?.sortOrder ?? 0).toString(),
    );
    _isActive = category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        widget.category == null ? l10n.addCategory : l10n.editCategory,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _textField(_nameAr, l10n.categoryNameArabic),
              const SizedBox(height: AppDimensions.space12),
              _textField(_nameEn, l10n.categoryNameEnglish),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _sortOrder,
                l10n.displayOrder,
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: Text(l10n.categoryActive),
              ),
              _imageControl(
                context: context,
                title: l10n.categoryImage,
                imageUrl: _removeImage ? '' : widget.category?.imageUrl ?? '',
                selectedFile: _imageFile,
                onPick: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      _imageFile = picked;
                      _removeImage = false;
                    });
                  }
                },
                onRemove: () {
                  setState(() {
                    _imageFile = null;
                    _removeImage = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  void _save() {
    final id =
        widget.category?.id ?? 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final category = CategoryModel(
      id: id,
      nameAr: _nameAr.text.trim(),
      nameEn: _nameEn.text.trim(),
      imageUrl: _removeImage ? '' : widget.category?.imageUrl ?? '',
      sortOrder: _parseInt(_sortOrder.text),
      isActive: _isActive,
    );

    context.read<AdminDashboardCubit>().saveCategory(
      category,
      imageFile: _imageFile,
      oldImageUrl: widget.category?.imageUrl ?? '',
    );
    Navigator.pop(context);
  }
}

class _SizePriceControllers {
  final TextEditingController name;
  final TextEditingController price;

  _SizePriceControllers({String initialName = '', String initialPrice = ''})
    : name = TextEditingController(text: initialName),
      price = TextEditingController(text: initialPrice);

  void dispose() {
    name.dispose();
    price.dispose();
  }
}

class _MenuItemFormDialog extends StatefulWidget {
  final MenuItemModel? item;
  final List<CategoryModel> categories;

  const _MenuItemFormDialog({this.item, required this.categories});

  @override
  State<_MenuItemFormDialog> createState() => _MenuItemFormDialogState();
}

class _MenuItemFormDialogState extends State<_MenuItemFormDialog> {
  late String _categoryId;
  late String _unitType;
  late final TextEditingController _nameAr;
  late final TextEditingController _nameEn;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _descriptionEn;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _sortOrder;
  final List<_SizePriceControllers> _sizeRows = [];
  bool _isPopular = false;
  bool _isNew = false;
  bool _isAvailable = true;
  bool _isActive = true;
  bool _removeImage = false;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final initialCategoryId = item?.categoryId;
    _categoryId =
        initialCategoryId != null &&
            widget.categories.any(
              (category) => category.id == initialCategoryId,
            )
        ? initialCategoryId
        : widget.categories.first.id;
    _unitType = item?.unitType ?? 'piece';
    _nameAr = TextEditingController(text: item?.nameAr ?? '');
    _nameEn = TextEditingController(text: item?.nameEn ?? '');
    _descriptionAr = TextEditingController(text: item?.descriptionAr ?? '');
    _descriptionEn = TextEditingController(text: item?.descriptionEn ?? '');
    _price = TextEditingController(text: item?.price.toStringAsFixed(2) ?? '');
    _oldPrice = TextEditingController(
      text: item?.oldPrice?.toStringAsFixed(2) ?? '',
    );
    _sortOrder = TextEditingController(text: (item?.sortOrder ?? 0).toString());
    for (final size in item?.sizes ?? const <String>[]) {
      final sizePrice = item?.sizePrices[size];
      _sizeRows.add(
        _SizePriceControllers(
          initialName: size,
          initialPrice: sizePrice == null ? '' : sizePrice.toStringAsFixed(2),
        ),
      );
    }
    _isPopular = item?.isPopular ?? false;
    _isNew = item?.isNew ?? false;
    _isAvailable = item?.isAvailable ?? true;
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _descriptionAr.dispose();
    _descriptionEn.dispose();
    _price.dispose();
    _oldPrice.dispose();
    _sortOrder.dispose();
    for (final row in _sizeRows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.item == null ? l10n.addItem : l10n.editItem),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: InputDecoration(labelText: l10n.category),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(
                      LocalizedValues.selectForContext(
                        context,
                        ar: category.nameAr,
                        en: category.nameEn,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _categoryId = value);
                },
              ),
              const SizedBox(height: AppDimensions.space12),
              _textField(_nameAr, l10n.itemNameArabic),
              const SizedBox(height: AppDimensions.space12),
              _textField(_nameEn, l10n.itemNameEnglish),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _descriptionAr,
                l10n.itemDescriptionArabic,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _descriptionEn,
                l10n.itemDescriptionEnglish,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.space12),
              _responsiveFields([
                _textField(
                  _price,
                  _unitType == 'weight'
                      ? l10n.defaultKiloPrice
                      : l10n.basePrice,
                  keyboardType: _decimalKeyboardType,
                  inputFormatters: _decimalInputFormatters,
                ),
                _textField(
                  _oldPrice,
                  l10n.oldPriceOptional,
                  keyboardType: _decimalKeyboardType,
                  inputFormatters: _decimalInputFormatters,
                ),
                _textField(
                  _sortOrder,
                  l10n.displayOrder,
                  keyboardType: TextInputType.number,
                ),
              ]),
              const SizedBox(height: AppDimensions.space12),
              DropdownButtonFormField<String>(
                initialValue: _unitType,
                decoration: InputDecoration(labelText: l10n.sellMethod),
                items: [
                  DropdownMenuItem(value: 'piece', child: Text(l10n.pieceUnit)),
                  DropdownMenuItem(value: 'weight', child: Text(l10n.kiloUnit)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _unitType = value);
                },
              ),
              const SizedBox(height: AppDimensions.space12),
              _buildSizePricesSection(),
              const SizedBox(height: AppDimensions.space12),
              Wrap(
                spacing: AppDimensions.space8,
                runSpacing: AppDimensions.space4,
                children: [
                  FilterChip(
                    label: Text(l10n.popular),
                    selected: _isPopular,
                    onSelected: (value) => setState(() => _isPopular = value),
                  ),
                  FilterChip(
                    label: Text(l10n.newItem),
                    selected: _isNew,
                    onSelected: (value) => setState(() => _isNew = value),
                  ),
                  FilterChip(
                    label: Text(l10n.available),
                    selected: _isAvailable,
                    onSelected: (value) => setState(() => _isAvailable = value),
                  ),
                  FilterChip(
                    label: Text(l10n.activeItem),
                    selected: _isActive,
                    onSelected: (value) => setState(() => _isActive = value),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),
              _imageControl(
                context: context,
                title: l10n.itemImage,
                imageUrl: _removeImage ? '' : widget.item?.imageUrl ?? '',
                selectedFile: _imageFile,
                onPick: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      _imageFile = picked;
                      _removeImage = false;
                    });
                  }
                },
                onRemove: () {
                  setState(() {
                    _imageFile = null;
                    _removeImage = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  void _save() {
    final id =
        widget.item?.id ?? 'item_${DateTime.now().millisecondsSinceEpoch}';
    final imageUrl = _removeImage ? '' : widget.item?.imageUrl ?? '';
    final sizePrices = _collectSizePrices();
    if (sizePrices == null) return;

    final sizes = sizePrices.keys.toList();
    final basePrice = sizes.isEmpty
        ? _parseDouble(_price.text)
        : sizePrices[sizes.first]!;
    final item = MenuItemModel(
      id: id,
      categoryId: _categoryId,
      nameAr: _nameAr.text.trim(),
      nameEn: _nameEn.text.trim(),
      descriptionAr: _descriptionAr.text.trim(),
      descriptionEn: _descriptionEn.text.trim(),
      price: basePrice,
      oldPrice: _oldPrice.text.trim().isEmpty
          ? null
          : _parseDouble(_oldPrice.text),
      imageUrl: imageUrl,
      images: imageUrl.isEmpty ? const [] : [imageUrl],
      isPopular: _isPopular,
      isNew: _isNew,
      isAvailable: _isAvailable,
      isActive: _isActive,
      sortOrder: _parseInt(_sortOrder.text),
      unitType: _unitType,
      sizes: sizes,
      sizePrices: sizePrices,
    );

    context.read<AdminDashboardCubit>().saveMenuItem(
      item,
      imageFile: _imageFile,
      oldImageUrl: widget.item?.imageUrl ?? '',
      oldImages: widget.item?.images ?? const [],
    );
    Navigator.pop(context);
  }

  Widget _buildSizePricesSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.sizesAndPrices,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: _addSizeRow,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addSize),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        if (_sizeRows.isEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l10n.noSizesAdded,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          ...List.generate(_sizeRows.length, (index) {
            final row = _sizeRows[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: row.name,
                      decoration: InputDecoration(
                        labelText: l10n.sizeName,
                        hintText: l10n.sizeExample,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: row.price,
                      keyboardType: _decimalKeyboardType,
                      inputFormatters: _decimalInputFormatters,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(labelText: l10n.sizePrice),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space4),
                  IconButton(
                    tooltip: l10n.deleteSize,
                    onPressed: () => _removeSizeRow(index),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _addSizeRow() {
    setState(() => _sizeRows.add(_SizePriceControllers()));
  }

  void _removeSizeRow(int index) {
    final row = _sizeRows.removeAt(index);
    row.dispose();
    setState(() {});
  }

  Map<String, double>? _collectSizePrices() {
    final result = <String, double>{};

    for (final row in _sizeRows) {
      final size = row.name.text.trim();
      final priceText = row.price.text.trim();

      if (size.isEmpty && priceText.isEmpty) continue;
      if (size.isEmpty || priceText.isEmpty) {
        _showValidationMessage(
          ErrorMessages.message(AppErrorKey.sizeNameAndPriceRequired),
        );
        return null;
      }

      if (result.containsKey(size)) {
        _showValidationMessage(
          ErrorMessages.message(AppErrorKey.duplicateSizeName),
        );
        return null;
      }

      final price = _tryParseDouble(priceText);
      if (price == null || price <= 0) {
        _showValidationMessage(
          ErrorMessages.message(AppErrorKey.validSizePriceRequired),
        );
        return null;
      }

      result[size] = price;
    }

    return result;
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _BranchFormDialog extends StatefulWidget {
  final BranchModel? branch;

  const _BranchFormDialog({this.branch});

  @override
  State<_BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<_BranchFormDialog> {
  late final TextEditingController _nameAr;
  late final TextEditingController _nameEn;
  late final TextEditingController _phones;
  late final TextEditingController _ordersWhatsapp;
  late final TextEditingController _locationText;
  late final TextEditingController _locationUrl;
  late final TextEditingController _sortOrder;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final branch = widget.branch;
    _nameAr = TextEditingController(text: branch?.nameAr ?? '');
    _nameEn = TextEditingController(text: branch?.nameEn ?? '');
    _phones = TextEditingController(
      text: branch?.phoneNumbers.join(', ') ?? '',
    );
    _ordersWhatsapp = TextEditingController(
      text: branch?.ordersWhatsappNumber ?? '',
    );
    _locationText = TextEditingController(text: branch?.locationText ?? '');
    _locationUrl = TextEditingController(text: branch?.locationUrl ?? '');
    _sortOrder = TextEditingController(
      text: (branch?.sortOrder ?? 0).toString(),
    );
    _isActive = branch?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _phones.dispose();
    _ordersWhatsapp.dispose();
    _locationText.dispose();
    _locationUrl.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.branch == null ? l10n.addBranch : l10n.editBranch),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _textField(_nameAr, l10n.branchNameArabic),
              const SizedBox(height: AppDimensions.space12),
              _textField(_nameEn, l10n.branchNameEnglish),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _phones,
                l10n.phoneNumbers,
                hintText: l10n.separateWithCommaOrLine,
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _ordersWhatsapp,
                l10n.branchOrdersWhatsapp,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: AppDimensions.space12),
              _textField(_locationText, l10n.branchAddress, maxLines: 2),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _locationUrl,
                l10n.googleMapsUrl,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: AppDimensions.space12),
              _textField(
                _sortOrder,
                l10n.displayOrder,
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: Text(l10n.branchActive),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  void _save() {
    if (_ordersWhatsapp.text.trim().isEmpty) {
      _showError(
        ErrorMessages.message(AppErrorKey.branchOrdersWhatsappRequired),
      );
      return;
    }

    if (!_isValidWhatsappNumber(_ordersWhatsapp.text)) {
      _showError(
        ErrorMessages.message(AppErrorKey.branchOrdersWhatsappInvalidInput),
      );
      return;
    }

    final id =
        widget.branch?.id ?? 'branch_${DateTime.now().millisecondsSinceEpoch}';
    final branch = BranchModel(
      id: id,
      nameAr: _nameAr.text.trim(),
      nameEn: _nameEn.text.trim(),
      phoneNumbers: _parseList(_phones.text),
      ordersWhatsappNumber: _ordersWhatsapp.text.trim(),
      locationUrl: _locationUrl.text.trim(),
      locationText: _locationText.text.trim(),
      sortOrder: _parseInt(_sortOrder.text),
      isActive: _isActive,
    );

    context.read<AdminDashboardCubit>().saveBranch(branch);
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isValidWhatsappNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 8 && digitsOnly.length <= 15;
  }
}

class _AdminListLayout extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAdd;
  final Widget? filter;
  final bool isEmpty;
  final String emptyMessage;
  final List<Widget> children;

  const _AdminListLayout({
    required this.title,
    required this.actionLabel,
    required this.onAdd,
    this.filter,
    required this.isEmpty,
    required this.emptyMessage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _sectionTitle(context, title)),
                  ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(actionLabel),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),
              if (filter != null) ...[
                filter!,
                const SizedBox(height: AppDimensions.space16),
              ],
              if (isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space32),
                    child: Text(emptyMessage),
                  ),
                )
              else
                ...children,
            ],
          ),
        ),
      ),
    );
  }
}

Widget _sectionTitle(BuildContext context, String title) {
  return Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
  );
}

Widget _adminSearchField({
  required TextEditingController controller,
  required String clearTooltip,
  required String label,
  required String hintText,
  required ValueChanged<String> onChanged,
  required VoidCallback onClear,
}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: controller.text.trim().isEmpty
          ? null
          : IconButton(
              tooltip: clearTooltip,
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
            ),
    ),
  );
}

Widget _adminEmptySearchResult(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.space32),
      child: Text(message),
    ),
  );
}

Widget _textField(
  TextEditingController controller,
  String label, {
  String? hintText,
  int maxLines = 1,
  TextInputType? keyboardType,
  TextDirection? textDirection,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    textDirection: textDirection,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(labelText: label, hintText: hintText),
  );
}

Widget _responsiveFields(List<Widget> children) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 680) {
        return Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                const SizedBox(height: AppDimensions.space12),
            ],
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i != children.length - 1)
              const SizedBox(width: AppDimensions.space12),
          ],
        ],
      );
    },
  );
}

Widget _imageControl({
  required BuildContext context,
  required String title,
  required String imageUrl,
  required XFile? selectedFile,
  required VoidCallback onPick,
  required VoidCallback onRemove,
}) {
  final hasImage = imageUrl.isNotEmpty || selectedFile != null;
  final l10n = AppLocalizations.of(context)!;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: Row(
        children: [
          _adminImageThumb(imageUrl, Icons.image_rounded),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (selectedFile != null)
                  Text(
                    selectedFile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else if (imageUrl.isNotEmpty)
                  Text(
                    imageUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_rounded),
            label: Text(l10n.choose),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
          ),
          const SizedBox(width: AppDimensions.space8),
          IconButton(
            tooltip: l10n.deleteImage,
            onPressed: hasImage ? onRemove : null,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _adminImageThumb(String imageUrl, IconData fallbackIcon) {
  return CircleAvatar(
    radius: 24,
    backgroundColor: AppColors.primaryContainer,
    backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
    child: imageUrl.isEmpty
        ? Icon(fallbackIcon, color: AppColors.primary)
        : null,
  );
}

Future<bool> _confirmDelete(BuildContext context, String title) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(l10n.confirmDeleteIrreversible),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );

  return result ?? false;
}

String _adminSuccessMessage(
  AppLocalizations l10n,
  AdminDashboardSuccess success,
) {
  return switch (success) {
    AdminDashboardSuccess.restaurantSaved => l10n.adminSavedRestaurantData,
    AdminDashboardSuccess.categorySaved => l10n.adminSavedCategory,
    AdminDashboardSuccess.categoryDeleted => l10n.adminDeletedCategory,
    AdminDashboardSuccess.itemSaved => l10n.adminSavedItem,
    AdminDashboardSuccess.itemDeleted => l10n.adminDeletedItem,
    AdminDashboardSuccess.branchSaved => l10n.adminSavedBranch,
    AdminDashboardSuccess.branchDeleted => l10n.adminDeletedBranch,
    AdminDashboardSuccess.adminCreated => l10n.adminCreatedAdmin,
    AdminDashboardSuccess.adminSaved => l10n.adminSavedAdmin,
    AdminDashboardSuccess.adminDeleted => l10n.adminDeletedAdmin,
  };
}

String _normalizeSearchText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('\u0623', '\u0627')
      .replaceAll('\u0625', '\u0627')
      .replaceAll('\u0622', '\u0627')
      .replaceAll('\u0649', '\u064A')
      .replaceAll('\u0629', '\u0647')
      .replaceAll(RegExp(r'\s+'), ' ');
}

double _parseDouble(String value) {
  return _tryParseDouble(value) ?? 0.0;
}

double? _tryParseDouble(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

int _parseInt(String value) {
  return int.tryParse(value.trim()) ?? 0;
}

List<String> _parseList(String value) {
  return value
      .split(RegExp(r'[\n,،]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
