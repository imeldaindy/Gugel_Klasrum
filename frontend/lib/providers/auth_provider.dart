import 'package:flutter/material.dart';

import '../core/constants/api_config.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  UserModel? _current;
  bool loading = false;

  // Token per akun (mode API), supaya ganti akun memakai token yang benar.
  final Map<int, String> _tokens = {};

  final List<UserModel> _accounts = ApiConfig.useDummy ? [
    UserModel(
      id: 1,
      name: '228_ Alif Muhammad Hafizh',
      email: '24051214228@mhs.unesa.ac.id',
    ),
    UserModel(
      id: 2,
      name: 'Alf Game',
      email: 'alfgame321@gmail.com',
      color: AppAvatarColors.orange,
    ),
    UserModel(
      id: 3,
      name: 'Alif Muhammad',
      email: 'alifscc0311@gmail.com',
      color: AppAvatarColors.orange,
    ),
    UserModel(
      id: 4,
      name: 'soto cak ipin',
      email: 'sotoayamcakipinktt@gmail.com',
      color: AppAvatarColors.green,
    ),
    UserModel(
      id: 5,
      name: 'Alif Hafizh',
      email: 'alifmhafizh0311@gmail.com',
      color: AppAvatarColors.orange,
    ),
  ] : [];

  UserModel? get current => _current;

  /// Semua akun yang sudah ditambahkan di aplikasi ini.
  List<UserModel> get accounts => List.unmodifiable(_accounts);
  bool get isLoggedIn => _current != null;

  List<UserModel> get otherAccounts =>
      _accounts.where((a) => a.id != _current?.id).toList();

  Future<bool> login(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      _current = await _service.login(email, password);
      _remember(_current!);
      return true;
    } catch (_) {
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _remember(UserModel u) {
    _activate(u);
    if (!_accounts.any((a) => a.id == u.id)) _accounts.add(u);
  }

  /// Tambah akun lain lalu langsung beralih ke akun tersebut.
  /// Mengembalikan null jika sukses, atau pesan error.
  Future<String?> addAccount(String email, String password) async {
    final e = email.trim().toLowerCase();
    if (_accounts.any((a) => a.email.toLowerCase() == e)) {
      return 'Akun ini sudah ditambahkan.';
    }
    loading = true;
    notifyListeners();
    try {
      final user = await _service.addAccount(e, password);
      _remember(user);
      _current = user;
      return null;
    } catch (err) {
      if (err is ApiException && err.message.startsWith('Tidak dapat terhubung')) {
        return err.message;
      }
      return 'Email atau sandi salah.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Daftar akun baru di database lalu langsung beralih ke akun itu.
  /// Mengembalikan null jika sukses, atau pesan error.
  Future<String?> registerAccount(
    String name,
    String email,
    String password,
  ) async {
    final e = email.trim().toLowerCase();
    if (_accounts.any((a) => a.email.toLowerCase() == e)) {
      return 'Akun ini sudah ditambahkan.';
    }
    loading = true;
    notifyListeners();
    try {
      final user = await _service.register(name.trim(), e, password);
      _remember(user);
      _current = user;
      return null;
    } catch (err) {
      final m = err is ApiException ? err.message : 'Gagal mendaftar.';
      if (m.contains('already been taken')) return 'Email ini sudah terdaftar.';
      if (m.contains('at least')) return 'Sandi minimal 6 karakter.';
      return m;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _activate(UserModel u) {
    if (ApiConfig.useDummy) return;
    if (ApiService.token != null) _tokens[u.id] = ApiService.token!;
    ApiService.userId = u.id;
  }

  void switchAccount(UserModel user) {
    if (!ApiConfig.useDummy) {
      ApiService.token = _tokens[user.id];
      ApiService.userId = user.id;
    }
    _current = user;
    notifyListeners();
  }

  void logout() {
    _current = null;
    ApiService.token = null;
    ApiService.userId = null;
    notifyListeners();
  }
}
