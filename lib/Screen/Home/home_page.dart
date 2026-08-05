import 'dart:async';

import 'package:flutter/material.dart';

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

  final List<String> _categories = const [
    'Home',
    'Cafe',
    'Restaurant',
    'Culture',
  ];

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    const userName = 'Traveler';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userName),
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
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning,',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B8B8B),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: primaryColor,
                    size: 16,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'London',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFF0F1F6),
          child: Icon(
            Icons.person_outline,
            color: Color(0xFF777777),
            size: 23,
          ),
        ),
      ],
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
    if (_selectedCategoryIndex == 0) {
      return _buildHomeContent();
    }

    return _buildCategoryContent(
      _categories[_selectedCategoryIndex],
    );
  }

  Widget _buildHomeContent() {
    return Column(
      key: const ValueKey('home'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBanner(),

        const SizedBox(height: 22),

        _buildSectionHeader('Archive'),
        const SizedBox(height: 12),
        _buildArchivePlaceholders(),

        const SizedBox(height: 24),

        _buildSectionHeader('Trending'),
        const SizedBox(height: 12),
        _buildTrendingPlaceholders(),

        const SizedBox(height: 24),

        _buildSectionHeader('Continue Exploring'),
        const SizedBox(height: 12),
        _buildContinuePlaceholders(),
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
                subtitle: 'Discover meaningful local places',
                colors: const [
                  Color(0xFF33384D),
                  Color(0xFF7484D2),
                ],
              ),
              _buildBannerItem(
                title: 'TRAVEL WITH PURPOSE',
                subtitle: 'Support independent shops in London',
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
              final selected = index == _currentBannerIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 13 : 5,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 3),
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

  Widget _buildSectionHeader(String title) {
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
        const Text(
          'More',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF8B8B8B),
          ),
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.chevron_right,
          size: 17,
          color: Color(0xFF8B8B8B),
        ),
      ],
    );
  }

  Widget _buildArchivePlaceholders() {
    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 170,
            decoration: BoxDecoration(
              color: const Color(0xFFE7E8ED),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 42,
                    color: Color(0xFFA1A3AB),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: primaryColor,
                      size: 17,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Archive ${index + 1}',
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

  Widget _buildTrendingPlaceholders() {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          return SizedBox(
            width: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 145,
                      height: 112,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7E8ED),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFA1A3AB),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        index == 0
                            ? 'The Kiln Rooms'
                            : index == 1
                            ? 'Padella'
                            : 'Manteca',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2FF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Text(
                        'Culture',
                        style: TextStyle(
                          fontSize: 7,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: Color(0xFF8B8B8B),
                    ),
                    SizedBox(width: 2),
                    Text(
                      'London, UK',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.star,
                      size: 10,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '4.6',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0xFF8B8B8B),
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

  Widget _buildContinuePlaceholders() {
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 126,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 126,
                  height: 105,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E8ED),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFA1A3AB),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Local Place ${index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: Color(0xFF8B8B8B),
                    ),
                    SizedBox(width: 2),
                    Text(
                      'London, UK',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0xFF8B8B8B),
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
    final IconData icon;

    switch (category) {
      case 'Cafe':
        icon = Icons.local_cafe_outlined;
        break;
      case 'Restaurant':
        icon = Icons.restaurant_outlined;
        break;
      default:
        icon = Icons.palette_outlined;
    }

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
                icon,
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
        const Text(
          'Trending This Week',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          4,
              (index) => _buildTrendingCard(
            category: category,
            index: index,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard({
    required String category,
    required int index,
  }) {
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
          Container(
            width: 88,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE7E8ED),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFFA1A3AB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$category Place ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Discover a local ${category.toLowerCase()} in London.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 13,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '4.6',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.favorite_border,
            color: primaryColor,
            size: 21,
          ),
        ],
      ),
    );
  }
}
