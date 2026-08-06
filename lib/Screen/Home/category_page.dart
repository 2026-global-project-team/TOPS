import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.category});
  final String category;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _places = [];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      // TODO(Supabase): 조회수/찜 수 컬럼이 생기면 해당 컬럼 기준으로 정렬
      final data = await Supabase.instance.client
          .from('places')
          .select(
        'id, name, category, description, address, city, '
            'latitude, longitude, image_url',
      )
          .order('id')
          .limit(20);

      if (!mounted) return;
      setState(() {
        _places = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      debugPrint('Trending 장소 조회 오류: $error');
      if (!mounted) return;
      setState(() {
        _places = [];
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          widget.category,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlaces,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 180),
          const Text(
            '장소 데이터를 불러오지 못했습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF777777)),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _loadPlaces,
              child: const Text('다시 시도'),
            ),
          ),
        ],
      );
    }

    if (_places.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Text(
            '등록된 장소가 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF777777)),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        Text(
          '${widget.category} This Week',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        ..._places.map((place) => _TrendingPlaceCard(place: place)),
      ],
    );
  }
}

class _TrendingPlaceCard extends StatelessWidget {
  const _TrendingPlaceCard({required this.place});
  final Map<String, dynamic> place;

  @override
  Widget build(BuildContext context) {
    final name = place['name']?.toString() ?? 'Local Place';
    final description = place['description']?.toString().trim() ?? '';
    final city = place['city']?.toString().trim() ?? 'London';
    final imageUrl = place['image_url']?.toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _PlaceImage(
            imageUrl: imageUrl,
            width: 88,
            height: 82,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  description.isEmpty
                      ? 'Discover a meaningful local place in London.'
                      : description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: Color(0xFF8B8B8B),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '$city, UK',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8B8B8B),
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const Icon(Icons.star, size: 11, color: Color(0xFFFFC107)),
                    const SizedBox(width: 2),
                    const Text(
                      '4.6',
                      style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.favorite_border,
            color: Color(0xFF6883FF),
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _PlaceImage extends StatelessWidget {
  const _PlaceImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: hasImage
          ? Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE7E8ED),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Color(0xFFA1A3AB)),
    );
  }
}
