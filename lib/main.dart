import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:firebase_core/firebase_core.dart';

// Store and models
import './redux/store/store.dart';
import './models/root_state.dart';

// Routes and Theme
import './routes/app_router.dart';
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final router = AppRouter.createRouter(appStore);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<RootState>(
      store: appStore,
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
