import 'package:flutter/material.dart';
// import 'package:flutter_application_68test_vscode/intro.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_gate.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mrmqkhybjlkphrzvuxmp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ybXFraHliamxrcGhyenZ1eG1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzNjYzNzAsImV4cCI6MjA4Nzk0MjM3MH0.LG-lvRQM6HN2rmNacW12D8J1iL89hC9SxmC5GQ6oAQE',
  );

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
