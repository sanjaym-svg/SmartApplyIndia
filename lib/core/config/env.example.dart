/// SmartApply India — Environment Configuration
///
/// Replace placeholder values with your actual Firebase + Supabase keys.
/// The app works in MOCK MODE when these are empty.
class Env {
  Env._();

  // ─── Supabase ───────────────────────────────────────────
  // Get these from: https://app.supabase.com → Project Settings → API
  static const String supabaseUrl = '';       // e.g. https://xxxx.supabase.co
  static const String supabaseAnonKey = '';    // e.g. eyJhbGciOiJI...

  // ─── Firebase Web ───────────────────────────────────────
  // Get these from: Firebase Console → Project Settings → Web App
  static const String firebaseApiKey = '';
  static const String firebaseAuthDomain = '';
  static const String firebaseProjectId = '';
  static const String firebaseStorageBucket = '';
  static const String firebaseMessagingSenderId = '';
  static const String firebaseAppId = '';

  // ─── Adzuna Job API ────────────────────────────────────
  // Get these from: https://developer.adzuna.com
  static const String adzunaAppId = '';
  static const String adzunaApiKey = '';

  // ─── Groq AI ──────────────────────────────────────────
  // Get free key from: https://console.groq.com/keys
  static const String groqApiKey = '';  // Free tier: 30 RPM, 14,400 req/day

  // ─── Mode Detection ─────────────────────────────────────
  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isAdzunaConfigured =>
      adzunaAppId.isNotEmpty && adzunaApiKey.isNotEmpty;

  static bool get isGroqConfigured => groqApiKey.isNotEmpty;

  static bool get isMockMode => !isFirebaseConfigured;
}
