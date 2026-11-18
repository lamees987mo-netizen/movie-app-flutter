import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/pages/account_page.dart';
import 'package:movie_app/features/auth/presentation/pages/manage_profile_page.dart';
import 'package:movie_app/features/auth/presentation/pages/security_page.dart';
import 'package:movie_app/features/auth/presentation/pages/sign_in_page.dart';

/// The Account tab (profile or "Sign in", plus the settings).
final StatefulShellBranch accountBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.account,
      name: RouteNames.account,
      builder: (context, state) => const AccountPage(),
    ),
  ],
);

bool _isSignedIn(BuildContext context) =>
    context.read<AuthCubit>().state is AuthSignedIn;

/// Full-screen routes shown above the bottom navigation bar.
final List<RouteBase> authRoutes = [
  GoRoute(
    path: Routes.signIn,
    name: RouteNames.signIn,
    // Already signed in (e.g. an old deep link): show the account instead.
    redirect: (context, state) => _isSignedIn(context) ? Routes.account : null,
    builder: (context, state) => const SignInPage(),
  ),
  // These two only make sense with an account: guests (e.g. from a deep
  // link) are sent to the sign-in screen.
  GoRoute(
    path: Routes.accountProfile,
    name: RouteNames.accountProfile,
    redirect: (context, state) => _isSignedIn(context) ? null : Routes.signIn,
    builder: (context, state) => const ManageProfilePage(),
  ),
  GoRoute(
    path: Routes.accountSecurity,
    name: RouteNames.accountSecurity,
    redirect: (context, state) => _isSignedIn(context) ? null : Routes.signIn,
    builder: (context, state) => const SecurityPage(),
  ),
];
