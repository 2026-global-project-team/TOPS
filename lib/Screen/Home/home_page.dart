import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tops/Main/widgets/app_top_bar.dart';
import 'package:tops/services/profile_service.dart';
import 'category_page.dart';
import 'continue_exploring_page.dart';
import 'search_page.dart';
import 'widgets/home_banner.dart';
import 'widgets/home_widgets.dart';

// Supabase 조회, 선택한 탭 상태,
// 화면 이동, 어떤 데이터를 보여줄지 결정

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.onProfilePressed,
  });

  /*
   * MainShell에서 Profile 탭으로 이동하는 함수를
   * 전달할 수 있도록 만든다.
   *
   * MainShell에서 연결하지 않아도 HomePage는 실행된다.
   */
  final VoidCallback? onProfilePressed;

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _categories = const [
    'Home',
    'Cafe',
    'Restaurant',
    'Culture',
  ];

  int _selectedCategoryIndex = 0;

  /*
   * ArchiveTopBar 사용자 정보
   *
   * 실제 값은 ProfileService를 통해
   * Supabase profiles 테이블에서 가져온다.
   */
  String _userName = 'TOPS Traveler';
  String _location = 'London';
  String? _profileImageUrl;

  bool _isProfileLoading = true;

  /*
   * places 테이블 상태
   */
  bool _isPlacesLoading = true;
  String? _placesError;

  List<Map<String, dynamic>> _places = [];

  @override
  void initState() {
    super.initState();

    _loadProfile();
    _loadPlaces();
  }

  // ============================================================
  // Supabase profiles 테이블 조회
  //
  // ProfileService가 담당하는 값:
  // - 사용자 이름
  // - 사용자 위치
  // - 프로필 사진 URL
  // ============================================================
  Future<void> _loadProfile() async {
    try {
      final ProfileData profile =
      await ProfileService.getCurrentProfile();

      if (!mounted) {
        return;
      }

      setState(() {
        _userName = profile.userName;
        _location = profile.location;
        _profileImageUrl =
            profile.profileImageUrl;

        _isProfileLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Home profile loading error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      /*
       * 프로필 조회가 실패하더라도
       * Home 화면 전체가 비정상으로 뜨지 않게
       * 기본값을 유지한다.
       */
      setState(() {
        _userName = 'TOPS Traveler';
        _location = 'London';
        _profileImageUrl = null;
        _isProfileLoading = false;
      });
    }
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
      final data =
      await Supabase.instance.client
          .from('places')
          .select(
        'id, name, category, description, '
            'address, city, latitude, longitude, '
            'image_url',
      )
          .order('id')
          .limit(70);

      if (!mounted) {
        return;
      }

      setState(() {
        _places =
        List<Map<String, dynamic>>.from(
          data,
        );

        _isPlacesLoading = false;
        _placesError = null;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Place loading error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _places = [];
        _isPlacesLoading = false;
        _placesError = error.toString();
      });
    }
  }

  /*
   * 화면을 아래로 당기면
   * 프로필과 장소 데이터를 모두 다시 조회한다.
   */
  Future<void> _refreshHome() async {
    await Future.wait([
      _loadProfile(),
      _loadPlaces(),
    ]);
  }

  void _openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const SearchPage();
        },
      ),
    );
  }

  List<Map<String, dynamic>>
  _placesByCategory(
      String category,
      ) {
    return _places.where(
          (Map<String, dynamic> place) {
        return place['category']
            ?.toString()
            .trim()
            .toLowerCase() ==
            category.trim().toLowerCase();
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              160,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                /*
                 * 공통 상단바
                 *
                 * ProfileService에서 가져온:
                 * - _userName
                 * - _location
                 * - _profileImageUrl
                 * 을 전달한다.
                 */
                ArchiveTopBar(
                  userName: _isProfileLoading
                      ? ''
                      : _userName,
                  location: _location,
                  profileImageUrl:
                  _profileImageUrl,
                  onProfilePressed: () {
                    /*
                     * MainShell에서 전달받은 함수가 있으면
                     * Profile 탭으로 이동한다.
                     */
                    widget.onProfilePressed?.call();
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
                  selectedIndex:
                  _selectedCategoryIndex,
                  onSelected: (int index) {
                    setState(() {
                      _selectedCategoryIndex =
                          index;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // 모든 카테고리 탭에서 공통으로 표시
                const HomeBanner(),

                const SizedBox(height: 22),

                AnimatedSwitcher(
                  duration:
                  const Duration(
                    milliseconds: 220,
                  ),
                  child:
                  _buildSelectedContent(),
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
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (_placesError != null) {
      return SizedBox(
        key: const ValueKey('error'),
        height: 280,
        child: Center(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Text(
                'Failed to load places.',
                style: TextStyle(
                  color:
                  Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: _loadPlaces,
                child:
                const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedCategoryIndex == 0) {
      return _buildHomeContent();
    }

    final String category =
    _categories[
    _selectedCategoryIndex];

    return CategoryPlacesList(
      category: category,
      places:
      _placesByCategory(category),
    );
  }

  Widget _buildHomeContent() {
    final List<Map<String, dynamic>>
    archivePlaces =
    _places.take(3).toList();

    final List<Map<String, dynamic>>
    trendingPlaces =
    _places.skip(3).take(6).toList();

    final List<Map<String, dynamic>>
    continuePlaces =
    _places.skip(9).take(8).toList();

    return Column(
      key: const ValueKey('home'),
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'Archive',
          onMorePressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text(
                    'Archive page will be connected soon.',
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
                builder: (_) {
                  return const CategoryPage(
                    category: 'Trending',
                  );
                },
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
                builder: (_) {
                  return const ContinueExploringPage();
                },
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