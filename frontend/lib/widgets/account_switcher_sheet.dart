import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../core/utils/account_launcher.dart';
import '../screens/auth/add_account_screen.dart';
import 'user_avatar.dart';

class AccountSwitcherSheet extends StatelessWidget {
  const AccountSwitcherSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AccountSwitcherSheet(),
    );
  }

  Future<void> _manageGoogle(BuildContext context, String email) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await AccountLauncher.openGoogleAccount(email);
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Tidak dapat membuka halaman akun Google')));
    }
  }

  void _addAccount(BuildContext context) {
    final nav = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context);
    nav.push(MaterialPageRoute(builder: (_) => const AddAccountScreen()));
  }

  Future<void> _manageDevice(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await AccountLauncher.openDeviceAccounts();
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Pengaturan akun perangkat hanya tersedia di Android')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.current;
    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Text(
                        'Gugel',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      UserAvatar(name: user.name, color: user.color, size: 56),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _manageGoogle(context, user.email),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Kelola Akun Google Anda',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                ...auth.otherAccounts.map(
                  (a) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 2,
                    ),
                    leading: UserAvatar(name: a.name, color: a.color, size: 48),
                    title: Text(a.name, style: const TextStyle(fontSize: 17)),
                    subtitle: Text(
                      a.email,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () {
                      context.read<AuthProvider>().switchAccount(a);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.person_add_alt_outlined),
                  title: const Text(
                    'Tambahkan akun lainnya',
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () => _addAccount(context),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: const Text(
                    'Kelola akun di perangkat ini',
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () => _manageDevice(context),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
