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
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
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
          appBar: AppBar(title: const Text('Sign In')),
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
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
                onChanged: (v) =>
                    context.read<LoginBloc>().add(LoginEmailChanged(v)),
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
                  onPressed: isLoading
                      ? null
                      : () => _handleEmailContinue(context),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Continue with Email',
                          style: TextStyle(color: cs.onPrimary),
                        ),
                ),
              ),
            ],
          ),
        );
      },
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
