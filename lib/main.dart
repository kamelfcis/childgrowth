import 'package:child_growth_tracker/pages/onboarding_page.dart';
import 'package:child_growth_tracker/utils/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService.initialize();  // ✅ Add this
  await Supabase.initialize(
    url: 'https://qparhqktuenpqviggbly.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwYXJocWt0dWVucHF2aWdnYmx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2MDI2MDEsImV4cCI6MjA1NTE3ODYwMX0.wPPMvLdXY89lIUUzJ_iXrm230VQZsUN5lNpyte-3Au8',  // Securely store this in environment variables
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Child Growth Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: OnboardingPage(),
    );
  }
}
