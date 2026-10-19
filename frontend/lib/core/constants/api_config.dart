import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // true = pakai data dummy (TIDAK masuk database), false = pakai Laravel API + MySQL
  static const bool useDummy = false;

  // Web (Chrome) & desktop: localhost. Android emulator: 10.0.2.2.
  // HP asli: ganti dengan IP laptop, misal http://192.168.1.5:8000/api
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';
}
