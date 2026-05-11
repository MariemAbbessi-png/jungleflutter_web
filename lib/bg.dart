import 'package:flutter/material.dart';

class bg extends StatelessWidget {
  final Widget child;

  const bg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'images/bgi.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: Container(
              width: 1050,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(25),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
