import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fbro/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fbro/features/auth/presentation/pages/login_page.dart';
import 'package:fbro/features/auth/presentation/pages/register_page.dart';
import 'package:fbro/features/auth/presentation/pages/phone_otp_page.dart';
import 'package:fbro/features/home/presentation/pages/home_page.dart';
import 'route_names.dart';

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: RouteNames.login,
    refreshListenable: _AuthStateNotifier(authCubit),
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authCubit.state.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      final isOnAuth = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.phone;

      if (isAuthenticated && isOnAuth) return RouteNames.home;
      if (!isAuthenticated && !isOnAuth) return RouteNames.login;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.phone,
        builder: (context, state) => const PhoneOtpPage(),
      ),
    ],
  );
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(AuthCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}
