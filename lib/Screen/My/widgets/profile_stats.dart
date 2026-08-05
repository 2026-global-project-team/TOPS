import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int placesCount;
  final int photosCount;
  final int wishCount;

  const ProfileStats({
    super.key,
    required this.placesCount,
    required this.photosCount,
    required this.wishCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 38,
        vertical: 30,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              title: 'Places',
              count: placesCount,
            ),
          ),

          const SizedBox(
            height: 54,
            child: VerticalDivider(
              color: Color(0xFFD0D0D0),
              thickness: 1,
            ),
          ),

          Expanded(
            child: _StatItem(
              title: 'Photos',
              count: photosCount,
            ),
          ),

          const SizedBox(
            height: 54,
            child: VerticalDivider(
              color: Color(0xFFD0D0D0),
              thickness: 1,
            ),
          ),

          Expanded(
            child: _StatItem(
              title: 'Wish',
              count: wishCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final int count;

  const _StatItem({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          count.toString(),
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}