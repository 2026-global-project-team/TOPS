import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PolaroidCard extends StatelessWidget {
  final Widget image;
  final double width;
  final double height;

  const PolaroidCard({
    super.key,
    required this.image,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        62,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRect(
        child: SizedBox.expand(
          child: image,
        ),
      ),
    );
  }
}