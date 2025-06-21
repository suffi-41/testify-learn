import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import './routes/app_router.dart'; // Your AppRouter file
import './theme/app_theme.dart'; // Your theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCp4nq1FBAkRuiYwJVWUq1r-8B659UU9jc",
        authDomain: "testify-learn-application.firebaseapp.com",
        projectId: "testify-learn-application",
        storageBucket: "testify-learn-application.appspot.com",
        messagingSenderId: "887875287802",
        appId: "1:887875287802:web:f3c6dfb97aa17865b72743",
        measurementId: "G-1ZN1ZSH1WR",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Create the router from SharedPreferences (local storage)
  final GoRouter router = await AppRouter.createRouter();
  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
