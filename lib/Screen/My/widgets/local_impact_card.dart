import 'dart:math' as math;

import 'package:flutter/material.dart';

class LocalImpactCard extends StatelessWidget {
  const LocalImpactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: const [
              Text(
                'Local Impact',
                style: TextStyle(
                  color: Color(0xFF627BFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(width: 18),

              Expanded(
                child: Text(
                  'Contribution by category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 135,
                height: 135,
                child: CustomPaint(
                  painter: LocalImpactChartPainter(),
                ),
              ),

              const SizedBox(width: 28),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _LegendItem(
                    color: Color(0xFF6981FF),
                    label: 'Cafe',
                  ),
                  SizedBox(height: 8),
                  _LegendItem(
                    color: Color(0xFF485CB7),
                    label: 'Restaurant',
                  ),
                  SizedBox(height: 8),
                  _LegendItem(
                    color: Color(0xFF33418E),
                    label: 'Culture',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class LocalImpactChartPainter extends CustomPainter {
  const LocalImpactChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = math.min(
      size.width,
      size.height,
    ) /
        2;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.butt;

    const values = [0.20, 0.55, 0.25];

    const colors = [
      Color(0xFF6981FF),
      Color(0xFF485CB7),
      Color(0xFF33418E),
    ];

    double startAngle = -math.pi / 2;

    for (int index = 0; index < values.length; index++) {
      final sweepAngle =
          (math.pi * 2 * values[index]) - 0.025;

      paint.color = colors[index];

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += math.pi * 2 * values[index];
    }
  }

  @override
  bool shouldRepaint(
      covariant LocalImpactChartPainter oldDelegate,
      ) {
    return false;
  }
}