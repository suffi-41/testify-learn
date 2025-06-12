import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

// redux
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/actions/auth_actions.dart';
import '../../../models/root_state.dart';

class DashoardScreen extends StatelessWidget {
  const DashoardScreen({super.key});
  Future<void> _signOut(BuildContext context) async {
    final store = StoreProvider.of<RootState>(context);
    store.dispatch(LogoutRequestAction());
    context.go('/login'); // Navigate after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("teacher Dashboard")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signOut(context),
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
