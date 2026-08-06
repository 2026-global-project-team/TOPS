import 'dart:async';

import 'package:flutter/material.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  static const Color primaryColor = Color(0xFF6883FF);
  static const int initialPage = 5000;

  final List<String> _bannerImages = const [
    'assets/images/banner.png',
    'assets/images/banner2.png',
  ];

  final PageController _pageController = PageController(
    initialPage: initialPage,
  );

  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();

    _currentBannerIndex = initialPage % _bannerImages.length;

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) {
        if (!mounted || !_pageController.hasClients) return;

        final currentPage =
            _pageController.page?.round() ?? initialPage;

        _pageController.animateToPage(
          currentPage + 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 158,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 10000,
            onPageChanged: (index) {
              if (!mounted) return;

              setState(() {
                _currentBannerIndex =
                    index % _bannerImages.length;
              });
            },
            itemBuilder: (context, index) {
              final imageIndex =
                  index % _bannerImages.length;

              return _buildBannerItem(
                imagePath: _bannerImages[imageIndex],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerImages.length,
                (index) {
              final isSelected =
                  index == _currentBannerIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 13 : 5,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isSelected
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
    required String imagePath,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}
