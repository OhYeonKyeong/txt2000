import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;

  const PageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06; // 화면 너비의 5%

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: 2.0
      ),
      child: child,
    );
  }
}
