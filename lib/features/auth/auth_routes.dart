import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/pages/account_page.dart';
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

/// Full-screen routes shown above the bottom navigation bar.
final List<RouteBase> authRoutes = [
  GoRoute(
    path: Routes.signIn,
    name: RouteNames.signIn,
    // Already signed in (e.g. an old deep link): show the account instead.
    redirect: (context, state) =>
        context.read<AuthCubit>().state is AuthSignedIn ? Routes.account : null,
    builder: (context, state) => const SignInPage(),
  ),
];
