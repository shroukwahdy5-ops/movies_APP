import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/utils.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/avatar_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late int _avatar;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;
    _name = TextEditingController(text: user.name);
    _phone = TextEditingController(text: user.phone);
    _avatar = user.avatar;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.updateUser(auth.user!.copyWith(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      avatar: _avatar,
    ));
    if (!mounted) return;
    showSnack(context, 'Profile updated');
    Navigator.pop(context);
  }

  Future<void> _resetPassword() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: AppTextField(
            hint: 'New Password',
            icon: Icons.lock,
            controller: controller,
            isPassword: true,
            validator: Validators.password,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, controller.text);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.yellow)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newPassword == null || !mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.resetPassword(auth.user!.email, newPassword);
    if (!mounted) return;
    showSnack(context, 'Password updated');
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final auth = context.read<AuthProvider>();
    final library = context.read<LibraryProvider>();
    final nav = Navigator.of(context);
    await auth.deleteAccount();
    library.clear();
    nav.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Avatar', style: TextStyle(color: AppColors.yellow, fontSize: 16)),
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
              const SizedBox(height: 24),
              AppTextField(
                  hint: 'Name', icon: Icons.person, controller: _name, validator: Validators.required),
              const SizedBox(height: 14),
              AppTextField(
                hint: 'Phone Number',
                icon: Icons.phone,
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text('Reset Password', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                text: 'Delete Account',
                color: AppColors.red,
                textColor: Colors.white,
                onTap: _delete,
              ),
              const SizedBox(height: 12),
              AppButton(text: 'Update Data', onTap: _update),
            ],
          ),
        ),
      ),
    );
  }
}
