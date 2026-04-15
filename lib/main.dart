import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'services/auth_state.dart';
import 'services/bookmark_service.dart';
import 'services/resume_service.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage first
  await StorageService().init();

  // Initialize Firebase
  if (Env.isFirebaseConfigured) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        authDomain: Env.firebaseAuthDomain,
        projectId: Env.firebaseProjectId,
        storageBucket: Env.firebaseStorageBucket,
        messagingSenderId: Env.firebaseMessagingSenderId,
        appId: Env.firebaseAppId,
      ),
    );
  }

  // Initialize Supabase (no-op if not configured)
  await SupabaseService().init();

  runApp(const SmartApplyApp());
}

class SmartApplyApp extends StatelessWidget {
  const SmartApplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => ResumeService()),
        ChangeNotifierProvider(create: (_) => BookmarkService()),
      ],
      child: MaterialApp(
        title: 'SmartApply India',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
