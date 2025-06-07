import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget? largeDesttop;

  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.largeDesttop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        print("Current width: $width");

        if (width >= 1040) {
          return largeDesttop ?? Text("Hello $width");
        } else if (width >= 500) {
          return tablet;
        } else if (width >= 800) {
          return desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
