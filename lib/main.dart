import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/features/auth/ui/auth_screen.dart';
import 'package:zeyra/features/dashboard/ui/home_page.dart';
import 'package:zeyra/core/constants/app_constants.dart';
import 'package:zeyra/features/auth/ui/reset_password_screen.dart';

// Global NavigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await AppConstants.loadEnv();

  // Initialize Supabase with values from AppConstants
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _supabase = Supabase.instance.client;
  User? _user;

  @override
  void initState() {
    super.initState();
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      final AuthChangeEvent event = data.event;

      setState(() {
        _user = session?.user;
      });

      // Check if the app has a navigator and context before trying to navigate
      if (navigatorKey.currentState != null && navigatorKey.currentContext != null) {
        if (event == AuthChangeEvent.passwordRecovery) {
          // Navigate to ResetPasswordScreen
          // Ensure no other dialogs or routes are on top that might block this.
          // Consider clearing stack or using a dedicated router if navigation becomes complex.
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
            (route) => route.isFirst, // Removes all routes until the first one (AuthScreen or HomePage)
                                       // then pushes ResetPasswordScreen, effectively making it the top route.
                                       // If AuthScreen is first, it will be AuthScreen -> ResetPasswordScreen.
          );
        } else if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
          // If user signs in or token is refreshed and they are on ResetPasswordScreen,
          // pop back to show HomePage (or AuthScreen if somehow session is null again).
          if (navigatorKey.currentState!.canPop()) {
            // Check if current route is ResetPasswordScreen, then pop
            // This is a simple check. A more robust way is to use route names with a routing package.
            navigatorKey.currentState!.popUntil((route) {
                return route.settings.name != null && route.settings.name == '/' || route.isFirst;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Assign the navigatorKey
      title: 'Zeyra Health App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // You can customize your theme further here
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          )
        )
      ),
      // If the user is logged in, show the HomePage, otherwise show AuthScreen.
      // This handles the navigation after OAuth flows as well.
      home: _user == null ? const AuthScreen() : const HomePage(),
      // If you are using go_router, you would set up your routes here
      // and use a redirect in the router based on the auth state.
    );
  }
}
