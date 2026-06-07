import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static const _keyToken = 'ventro_token';
  static const _keyTenantId = 'ventro_tenant_id';
  static const _keyOnboarding = 'ventro_onboarding_complete';

  static Future<void> saveSession({
    required String token,
    required String tenantId,
    bool onboardingComplete = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyTenantId, tenantId);
    await prefs.setBool(_keyOnboarding, onboardingComplete);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getTenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTenantId);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyTenantId);
    await prefs.remove(_keyOnboarding);
  }
}
