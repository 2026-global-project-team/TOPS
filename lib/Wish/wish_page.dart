import 'package:flutter/material.dart';

import '../Screen/Archive/models/story.dart';
import '../Screen/Archive/widgets/story_card.dart';

// TODO: Supabase 연결 시 아래 import 주석 해제
// import 'package:supabase_flutter/supabase_flutter.dart';
// ============================================================

class WishPage extends StatefulWidget {
  const WishPage({
    super.key,
    this.initialStories = const [],
  });

  /// Archive 화면에서 이미 가지고 있는 Story 목록을 전달받는 용도
  ///
  /// 예시:
  /// WishPage(
  ///   initialStories: stories
  ///       .where((story) => story.isWish)
  ///       .toList(),
  /// )
  final List<Story> initialStories;

  @override
  State<WishPage> createState() => _WishPageState();
}

class _WishPageState extends State<WishPage> {
  static const Color primaryColor = Color(0xFF6680FF);

  // 0 = Places, 1 = Stories
  int _selectedTabIndex = 0;

  bool _isLoading = false;

  late List<Story> _wishStories;

  // ============================================================
  // 현재는 화면 확인용 임시 장소 데이터
  //
  // 나중에 Supabase favorites + places 테이블에서 조회한 데이터로
  // 아래 리스트를 교체하면 됨
  // ============================================================
  List<Map<String, dynamic>> _wishPlaces = [
    {
      'id': 1,
      'name': 'Bibimbap To Go Cannon Street',
      'address':
      '13 St Swithin\'s Ln, London EC4N 8AL UK',
      'image_url':
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5'
          '?auto=format&fit=crop&w=1200&q=80',
      'delivery': true,
      'takeaway': true,
      'is_wish': true,
    },
    {
      'id': 2,
      'name': 'The Corner Shop',
      'address': 'Camden, London, UK',
      'image_url':
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8'
          '?auto=format&fit=crop&w=1200&q=80',
      'delivery': true,
      'takeaway': true,
      'is_wish': true,
    },
    {
      'id': 3,
      'name': 'Local Coffee House',
      'address': 'Soho, London, UK',
      'image_url':
      'https://images.unsplash.com/photo-1554118811-1e0d58224f24'
          '?auto=format&fit=crop&w=1200&q=80',
      'delivery': false,
      'takeaway': true,
      'is_wish': true,
    },
  ];

  @override
  void initState() {
    super.initState();

    // 전달받은 Story 중 찜한 Story만 표시
    _wishStories = widget.initialStories
        .where((story) => story.isWish)
        .toList();

    // ============================================================
    // TODO: Supabase 연결 시 아래 함수 호출 주석 해제
    //
    // _loadWishPlaces();
    // _loadWishStories();
    // ============================================================
  }

  // ============================================================
  // Supabase 연결 예시 1: 찜한 장소 조회
  //
  // favorites 테이블 구조 예시:
  // id         int8
  // user_id    uuid
  // place_id   int8
  // created_at timestamptz
  //
  // places 테이블과 관계가 연결되어 있어야 함
  // ============================================================

  /*
  Future<void> _loadWishPlaces() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser =
          Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        setState(() {
          _wishPlaces = [];
          _isLoading = false;
        });
        return;
      }

      final data = await Supabase.instance.client
          .from('favorites')
          .select(
            '''
            id,
            place_id,
            places (
              id,
              name,
              category,
              description,
              address,
              city,
              latitude,
              longitude,
              image_url
            )
            ''',
          )
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      final convertedPlaces =
          List<Map<String, dynamic>>.from(data)
              .map((favorite) {
        final place = favorite['places'];

        if (place == null) {
          return null;
        }

        return Map<String, dynamic>.from(place);
      })
              .whereType<Map<String, dynamic>>()
              .toList();

      if (!mounted) return;

      setState(() {
        _wishPlaces = convertedPlaces;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Wish 장소 조회 오류: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }
  */

  // ============================================================
  // Supabase 연결 예시 2: Story 목록 조회
  //
  // Story 테이블 이름과 컬럼은 친구가 만든 DB 구조에 맞게 수정해야 함
  //
  // 예상 컬럼:
  // id
  // user_id
  // title
  // location
  // visited_at
  // image_urls
  // is_wish
  // ============================================================

  /*
  Future<void> _loadWishStories() async {
    final currentUser =
        Supabase.instance.client.auth.currentUser;

    if (currentUser == null) return;

    try {
      final data = await Supabase.instance.client
          .from('stories')
          .select()
          .eq('user_id', currentUser.id)
          .eq('is_wish', true)
          .order('visited_at', ascending: false);

      // Story.fromJson()이 Story 모델에 있어야 사용 가능
      final stories = List<Map<String, dynamic>>.from(data)
          .map((json) => Story.fromJson(json))
          .toList();

      if (!mounted) return;

      setState(() {
        _wishStories = stories;
      });
    } catch (error) {
      debugPrint('Wish Story 조회 오류: $error');
    }
  }
  */

  void _changeTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _removePlaceWish(
      Map<String, dynamic> place,
      ) {
    setState(() {
      _wishPlaces.removeWhere(
            (item) => item['id'] == place['id'],
      );
    });

    // ============================================================
    // TODO: Supabase 연결 시 아래 함수 호출
    //
    // _deletePlaceWish(place['id']);
    // ============================================================
  }

  // ============================================================
  // Supabase 연결 예시 3: 장소 찜 해제
  // ============================================================

