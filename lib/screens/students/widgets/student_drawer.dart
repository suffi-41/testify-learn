import 'package:flutter/material.dart';
import "package:go_router/go_router.dart";
import "../../../constants/app_routes.dart";

Widget buildStudentDrawer(BuildContext context) {
  return Container(
    width: 250, // fixed width for the sidebar
    color: Colors.deepPurple,
    child: ListView(
      children: [
        DrawerHeader(
          child: Text(
            'Menu',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home, color: Colors.white),
          title: Text('Home', style: TextStyle(color: Colors.white)),
          onTap: () {
            context.go(AppRoutes.studentDashboard);
          },
        ),
        ListTile(
          leading: Icon(Icons.assignment, color: Colors.white),
          title: Text('Tests', style: TextStyle(color: Colors.white)),
          onTap: () {
            context.go(AppRoutes.studentTest);
          },
        ),
        ListTile(
          leading: Icon(Icons.leaderboard, color: Colors.white),
          title: Text('Rank', style: TextStyle(color: Colors.white)),
          onTap: () {
            context.go(AppRoutes.testLeaderborad);
          },
        ),
        ListTile(
          leading: Icon(Icons.wallet, color: Colors.white),
          title: Text('Wallet', style: TextStyle(color: Colors.white)),
          onTap: () {
            context.go(AppRoutes.studentWallet);
          },
        ),
        ListTile(
          leading: Icon(Icons.person, color: Colors.white),
          title: Text('Profile', style: TextStyle(color: Colors.white)),
          onTap: () {
            context.go(AppRoutes.studentProfile);
          },
        ),
      ],
    ),
  );
}
