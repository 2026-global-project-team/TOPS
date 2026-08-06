//홈 화면 UI 위젯 모음
import 'package:flutter/material.dart';

const Color homePrimaryColor = Color(0xFF6883FF);

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: Color(0xFF999999),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Start your local journey...',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCategoryTabs extends StatelessWidget {
  const HomeCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        categories.length,
            (index) {
          final selected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(index),
              child: SizedBox(
                height: 38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      categories[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? Colors.black
                            : const Color(0xFF8B8B8B),
                      ),
                    ),
                    const SizedBox(height: 7),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 26 : 0,
                      height: 2,
                      decoration: BoxDecoration(
                        color: selected
                            ? homePrimaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onMorePressed,
  });

  final String title;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (onMorePressed != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMorePressed,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Text(
                    'More',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B8B8B),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 17,
                    color: Color(0xFF8B8B8B),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ArchivePlacesList extends StatelessWidget {
  const ArchivePlacesList({
    super.key,
    required this.places,
  });

  final List<Map<String, dynamic>> places;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const HomeEmptyBox(height: 205);
    }

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final place = places[index];
          final name =
              place['name']?.toString() ?? 'Local Place';
          final imageUrl = place['image_url']?.toString();

          return Container(
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                HomeNetworkImage(
                  imageUrl: imageUrl,
                  width: 170,
                  height: 205,
                  borderRadius: 18,
                ),
                const Positioned(
                  top: 10,
                  right: 10,
                  child: HomeFavoriteButton(),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HorizontalPlacesList extends StatelessWidget {
  const HorizontalPlacesList({
    super.key,
    required this.places,
    required this.cardWidth,
    required this.imageHeight,
  });

  final List<Map<String, dynamic>> places;
  final double cardWidth;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return HomeEmptyBox(height: imageHeight + 55);
    }

    return SizedBox(
      height: imageHeight + 55,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final place = places[index];
          final name =
              place['name']?.toString() ?? 'Local Place';
          final category =
              place['category']?.toString() ?? '';
          final city = place['city']?.toString() ?? 'London';
          final imageUrl = place['image_url']?.toString();

          return SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    HomeNetworkImage(
                      imageUrl: imageUrl,
                      width: cardWidth,
                      height: imageHeight,
                      borderRadius: 14,
                    ),
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: HomeFavoriteButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2FF),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 7,
                            color: homePrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: Color(0xFF8B8B8B),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '$city, UK',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Color(0xFF8B8B8B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoryPlacesList extends StatelessWidget {
  const CategoryPlacesList({
    super.key,
    required this.title,
    required this.places,
  });

  final String title;
  final List<Map<String, dynamic>> places;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(title),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (places.isEmpty)
          const HomeEmptyBox(height: 150)
        else
          ...places.take(10).map(
                (place) => CategoryPlaceCard(place: place),
          ),
      ],
    );
  }
}

class CategoryPlaceCard extends StatelessWidget {
  const CategoryPlaceCard({
    super.key,
    required this.place,
  });

  final Map<String, dynamic> place;

  @override
  Widget build(BuildContext context) {
    final name = place['name']?.toString() ?? 'Local Place';
    final description =
        place['description']?.toString() ?? '';
    final city = place['city']?.toString() ?? 'London';
    final imageUrl = place['image_url']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFECECEC),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          HomeNetworkImage(
            imageUrl: imageUrl,
            width: 88,
            height: 80,
            borderRadius: 11,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description.isEmpty
                      ? 'Discover a meaningful local place in London.'
                      : description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Color(0xFF8B8B8B),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '$city, UK',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8B8B8B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.favorite_border,
            color: homePrimaryColor,
            size: 21,
          ),
        ],
      ),
    );
  }
}

class HomeNetworkImage extends StatelessWidget {
  const HomeNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: hasImage
          ? Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _fallback();
        },
      )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE7E8ED),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFA1A3AB),
      ),
    );
  }
}

class HomeFavoriteButton extends StatelessWidget {
  const HomeFavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.favorite_border,
        color: homePrimaryColor,
        size: 17,
      ),
    );
  }
}

class HomeEmptyBox extends StatelessWidget {
  const HomeEmptyBox({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        '등록된 장소가 없습니다.',
        style: TextStyle(
          color: Color(0xFF8B8B8B),
        ),
      ),
    );
  }
}
