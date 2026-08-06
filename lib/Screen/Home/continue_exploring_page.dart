import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContinueExploringPage extends StatefulWidget {
  const ContinueExploringPage({super.key});

  @override
  State<ContinueExploringPage> createState() =>
      _ContinueExploringPageState();
}

class _ContinueExploringPageState extends State<ContinueExploringPage> {
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
      // TODO(Supabase): 나중에 사용자 탐색 이력이 생기면 viewed_at 기준 조회
      final data = await Supabase.instance.client
          .from('places')
          .select(
        'id, name, category, description, address, city, '
            'latitude, longitude, image_url',
      )
          .order('id')
          .limit(30);

      if (!mounted) return;
      setState(() {
        _places = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      debugPrint('Continue Exploring 조회 오류: $error');
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
        title: const Text(
          'Continue Exploring',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
      itemCount: _places.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        return _ExploringPlaceCard(place: _places[index]);
      },
    );
  }
}

class _ExploringPlaceCard extends StatelessWidget {
  const _ExploringPlaceCard({required this.place});
  final Map<String, dynamic> place;

  @override
  Widget build(BuildContext context) {
    final name = place['name']?.toString() ?? 'Local Place';
    final city = place['city']?.toString().trim() ?? 'London';
    final imageUrl = place['image_url']?.toString().trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _PlaceImage(imageUrl: imageUrl, borderRadius: 14),
              const Positioned(
                top: 8,
                right: 8,
                child: _FavoriteButton(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 9,
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
                  fontSize: 8,
                ),
              ),
            ),
            const Icon(Icons.star, size: 9, color: Color(0xFFFFC107)),
            const SizedBox(width: 2),
            const Text(
              '4.6',
              style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlaceImage extends StatelessWidget {
  const _PlaceImage({required this.imageUrl, required this.borderRadius});
  final String? imageUrl;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: hasImage
          ? Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFE7E8ED),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFA1A3AB),
        size: 30,
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.favorite_border,
        color: Color(0xFF6883FF),
        size: 17,
      ),
    );
  }
}
