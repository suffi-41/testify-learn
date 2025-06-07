import 'package:flutter/material.dart';

class StickyTopPositioned extends StatelessWidget {
  final Widget child;

  const StickyTopPositioned({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeader(child: child),
    );
  }
}

class _StickyHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyHeader({required this.child});

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyHeader oldDelegate) {
    return child != oldDelegate.child;
  }
}
