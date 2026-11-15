enum AppEnvironment {
  prod,
  staging,
  local,
  emulator,
  lan;

  static AppEnvironment fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'local':
      case 'dev':
      case 'development':
        return AppEnvironment.local;
      case 'emulator':
      case 'android_emulator':
        return AppEnvironment.emulator;
      case 'lan':
        return AppEnvironment.lan;
      case 'prod':
      case 'production':
      default:
        return AppEnvironment.prod;
    }
  }
}

class Env {
  // Read from --dart-define
  static const String _rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'prod');
  static const String _rawBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
  static const String _rawMediaBaseUrl = String.fromEnvironment('MEDIA_BASE_URL', defaultValue: '');
  static const String _rawLanIp = String.fromEnvironment('LAN_IP', defaultValue: '192.168.1.100');

  // Allow test override
  static AppEnvironment? _overrideEnvironment;
  static String? _overrideBaseUrl;
  static String? _overrideMediaBaseUrl;

  static void setOverride({
    AppEnvironment? environment,
    String? baseUrl,
    String? mediaBaseUrl,
  }) {
    _overrideEnvironment = environment;
    _overrideBaseUrl = baseUrl;
    _overrideMediaBaseUrl = mediaBaseUrl;
  }

  static void reset() {
    _overrideEnvironment = null;
    _overrideBaseUrl = null;
    _overrideMediaBaseUrl = null;
  }

  static AppEnvironment get currentEnvironment =>
      _overrideEnvironment ?? AppEnvironment.fromString(_rawEnv);

  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }
    if (_rawBaseUrl.isNotEmpty) return _rawBaseUrl;

    return getBaseUrlForEnvironment(currentEnvironment, lanIp: _rawLanIp);
  }

  /// The hostname of the API server (used for strict SSL certificate pinning).
  static String get apiHost => Uri.tryParse(baseUrl)?.host ?? 'ghorbd.com';

  static String get mediaBaseUrl {
    if (_overrideMediaBaseUrl != null && _overrideMediaBaseUrl!.isNotEmpty) {
      return _overrideMediaBaseUrl!;
    }
    if (_rawMediaBaseUrl.isNotEmpty) return _rawMediaBaseUrl;

    return getMediaBaseUrlForEnvironment(currentEnvironment, lanIp: _rawLanIp);
  }

  static String getBaseUrlForEnvironment(
    AppEnvironment environment, {
    String lanIp = '192.168.1.100',
  }) {
    switch (environment) {
      case AppEnvironment.prod:
        return 'https://ghorbd.com/api';
      case AppEnvironment.staging:
        return 'https://staging.ghorbd.com/api';
      case AppEnvironment.local:
        return 'http://localhost:5000/api';
      case AppEnvironment.emulator:
        return 'http://10.0.2.2:5000/api';
      case AppEnvironment.lan:
        return 'http://$lanIp:5000/api';
    }
  }

  static String getMediaBaseUrlForEnvironment(
    AppEnvironment environment, {
    String lanIp = '192.168.1.100',
  }) {
    switch (environment) {
      case AppEnvironment.prod:
        return 'https://ghorbd.com';
      case AppEnvironment.staging:
        return 'https://staging.ghorbd.com';
      case AppEnvironment.local:
        return 'http://localhost:5000';
      case AppEnvironment.emulator:
        return 'http://10.0.2.2:5000';
      case AppEnvironment.lan:
        return 'http://$lanIp:5000';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  static bool get isProduction => currentEnvironment == AppEnvironment.prod;
  static bool get isDevelopment => currentEnvironment != AppEnvironment.prod;
}
