import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tops/Main/widgets/app_top_bar.dart';

import 'category_page.dart';
import 'continue_exploring_page.dart';
import 'search_page.dart';
import 'widgets/home_banner.dart';
import 'widgets/home_widgets.dart';

// supabase조회, 선택한 탭 상태, 화면 이동, 어떤 데이터 보여줄지 결정

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _categories = const [
    'Home',
    'Cafe',
    'Restaurant',
    'Culture',
  ];

  int _selectedCategoryIndex = 0;

  bool _isPlacesLoading = true;
  String? _placesError;
  List<Map<String, dynamic>> _places = [];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  // ============================================================
  // Supabase places 테이블 조회
  //
  // 필요한 컬럼:
  // id, name, category, description, address, city,
  // latitude, longitude, image_url
  // ============================================================
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

  void _openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchPage(),
      ),
    );
  }

  List<Map<String, dynamic>> _placesByCategory(
      String category,
      ) {
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
                    // TODO: MainShell의 Profile 탭 연결
                  },
                  onLocationPressed: () {
                    // TODO: 위치 선택 기능 연결
                  },
                ),
                const SizedBox(height: 14),
                HomeSearchBar(
                  onTap: _openSearchPage,
                ),
                const SizedBox(height: 14),
                HomeCategoryTabs(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onSelected: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // 모든 카테고리 탭에서 공통으로 표시
                const HomeBanner(),

                const SizedBox(height: 22),
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

    final category =
    _categories[_selectedCategoryIndex];

    return CategoryPlacesList(
      category: category,
      places: _placesByCategory(category),
    );
  }

  Widget _buildHomeContent() {
    final archivePlaces = _places.take(3).toList();
    final trendingPlaces =
    _places.skip(3).take(6).toList();
    final continuePlaces =
    _places.skip(9).take(8).toList();

    return Column(
      key: const ValueKey('home'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'Archive',
          onMorePressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Archive 화면은 준비 중입니다.',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ArchivePlacesList(
          places: archivePlaces,
        ),
        const SizedBox(height: 24),
        HomeSectionHeader(
          title: 'Trending',
          onMorePressed: () {
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
        HorizontalPlacesList(
          places: trendingPlaces,
          cardWidth: 145,
          imageHeight: 112,
        ),
        const SizedBox(height: 24),
        HomeSectionHeader(
          title: 'Continue Exploring',
          onMorePressed: () {
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
        HorizontalPlacesList(
          places: continuePlaces,
          cardWidth: 126,
          imageHeight: 105,
        ),
      ],
    );
  }
}
