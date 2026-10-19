import '../core/constants/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Akun untuk mode dummy. Sandi semua akun: "password" (sama dengan data seed MySQL).
  static const _dummyPassword = 'password';
  static const _dummyAccounts = <String, UserModel>{
    '24051214228@mhs.unesa.ac.id': UserModel(
      id: 1,
      name: '228_ Alif Muhammad Hafizh',
      email: '24051214228@mhs.unesa.ac.id',
    ),
    'alfgame321@gmail.com': UserModel(
      id: 2,
      name: 'Alf Game',
      email: 'alfgame321@gmail.com',
      color: AppAvatarColors.orange,
    ),
    'alifscc0311@gmail.com': UserModel(
      id: 3,
      name: 'Alif Muhammad',
      email: 'alifscc0311@gmail.com',
      color: AppAvatarColors.orange,
    ),
    'sotoayamcakipinktt@gmail.com': UserModel(
      id: 4,
      name: 'soto cak ipin',
      email: 'sotoayamcakipinktt@gmail.com',
      color: AppAvatarColors.green,
    ),
    'alifmhafizh0311@gmail.com': UserModel(
      id: 5,
      name: 'Alif Hafizh',
      email: 'alifmhafizh0311@gmail.com',
      color: AppAvatarColors.orange,
    ),
  };

  Future<UserModel> login(String email, String password) async {
    if (ApiConfig.useDummy) {
      await Future.delayed(const Duration(milliseconds: 600));
      final user = _dummyAccounts[email.trim().toLowerCase()];
      if (user == null || password != _dummyPassword) {
        throw Exception('Email atau sandi salah');
      }
      return user;
    }
    final data = await ApiService.post('/login', {
      'email': email,
      'password': password,
    });
    ApiService.token = data['token'];
    return UserModel.fromJson(data['user']);
  }

  /// Daftar akun baru ke database (POST /register), lalu langsung masuk.
  Future<UserModel> register(String name, String email, String password) async {
    if (ApiConfig.useDummy) return addAccount(email, password);
    final data = await ApiService.post('/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    ApiService.token = data['token'];
    return UserModel.fromJson(data['user']);
  }

  static const _newColors = [
    AppAvatarColors.teal,
    AppAvatarColors.orange,
    AppAvatarColors.green,
    AppAvatarColors.brown,
    AppAvatarColors.red,
  ];

  /// Untuk "Tambahkan akun lainnya". Mode dummy: akun bawaan dipakai apa
  /// adanya, email lain tetap diterima asal sandinya "password".
  Future<UserModel> addAccount(String email, String password) async {
    if (!ApiConfig.useDummy) return login(email, password);
    await Future.delayed(const Duration(milliseconds: 600));
    if (password != _dummyPassword) throw Exception('Email atau sandi salah');
    final known = _dummyAccounts[email];
    if (known != null) return known;
    final id = DateTime.now().millisecondsSinceEpoch % 1000000000 + 1000;
    final local = email.split('@').first.replaceAll(RegExp(r'[._]+'), ' ');
    final name = local.isEmpty
        ? email
        : local[0].toUpperCase() + local.substring(1);
    return UserModel(
      id: id,
      name: name,
      email: email,
      color: _newColors[id % _newColors.length],
    );
  }
}
