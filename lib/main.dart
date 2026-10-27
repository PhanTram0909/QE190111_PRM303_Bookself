import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/books_provider.dart';
import 'screens/books_list_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error / warning: $e');
  }

  runApp(const BookShelfApp());
}

class BookShelfApp extends StatelessWidget {
  const BookShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<BooksProvider>(
          create: (_) => BooksProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            primary: const Color(0xFF1E88E5),
            secondary: const Color(0xFF0D47A1),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// AuthGate manages the root authentication state.
/// - Shows a centered loading indicator while the initial auth state is resolving.
/// - Opens directly to BooksListScreen if the user is already authenticated.
/// - Opens to HomeScreen (public) if not logged in.
/// - Because navigation happens reactively at the root, pressing Back on the List screen
///   will not navigate back to Login or Register.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb_auth.User?>(
      stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking auth state, show only a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is authenticated, open directly on BooksListScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const BooksListScreen();
        }

        // If not logged in, show public HomeScreen
        return const HomeScreen();
      },
    );
  }
}
