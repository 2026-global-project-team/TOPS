import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TravelMapPage extends StatefulWidget {
  const TravelMapPage({
    super.key,
    required this.onBackPressed,
  });

  final VoidCallback onBackPressed;

  @override
  State<TravelMapPage> createState() => _TravelMapPageState();
}

class _TravelMapPageState extends State<TravelMapPage> {
  static const Color routeColor = Color(0xFF6981FF);

  final MapController _mapController = MapController();

  static const LatLng _londonCenter = LatLng(
    51.5074,
    -0.1278,
  );

  // ============================================================
  // TODO(Supabase)
  //
  // 현재는 프론트 확인용 임시 방문 기록.
  //
  // 실제 연결 시 아래 데이터를 DB에서 조회:
  //
  // stories
  // - id
  // - user_id
  // - place_id
  // - visited_at
  //
  // story_images
  // - story_id
  // - storage_path 또는 image_url
  // - sort_order
  //
  // places
  // - id
  // - name
  // - latitude
  // - longitude
  //
  // 조회 순서:
  // 1. 현재 사용자의 stories를 visited_at 오름차순으로 조회
  // 2. stories.place_id로 places 좌표 조회
  // 3. 각 story의 대표 사진 1장 조회
  // 4. 방문 순서대로 Polyline 생성
  // 5. 각 장소 좌표에 사진 Marker 생성
  // ============================================================
  final List<_VisitedPlace> _visitedPlaces = const [
    _VisitedPlace(
      id: '1',
      name: 'Hyde Park',
      position: LatLng(51.5073, -0.1657),
      imagePath: 'assets/images/story_picnic.png',
    ),
    _VisitedPlace(
      id: '2',
      name: 'Camden Market',
      position: LatLng(51.5416, -0.1433),
      imagePath: 'assets/images/story_dinner.png',
    ),
    _VisitedPlace(
      id: '3',
      name: 'Covent Garden',
      position: LatLng(51.5117, -0.1240),
      imagePath: 'assets/images/story_picnic_2.png',
    ),
  ];

  List<LatLng> get _routePoints {
    return _visitedPlaces
        .map((place) => place.position)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202329),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _londonCenter,
              initialZoom: 12.2,
              minZoom: 5,
              maxZoom: 18,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(49.8, -8.7),
                  const LatLng(60.9, 1.8),
                ),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // ==================================================
              // 실제 OpenStreetMap 타일을 사용하되,
              // ColorFiltered로 어두운 지도처럼 표현.
              //
              // 장점:
              // - 별도의 다크 타일 API 키가 필요 없음
              // - 기존 Explore 화면과 같은 OSM 사용
              //
              // 나중에 전용 다크 타일 공급자를 쓰게 되면
              // 이 ColorFiltered를 제거하고 urlTemplate만 교체.
              // ==================================================
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  -0.62, 0.00, 0.00, 0.00, 255.0,
                  0.00, -0.62, 0.00, 0.00, 255.0,
                  0.00, 0.00, -0.62, 0.00, 255.0,
                  0.00, 0.00, 0.00, 1.00, 0.00,
                ]),
                child: TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.tops',
                ),
              ),

              // 방문 장소들을 방문 순서대로 연결
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4,
                    color: routeColor,
                    borderStrokeWidth: 2,
                    borderColor:
                    Colors.black.withValues(alpha: 0.32),
                  ),
                ],
              ),

              // 방문 장소 사진 마커
              MarkerLayer(
                markers: _visitedPlaces.map((place) {
                  return Marker(
                    point: place.position,
                    width: 54,
                    height: 66,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () {
                        _showPlacePreview(place);
                      },
                      child: _PhotoMarker(
                        imagePath: place.imagePath,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 지도 위에 살짝 어두운 투명막을 추가해서
          // 파란 경로선과 흰색 사진 마커가 더 잘 보이게 함.
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.12),
              ),
            ),
          ),

          // 상단 헤더
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                8,
                10,
                8,
                0,
              ),
              child: Row(
                children: [
                  _HeaderCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: widget.onBackPressed,
                  ),
                  const Expanded(
                    child: Text(
                      'Travel Map',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _HeaderCircleButton(
                    icon: Icons.info_outline,
                    onPressed: _showTravelMapInfo,
                  ),
                ],
              ),
            ),
          ),

          // My Map 배지
          Positioned(
            top: 92,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: routeColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'My Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlacePreview(_VisitedPlace place) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    place.imagePath,
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 82,
                        height: 82,
                        color: const Color(0xFFE7E8ED),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFFA1A3AB),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Visited place from your Archive',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B8B8B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTravelMapInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Travel Map'),
          content: const Text(
            'Places saved in your Archive are shown as photo markers and connected in the order you visited them.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _VisitedPlace {
  const _VisitedPlace({
    required this.id,
    required this.name,
    required this.position,
    required this.imagePath,
  });

  final String id;
  final String name;
  final LatLng position;
  final String imagePath;
}

class _PhotoMarker extends StatelessWidget {
  const _PhotoMarker({
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 54,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 9,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFFE7E8ED),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFA1A3AB),
                    size: 22,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: -7,
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.34),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}
