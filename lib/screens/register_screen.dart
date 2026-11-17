import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/utils.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/avatar_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  int _avatar = 0;
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final library = context.read<LibraryProvider>();
    final error = await auth.register(UserModel(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      phone: _phone.text,
      avatar: _avatar,
    ));
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
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: AppColors.yellow, fontSize: 16)),
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
              AvatarPicker(selected: _avatar, onChanged: (i) => setState(() => _avatar = i)),
              const SizedBox(height: 8),
              const Text('Avatar'),
              const SizedBox(height: 20),
              AppTextField(
                  hint: 'Name', icon: Icons.person, controller: _name, validator: Validators.required),
              const SizedBox(height: 14),
              AppTextField(
                hint: 'Email',
                icon: Icons.email,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 14),
              AppTextField(
                hint: 'Password',
                icon: Icons.lock,
                controller: _password,
                isPassword: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 14),
              AppTextField(
                hint: 'Confirm Password',
                icon: Icons.lock,
                controller: _confirm,
                isPassword: true,
                validator: (v) => v != _password.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                hint: 'Phone Number',
                icon: Icons.phone,
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 24),
              AppButton(text: 'Create Account', onTap: _register, loading: _loading),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already Have Account ? '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Login',
                        style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
