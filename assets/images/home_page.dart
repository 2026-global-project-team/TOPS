import 'dart:async';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentBannerIndex = 0;

  final PageController _bannerController = PageController();

  final List<String> _bannerImages = const [
    'assets/images/banner.png',
    'assets/images/banner2.png',
  ];

  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) {
        if (!_bannerController.hasClients) {
          return;
        }

        final nextIndex =
            (_currentBannerIndex + 1) % _bannerImages.length;

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

  @override
  Widget build(BuildContext context) {
    // 나중에 Supabase 사용자 정보로 교체
    const userName = 'Traveler';
    const String? profileUrl = null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                userName: userName,
                profileUrl: profileUrl,
              ),
              const SizedBox(height: 28),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildCategoryTabs(),
              const SizedBox(height: 16),
              _buildBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String userName,
    required String? profileUrl,
  }) {
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
                  fontSize: 16,
                  color: Color(0xFF8B8B8B),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFF6883FF),
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'London',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 27,
          backgroundColor: const Color(0xFFF0F1F6),
          backgroundImage:
          profileUrl != null ? NetworkImage(profileUrl) : null,
          child: profileUrl == null
              ? const Icon(
            Icons.person_outline,
            color: Color(0xFF777777),
            size: 28,
          )
              : null,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.search,
            color: Color(0xFF8B8B8B),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search for local places',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CategoryText(
          label: 'Home',
          selected: true,
        ),
        _CategoryText(
          label: 'Cafe',
        ),
        _CategoryText(
          label: 'Restaurant',
        ),
        _CategoryText(
          label: 'Culture',
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    _bannerImages[index],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        color: const Color(0xFFE9ECFF),
                        alignment: Alignment.center,
                        child: Text(
                          '배너 ${index + 1}을 불러오지 못했습니다.',
                          style: const TextStyle(
                            color: Color(0xFF6883FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerImages.length,
                (index) {
              final isSelected =
                  index == _currentBannerIndex;

              return AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                width: isSelected ? 14 : 5,
                height: 5,
                margin: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6883FF)
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
}

class _CategoryText extends StatelessWidget {
  const _CategoryText({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight:
            selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? Colors.black
                : const Color(0xFF8B8B8B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 20,
          height: 2,
          color: selected
              ? const Color(0xFF6883FF)
              : Colors.transparent,
        ),
      ],
    );
  }
}