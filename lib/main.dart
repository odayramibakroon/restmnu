import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'firebase_options.dart';
import 'core/config/supabase_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/errors/error_messages.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'l10n/app_localizations.dart';
import 'features/restaurant_info/presentation/cubit/restaurant_cubit.dart';
import 'features/menu/presentation/cubit/menu_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/checkout/presentation/cubit/checkout_cubit.dart';
import 'features/main_navigation/presentation/pages/main_navigation_shell.dart';

const _startupStepTimeout = Duration(seconds: 12);
const _dependencyStartupTimeout = Duration(seconds: 20);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late Future<void> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializeFirebase();
    await _initializeSupabase();

    try {
      await di.initDependencies().timeout(_dependencyStartupTimeout);
    } catch (e) {
      debugPrint(
        ErrorMessages.withDetails(
          AppErrorKey.loadLocalStorage,
          e,
        ),
      );
      rethrow;
    }
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(_startupStepTimeout);
    } catch (e) {
      debugPrint(
        ErrorMessages.withDetails(
          AppErrorKey.firebaseInitNotice,
          e,
        ),
      );
    }
  }

  Future<void> _initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      ).timeout(_startupStepTimeout);
    } catch (e) {
      debugPrint(
        ErrorMessages.withDetails(
          AppErrorKey.supabaseInitNotice,
          e,
        ),
      );
    }
  }

  void _retryStartup() {
    setState(() {
      _startupFuture = _initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return const MyApp();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          localizationsDelegates:
              AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => snapshot.hasError
                ? _BootstrapErrorScreen(
                    onRetry: _retryStartup,
                  )
                : const _BootstrapLoadingScreen(),
          ),
        );
      },
    );
  }
}

class _BootstrapLoadingScreen extends StatefulWidget {
  const _BootstrapLoadingScreen();

  @override
  State<_BootstrapLoadingScreen> createState() =>
      _BootstrapLoadingScreenState();
}

class _BootstrapLoadingScreenState
    extends State<_BootstrapLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoWidth = constraints.maxWidth > 220
                ? 220.0
                : constraints.maxWidth * 0.34;

            return SizedBox(
              width: logoWidth,
              child: AspectRatio(
                aspectRatio: 1672 / 941,
                child: _OrbCodeSplashLogo(
                  animation: _orbitController,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrbCodeSplashLogo extends StatelessWidget {
  final Animation<double> animation;

  const _OrbCodeSplashLogo({
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final orbitSize = width * 0.42;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/branding/orb_code_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: width * 0.02,
              top: height * 0.015,
              width: orbitSize,
              height: orbitSize,
              child: RotationTransition(
                turns: animation,
                child: const _OrbOrbitRing(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OrbOrbitRing extends StatelessWidget {
  const _OrbOrbitRing();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x40FFFFFF),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x334FC3FF),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.72, -0.72),
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF8FBFF),
              boxShadow: [
                BoxShadow(
                  color: Color(0xCC4FC3FF),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _BootstrapErrorScreen({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 54,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.startupFailed,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) =>
              di.sl<ThemeCubit>()..restorePreferences(),
        ),
        BlocProvider<RestaurantCubit>(
          create: (_) =>
              di.sl<RestaurantCubit>()..loadRestaurantInfo(),
        ),
        BlocProvider<MenuCubit>(
          create: (_) =>
              di.sl<MenuCubit>()..loadMenuData(),
        ),
        BlocProvider<CartCubit>(
          create: (_) =>
              di.sl<CartCubit>()..restoreCart(),
        ),
        BlocProvider<CheckoutCubit>(
          create: (_) =>
              di.sl<CheckoutCubit>()..restoreSavedCustomerInfo(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            themeMode: themeState.themeMode,
            locale: themeState.locale,

            localizationsDelegates:
                AppLocalizations.localizationsDelegates,
            supportedLocales:
                AppLocalizations.supportedLocales,

            home: const MainNavigationShell(),

            builder: (context, child) {
              return Directionality(
                textDirection: themeState.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}