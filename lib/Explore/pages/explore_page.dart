import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/place_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final MapController _mapController = MapController();
  final PlaceService _placeService = PlaceService();

  final List<Marker> _markers = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _placeService.getPlaces();

      final loadedMarkers = places.map((place) {
        final latitude = (place['latitude'] as num).toDouble();
        final longitude = (place['longitude'] as num).toDouble();
        final name = place['name']?.toString() ?? '이름 없음';

        return Marker(
          point: LatLng(latitude, longitude),
          width: 50,
          height: 50,
          child: Tooltip(
            message: name,
            child: const Icon(
              Icons.location_pin,
              size: 50,
              color: Colors.red,
            ),
          ),
        );
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _markers
          ..clear()
          ..addAll(loadedMarkers);

        _isLoading = false;
      });

      debugPrint('불러온 장소: $places');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });

      debugPrint('장소 조회 실패: $error');
    }
  }

  void _addMarker(LatLng coordinate) {
    setState(() {
      _markers.add(
        Marker(
          point: coordinate,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_pin,
            size: 50,
            color: Colors.blue,
          ),
        ),
      );
    });
  }

  void _zoomOut() {
    final currentCamera = _mapController.camera;

    _mapController.move(
      currentCamera.center,
      currentCamera.zoom - 1,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                51.5074,
                -0.1278,
              ),
              initialZoom: 13,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, coordinate) {
                _mapController.move(
                  coordinate,
                  _mapController.camera.zoom,
                );

                _addMarker(coordinate);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tops',
              ),
              MarkerLayer(
                markers: _markers,
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          if (_errorMessage != null)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '장소를 불러오지 못했습니다.\n$_errorMessage',
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _zoomOut,
        child: const Icon(Icons.zoom_out),
      ),
    );
  }
}