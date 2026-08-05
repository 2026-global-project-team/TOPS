import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tops/Main/widgets/app_top_bar.dart';
import 'category_page.dart';
import 'continue_exploring_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color primaryColor = Color(0xFF6883FF);

  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  int _selectedCategoryIndex = 0;
  int _currentBannerIndex = 0;

  bool _isPlacesLoading = true;
  String? _placesError;
  List<Map<String, dynamic>> _places = [];

  final List<String> _categories = const [
    'Home',
    'Cafe',
    'Restaurant',
    'Culture',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlaces();

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) {
        if (!_bannerController.hasClients) return;

        final nextIndex = (_currentBannerIndex + 1) % 2;

        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Future<void> _loadPlaces() async {
    try {
      final data = await Supabase.instance.client
          .from('places')
          .select(
        'id, name, category, description, address, city, '
            'latitude, longitude, image_url',
      )
          .order('id')
          .limit(70);

      if (!mounted) return;

      setState(() {
        _places = List<Map<String, dynamic>>.from(data);
        _isPlacesLoading = false;
        _placesError = null;
      });
    } catch (error) {
      debugPrint('장소 조회 오류: $error');

      if (!mounted) return;

      setState(() {
        _places = [];
        _isPlacesLoading = false;
        _placesError = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchPage(),
      ),
    );
  }

  List<Map<String, dynamic>> _placesByCategory(String category) {
    return _places.where((place) {
      return place['category']
          ?.toString()
          .trim()
          .toLowerCase() ==
          category.trim().toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const userName = 'Traveler';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPlaces,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              160,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArchiveTopBar(
                  userName: userName,
                  location: 'London',
                  profileImageUrl: null,
                  onProfilePressed: () {
                    // TODO: 프로필 화면 이동
                  },
                  onLocationPressed: () {
                    // TODO: 위치 선택
                  },
                ),
                const SizedBox(height: 14),
                _buildSearchBar(),
                const SizedBox(height: 14),
                _buildCategoryTabs(),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildSelectedContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openSearchPage,
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

  Widget _buildCategoryTabs() {
    return Row(
      children: List.generate(
        _categories.length,
            (index) {
          final selected = index == _selectedCategoryIndex;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: SizedBox(
                height: 38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _categories[index],
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
                            ? primaryColor
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

  Widget _buildSelectedContent() {
    if (_isPlacesLoading) {
      return const SizedBox(
        key: ValueKey('loading'),
        height: 280,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_placesError != null) {
      return SizedBox(
        key: const ValueKey('error'),
        height: 280,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '장소 데이터를 불러오지 못했습니다.',
                style: TextStyle(
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _loadPlaces,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedCategoryIndex == 0) {
      return _buildHomeContent();
    }

    return _buildCategoryContent(
      _categories[_selectedCategoryIndex],
    );
  }

  Widget _buildHomeContent() {
    final archivePlaces = _places.take(3).toList();
    final trendingPlaces = _places.skip(3).take(6).toList();
    final continuePlaces = _places.skip(9).take(8).toList();

    return Column(
      key: const ValueKey('home'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBanner(),
        const SizedBox(height: 22),
        _buildSectionHeader(
          'Archive',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Archive 화면은 준비 중입니다.'),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildArchivePlaces(archivePlaces),
        const SizedBox(height: 24),
        _buildSectionHeader(
          'Trending',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryPage(
                  category: 'Trending',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildHorizontalPlaces(
          places: trendingPlaces,
          cardWidth: 145,
          imageHeight: 112,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          'Continue Exploring',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const ContinueExploringPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildHorizontalPlaces(
          places: continuePlaces,
          cardWidth: 126,
          imageHeight: 105,
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 158,
          child: PageView(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            children: [
              _buildBannerItem(
                title: 'TOPS PICKS',
                subtitle:
                'Discover meaningful local places',
                colors: const [
                  Color(0xFF33384D),
                  Color(0xFF7484D2),
                ],
              ),
              _buildBannerItem(
                title: 'TRAVEL WITH PURPOSE',
                subtitle:
                'Support independent shops in London',
                colors: const [
                  Color(0xFF746247),
                  Color(0xFFB9A773),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            2,
                (index) {
              final selected =
                  index == _currentBannerIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 13 : 5,
                height: 5,
                margin: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? primaryColor
                      : const Color(0xFFD7D7D7),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem({
    required String title,
    required String subtitle,
    required List<Color> colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, {
        VoidCallback? onTap,
      }) {
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
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

  Widget _buildArchivePlaces(
      List<Map<String, dynamic>> places,
      ) {
    if (places.isEmpty) {
      return _buildEmptyPlaceBox(height: 205);
    }

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final place = places[index];
          final name =
              place['name']?.toString() ?? 'Local Place';
          final imageUrl =
          place['image_url']?.toString();

          return Container(
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildNetworkPlaceImage(
                  imageUrl: imageUrl,
                  width: 170,
                  height: 205,
                  borderRadius: 18,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildFavoriteButton(),
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
                      borderRadius:
                      BorderRadius.circular(14),
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

  Widget _buildHorizontalPlaces({
    required List<Map<String, dynamic>> places,
    required double cardWidth,
    required double imageHeight,
  }) {
    if (places.isEmpty) {
      return _buildEmptyPlaceBox(
        height: imageHeight + 55,
      );
    }

    return SizedBox(
      height: imageHeight + 55,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final place = places[index];

          final name =
              place['name']?.toString() ?? 'Local Place';
          final category =
              place['category']?.toString() ?? '';
          final city =
              place['city']?.toString() ?? 'London';
          final imageUrl =
          place['image_url']?.toString();

          return SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _buildNetworkPlaceImage(
                      imageUrl: imageUrl,
                      width: cardWidth,
                      height: imageHeight,
                      borderRadius: 14,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildFavoriteButton(),
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
                          borderRadius:
                          BorderRadius.circular(9),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 7,
                            color: primaryColor,
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

  Widget _buildCategoryContent(String category) {
    final categoryPlaces = _placesByCategory(category);

    return Column(
      key: ValueKey(category),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6883FF),
                Color(0xFFA6B3F5),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _categoryIcon(category),
                color: Colors.white,
                size: 34,
              ),
              const SizedBox(height: 9),
              Text(
                'Discover local $category',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '$category Places',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (categoryPlaces.isEmpty)
          _buildEmptyPlaceBox(height: 150)
        else
          ...categoryPlaces.take(10).map(
            _buildCategoryPlaceCard,
          ),
      ],
    );
  }

  Widget _buildCategoryPlaceCard(
      Map<String, dynamic> place,
      ) {
    final name =
        place['name']?.toString() ?? 'Local Place';
    final description =
        place['description']?.toString() ?? '';
    final city =
        place['city']?.toString() ?? 'London';
    final imageUrl =
    place['image_url']?.toString();

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
          _buildNetworkPlaceImage(
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
            color: primaryColor,
            size: 21,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkPlaceImage({
    required String? imageUrl,
    required double width,
    required double height,
    required double borderRadius,
  }) {
    final hasImage =
        imageUrl != null && imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: hasImage
          ? Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _buildImageFallback(
            width: width,
            height: height,
          );
        },
      )
          : _buildImageFallback(
        width: width,
        height: height,
      ),
    );
  }

  Widget _buildImageFallback({
    required double width,
    required double height,
  }) {
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

  Widget _buildFavoriteButton() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.favorite_border,
        color: primaryColor,
        size: 17,
      ),
    );
  }

  Widget _buildEmptyPlaceBox({
    required double height,
  }) {
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Cafe':
        return Icons.local_cafe_outlined;
      case 'Restaurant':
        return Icons.restaurant_outlined;
      default:
        return Icons.palette_outlined;
    }
  }
}
