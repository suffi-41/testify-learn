import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify_learn_application/constants/app_routes.dart';
import 'package:testify_learn_application/theme/color_pelette.dart';
import '../../utils/helpers.dart';
import '../../widgets/state_box.dart';
import '../../widgets/text_card.dart';
import '../../widgets/tab_buttom.dart';
import '../../utils/responsive.dart';
import '../../widgets/sticky_widget.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _tabIndex = 0;

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
                        "Coaching Name: Sufiyan coaching center",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Coaching code: A3899Y00990",
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
                      count: "4",
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
                ...List.generate(10, (index) => const TestCard()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
