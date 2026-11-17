import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Sign in or create an account, with email + password or with Google.
///
/// This widget only creates the cubit; [SignInView] draws the screen, so
/// widget tests can give the view a mock cubit.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignInCubit>(),
      child: const SignInView(),
    );
  }
}

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  /// Firebase refuses shorter passwords ("weak-password"); checking here
  /// first gives a clearer message without a network round trip.
  static const int minPasswordLength = 6;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();

  /// "Forgot password?" only needs a valid email, so that one field can be
  /// validated alone.
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// `false`: "Sign in" form. `true`: "Create account" form (with a name).
  bool _isSignUp = false;
  bool _obscurePassword = true;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.authEmailRequired;
    if (!_emailPattern.hasMatch(email)) return l10n.authEmailInvalid;
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    final password = value ?? '';
    if (password.isEmpty) return l10n.authPasswordRequired;
    // Only for new accounts: an old account may have any password.
    if (_isSignUp && password.length < SignInView.minPasswordLength) {
      return l10n.authPasswordTooShort(SignInView.minPasswordLength);
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<SignInCubit>();
    if (_isSignUp) {
      await cubit.signUpWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await cubit.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  Future<void> _forgotPassword() async {
    if (!(_emailFieldKey.currentState?.validate() ?? false)) return;
    await context.read<SignInCubit>().sendPasswordResetEmail(
      _emailController.text,
    );
  }

  void _onStateChanged(BuildContext context, SignInState state) {
    switch (state) {
      case SignInSuccess():
        _close(context);
      case SignInResetEmailSent(:final email):
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authResetEmailSent(email))),
        );
      case SignInIdle() || SignInLoading() || SignInError():
        break;
    }
  }

  /// Back to where the user came from. Opened directly (a deep link, so
  /// nothing to go back to): go to the account tab instead.
  static void _close(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router != null && !router.canPop()) {
      router.go(Routes.account);
    } else {
      unawaited(Navigator.of(context).maybePop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? l10n.authSignUp : l10n.authSignIn),
      ),
      body: BlocConsumer<SignInCubit, SignInState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final loading = state is SignInLoading;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              children: [
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _nameController,
                    enabled: !loading,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: l10n.authName,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TextFormField(
                  key: _emailFieldKey,
                  controller: _emailController,
                  enabled: !loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: l10n.authEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) => _validateEmail(value, l10n),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  enabled: !loading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: [
                    if (_isSignUp)
                      AutofillHints.newPassword
                    else
                      AutofillHints.password,
                  ],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.authPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: l10n.authShowPassword,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (value) => _validatePassword(value, l10n),
                ),
                if (!_isSignUp)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: loading ? null : _forgotPassword,
                      child: Text(l10n.authForgotPassword),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                if (state is SignInError) ...[
                  Text(
                    state.failure.message(l10n),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isSignUp ? l10n.authSignUp : l10n.authSignIn),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? l10n.authSwitchToSignIn
                        : l10n.authSwitchToSignUp,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _OrDivider(label: l10n.authOr),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : context.read<SignInCubit>().signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(l10n.authContinueWithGoogle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ———— or ————
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
          ),
          child: Text(label),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
