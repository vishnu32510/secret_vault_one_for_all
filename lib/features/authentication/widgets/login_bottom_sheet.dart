import 'package:flutter/material.dart';
import 'package:secretvaultoneforall/features/authentication/screens/login_screen.dart';

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 680, child: LoginScreen());
  }
}
