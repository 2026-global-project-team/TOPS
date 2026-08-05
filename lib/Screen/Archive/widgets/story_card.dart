import 'package:flutter/material.dart';

import '../models/story.dart';

class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onPressed;
  final VoidCallback onWishPressed;

  const StoryCard({
    super.key,
    required this.story,
    required this.onPressed,
    required this.onWishPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 280,
        margin: const EdgeInsets.only(
          bottom: 18,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackgroundImage(),

              // 위쪽 사진 개수
              Positioned(
                top: 14,
                left: 16,
                child: _PhotoCountBadge(
                  photoCount: story.imageUrls.length,
                ),
              ),

              // 오른쪽 위 찜 버튼
              Positioned(
                top: 14,
                right: 16,
                child: _WishButton(
                  isWish: story.isWish,
                  onPressed: onWishPressed,
                ),
              ),

              // 아래쪽 기록 정보
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: _StoryInformation(
                  story: story,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (story.imageUrls.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 48,
        ),
      );
    }

    final imageUrl = story.imageUrls.first;

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 48,
            ),
          );
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
            size: 48,
          ),
        );
      },
    );
  }
}

class _PhotoCountBadge extends StatelessWidget {
  final int photoCount;

  const _PhotoCountBadge({
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '+$photoCount Photos',
        style: const TextStyle(
          color: Color(0xFF6680FF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _WishButton extends StatelessWidget {
  final bool isWish;
  final VoidCallback onPressed;

  const _WishButton({
    required this.isWish,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            isWish
                ? Icons.favorite
                : Icons.favorite_border,
            color: const Color(0xFF6680FF),
            size: 27,
          ),
        ),
      ),
    );
  }
}

class _StoryInformation extends StatelessWidget {
  final Story story;

  const _StoryInformation({
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: [
          _DateCircle(
            date: story.visitedAt,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF292929),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey,
                      size: 16,
                    ),

                    const SizedBox(width: 3),

                    Expanded(
                      child: Text(
                        story.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _DateCircle extends StatelessWidget {
  final DateTime date;

  const _DateCircle({
    required this.date,
  });

  static const List<String> _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];

    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$day, $month',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}