import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/utils.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final library = context.read<LibraryProvider>();
    final error = await auth.login(_email.text, _password.text);
    if (!mounted) return;
    if (error != null) {
      setState(() => _loading = false);
      showSnack(context, error);
      return;
    }
    await library.load(auth.user!.email);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.play_circle_outline, size: 100, color: AppColors.yellow),
                  const SizedBox(height: 32),
                  AppTextField(
                    hint: 'Email',
                    icon: Icons.email,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hint: 'Password',
                    icon: Icons.lock,
                    controller: _password,
                    isPassword: true,
                    validator: Validators.password,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot'),
                      child: const Text('Forget Password ?',
                          style: TextStyle(color: AppColors.yellow)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppButton(text: 'Login', onTap: _login, loading: _loading),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't Have Account ? "),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Create One',
                            style: TextStyle(
                                color: AppColors.yellow, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.yellow)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: TextStyle(color: AppColors.yellow)),
                      ),
                      Expanded(child: Divider(color: AppColors.yellow)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // TODO: لو عايز Google Login فعلي ضيف firebase_auth و google_sign_in وانده الدالة هنا بدل الـ snack
                  AppButton(
                    text: 'Login With Google',
                    onTap: () => showSnack(context, 'Google login is not connected yet'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
