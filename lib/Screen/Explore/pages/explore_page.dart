import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/place_service.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({
    super.key,
    this.isPlaceSelectionMode = false,
  });

  final bool isPlaceSelectionMode;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const LatLng _londonCenter = LatLng(51.5074, -0.1278);
  static const Color _primaryColor = Color(0xFF4A5FD3);

  final MapController _mapController = MapController();
  final PlaceService _placeService = PlaceService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allPlaces = [];
  List<Map<String, dynamic>> _filteredPlaces = [];

  Map<String, dynamic>? _selectedPlace;
  LatLng? _currentLocation;

  String _selectedCategory = 'ALL';
  bool _isLoadingPlaces = true;
  bool _isFindingLocation = false;
  String? _errorMessage;

  final List<String> _categories = const [
    'ALL',
    'Cafe',
    'Restaurant',
    'Culture',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _placeService.getPlaces();

      if (!mounted) return;

      setState(() {
        _allPlaces = places;
        _filteredPlaces = places;
        _isLoadingPlaces = false;
        _errorMessage = null;
      });

      debugPrint('불러온 장소 개수: ${places.length}');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingPlaces = false;
        _errorMessage = error.toString();
      });

      debugPrint('장소 조회 실패: $error');
    }
  }

  void _filterPlaces() {
    final keyword = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredPlaces = _allPlaces.where((place) {
        final name = place['name']?.toString().toLowerCase() ?? '';
        final address = place['address']?.toString().toLowerCase() ?? '';
        final city = place['city']?.toString().toLowerCase() ?? '';
        final category = place['category']?.toString().toLowerCase() ?? '';

        final matchesKeyword = keyword.isEmpty ||
            name.contains(keyword) ||
            address.contains(keyword) ||
            city.contains(keyword);

        final matchesCategory = _selectedCategory == 'ALL' ||
            category == _selectedCategory.toLowerCase();

        return matchesKeyword && matchesCategory;
      }).toList();

      _selectedPlace = null;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterPlaces();
  }

  void _clearSearch() {
    _searchController.clear();
    _filterPlaces();
  }

  String _getMarkerImage(String category) {
    switch (category.toLowerCase()) {
      case 'cafe':
        return 'assets/images/pin_cafe.png';
      case 'restaurant':
        return 'assets/images/pin_restaurant.png';
      case 'culture':
        return 'assets/images/pin_culture.png';
      default:
        return 'assets/images/pin_cafe.png';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'culture':
        return Icons.palette;
      default:
        return Icons.storefront;
    }
  }

  List<Marker> _buildPlaceMarkers() {
    return _filteredPlaces.map((place) {
      final latitude = (place['latitude'] as num).toDouble();
      final longitude = (place['longitude'] as num).toDouble();
      final name = place['name']?.toString() ?? '이름 없음';
      final category = place['category']?.toString() ?? '';
      final isSelected = _selectedPlace?['id'] == place['id'];

      return Marker(
        point: LatLng(latitude, longitude),
        width: isSelected ? 68 : 54,
        height: isSelected ? 78 : 64,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedPlace = place;
            });
            _mapController.move(LatLng(latitude, longitude), 15);
          },
          child: Tooltip(
            message: name,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isSelected ? 68 : 54,
              height: isSelected ? 78 : 64,
              child: Image.asset(
                _getMarkerImage(category),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.location_pin,
                    size: 54,
                    color: _primaryColor,
                  );
                },
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _moveToCurrentLocation() async {
    if (_isFindingLocation) return;

    setState(() {
      _isFindingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('기기의 위치 서비스를 켜 주세요.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('현재 위치를 사용하려면 위치 권한이 필요합니다.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 차단되어 있습니다. 기기 설정에서 TOPS의 위치 권한을 허용해 주세요.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      final isInsideUk = _isInsideUnitedKingdom(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      if (!isInsideUk) {
        setState(() {
          _isFindingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('현재 위치가 영국 밖으로 확인되었습니다. 런던 지도를 유지합니다.'),
          ),
        );
        return;
      }

      setState(() {
        _currentLocation = location;
        _isFindingLocation = false;
        _selectedPlace = null;
      });

      _mapController.move(location, 15);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isFindingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 위치를 가져오지 못했습니다. 에뮬레이터 위치를 확인해 주세요.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isFindingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  bool _isInsideUnitedKingdom({
    required double latitude,
    required double longitude,
  }) {
    return latitude >= 49.8 &&
        latitude <= 60.9 &&
        longitude >= -8.7 &&
        longitude <= 1.8;
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    final nextZoom = (camera.zoom + 1).clamp(3.0, 18.0).toDouble();
    _mapController.move(camera.center, nextZoom);
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    final nextZoom = (camera.zoom - 1).clamp(3.0, 18.0).toDouble();
    _mapController.move(camera.center, nextZoom);
  }

  Future<void> _openDirections(
      Map<String, dynamic> place,
      ) async {
    final latitude =
    (place['latitude'] as num).toDouble();

    final longitude =
    (place['longitude'] as num).toDouble();

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&destination=$latitude,$longitude'
          '&travelmode=walking',
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지도 앱을 열 수 없습니다.'),
        ),
      );
    }
  }


  void _confirmSelectedPlace() {
    final Map<String, dynamic>? selectedPlace = _selectedPlace;

    if (selectedPlace == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a place.',
            ),
          ),
        );

      return;
    }

    Navigator.pop<Map<String, dynamic>>(
      context,
      Map<String, dynamic>.from(selectedPlace),
    );
  }

  Widget _buildSearchArea() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          widget.isPlaceSelectionMode ? 66 : 16,
          12,
          16,
          0,
        ),
        child: Column(
          children: [
            Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _filterPlaces(),
                decoration: InputDecoration(
                  hintText: '지역 또는 매장을 검색하세요',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close),
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return ChoiceChip(
                    selected: isSelected,
                    onSelected: (_) => _selectCategory(category),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category != 'ALL') ...[
                          Icon(
                            _getCategoryIcon(category),
                            size: 18,
                            color: isSelected ? Colors.white : _primaryColor,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(category),
                      ],
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : _primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedColor: _primaryColor,
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    elevation: isSelected ? 3 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButtons() {
    return Positioned(
      right: 16,
      bottom: _selectedPlace == null ? 120 : 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'currentLocation',
            onPressed: _isFindingLocation ? null : _moveToCurrentLocation,
            tooltip: '현재 위치',
            backgroundColor: Colors.white,
            foregroundColor: _primaryColor,
            child: _isFindingLocation
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoomIn',
            onPressed: _zoomIn,
            tooltip: '확대',
            backgroundColor: Colors.white,
            foregroundColor: _primaryColor,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoomOut',
            onPressed: _zoomOut,
            tooltip: '축소',
            backgroundColor: Colors.white,
            foregroundColor: _primaryColor,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard() {
    final place = _selectedPlace;

    if (place == null) {
      return const SizedBox.shrink();
    }

    final name =
        place['name']?.toString() ?? '이름 없음';

    final category =
        place['category']?.toString() ?? '카테고리 없음';

    final address =
        place['address']?.toString() ?? '주소 정보 없음';

    final city =
        place['city']?.toString() ?? '';

    final description =
    place['description']?.toString();

    final imageUrl =
    place['image_url']?.toString();

    return DraggableScrollableSheet(
      initialChildSize: 0.48,
      minChildSize: 0.28,
      maxChildSize: 0.88,
      snap: true,
      snapSizes: const [
        0.28,
        0.48,
        0.88,
      ],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 10),

              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      color: _primaryColor,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('4.6'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedPlace = null;
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: imageUrl != null &&
                            imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return _buildImagePlaceholder(
                              category,
                            );
                          },
                        )
                            : _buildImagePlaceholder(
                          category,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (description != null &&
                        description.trim().isNotEmpty) ...[
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.format_quote,
                            color: _primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              description,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            city.isEmpty
                                ? address
                                : '$address, $city',
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 10),
                        Text('영업시간 정보 준비 중'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        Icon(Icons.storefront_outlined),
                        SizedBox(width: 10),
                        Text('Independent local spot'),
                      ],
                    ),

                    const SizedBox(height: 26),

                    if (widget.isPlaceSelectionMode)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _confirmSelectedPlace,
                          icon: const Icon(
                            Icons.check_circle_outline,
                          ),
                          label: const Text(
                            'Select Place',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Wish 저장 기능 연결
                              },
                              icon: const Icon(
                                Icons.favorite_border,
                              ),
                              label: const Text('Save'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: () {
                                _openDirections(place);
                              },
                              icon: const Icon(
                                Icons.directions_walk,
                              ),
                              label: const Text(
                                'Walking Directions',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: _primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder(String category) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(category),
          color: _primaryColor,
          size: 70,
        ),
      ),
    );
  }

  Widget _buildCurrentLocationMarker() {
    return MarkerLayer(
      markers: [
        Marker(
          point: _currentLocation!,
          width: 48,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 3),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options:  MapOptions(
              initialCenter: _londonCenter,
              initialZoom: 11,
              minZoom: 5,
              maxZoom: 18,
              cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(
                LatLng(49.8, -8.7),
                LatLng(60.9, 1.8),
              ),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tops',

              ),
              // RichAttributionWidget(
              //   attributions: [
              //     TextSourceAttribution(
              //       'OpenStreetMap contributors',
              //     ),
              //   ],
              // ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  markers: _buildPlaceMarkers(),
                  maxClusterRadius: 55,
                  size: const Size(46, 46),
                  maxZoom: 16,
                  padding: const EdgeInsets.all(50),
                  zoomToBoundsOnClick: true,
                  builder: (context, markers) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        '${markers.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_currentLocation != null) _buildCurrentLocationMarker(),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (widget.isPlaceSelectionMode)
            Positioned(
              top: 12,
              left: 12,
              child: SafeArea(
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: IconButton(
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          _buildSearchArea(),
          _buildMapButtons(),
          _buildPlaceCard(),
          if (_isLoadingPlaces)
            Container(
              color: Colors.black12,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Positioned(
              left: 16,
              right: 16,
              top: 180,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('장소를 불러오지 못했습니다.\n$_errorMessage'),
                      ),
                      IconButton(
                        onPressed: _loadPlaces,
                        icon: const Icon(Icons.refresh),
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
}
