import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/session_manager.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/register_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/browse/domain/entities/facets_entity.dart';
import '../../features/browse/presentation/pages/home_page.dart';
import '../../features/browse/presentation/pages/listing_detail_page.dart';
import '../../features/browse/presentation/pages/listings_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../di/injection.dart';

class AppRoutes {
  static const String home = '/';
  static const String listings = '/listings';
  static const String listingDetail = '/listings/:slug';
  static const String map = '/map';
  static const String land = '/land';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String verifyOtpAlt = '/verify_otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';
  static const String favorites = '/favorites';
  static const String createListing = '/listings/new';

  static const Set<String> protectedRoutes = {
    dashboard,
    favorites,
    createListing,
  };
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  // Manual override for testing
  static bool? _authOverride;

  static void setAuthOverride(bool? isAuth) {
    _authOverride = isAuth;
  }

  static bool get isAuthenticated {
    if (_authOverride != null) return _authOverride!;
    if (sl.isRegistered<SessionManager>()) {
      return sl<SessionManager>().currentStatus == SessionStatus.authenticated;
    }
    return false;
  }

  static String? authGuard(BuildContext context, GoRouterState state) {
    final destination = state.matchedLocation;
    final isProtected = AppRoutes.protectedRoutes.any(
      (route) => destination == route || destination.startsWith('$route/'),
    );

    if (isProtected && !isAuthenticated) {
      final from = Uri.encodeComponent(destination);
      return '${AppRoutes.login}?redirect=$from';
    }

    if (isAuthenticated &&
        (destination == AppRoutes.login || destination == AppRoutes.register)) {
      return AppRoutes.home;
    }

    return null;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: authGuard,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.createListing,
        name: 'create_listing',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Create Listing (SCR-012)'),
      ),
      GoRoute(
        path: AppRoutes.listings,
        name: 'listings',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final params = ListingFilterParams(
            purpose: query['purpose'],
            propertyType: query['type'] ?? query['propertyType'],
            areaSlug: query['area'] ?? query['areaSlug'],
            division: query['division'],
            featured: query['featured'] == 'true',
            search: query['search'],
          );
          return ListingsPage(initialParams: params);
        },
      ),
      GoRoute(
        path: '/listings/sale',
        builder: (context, state) => const ListingsPage(
          initialParams: ListingFilterParams(purpose: 'sale'),
        ),
      ),
      GoRoute(
        path: '/listings/verified',
        builder: (context, state) => const ListingsPage(
          initialParams: ListingFilterParams(verified: true),
        ),
      ),
      GoRoute(
        path: '/listings/division/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug'];
          return ListingsPage(
            initialParams: ListingFilterParams(division: slug),
          );
        },
      ),
      GoRoute(
        path: '/rent/dhaka/:area',
        builder: (context, state) {
          final area = state.pathParameters['area'];
          return ListingsPage(
            initialParams: ListingFilterParams(purpose: 'rent', areaSlug: area),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.listingDetail,
        name: 'listing_detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return ListingDetailPage(idOrSlug: slug);
        },
      ),
      GoRoute(
        path: AppRoutes.map,
        name: 'map',
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: AppRoutes.land,
        name: 'land',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Land Marketplace (SCR-005)'),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return BlocProvider<AuthBloc>(
            create: (_) => sl<AuthBloc>(),
            child: LoginPage(redirect: redirect),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return BlocProvider<RegisterBloc>(
            create: (_) => sl<RegisterBloc>(),
            child: RegisterPage(initialRole: role),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        name: 'verify_otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? state.uri.queryParameters['email'] ?? '';
          final devOtp = extra['devOtp'] as String?;
          return BlocProvider<RegisterBloc>(
            create: (_) => sl<RegisterBloc>(),
            child: VerifyOtpPage(email: email, devOtp: devOtp),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verifyOtpAlt,
        name: 'verify_otp_alt',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? state.uri.queryParameters['email'] ?? '';
          final devOtp = extra['devOtp'] as String?;
          return BlocProvider<RegisterBloc>(
            create: (_) => sl<RegisterBloc>(),
            child: VerifyOtpPage(email: email, devOtp: devOtp),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset_password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return ResetPasswordPage(initialToken: token);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Dashboard: My Listings (SCR-013)'),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('404: No route defined for ${state.uri.toString()}'),
      ),
    ),
  );
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
