import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/blocs/wallets_repository.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/shared/widgets/password_visibility_control.dart';

class WalletDeleting extends StatefulWidget {
  const WalletDeleting({
    super.key,
    required this.wallet,
    required this.close,
  });
  final Wallet wallet;
  final VoidCallback close;

  @override
  State<WalletDeleting> createState() => _WalletDeletingState();
}

class _WalletDeletingState extends State<WalletDeleting> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;
  String? _error;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Text(
              LocaleKeys.deleteWalletTitle.tr(args: [widget.wallet.name]),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              LocaleKeys.deleteWalletInfo.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: _PasswordField(
              controller: _passwordController,
              errorText: _error,
              onFieldSubmitted: _isDeleting ? null : _deleteWallet,
              onChanged: _handlePasswordChanged,
              validator: (password) {
                if (password == null || password.isEmpty) {
                  return LocaleKeys.passwordIsEmpty.tr();
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: _buildButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(0),
          icon: Icon(
            Icons.chevron_left,
            color: theme.custom.headerIconColor,
          ),
          splashRadius: 15,
          iconSize: 18,
          onPressed: widget.close,
        ),
        Text(
          LocaleKeys.back.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Flexible(
          child: UiBorderButton(
            text: LocaleKeys.cancel.tr(),
            onPressed: widget.close,
            height: 40,
            width: 150,
            borderWidth: 2,
            borderColor: theme.custom.specificButtonBorderColor,
          ),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          child: UiPrimaryButton(
            backgroundColor: Theme.of(context).colorScheme.error,
            text: LocaleKeys.delete.tr(),
            onPressed: _isDeleting ? null : _deleteWallet,
            prefix: _isDeleting ? const UiSpinner() : null,
            height: 40,
            width: 150,
          ),
        )
      ],
    );
  }

  void _handlePasswordChanged(String? value) {
    // Clear the error when user starts typing a new password
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  Future<void> _deleteWallet() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isDeleting = true;
      _error = null;
    });
    final walletsRepository = RepositoryProvider.of<WalletsRepository>(context);
    try {
      await walletsRepository.deleteWallet(
        widget.wallet,
        password: _passwordController.text,
      );
      widget.close();
    } catch (e) {
      if (e is AuthException) {
        switch (e.type) {
          case AuthExceptionType.incorrectPassword:
            _error = LocaleKeys.incorrectPassword.tr();
            break;
          case AuthExceptionType.walletNotFound:
            _error = LocaleKeys.walletNotFound.tr();
            break;
          default:
            _error = e.message;
        }
      } else {
        _error = e.toString();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.errorText,
    required this.onFieldSubmitted,
    required this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onFieldSubmitted;
  final String? Function(String?) validator;
  final void Function(String?)? onChanged;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return UiTextFormField(
      key: const Key('delete-wallet-password'),
      controller: widget.controller,
      autofocus: true,
      autocorrect: false,
      obscureText: _isObscured,
      errorText: widget.errorText,
      validator: widget.validator,
      validationMode: InputValidationMode.eager,
      hintText: LocaleKeys.walletCreationPasswordHint.tr(),
      onChanged: widget.onChanged,
      suffixIcon: PasswordVisibilityControl(
        onVisibilityChange: (v) => setState(() => _isObscured = v),
      ),
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
    );
  }
}
