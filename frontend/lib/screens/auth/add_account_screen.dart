import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/account_launcher.dart';
import '../../providers/auth_provider.dart';

/// Layar "Tambahkan akun lainnya".
class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final err = await auth.addAccount(_email.text, _password.text);
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final name = auth.current?.name ?? '';
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text('Akun $name ditambahkan')));
  }

  Future<void> _openDeviceAdd() async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await AccountLauncher.openAddDeviceAccount();
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Pengaturan akun perangkat hanya tersedia di Android')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Tambahkan akun'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masuk dengan akun lain untuk ditambahkan ke daftar akun.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Email wajib diisi';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _hide,
                  onFieldSubmitted: (_) => loading ? null : _submit(),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  validator: (v) =>
                      (v ?? '').isEmpty ? 'Sandi wajib diisi' : null,
                  decoration: InputDecoration(
                    labelText: 'Sandi',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _hide ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                ),
                if (ApiConfig.useDummy)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Mode dummy: sandi semua akun adalah "password".',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Tambahkan akun',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _openDeviceAdd,
                    icon: const Icon(Icons.phone_android_outlined),
                    label: const Text('Tambahkan akun lewat pengaturan perangkat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
