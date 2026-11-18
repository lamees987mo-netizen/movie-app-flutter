import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:movie_app/features/auth/presentation/widgets/signed_in_guard.dart';
import 'package:movie_app/features/auth/presentation/widgets/user_avatar.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_group.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Manage profile": change the display name, and see the email and how
/// the user signs in.
///
/// Like `AccountPage`, it only creates the cubit; [ManageProfileView]
/// draws the screen.
class ManageProfilePage extends StatelessWidget {
  const ManageProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: const ManageProfileView(),
    );
  }
}

class ManageProfileView extends StatelessWidget {
  const ManageProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).accountManageProfile),
      ),
      body: SignedInGuard(builder: (_, user) => _ProfileForm(user: user)),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.user});

  final AppUser user;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  /// Starts with the current name. Created once, so a rebuild (e.g. the
  /// new name arriving from Firebase) doesn't reset what the user typed.
  late final _name = TextEditingController(text: widget.user.displayName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    unawaited(context.read<ProfileCubit>().saveName(_name.text));
  }

  void _showResult(BuildContext context, ProfileState state) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    switch (state) {
      case ProfileSaved():
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.accountProfileSaved)),
        );
      case ProfileError(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.message(l10n))));
      case ProfileIdle() || ProfileSaving():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = widget.user;
    final method = switch (user.signInMethod) {
      SignInMethod.google => l10n.accountSignInMethodGoogle,
      SignInMethod.email => l10n.accountSignInMethodEmail,
      SignInMethod.unknown => null,
    };
    return BlocListener<ProfileCubit, ProfileState>(
      listener: _showResult,
      child: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(child: UserAvatar(user: user)),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.name],
              decoration: InputDecoration(
                labelText: l10n.accountProfileName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? l10n.accountProfileNameRequired
                  : null,
              onFieldSubmitted: (_) => _save(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final saving = state is ProfileSaving;
              return FilledButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.accountProfileSave),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          // Read-only: changing the email is not supported (yet).
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.email_outlined,
                title: l10n.authEmail,
                subtitle: user.email ?? '',
              ),
              if (method != null)
                SettingsTile(
                  icon: Icons.login,
                  title: l10n.accountSignInMethod,
                  subtitle: method,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
