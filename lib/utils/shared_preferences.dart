import 'package:shared_preferences/shared_preferences.dart';

// --- Enum for subscription status ---
enum SubscriptionStatus {
  notRegistered,
  trialActive,
  trialExpired,
  paidActive,
  paidExpired,
}

class PreferenceService {
  static const _keyAcceptedPolicies = 'acceptedPolicies';
  static const _keyIsRegistered = 'isRegistered';
  static const _keySubscriptionType = 'subscriptionType';
  static const _keyTrialStartDate = 'trialStartDate';
  static const _keyIsPaid = 'isPaid';
  static const _keySubscriptionStartDate = 'subscriptionStartDate';

  static Future<bool> getIsPaid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPaid) ?? false;
  }

  static Future<void> setIsPaid(bool isPaid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPaid, isPaid);
  }

  static Future<void> clearPaidFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsPaid);
  }

  static Future<void> setTrialStartDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTrialStartDate, date.toIso8601String());
  }

  static Future<DateTime?> getTrialStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyTrialStartDate);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  static Future<void> setSubscriptionStartDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubscriptionStartDate, date.toIso8601String());
  }

  static Future<DateTime?> getSubscriptionStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keySubscriptionStartDate);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  static Future<void> setAcceptedPolicies(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAcceptedPolicies, value);
  }

  static Future<void> setIsRegistered(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsRegistered, value);
  }

  static Future<void> setSubscriptionType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubscriptionType, type);
  }

  static Future<bool> getAcceptedPolicies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAcceptedPolicies) ?? false;
  }

  static Future<bool> getIsRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsRegistered) ?? false;
  }

  static Future<String?> getSubscriptionType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySubscriptionType);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // --- Robust Centralized subscription status logic ---
  static Future<SubscriptionStatus> getSubscriptionStatus() async {
    final isRegistered = await getIsRegistered();
    if (!isRegistered) return SubscriptionStatus.notRegistered;

    final plan = await getSubscriptionType();

    if (plan == 'free') {
      final trialStart = await getTrialStartDate();
      if (trialStart == null) return SubscriptionStatus.trialActive;
      final days = DateTime.now().difference(trialStart).inDays;
      if (days < 7) return SubscriptionStatus.trialActive;
      return SubscriptionStatus.trialExpired;
    }

    if (plan == 'year') {
      final subStart = await getSubscriptionStartDate();
      if (subStart == null) return SubscriptionStatus.paidActive;
      final days = DateTime.now().difference(subStart).inDays;
      if (days < 365) return SubscriptionStatus.paidActive;
      return SubscriptionStatus.paidExpired;
    }

    return SubscriptionStatus.notRegistered;
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAcceptedPolicies);
    await prefs.remove(_keyIsRegistered);
    await prefs.remove(_keySubscriptionType);
    await prefs.remove(_keyTrialStartDate);
    await prefs.remove(_keySubscriptionStartDate);
    await prefs.remove(_keyIsPaid);
  }
}