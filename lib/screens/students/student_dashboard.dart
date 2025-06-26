import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify_learn_application/constants/app_routes.dart';
import 'package:testify_learn_application/theme/color_pelette.dart';
import '../../utils/helpers.dart';
import '../../widgets/state_box.dart';
import '../../widgets/tab_buttom.dart';
import '../../utils/responsive.dart';
import '../../widgets/sticky_widget.dart';
import './widgets/test_list.dart';
import '../../utils/loacl_storage.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _tabIndex = 0;
  String? _coachingCode;
  String _uid = ""; // Update this with actual UID from auth

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  void _loadLocalData() async {
    final code = await getLoacalStorage("coachingCode");
    final uid = await getLoacalStorage("uid");
    setState(() {
      _coachingCode = code;
      //  _uid = uid;
    });
  }

  void _setTab(int index) {
    setState(() {
      _tabIndex = index;
    });
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
                        "Welcome back, Affan!",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Coaching Code: $_coachingCode",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    StatBox(
                      count: "12",
                      label: "Tests Taken",
                      color: AppColors.primaryComman,
                      icon: Icons.assignment,
                    ),
                    StatBox(
                      count: "4",
                      label: "Tests Won",
                      color: AppColors.tertiaryComman,
                      icon: Icons.emoji_events,
                    ),
                    StatBox(
                      count: "2",
                      label: "Rank",
                      color: AppColors.secondaryComman,
                      icon: Icons.leaderboard,
                    ),
                  ],
                ),
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
                  label: 'New tests',
                  index: 0,
                  currentIndex: _tabIndex,
                  onTap: _setTab,
                ),
                TabButton(
                  label: 'Enroll tests',
                  index: 1,
                  currentIndex: _tabIndex,
                  onTap: _setTab,
                ),
                TabButton(
                  label: 'Completed tests',
                  index: 2,
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
                if (_coachingCode != null)
                  TestListScreen(
                    // uid: _uid,
                    coachingCode: _coachingCode!,
                    // tabIndex: _tabIndex,
                  )
                else
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
