import 'package:flutter/material.dart';
import '../../utils/helpers.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  final List<Map<String, String>> notifications = [
    {
      "title": "New Quiz Available!",
      "subtitle": "Try out the new Science quiz now.",
      "time": "Just now",
    },
    {
      "title": "Leaderboard Updated",
      "subtitle": "You moved to 3rd place!",
      "time": "2 hours ago",
    },
    {
      "title": "Quiz Result",
      "subtitle": "Your score for Math Quiz is 85%",
      "time": "Yesterday",
    },
    {
      "title": "Reminder",
      "subtitle": "Don't forget to take the weekly quiz.",
      "time": "2 days ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        "Notifications",
        automaticallyImplyLeading:true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Icon(Icons.filter_2_outlined, color: Colors.white),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.notifications_active,
                color: Colors.deepPurple,
              ),
              title: Text(
                notif["title"] ?? "",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notif["subtitle"] ?? ""),
              trailing: Text(
                notif["time"] ?? "",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
