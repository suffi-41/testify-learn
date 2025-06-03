import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

// redux
import 'package:flutter_redux/flutter_redux.dart';
import '../../redux/actions/auth_actions.dart';
import '../../models/root_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  Timer? _timer;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    final store = StoreProvider.of<RootState>(context, listen: false);

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) async {
      if (user != null) {
        final role = await getUserRole(user.uid.toString());

        /// ✅ Dispatch LoginSuccess to Redux
        store.dispatch(
          AuthSuccess(user.uid, role.toString()),
        ); // or get role from Firestore
      } else {
        /// ✅ Dispatch LogoutAction to Redux
        store.dispatch(LogoutRequestAction());
      }
    });

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) context.go("/");
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          child: Hero(
            tag: 'app-logo',
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                "assets/images/app_logo.jpg",
                width: 120,
                height: 120,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