  /*
  Future<void> _deletePlaceWish(int placeId) async {
    final currentUser =
        Supabase.instance.client.auth.currentUser;

    if (currentUser == null) return;

    try {
      await Supabase.instance.client
          .from('favorites')
          .delete()
          .eq('user_id', currentUser.id)
          .eq('place_id', placeId);
    } catch (error) {
      debugPrint('장소 찜 해제 오류: $error');

      // 삭제 실패 시 다시 목록 조회
      await _loadWishPlaces();
    }
  }
  */

  void _removeStoryWish(Story story) {
    setState(() {
      _wishStories.remove(story);
    });

    // ============================================================
    // TODO: Supabase 연결 시 Story의 id를 이용해
    // stories 테이블 is_wish 값을 false로 변경
    //
    // _updateStoryWish(story.id, false);
    // ============================================================
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // MainShell 내부 화면이 아니라 Navigator.push로 여는 화면이므로
      // 여기에는 bottomNavigationBar를 따로 넣지 않음
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            const Divider(
              height: 1,
              color: Color(0xFFE8E8E8),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 200,
                ),
                child: _selectedTabIndex == 0
                    ? _buildPlacesTab()
                    : _buildStoriesTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          const SizedBox(width: 8),

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 22,
              color: Color(0xFF292929),
            ),
          ),

          const SizedBox(width: 2),

          const Text(
            'Wish',
            style: TextStyle(
              color: Color(0xFF292929),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          const SizedBox(width: 16),

          _WishTabButton(
            title: 'Places',
            selected: _selectedTabIndex == 0,
            onPressed: () {
              _changeTab(0);
            },
          ),

          const SizedBox(width: 10),

          _WishTabButton(
            title: 'Stories',
            selected: _selectedTabIndex == 1,
            onPressed: () {
              _changeTab(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesTab() {
    if (_wishPlaces.isEmpty) {
      return const _EmptyWishView(
        key: ValueKey('empty-places'),
        icon: Icons.storefront_outlined,
        title: 'No wished places yet',
        description:
        'Places you save will appear here.',
      );
    }

    return ListView.separated(
      key: const ValueKey('places'),
      padding: const EdgeInsets.fromLTRB(
        16,
        32,
        16,
        130,
      ),
      itemCount: _wishPlaces.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 18);
      },
      itemBuilder: (context, index) {
        final place = _wishPlaces[index];

        return _WishPlaceCard(
          place: place,
          onPressed: () {
            // TODO: 장소 상세 페이지 이동
          },
          onWishPressed: () {
            _removePlaceWish(place);
          },
        );
      },
    );
  }

  Widget _buildStoriesTab() {
    if (_wishStories.isEmpty) {
      return const _EmptyWishView(
        key: ValueKey('empty-stories'),
        icon: Icons.auto_stories_outlined,
        title: 'No wished stories yet',
        description:
        'Stories you save will appear here.',
      );
    }

    return ListView.builder(
      key: const ValueKey('stories'),
      padding: const EdgeInsets.fromLTRB(
        16,
        32,
        16,
        130,
      ),
      itemCount: _wishStories.length,
      itemBuilder: (context, index) {
        final story = _wishStories[index];

        // 친구가 만들어 둔 StoryCard 그대로 재사용
        return StoryCard(
          story: story,
          onPressed: () {
            // TODO: Story 상세 페이지 이동
          },
          onWishPressed: () {
            _removeStoryWish(story);
          },
        );
      },
    );
  }
}

// ============================================================
// Places / Stories 탭 버튼
// ============================================================

class _WishTabButton extends StatelessWidget {
  const _WishTabButton({
    required this.title,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        height: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF292929)
                    : const Color(0xFF777777),
                fontSize: 20,
                fontWeight: selected
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
            ),

            const SizedBox(height: 9),

            AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              width: selected ? 72 : 0,
              height: 1,
              color: const Color(0xFF292929),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Places 탭 카드
// ============================================================

class _WishPlaceCard extends StatelessWidget {
  const _WishPlaceCard({
    required this.place,
    required this.onPressed,
    required this.onWishPressed,
  });

  final Map<String, dynamic> place;
  final VoidCallback onPressed;
  final VoidCallback onWishPressed;

  @override
  Widget build(BuildContext context) {
    final name =
        place['name']?.toString() ?? 'Local Place';

    final address =
        place['address']?.toString() ?? 'London, UK';

    final imageUrl =
    place['image_url']?.toString();

    final delivery =
        place['delivery'] == true;

    final takeaway =
        place['takeaway'] == true;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 265,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFFE7E8ED),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(imageUrl),

              // 이미지 아래쪽을 살짝 어둡게 해서 글자가 잘 보이게 함
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 14,
                right: 14,
                child: _PlaceWishButton(
                  onPressed: onWishPressed,
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 17,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (delivery || takeaway) ...[
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (delivery)
                            const _PlaceOptionBadge(
                              text: 'Delivery',
                            ),

                          if (takeaway)
                            const _PlaceOptionBadge(
                              text: 'Takeaway',
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    final hasImage =
        imageUrl != null &&
            imageUrl.trim().isNotEmpty;

    if (!hasImage) {
      return _buildFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFFE7E8ED),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFA1A3AB),
        size: 48,
      ),
    );
  }
}

class _PlaceWishButton extends StatelessWidget {
  const _PlaceWishButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.favorite,
            color: Color(0xFF6680FF),
            size: 27,
          ),
        ),
      ),
    );
  }
}

class _PlaceOptionBadge extends StatelessWidget {
  const _PlaceOptionBadge({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.58,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 찜 목록이 비었을 때 표시
// ============================================================

class _EmptyWishView extends StatelessWidget {
  const _EmptyWishView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 54,
              color: const Color(0xFFB3B3B3),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8B8B8B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}