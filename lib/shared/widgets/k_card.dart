import 'package:flutter/material.dart';

class KCard extends StatelessWidget {
  const KCard({
    super.key,
    required this.child,
    this.tint = Colors.white,
    this.padding = 16,
  });

  final Widget child;
  final Color tint;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1EAE6),
        ),
      ),
      child: child,
    );
  }
}
