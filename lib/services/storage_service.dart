import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized local storage service using SharedPreferences.
/// Persists user sessions, resume data, bookmarks, and preferences.
class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  SharedPreferences? _prefs;

  // ─── Keys ──────────────────────────────────────────────
  static const String _keyUserUid = 'user_uid';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_display_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserBio = 'user_bio';
  static const String _keyUserPhoto = 'user_photo_url';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static const String _keyResumeText = 'resume_text';
  static const String _keyResumeFileName = 'resume_file_name';

  static const String _keyBookmarkedIds = 'bookmarked_job_ids';
  static const String _keyBookmarkedData = 'bookmarked_jobs_data';
  static const String _keyAppliedIds = 'applied_job_ids';
  static const String _keyAppliedData = 'applied_jobs_data';

  static const String _keyNotifJobAlerts = 'notif_job_alerts';
  static const String _keyNotifAppUpdates = 'notif_app_updates';
  static const String _keyNotifResumeTips = 'notif_resume_tips';
  static const String _keyNotifPromo = 'notif_promotional';

  static const String _keyPrivacyProfile = 'privacy_profile_visible';
  static const String _keyPrivacyDataSharing = 'privacy_data_sharing';
  static const String _keyPrivacyAnalytics = 'privacy_analytics';

  // ─── Init ──────────────────────────────────────────────

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isReady => _prefs != null;

  // ─── User Session ──────────────────────────────────────

  Future<void> saveUser({
    required String uid,
    required String email,
    required String displayName,
    String? phone,
    String? bio,
    String? photoUrl,
  }) async {
    await _prefs?.setString(_keyUserUid, uid);
    await _prefs?.setString(_keyUserEmail, email);
    await _prefs?.setString(_keyUserName, displayName);
    if (phone != null) await _prefs?.setString(_keyUserPhone, phone);
    if (bio != null) await _prefs?.setString(_keyUserBio, bio);
    if (photoUrl != null) await _prefs?.setString(_keyUserPhoto, photoUrl);
    await _prefs?.setBool(_keyIsLoggedIn, true);
  }

  bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;

  Map<String, String?> loadUser() {
    if (!isLoggedIn) return {};
    return {
      'uid': _prefs?.getString(_keyUserUid),
      'email': _prefs?.getString(_keyUserEmail),
      'displayName': _prefs?.getString(_keyUserName),
      'phone': _prefs?.getString(_keyUserPhone),
      'bio': _prefs?.getString(_keyUserBio),
      'photoUrl': _prefs?.getString(_keyUserPhoto),
    };
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? phone,
    String? bio,
  }) async {
    if (displayName != null) await _prefs?.setString(_keyUserName, displayName);
    if (phone != null) await _prefs?.setString(_keyUserPhone, phone);
    if (bio != null) await _prefs?.setString(_keyUserBio, bio);
  }

  Future<void> clearUser() async {
    await _prefs?.remove(_keyUserUid);
    await _prefs?.remove(_keyUserEmail);
    await _prefs?.remove(_keyUserName);
    await _prefs?.remove(_keyUserPhone);
    await _prefs?.remove(_keyUserBio);
    await _prefs?.remove(_keyUserPhoto);
    await _prefs?.setBool(_keyIsLoggedIn, false);
  }

  // ─── Resume ────────────────────────────────────────────

  Future<void> saveResume(String text, String fileName) async {
    await _prefs?.setString(_keyResumeText, text);
    await _prefs?.setString(_keyResumeFileName, fileName);
  }

  String? get savedResumeText => _prefs?.getString(_keyResumeText);
  String? get savedResumeFileName => _prefs?.getString(_keyResumeFileName);

  Future<void> clearResume() async {
    await _prefs?.remove(_keyResumeText);
    await _prefs?.remove(_keyResumeFileName);
  }

  // ─── Bookmarks ─────────────────────────────────────────

  Future<void> saveBookmarks(Map<String, dynamic> bookmarkedJobs) async {
    await _prefs?.setString(_keyBookmarkedData, jsonEncode(bookmarkedJobs));
  }

  Map<String, dynamic>? loadBookmarks() {
    final data = _prefs?.getString(_keyBookmarkedData);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveApplied(Map<String, dynamic> appliedJobs) async {
    await _prefs?.setString(_keyAppliedData, jsonEncode(appliedJobs));
  }

  Map<String, dynamic>? loadApplied() {
    final data = _prefs?.getString(_keyAppliedData);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ─── Notification Preferences ──────────────────────────

  Future<void> saveNotificationPrefs({
    required bool jobAlerts,
    required bool appUpdates,
    required bool resumeTips,
    required bool promotional,
  }) async {
    await _prefs?.setBool(_keyNotifJobAlerts, jobAlerts);
    await _prefs?.setBool(_keyNotifAppUpdates, appUpdates);
    await _prefs?.setBool(_keyNotifResumeTips, resumeTips);
    await _prefs?.setBool(_keyNotifPromo, promotional);
  }

  bool get notifJobAlerts => _prefs?.getBool(_keyNotifJobAlerts) ?? true;
  bool get notifAppUpdates => _prefs?.getBool(_keyNotifAppUpdates) ?? true;
  bool get notifResumeTips => _prefs?.getBool(_keyNotifResumeTips) ?? true;
  bool get notifPromotional => _prefs?.getBool(_keyNotifPromo) ?? false;

  // ─── Privacy Preferences ──────────────────────────────

  Future<void> savePrivacyPrefs({
    required bool profileVisible,
    required bool dataSharing,
    required bool analytics,
  }) async {
    await _prefs?.setBool(_keyPrivacyProfile, profileVisible);
    await _prefs?.setBool(_keyPrivacyDataSharing, dataSharing);
    await _prefs?.setBool(_keyPrivacyAnalytics, analytics);
  }

  bool get privacyProfileVisible => _prefs?.getBool(_keyPrivacyProfile) ?? true;
  bool get privacyDataSharing => _prefs?.getBool(_keyPrivacyDataSharing) ?? false;
  bool get privacyAnalytics => _prefs?.getBool(_keyPrivacyAnalytics) ?? true;

  /// Clear all stored data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
