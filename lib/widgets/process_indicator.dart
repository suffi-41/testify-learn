import 'package:flutter/material.dart';

class FullScreenIndicator extends StatelessWidget {
  final Color backgroundColor;
  final Color indicatorColor;

  const FullScreenIndicator({
    super.key,
    this.backgroundColor = const Color.fromRGBO(
      0,
      0,
      0,
      0.5,
    ), // semi-transparent black
    this.indicatorColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dim background
          ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.5)),
          // Loading spinner
          Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
