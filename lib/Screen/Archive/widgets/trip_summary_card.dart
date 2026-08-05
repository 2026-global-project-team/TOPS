import 'package:flutter/material.dart';

class TripSummaryCard extends StatelessWidget {
  final String tripTitle;
  final int visitedPlacesCount;
  final VoidCallback onPlaceCountPressed;
  final VoidCallback onNewStoryPressed;
  final VoidCallback onTravelMapPressed;
  final VoidCallback onWishPressed;

  const TripSummaryCard({
    super.key,
    required this.tripTitle,
    required this.visitedPlacesCount,
    required this.onPlaceCountPressed,
    required this.onNewStoryPressed,
    required this.onTravelMapPressed,
    required this.onWishPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          const SizedBox(height: 2),

          Text(
            tripTitle,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            '$visitedPlacesCount+ Places Visited',
            style: const TextStyle(
              color: Color(0xFF2B2B2B),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: onPlaceCountPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2E3D83),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$visitedPlacesCount Places',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 11,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'New Story',
                  onTap: onNewStoryPressed,
                ),
                _ActionButton(
                  icon: Icons.route_outlined,
                  label: 'Travel Map',
                  onTap: onTravelMapPressed,
                ),
                _ActionButton(
                  icon: Icons.bookmark_border,
                  label: 'Wish',
                  onTap: onWishPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 88,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF6981FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}