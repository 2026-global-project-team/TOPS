import 'package:flutter/material.dart';
import 'package:tops/Main/main_shell.dart';
import 'create_archive_page.dart';
import 'models/story.dart';
import '../../Main/widgets/app_top_bar.dart';
import 'widgets/story_card.dart';
import 'widgets/trip_summary_card.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final List<Story> _stories = [
    Story(
      id: '2',
      title: 'Good dinner',
      location: 'Camden, London, UK',
      visitedAt: DateTime(2026, 10, 20),
      imageUrls: const [
        'assets/images/story_dinner.png',
        'assets/images/story_dinner_2.png',
      ],
    ),
    Story(
      id: '1',
      title: 'Picnic day',
      location: 'Hyde Park, London, UK',
      visitedAt: DateTime(2026, 10, 18),
      imageUrls: const [
        'assets/images/story_picnic.png',
        'assets/images/story_picnic_2.png',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sortStories();
  }

  void _sortStories() {
    _stories.sort(
          (a, b) => b.visitedAt.compareTo(a.visitedAt),
    );
  }

  Future<void> _openNewStoryPage() async {
    // 추후 StoryCreatePage 연결
  }

  void _toggleWish(String storyId) {
    final index = _stories.indexWhere(
          (story) => story.id == storyId,
    );

    if (index == -1) {
      return;
    }

    setState(() {
      final selectedStory = _stories[index];

      _stories[index] = selectedStory.copyWith(
        isWish: !selectedStory.isWish,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FF),

      // MainShell이 이미 하단바를 담당하므로
      // 여기에는 bottomNavigationBar를 넣지 않음
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ArchiveTopBar(
                userName: 'Eunji',
                location: 'London',
                profileImageUrl: null,
                onProfilePressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainShell(index: 3),
                    ),
                  );
                },
                onLocationPressed: () {
                  debugPrint('지역 선택');
                },
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TripSummaryCard(
                  tripTitle: 'London Trip',
                  visitedPlacesCount: 12,
                  onPlaceCountPressed: () {
                    debugPrint('Places 버튼 클릭');
                  },
                  onNewStoryPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateArchivePage(),
                      ),
                    );
                  },
                  onTravelMapPressed: () {
                    debugPrint('Travel Map');
                  },
                  onWishPressed: () {
                    debugPrint('Wish');
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            if (_stories.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    '아직 작성한 기록이 없습니다.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  110,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final story = _stories[index];

                      return StoryCard(
                        key: ValueKey(story.id),
                        story: story,
                        onPressed: () {
                          debugPrint(
                            '${story.title} 상세 화면 이동',
                          );
                        },
                        onWishPressed: () {
                          _toggleWish(story.id);
                        },
                      );
                    },
                    childCount: _stories.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}