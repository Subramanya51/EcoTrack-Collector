import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/google_maps_service.dart';
import '../theme/app_theme.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default to SF
  LatLng? _dumpYardLocation; // Will default to _currentLocation for loop route
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<DatabaseEvent>? _pickupSubscription;
  String? _collectorId;
  final AuthService _authService = AuthService();
  final GoogleMapsService _googleMapsService = GoogleMapsService();

  String _totalDistance = "";
  String _totalDuration = "";
  List<int> _optimizedOrder = [];
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocation();
    _listenToPickupPoints();
    _startLocationTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOfflineStatus();
    _locationSubscription?.cancel();
    _pickupSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App is switched or backgrounded
      print('--- App Lifecycle: $state. Setting OFFLINE status. ---');
      _setOfflineStatus();
    } else if (state == AppLifecycleState.resumed) {
      // App is resumed
      print('--- App Lifecycle: RESUMED. Setting ONLINE status. ---');
      _setOnlineStatus();
    }
  }

  Future<void> _setOnlineStatus() async {
    if (_collectorId == null) return;
    try {
      await FirebaseDatabase.instance
          .ref('Collector_Locations/$_collectorId')
          .update({'status': 'ONLINE', 'timestamp': ServerValue.timestamp});
      print('--- Status set to ONLINE in RTDB for $_collectorId ---');
    } catch (e) {
      print('--- Error setting online status in RTDB: $e ---');
    }
  }

  Future<void> _setOfflineStatus() async {
    if (_collectorId == null) return;
    try {
      await FirebaseDatabase.instance
          .ref('Collector_Locations/$_collectorId')
          .update({'status': 'OFFLINE', 'timestamp': ServerValue.timestamp});
      print('--- Status set to OFFLINE in RTDB for $_collectorId ---');
    } catch (e) {
      print('--- Error setting offline status in RTDB: $e ---');
    }
  }

  Future<void> _startLocationTracking() async {
    _collectorId = await _authService.getCollectorId();
    if (_collectorId == null) {
      print('--- ERROR: No Collector ID found in SharedPreferences! ---');
      print(
        '--- ACTION REQUIRED: Please log out and log in again to save your ID. ---',
      );
      return;
    }

    print(
      '--- SUCCESS: Collector ID "$_collectorId" fetched. Starting stream... ---',
    );

    // Subscribe to location updates
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // Update every 5 meters
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(position.latitude, position.longitude);
            });
          }
          _updateLocationInFirestore(position);
        });
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    if (_collectorId == null) return;

    // Periodically check if token is still valid
    final isValid = await _authService.isTokenValid();
    if (!isValid) {
      print('--- TOKEN EXPIRED during location update. Logging out... ---');
      _authService.logout();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
      return;
    }

    try {
      print(
        '--- SYNCING TO RTDB: Collector/$_collectorId at (${position.latitude}, ${position.longitude}) ---',
      );
      final ref = FirebaseDatabase.instance.ref(
        'Collector_Locations/$_collectorId',
      );

      // Ensure we set status to OFFLINE if the app is closed/connection lost
      await ref.onDisconnect().update({
        'status': 'OFFLINE',
        'timestamp': ServerValue.timestamp,
      });

      await ref.update({
        'collectorId': _collectorId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'status': 'ONLINE',
        'lastUpdated': DateTime.now().toIso8601String(),
        'timestamp': ServerValue.timestamp,
      });

      print('--- RTDB UPDATE SUCCESSFUL ---');
    } catch (e) {
      print('--- RTDB UPDATE FAILED: $e ---');
    }
  }

  Future<void> _initLocation() async {
    print('--- Checking Location Permissions ---');
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('--- Location Services are DISABLED on this device ---');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('--- Requesting Location Permissions ---');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('--- Location Permissions were DENIED ---');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('--- Location Permissions are PERMANENTLY DENIED ---');
        return;
      }

      print('--- Fetching Current GPS Position... ---');
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 30),
        );
      } catch (e) {
        print(
          '--- GPS Timeout/Error, attempting to use last known location... ---',
        );
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        final pos = position; // Create a non-nullable reference
        print(
          '--- Current Location Found: ${pos.latitude}, ${pos.longitude} ---',
        );
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(pos.latitude, pos.longitude);
          });

          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_currentLocation, 14.0),
          );

          // Initial sync to RTDB so node appears immediately
          _updateLocationInFirestore(pos);
        }
      } else {
        print(
          '--- Could not determine location. Falling back to first pickup point... ---',
        );
        if (_markers.isNotEmpty) {
          final firstPickup = _markers.first.position;
          if (mounted) {
            setState(() {
              _currentLocation = firstPickup;
            });
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(firstPickup, 14.0),
            );
          }
        }
      }
    } catch (e) {
      print('--- Error getting location: $e ---');
    }
  }

  Future<void> _listenToPickupPoints() async {
    // City/zone saved at login (from the JWT)
    final city = await _authService.getCity();
    final zone = await _authService.getZone();

    print('--- Listening to pickupRequests (city: $city, zone: $zone) ---');

    // Only this collector's city, filtered by Firebase (needs ".indexOn": ["city"] in the rules)
    Query query = FirebaseDatabase.instance.ref('pickupRequests');
    if (city != null) query = query.orderByChild('city').equalTo(city);

    _pickupSubscription = query.onValue.listen(
      (event) {
        final rawData = event.snapshot.value;

        // No early return on empty data: the map must clear when the last pickup closes
        final Map<dynamic, dynamic> data = (rawData is Map) ? rawData : {};

        final newMarkers = <Marker>{};

        data.forEach((key, value) {
          if (value is Map) {
            // Show only open requests: hides COMPLETED (picked up) and FAILED (not picked up)
            final status = value['status'];
            if (status != 'REQUESTED' && status != 'IN_PROGRESS') {
              return;
            }

            // A zone collector sees only their zone; a city-wide collector (zone == null) sees all
            if (zone != null && value['zone'] != zone) {
              return;
            }

            try {
              final lat = (value['latitude'] as num).toDouble();
              final lng = (value['longitude'] as num).toDouble();

              newMarkers.add(
                Marker(
                  markerId: MarkerId(key.toString()),
                  position: LatLng(lat, lng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Pickup Point',
                    snippet: 'ID: $key',
                  ),
                ),
              );
            } catch (e) {
              print('--- Error parsing RTDB record $key: $e ---');
            }
          }
        });

        if (mounted) {
          setState(() {
            // Preserve origin and destination markers if they already exist
            final originMarker = _markers
                .where((m) => m.markerId.value == 'origin')
                .firstOrNull;
            final destMarker = _markers
                .where((m) => m.markerId.value == 'destination')
                .firstOrNull;

            _markers = newMarkers;

            if (originMarker != null) _markers.add(originMarker);
            if (destMarker != null) _markers.add(destMarker);
          });

          // Auto-zoom to markers if we are stuck at default location
          if (_markers.isNotEmpty) {
            _zoomToFitMarkers();
          }
        }
      },
      onError: (error) {
        print('--- Realtime Database Error: $error ---');
      },
    );
  }

  Future<void> _optimizeRoute() async {
    if (_markers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pickup points to optimize')),
      );
      return;
    }

    // Check if we are still at default location (SF) while likely being elsewhere
    if (_currentLocation.latitude == 37.7749 &&
        _currentLocation.longitude == -122.4194) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Waiting for GPS location... Please try again in a moment.',
          ),
        ),
      );
      _initLocation();
      return;
    }

    final destination = _dumpYardLocation ?? _currentLocation;

    final List<LatLng> waypointLatLngs = _markers
        .where(
          (m) =>
              m.markerId.value != 'origin' && m.markerId.value != 'destination',
        )
        .map((m) => m.position)
        .toList();

    if (waypointLatLngs.length > 23) {
      // 23 waypoints + origin + destination = 25 total (Standard API limit)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Too many pickup points (limit 23 for one route)'),
        ),
      );
      // Optional: split into multiple routes as per requirement,
      // but the user said "Do not create multiple separate routes. Always generate one optimized route."
      // So I'll just warn and proceed with the first 23.
    }

    setState(() {
      _isOptimizing = true;
    });
    try {
      final result = await _googleMapsService.getOptimizedRoute(
        origin: _currentLocation,
        destination: destination,
        waypoints: waypointLatLngs,
      );

      if (result != null) {
        final route = result['routes'][0];
        final overviewPolyline = route['overview_polyline']['points'];
        final List<LatLng> polylinePoints = _googleMapsService.decodePolyline(
          overviewPolyline,
        );

        // Waypoint order gives us the sequence (0-indexed based on the waypoints list we sent)
        final List<dynamic> order = route['waypoint_order'];

        // Extract total distance and duration
        int totalDist = 0;
        int totalDur = 0;
        final legs = route['legs'] as List;
        for (var leg in legs) {
          totalDist += (leg['distance']['value'] as num).toInt();
          totalDur += (leg['duration']['value'] as num).toInt();
        }

        setState(() {
          _totalDistance = "${(totalDist / 1000).toStringAsFixed(1)} km";
          _totalDuration = "${(totalDur / 60).toStringAsFixed(0)} mins";
          _optimizedOrder = order.cast<int>();

          _polylines = {
            Polyline(
              polylineId: const PolylineId('optimized_route'),
              points: polylinePoints,
              color: const Color(0xFF00E676),
              width: 5,
            ),
          };

          // Update markers to include origin and destination if not already there
          _markers.add(
            Marker(
              markerId: const MarkerId('origin'),
              position: _currentLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
              infoWindow: const InfoWindow(title: 'Start Location (Truck)'),
            ),
          );

          _markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: destination,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: const InfoWindow(
                title: 'Final Destination (Dump Yard)',
              ),
            ),
          );
        });

        _zoomToFitAll(destination);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to optimize route')),
        );
      }
    } catch (e) {
      print('Error optimizing route: $e');
    } finally {
      setState(() {
        _isOptimizing = false;
      });
    }
  }

  void _zoomToFitAll(LatLng destination) {
    if (_markers.isEmpty || _mapController == null) return;

    double minLat = _currentLocation.latitude;
    double maxLat = _currentLocation.latitude;
    double minLng = _currentLocation.longitude;
    double maxLng = _currentLocation.longitude;

    for (var m in _markers) {
      if (m.position.latitude < minLat) minLat = m.position.latitude;
      if (m.position.latitude > maxLat) maxLat = m.position.latitude;
      if (m.position.longitude < minLng) minLng = m.position.longitude;
      if (m.position.longitude > maxLng) maxLng = m.position.longitude;
    }

    // Include destination
    if (destination.latitude < minLat) minLat = destination.latitude;
    if (destination.latitude > maxLat) maxLat = destination.latitude;
    if (destination.longitude < minLng) minLng = destination.longitude;
    if (destination.longitude > maxLng) maxLng = destination.longitude;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // Extra Padding for route
      ),
    );
  }

  void _zoomToFitMarkers() {
    if (_markers.isEmpty || _mapController == null) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (var m in _markers) {
      if (m.position.latitude < minLat) minLat = m.position.latitude;
      if (m.position.latitude > maxLat) maxLat = m.position.latitude;
      if (m.position.longitude < minLng) minLng = m.position.longitude;
      if (m.position.longitude > maxLng) maxLng = m.position.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        70, // Padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // Actual Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14.0,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),

          // Top header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF071325),
              padding: EdgeInsets.only(
                top: topPad,
                bottom: 16,
                left: 24,
                right: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.navigation, color: Color(0xFF00E676)),
                      SizedBox(width: 12),
                      Text(
                        'ECO DISPATCH',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                        height: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFF00E676),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ONLINE',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Material(
                        color: const Color(0x801F2A3D),
                        shape: const CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(
                              Icons.account_circle,
                              color: Color(0xFF00E676),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Route Info Card
          if (_totalDistance.isNotEmpty)
            Positioned(
              top: topPad + 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF071325).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00E676).withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRouteStat(
                      Icons.straighten,
                      'Distance',
                      _totalDistance,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _buildRouteStat(
                      Icons.access_time,
                      'Est. Time',
                      _totalDuration,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _buildRouteStat(
                      Icons.location_on,
                      'Pickups',
                      '${_markers.length - 2}',
                    ),
                  ],
                ),
              ),
            ),

          // Optimized Sequence List (Hidden by default, shown when expanded)
          if (_optimizedOrder.isNotEmpty)
            Positioned(
              top: topPad + 160,
              left: 20,
              right: 20,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFF071325).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00E676).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 8, bottom: 4),
                      child: Text(
                        'OPTIMIZED SEQUENCE',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: _optimizedOrder.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: const Color(0xFF00E676),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Stop ${_optimizedOrder[index] + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 48,
              color: const Color(0xFF071325),
              alignment: Alignment.center,
              child: Container(
                width: 96,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _initLocation();
        },
        backgroundColor: const Color(0xFF00E676),
        child: const Icon(Icons.my_location, color: Color(0xFF071325)),
      ),
    );
  }

  Widget _buildRouteStat(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF00E676), size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
