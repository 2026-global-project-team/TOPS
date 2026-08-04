import 'package:flutter/material.dart';

class ArrowActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;
  final double size;

  const ArrowActionButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.icon = Icons.arrow_forward,
    this.size = 54,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(
          icon,
          color: Colors.white,
          size: size * 0.46,
        ),
      ),
    );
  }
}