import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color primaryColor = Color(0xFF6883FF);

  final TextEditingController _controller =
  TextEditingController();

  final List<String> _allPlaces = const [
    'Padella',
    'The Kiln Rooms',
    'Manteca',
    'WatchHouse Covent Garden',
    'Dear Coffee Lover',
    'Bloomsbury Coffee Co.',
    'Origin Coffee',
    'Hidden Gems',
    'Local Restaurants',
    'Local Cafes',
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

  List<String> get _results {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return [];
    }

    return _allPlaces
        .where(
          (place) => place.toLowerCase().contains(query),
    )
        .toList();
  }

  void _search(String text) {
    final value = text.trim();

    if (value.isEmpty) return;

    _controller.text = value;
    _controller.selection = TextSelection.collapsed(
      offset: value.length,
    );

    setState(() {
      _query = value;
      _recentSearches.remove(value);
      _recentSearches.insert(0, value);
    });
  }

  Future<void> _clearRecentSearches() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Clear recent searches?',
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
                'Clear',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _recentSearches.clear();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _query.trim().isEmpty
                  ? _buildInitialContent()
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pop(context),
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
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      onSubmitted: _search,
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
                        _controller.clear();

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

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
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
              children: _recentSearches.map(
                    (text) {
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
                          onTap: () => _search(text),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _recentSearches.remove(text);
                            });
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
                },
              ).toList(),
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
              final text = _popularSearches[index];

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _search(text),
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
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF9B9BA3),
                        size: 19,
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

  Widget _buildResults() {
    final results = _results;

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No results found.',
          style: TextStyle(
            color: Color(0xFF8B8B8B),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      itemCount: results.length,
      separatorBuilder: (_, __) {
        return const Divider(
          height: 1,
          color: Color(0xFFEEEEEE),
        );
      },
      itemBuilder: (context, index) {
        final place = results[index];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _search(place);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$place selected'),
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
                        place,
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
