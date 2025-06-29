import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify_learn_application/constants/app_routes.dart';
import '../../utils/responsive.dart';
import '../students/widgets/student_drawer.dart';

class TeacherMainScaffold extends StatelessWidget {
  final Widget child;
  const TeacherMainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: child,
        tablet: child,
        desktop: Row(
          children: [
            buildStudentDrawer(context), // always visible drawer
            Expanded(
              child: child, // main content fills the rest
            ),
          ],
        ),
        largeDesttop: Row(
          children: [
            buildStudentDrawer(context), // always visible drawer
            Expanded(
              child: child, // main content fills the rest
            ),
          ],
        ),
      ),

      bottomNavigationBar: ResponsiveLayout(
        mobile: _bottomNaviagationBar(context),
        tablet: Container(
          color: Theme.of(context)
              .appBarTheme
              .backgroundColor, // 🔴 Set your desired background color here
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 500, child: _bottomNaviagationBar(context)),
            ],
          ),
        ),

        desktop: SizedBox(child: null),
        largeDesttop: SizedBox(child: null),
      ),
    );
  }

  Widget _bottomNaviagationBar(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;

    if (location.startsWith(AppRoutes.teacherShowStudent))
      index = 1;
    else if (location.startsWith(AppRoutes.createNewTests))
      index = 2;
    else if (location.startsWith(AppRoutes.teacherProfile))
      index = 4;
    else if (location.startsWith(AppRoutes.teacherWallet))
      index = 3;
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (value) {
        switch (value) {
          case 0:
            context.go(AppRoutes.teacherDashboard);
            break;
          case 1:
            context.go(AppRoutes.teacherShowStudent);
            break;
          case 2:
            context.go(AppRoutes.createNewTests);
            break;
          case 3:
            context.go(AppRoutes.teacherWallet);
            break;
          case 4:
            context.go(AppRoutes.teacherProfile);
        }
      },
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Students'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
