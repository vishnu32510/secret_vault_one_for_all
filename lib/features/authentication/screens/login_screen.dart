import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secretvaultoneforall/core/di/injection.dart';
import 'package:secretvaultoneforall/core/services/toast_service.dart';
import 'package:secretvaultoneforall/features/authentication/authentication_bloc/authentication_bloc.dart';
import 'package:secretvaultoneforall/features/authentication/authentication_enums.dart';
import 'package:secretvaultoneforall/features/authentication/login_bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<AuthenticationBloc, AuthenticationBlocState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.authenticated) {
          Navigator.pop(context);
        }
      },
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.failure &&
              state.errorMessage != null) {
            getIt<IToastService>().showError(state.errorMessage!);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Sign In'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Safepad', style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account or sign in to unlock your secret vault.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildEmailForm(context),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: cs.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: cs.outlineVariant)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final cs = Theme.of(context).colorScheme;
        final isLoading = state.status == FormzSubmissionStatus.inProgress;
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                onChanged: (v) => context.read<LoginBloc>().add(LoginEmailChanged(v)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Password must be at least 6 characters'
                    : null,
                onChanged: (v) =>
                    context.read<LoginBloc>().add(LoginPasswordChanged(v)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : () => _handleEmailContinue(context),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Continue with Email',
                          style: TextStyle(color: cs.onPrimary)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialButtons(BuildContext context) {
    final showApple = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
    return Column(
      children: [
        _SocialButton(
          icon: Icons.g_mobiledata,
          iconColor: Colors.red,
          label: 'Continue with Google',
          onTap: () => context.read<LoginBloc>().add(const LoginWithGoogle()),
        ),
        if (showApple) ...[
          const SizedBox(height: 12),
          _SocialButton(
            icon: Icons.apple,
            iconColor: Theme.of(context).colorScheme.onSurface,
            label: 'Continue with Apple',
            onTap: () => context.read<LoginBloc>().add(const LoginWithApple()),
          ),
        ],
      ],
    );
  }

  void _handleEmailContinue(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(
            ContinueWithEmailAndPassword(
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text.trim(),
            ),
          );
    }
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor),
        label: Text(label),
      ),
    );
  }
}
