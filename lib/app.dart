import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/features/auth/ui/widgets/auth_gate.dart'; // Restore AuthGate

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const App({super.key, required this.navigatorKey}); // Add navigatorKey to constructor

  @override
  Widget build(BuildContext context) {
    // Wrap the entire application with ProviderScope for Riverpod state management
    return ProviderScope(
      child: MaterialApp(
        navigatorKey: navigatorKey, // Pass navigatorKey to MaterialApp
        title: 'Zeyra Health App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              primary: Colors.teal[700], // Darker teal for primary elements
              secondary: Colors.pinkAccent[200], // A vibrant secondary color
              surface: Colors.white, // Card and dialog backgrounds
              error: Colors.red[600],
          ),
          scaffoldBackgroundColor: Colors.grey[100], // Set scaffold background explicitly
          useMaterial3: true,
          fontFamily: 'Roboto', // A common, readable font
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal[600], // Consistent AppBar color
            foregroundColor: Colors.white, // Text and icon color for AppBar
            elevation: 2.0,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto', // Ensure font consistency
              color: Colors.white, // Explicitly set title color
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.pinkAccent[200],
            foregroundColor: Colors.white,
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded FAB
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Roboto'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.teal[700],
            unselectedItemColor: Colors.grey[700], 
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0), 
            unselectedLabelStyle: const TextStyle(fontSize: 11.5), // Slightly smaller unselected label
            backgroundColor: Colors.white, 
            elevation: 8.0, 
            type: BottomNavigationBarType.fixed, 
          ),
          cardTheme: CardThemeData(
            elevation: 2.0, // Subtle shadow for cards
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Rounded cards
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0), 
          ),
          listTileTheme: ListTileThemeData(
            iconColor: Colors.teal[600],
            tileColor: Colors.transparent, // Ensure ListTiles can inherit Card color
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Rounded ListTiles if used standalone
          ),
          inputDecorationTheme: InputDecorationTheme( // Basic styling for text fields
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          textTheme: TextTheme( // Base text styles for consistency
            displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.teal[800]),
            titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.black87),
            titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, fontFamily: 'Roboto', color: Colors.black87),
            bodyLarge: TextStyle(fontSize: 16.0, fontFamily: 'Roboto', color: Colors.grey[800]),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Roboto', color: Colors.grey[700]),
            labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: 'Roboto', color: Colors.white), // For button text
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.teal[700], fontFamily: 'Roboto'),
          ),
        ),
        debugShowCheckedModeBanner: false, // Clean look for MVP
        home: const AuthGate(), // Restore AuthGate as home
      ),
    );
  }
} 