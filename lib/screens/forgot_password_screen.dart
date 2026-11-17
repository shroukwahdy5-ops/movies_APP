import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (!auth.emailExists(_email.text)) {
      showSnack(context, 'No account with this email');
      return;
    }
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) => const _NewPasswordDialog(),
    );
    if (newPassword == null) return;
    await auth.resetPassword(_email.text, newPassword);
    if (!mounted) return;
    showSnack(context, 'Password updated');
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password', style: TextStyle(color: AppColors.yellow, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock_reset, size: 160, color: AppColors.yellow),
              const SizedBox(height: 40),
              AppTextField(
                hint: 'Email',
                icon: Icons.email,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 24),
              AppButton(text: 'Verify Email', onTap: _verify),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewPasswordDialog extends StatefulWidget {
  const _NewPasswordDialog();

  @override
  State<_NewPasswordDialog> createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<_NewPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('New Password'),
      content: Form(
        key: _formKey,
        child: AppTextField(
          hint: 'New Password',
          icon: Icons.lock,
          controller: _password,
          isPassword: true,
          validator: Validators.password,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) Navigator.pop(context, _password.text);
          },
          child: const Text('Save', style: TextStyle(color: AppColors.yellow)),
        ),
      ],
    );
  }
}
