import 'package:flutter/material.dart';

import '../../Main/widgets/app_top_bar.dart';
import '../../services/profile_service.dart';
import '../../services/story_service.dart';

import 'create_archive_page.dart';
import 'models/story.dart';
import 'widgets/story_card.dart';
import 'widgets/trip_summary_card.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({
    super.key,
    required this.onWishPressed,
    required this.onProfilePressed,
    required this.onTravelMapPressed,
  });

  final VoidCallback onWishPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onTravelMapPressed;

  @override
  State<ArchivePage> createState() =>
      _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String _userName = 'TOPS Traveler';
  String _location = 'London';
  String? _profileImageUrl;

  bool _isProfileLoading = true;

  List<Story> _stories = [];

  bool _isStoriesLoading = true;
  String? _storiesError;

  @override
  void initState() {
    super.initState();

    _loadProfile();
    _loadStories();
  }

  Future<void> _loadProfile() async {
    try {
      /*
       * profile_service.dart의 getCurrentProfile()은
       * 현재 ProfileData를 반환한다.
       */
      final ProfileData profile =
      await ProfileService.getCurrentProfile();

      if (!mounted) {
        return;
      }

      setState(() {
        _userName = profile.userName;
        _location = profile.location;
        _profileImageUrl = profile.profileImageUrl;
        _isProfileLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Archive profile loading error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _userName = 'TOPS Traveler';
        _location = 'London';
        _profileImageUrl = null;
        _isProfileLoading = false;
      });
    }
  }

  Future<void> _loadStories() async {
    setState(() {
      _isStoriesLoading = true;
      _storiesError = null;
    });

    try {
      final List<Story> stories =
      await StoryService
          .getCurrentUserStories();

      if (!mounted) {
        return;
      }

      setState(() {
        _stories = stories;
        _isStoriesLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Archive stories loading error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _stories = [];
        _isStoriesLoading = false;
        _storiesError = error.toString();
      });
    }
  }

  Future<void> _refreshArchive() async {
    await Future.wait([
      _loadProfile(),
      _loadStories(),
    ]);
  }

  void _sortStories() {
    _stories.sort(
          (Story a, Story b) {
        return b.visitedAt.compareTo(
          a.visitedAt,
        );
      },
    );
  }

  void _toggleWish(int storyId) {
    final int index = _stories.indexWhere(
          (Story story) {
        return story.id == storyId;
      },
    );

    if (index == -1) {
      return;
    }

    setState(() {
      final Story selectedStory =
      _stories[index];

      _stories[index] =
          selectedStory.copyWith(
            isWish: !selectedStory.isWish,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF4F5FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshArchive,
          child: CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ArchiveTopBar(
                  userName: _isProfileLoading
                      ? ''
                      : _userName,
                  location: _location,
                  profileImageUrl:
                  _profileImageUrl,
                  onProfilePressed:
                  widget.onProfilePressed,
                  onLocationPressed: () {
                    debugPrint(
                      'Location button pressed',
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.only(
                    top: 8,
                  ),
                  child: TripSummaryCard(
                    tripTitle: 'London Trip',
                    visitedPlacesCount: 12,
                    onPlaceCountPressed: () {
                      debugPrint(
                        'Places button pressed',
                      );
                    },
                    onNewStoryPressed: () async {
                      final bool? created =
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const CreateArchivePage(),
                        ),
                      );

                      if (created == true) {
                        await _loadStories();
                      }
                    },
                    onTravelMapPressed:
                    widget.onTravelMapPressed,
                    onWishPressed:
                    widget.onWishPressed,
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
                      'No stories yet.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    110,
                  ),
                  sliver: SliverList(
                    delegate:
                    SliverChildBuilderDelegate(
                          (
                          BuildContext context,
                          int index,
                          ) {
                        final Story story =
                        _stories[index];

                        return StoryCard(
                          key: ValueKey(
                            story.id,
                          ),
                          story: story,
                          onPressed: () {
                            debugPrint(
                              '${story.title} detail page',
                            );
                          },
                          onWishPressed: () {
                            _toggleWish(
                              story.id,
                            );
                          },
                        );
                      },
                      childCount:
                      _stories.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}