import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

// redux
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/actions/auth_actions.dart';
import '../../../models/root_state.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final store = StoreProvider.of<RootState>(context);
    store.dispatch(LogoutRequestAction());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signOut(context),
          child: Text("Logout ${currentUser?.email ?? ''}"),
        ),
      ),
    );
  }
}
