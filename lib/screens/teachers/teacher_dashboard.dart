import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify_learn_application/constants/app_routes.dart';

import 'package:testify_learn_application/theme/color_pelette.dart';
import '../../utils/helpers.dart';
import '../../widgets/state_box.dart';
import '../../utils/loacl_storage.dart';

import '../../widgets/tab_buttom.dart';
import '../../utils/responsive.dart';
import '../../widgets/sticky_widget.dart';

// teacher widgets
import './widgets/test_list_screen.dart';
import './widgets/studnet_list_screen.dart';
import './widgets/all_activity_list.dart';
// firebase
import 'package:cloud_firestore/cloud_firestore.dart';

// services
import '../../services/firebase_service.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _tabIndex = 0;
  String? uid;
  String? code;
  String? coaching_name;
  String? name;
  int totalTests = 0;

  @override
  void initState() {
    super.initState();
    fetchTeacherDetails();
  }

  void _setTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void fetchTeacherDetails() async {
    final userId = await getLoacalStorage("uid");
    final user = await userDetails(userId.toString(), "teachers");
    if (user != null) {
      final coachingCode = user["coachingCode"]?.toString() ?? "N/A";
      saveLoacalStorage("coachingCode", coachingCode);
      final quizSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('createdBy', isEqualTo: userId.toString())
          .where('coachingCode', isEqualTo: coachingCode)
          .get();

      setState(() {
        uid = userId;
        code = coachingCode;
        coaching_name = user['coachingName']?.toString() ?? "N/A";
        name = user['fullName']?.toString() ?? "N/A";
        totalTests = quizSnapshot.docs.length;
      });
    } else {
      print("User not found or no data available");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        "Dashboard",
        actions: [
          IconButton(
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
            icon: const Icon(
              Icons.notifications,
              color: AppColors.iconsPrimary,
              size: 30,
            ),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _dashboardBody(context),
        tablet: _dashboardBody(context),
        desktop: _dashboardBody(context),
        largeDesttop: Row(
          children: [
            Expanded(flex: 2, child: _dashboardBody(context)),
            const VerticalDivider(width: 1),
            const Expanded(child: Center(child: Text("Extra Panel"))),
          ],
        ),
      ),
    );
  }

  Widget _dashboardBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back, ${name ?? 'Loading...'}!",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Coaching Name: ${coaching_name ?? 'Loading...'}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Coaching code: ${code ?? 'Loading...'}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    StatBox(
                      count: "200",
                      label: "Students",
                      color: AppColors.primaryComman,
                      icon: Icons.group,
                    ),
                    StatBox(
                      count: totalTests.toString() ?? "Loadding...",
                      label: "Tests",
                      color: AppColors.tertiaryComman,
                      icon: Icons.assignment,
                    ),
                    StatBox(
                      count: "32030",
                      label: "Earnings",
                      color: AppColors.secondaryComman,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                UiHelpers.customButton(context, "+ Create new test", () {
                  context.go(AppRoutes.createNewTests);
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        StickyTopPositioned(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TabButton(
                  label: 'All',
                  index: 0,
                  currentIndex: _tabIndex,
                  onTap: _setTab,
                ),
                TabButton(
                  label: 'Students',
                  index: 1,
                  currentIndex: _tabIndex,
                  onTap: _setTab,
                ),
                TabButton(
                  label: 'Tests',
                  index: 2,
                  currentIndex: _tabIndex,
                  onTap: _setTab,
                ),
                TabButton(
                  label: 'Earnings',
                  index: 3,
                  currentIndex: _tabIndex,
                  onTap: _setTab,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tabIndex == 0
                      ? 'Recent Activity'
                      : _tabIndex == 1
                          ? 'Upcoming Tests'
                          : 'Completed Tests',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _getTabContent(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getTabContent() {
    if (uid == null && code == null) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (_tabIndex) {
      case 0:
        return AllActivityList(uid: uid!, coachingCode: code!);
      case 1:
        return StudentListScreen(coachingCode: code!);
      case 2:
        return TestListScreen(uid: uid!, coachingCode: code!);
      case 3:
        return const Center(child: Text('Earnings will be shown here.'));
      default:
        return const SizedBox.shrink();
    }
  }
}
