import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://gdlazfqxhbbtpushuojo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkbGF6ZnF4aGJidHB1c2h1b2pvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTYwMzgsImV4cCI6MjA2NzAzMjAzOH0.vcaq0oHVDcjfzuZQxTgHYklKrAVPM3EyPYk--Q63jzI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF to Audiobook',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: AuthScreen(),
    );
  }
}
