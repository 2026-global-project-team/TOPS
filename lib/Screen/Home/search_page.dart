import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color _primaryColor = Color(0xFF6883FF);

  final TextEditingController _searchController =
  TextEditingController();

  final List<String> _allPlaces = const [
    'Padella',
    'The Kiln Rooms',
    'Manteca',
    'WatchHouse Covent Garden',
    'Dear Coffee Lover',
    'Bloomsbury Coffee Co.',
    'Kitchen Coffee',
    'Origin Coffee',
    'Hidden Gems',
    'Local Restaurants',
  ];

  final List<String> _popularSearches = const [
    'Hidden Gems',
    'Soho',
    'Notting Hill',
    'Local Restaurants',
    'Local Cafes',
  ];

  final List<String> _recentSearches = [
    'Padella',
    'The Kiln Rooms',
  ];

  String _query = '';

  List<String> get _filteredPlaces {
    final trimmedQuery = _query.trim().toLowerCase();

    if (trimmedQuery.isEmpty) {
      return [];
    }

    return _allPlaces.where((place) {
      return place.toLowerCase().contains(trimmedQuery);
    }).toList();
  }

  void _submitSearch(String value) {
    final searchText = value.trim();

    if (searchText.isEmpty) {
      return;
    }

    setState(() {
      _recentSearches.remove(searchText);
      _recentSearches.insert(0, searchText);
      _query = searchText;
    });
  }

  void _removeRecentSearch(String searchText) {
    setState(() {
      _recentSearches.remove(searchText);
    });
  }

  Future<void> _clearRecentSearches() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Clear all recent searches?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF8B8B8B),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      setState(() {
        _recentSearches.clear();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _filteredPlaces;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _query.trim().isEmpty
                  ? _buildDefaultSearchContent()
                  : _buildSearchResults(searchResults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 20,
                    color: Color(0xFF9B9BA3),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      onSubmitted: _submitSearch,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Start your local journey...',
                        hintStyle: TextStyle(
                          color: Color(0xFFA1A3AB),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();

                        setState(() {
                          _query = '';
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF9B9BA3),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSearchContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _clearRecentSearches,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B8B8B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((searchText) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    7,
                    8,
                    7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _searchController.text = searchText;
                          _submitSearch(searchText);
                        },
                        child: Text(
                          searchText,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          _removeRecentSearch(searchText);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Color(0xFF8B8B8B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _popularSearches.length,
                (index) {
              final searchText = _popularSearches[index];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _searchController.text = searchText;
                  _submitSearch(searchText);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          searchText,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(
                        index.isEven
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: index.isEven
                            ? Colors.redAccent
                            : _primaryColor,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<String> searchResults) {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(
            color: Color(0xFF8B8B8B),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        40,
      ),
      itemCount: searchResults.length,
      separatorBuilder: (_, __) {
        return const Divider(
          height: 1,
          color: Color(0xFFEEEEEE),
        );
      },
      itemBuilder: (context, index) {
        final placeName = searchResults[index];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _submitSearch(placeName);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$placeName 선택'),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEEF3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        placeName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'London, UK',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B8B8B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9B9BA3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}