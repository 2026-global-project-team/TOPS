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
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.fromLTRB(
        12,
        24,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            tripTitle,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            '$visitedPlacesCount+ Places Visited',
            style: const TextStyle(
              color: Color(0xFF292929),
              fontSize: 24,
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
                color: const Color(0xFF2D3977),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$visitedPlacesCount Places',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TripMenuItem(
                  icon: Icons.edit_outlined,
                  label: 'New Story',
                  onPressed: onNewStoryPressed,
                ),
                _TripMenuItem(
                  icon: Icons.route_outlined,
                  label: 'Travel Map',
                  onPressed: onTravelMapPressed,
                ),
                _TripMenuItem(
                  icon: Icons.bookmark_border,
                  label: 'Wish',
                  onPressed: onWishPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _TripMenuItem({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF6480FF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Colors.white,
                size: 27,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF292929),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}