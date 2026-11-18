import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';

/// Builds a page body for the signed-in user only.
///
/// The routes already send guests to the sign-in screen, but the user can
/// also disappear while the page is open (signing out from the "requires
/// recent login" SnackBar, or deleting the account). Then this goes back
/// to the account tab instead of showing a page about nobody.
class SignedInGuard extends StatelessWidget {
  const SignedInGuard({required this.builder, super.key});

  final Widget Function(BuildContext context, AppUser user) builder;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (_, current) => current is AuthSignedOut,
      listener: (context, _) => context.go(Routes.account),
      builder: (context, state) => switch (state) {
        AuthSignedIn(:final user) => builder(context, user),
        AuthSignedOut() => const SizedBox.shrink(),
      },
    );
  }
}
