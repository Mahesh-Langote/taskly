import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/category_provider.dart';
import 'providers/note_provider.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/sync_manager.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

// Global flag for offline mode
bool isOfflineMode = false;

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Try to initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully!");
  } catch (e) {
    // If Firebase fails to initialize, set offline mode flag
    isOfflineMode = true;
    debugPrint('Error initializing Firebase: $e');
  }

  // Run the app after Firebase initialization attempt
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create services first with offline mode flag
    final authService = AuthService(isOfflineMode: isOfflineMode);
    final databaseService = DatabaseService(isOfflineMode: isOfflineMode);

    // Create sync manager using both services
    final syncManager = SyncManager(
      authService: authService,
      databaseService: databaseService,
    );

    return MultiProvider(
      providers: [
        // Auth service provider
        ChangeNotifierProvider<AuthService>.value(value: authService),

        // Database service provider
        Provider<DatabaseService>.value(value: databaseService),

        // SyncManager provider
        Provider<SyncManager>.value(value: syncManager),

        // Theme provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Providers that depend on AuthService and SyncManager
        ChangeNotifierProxyProvider2<AuthService, SyncManager,
            CategoryProvider>(
          create: (_) => CategoryProvider(
            authService: authService,
            syncManager: syncManager,
          ),
          update: (_, authService, syncManager, previous) =>
              previous ??
              CategoryProvider(
                authService: authService,
                syncManager: syncManager,
              ),
        ),
        ChangeNotifierProxyProvider2<AuthService, SyncManager, TaskProvider>(
          create: (_) => TaskProvider(
            authService: authService,
            syncManager: syncManager,
          ),
          update: (_, authService, syncManager, previous) =>
              previous ??
              TaskProvider(
                authService: authService,
                syncManager: syncManager,
              ),
        ),

        // Note provider
        ChangeNotifierProxyProvider2<AuthService, SyncManager, NoteProvider>(
          create: (_) => NoteProvider(
            authService: authService,
            syncManager: syncManager,
          ),
          update: (_, authService, syncManager, previous) =>
              previous ??
              NoteProvider(
                authService: authService,
                syncManager: syncManager,
              ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Task Organizer',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
