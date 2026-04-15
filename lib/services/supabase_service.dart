import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/env.dart';
import 'auth_service.dart';

/// Supabase service for database + storage operations.
/// Falls back to no-op when Supabase is not configured.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  SupabaseClient? _client;
  bool _initialized = false;

  bool get isConfigured => Env.isSupabaseConfigured;

  SupabaseClient? get client => _client;

  Future<void> init() async {
    if (!Env.isSupabaseConfigured) {
      _initialized = true;
      return;
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _initialized = true;
  }

  /// Sync Firebase/mock user to Supabase users table
  Future<void> syncUser(AppUser user) async {
    if (!isConfigured || _client == null) return;

    try {
      await _client!.from('users').upsert({
        'id': user.uid,
        'email': user.email,
        'display_name': user.displayName,
        'photo_url': user.photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (e) {
      // Silently fail if table doesn't exist yet
    }
  }

  /// Check if Supabase is initialized and ready
  bool get isReady => _initialized && isConfigured && _client != null;
}
