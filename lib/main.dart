import 'package:flutter/material.dart';
// import 'package:flutter_application_68test_vscode/intro.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mrmqkhybjlkphrzvuxmp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ybXFraHliamxrcGhyenZ1eG1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzNjYzNzAsImV4cCI6MjA4Nzk0MjM3MH0.LG-lvRQM6HN2rmNacW12D8J1iL89hC9SxmC5GQ6oAQE',
  );

  final prefs = await SharedPreferences.getInstance();
  final lastActiveStr = prefs.getString('last_active');
  final now = DateTime.now();

  if (lastActiveStr != null) {
    final lastActive = DateTime.parse(lastActiveStr);
    final diff = now.difference(lastActive);

    if (diff.inDays >= 7) {
      // Session expired
      await Supabase.instance.client.auth.signOut();
      await prefs.remove('last_active');
    } else {
      // Update last active
      await prefs.setString('last_active', now.toIso8601String());
    }
  } else {
    // Check if there is an existing session but no timestamp (first update)
    if (Supabase.instance.client.auth.currentSession != null) {
      await prefs.setString('last_active', now.toIso8601String());
    }
  }

  // Also listen for auth changes to set the timestamp upon manual login
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      await prefs.setString('last_active', DateTime.now().toIso8601String());
    } else if (event == AuthChangeEvent.signedOut) {
      await prefs.remove('last_active');
    }
  });

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
