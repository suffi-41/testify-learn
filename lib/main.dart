import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import "./routes/app_router.dart";
import './theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCp4nq1FBAkRuiYwJVWUq1r-8B659UU9jc",
        authDomain: "testify-learn-application.firebaseapp.com",
        projectId: "testify-learn-application",
        storageBucket: "testify-learn-application.firebasestorage.app",
        messagingSenderId: "887875287802",
        appId: "1:887875287802:web:f3c6dfb97aa17865b72743",
        measurementId: "G-1ZN1ZSH1WR",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.goRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
