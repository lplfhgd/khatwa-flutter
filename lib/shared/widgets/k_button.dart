import 'package:flutter/material.dart';

class KButton extends StatelessWidget {
  const KButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.large = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: large ? 72 : 52,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF168F8B),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(large ? 24 : 14),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: large ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF168F8B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(large ? 24 : 14),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: large ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
