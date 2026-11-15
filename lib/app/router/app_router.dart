import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/deep_link_validator.dart';
import '../../core/security/input_sanitizer.dart';
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
import '../../features/land/presentation/pages/land_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/owner/presentation/pages/create_edit_listing_page.dart';
import '../../features/owner/presentation/pages/owner_dashboard_page.dart';
import '../../features/content/presentation/pages/ask_question_page.dart';
import '../../features/content/presentation/pages/blog_detail_page.dart';
import '../../features/content/presentation/pages/blog_page.dart';
import '../../features/content/presentation/pages/guide_detail_page.dart';
import '../../features/content/presentation/pages/guides_page.dart';
import '../../features/content/presentation/pages/profile_settings_page.dart';
import '../../features/content/presentation/pages/qa_page.dart';
import '../../features/content/presentation/pages/question_detail_page.dart';
import '../../features/content/presentation/pages/static_content_page.dart';
import '../../features/plans/presentation/pages/pricing_page.dart';
import '../../l10n/app_localizations.dart';
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
  static const String editListing = '/listings/:id/edit';
  static const String blog = '/blog';
  static const String blogDetail = '/blog/:slug';
  static const String qa = '/qa';
  static const String qaAsk = '/qa/ask';
  static const String qaDetail = '/qa/:id';
  static const String guides = '/guides';
  static const String guideDetail = '/guides/:slug';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String help = '/help';
  static const String pricing = '/pricing';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static const Set<String> protectedRoutes = {
    dashboard,
    favorites,
    createListing,
    qaAsk,
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
        builder: (context, state) => const CreateEditListingPage(),
      ),
      GoRoute(
        path: AppRoutes.editListing,
        name: 'edit_listing',
        builder: (context, state) {
          final id = DeepLinkValidator.sanitizeId(state.pathParameters['id']);
          return CreateEditListingPage(listingId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.listings,
        name: 'listings',
        builder: (context, state) {
          final query = DeepLinkValidator.sanitizeQueryParams(state.uri.queryParameters);
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
          final slug = DeepLinkValidator.sanitizeSlug(state.pathParameters['slug']);
          return ListingsPage(
            initialParams: ListingFilterParams(division: slug),
          );
        },
      ),
      GoRoute(
        path: '/rent/dhaka/:area',
        builder: (context, state) {
          final area = DeepLinkValidator.sanitizeSlug(state.pathParameters['area']);
          return ListingsPage(
            initialParams: ListingFilterParams(purpose: 'rent', areaSlug: area),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.listingDetail,
        name: 'listing_detail',
        builder: (context, state) {
          final rawSlug = state.pathParameters['slug'] ?? '';
          final idParam = state.uri.queryParameters['id'];
          final sanitizedSlug = DeepLinkValidator.sanitizeSlug(rawSlug);
          final slug = (sanitizedSlug != null && sanitizedSlug.isNotEmpty)
              ? sanitizedSlug
              : (idParam ?? rawSlug);
          return ListingDetailPage(
            idOrSlug: slug,
            fallbackId: idParam,
          );
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
        builder: (context, state) => const LandPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          final redirect = DeepLinkValidator.sanitizeRedirectUrl(state.uri.queryParameters['redirect']);
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
          final rawEmail = extra['email'] as String? ?? state.uri.queryParameters['email'] ?? '';
          final email = InputSanitizer.normalizeEmail(rawEmail);
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
          final rawEmail = extra['email'] as String? ?? state.uri.queryParameters['email'] ?? '';
          final email = InputSanitizer.normalizeEmail(rawEmail);
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
          final rawToken = state.uri.queryParameters['token'] ?? '';
          final token = InputSanitizer.sanitizeSearchQuery(rawToken);
          return ResetPasswordPage(initialToken: token.isEmpty ? null : token);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const OwnerDashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: AppRoutes.blog,
        name: 'blog',
        builder: (context, state) => const BlogPage(),
      ),
      GoRoute(
        path: AppRoutes.blogDetail,
        name: 'blog_detail',
        builder: (context, state) {
          final rawSlug = state.pathParameters['slug'] ?? '';
          final slug = DeepLinkValidator.sanitizeSlug(rawSlug) ?? rawSlug;
          return BlogDetailPage(slug: slug);
        },
      ),
      GoRoute(
        path: AppRoutes.qa,
        name: 'qa',
        builder: (context, state) => const QaPage(),
      ),
      GoRoute(
        path: AppRoutes.qaAsk,
        name: 'qa_ask',
        builder: (context, state) => const AskQuestionPage(),
      ),
      GoRoute(
        path: AppRoutes.qaDetail,
        name: 'qa_detail',
        builder: (context, state) {
          final rawId = state.pathParameters['id'] ?? '';
          final id = DeepLinkValidator.sanitizeId(rawId) ?? rawId;
          return QuestionDetailPage(id: id);
        },
      ),
      GoRoute(
        path: AppRoutes.guides,
        name: 'guides',
        builder: (context, state) => const GuidesPage(),
      ),
      GoRoute(
        path: AppRoutes.guideDetail,
        name: 'guide_detail',
        builder: (context, state) {
          final rawSlug = state.pathParameters['slug'] ?? '';
          final slug = DeepLinkValidator.sanitizeSlug(rawSlug) ?? rawSlug;
          return GuideDetailPage(slug: slug);
        },
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const StaticContentPage(slug: 'about'),
      ),
      GoRoute(
        path: AppRoutes.contact,
        name: 'contact',
        builder: (context, state) => const StaticContentPage(slug: 'contact'),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (context, state) => const StaticContentPage(slug: 'privacy'),
      ),
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        builder: (context, state) => const StaticContentPage(slug: 'terms'),
      ),
      GoRoute(
        path: AppRoutes.help,
        name: 'help',
        builder: (context, state) => const StaticContentPage(slug: 'help'),
      ),
      GoRoute(
        path: AppRoutes.pricing,
        name: 'pricing',
        builder: (context, state) => const PricingPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const ProfileSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileSettingsPage(),
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n?.error_not_found ?? 'Resource not found')),
        body: Center(
          child: Text(
            l10n != null
                ? '${l10n.error_not_found}: ${state.uri}'
                : '404: No route defined for ${state.uri}',
          ),
        ),
      );
    },
  );
}
