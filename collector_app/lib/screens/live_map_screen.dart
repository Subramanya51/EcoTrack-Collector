import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // Default to SF
  StreamSubscription<Position>? _locationSubscription;
  String? _collectorId;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initLocation();
    _listenToPickupPoints();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _setOfflineStatus();
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setOfflineStatus() async {
    if (_collectorId == null) return;
    try {
      await FirebaseDatabase.instance
          .ref('Collector_Locations/$_collectorId')
          .update({'status': 'OFFLINE'});
      print('--- Status set to OFFLINE in RTDB for $_collectorId ---');
    } catch (e) {
      print('--- Error setting offline status in RTDB: $e ---');
    }
  }

  Future<void> _startLocationTracking() async {
    _collectorId = await _authService.getCollectorId();
    if (_collectorId == null) {
      print('--- ERROR: No Collector ID found in SharedPreferences! ---');
      print('--- ACTION REQUIRED: Please log out and log in again to save your ID. ---');
      return;
    }

    print('--- SUCCESS: Collector ID "$_collectorId" fetched. Starting stream... ---');

    // Subscribe to location updates
    _locationSubscription = Geolocator.getPositionStream(
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

    try {
      print('--- SYNCING TO RTDB: Collector/$_collectorId at (${position.latitude}, ${position.longitude}) ---');
      await FirebaseDatabase.instance
          .ref('Collector_Locations/$_collectorId')
          .update({
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
        print('--- GPS Timeout/Error, attempting to use last known location... ---');
        position = await Geolocator.getLastKnownPosition();
      }
      
      if (position != null) {
        final pos = position; // Create a non-nullable reference
        print('--- Current Location Found: ${pos.latitude}, ${pos.longitude} ---');
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
        print('--- Could not determine location. Moving camera to first pickup point... ---');
        if (_markers.isNotEmpty) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_markers.first.position, 14.0),
          );
        }
      }
    } catch (e) {
      print('--- Error getting location: $e ---');
    }
  }

  void _listenToPickupPoints() {
    print('--- Listening to pickupRequests in Realtime Database ---');
    FirebaseDatabase.instance.ref('pickupRequests').onValue.listen((event) {
      final rawData = event.snapshot.value;
      if (rawData == null) {
        print('--- No data found in pickupRequests ---');
        return;
      }

      print('--- Realtime Database Snapshot Received ---');
      
      final Map<dynamic, dynamic> data = (rawData is Map) 
          ? rawData 
          : {};
      
      final newMarkers = <Marker>{};

      data.forEach((key, value) {
        if (value is Map) {
          if (value['status'] != "REQUESTED") {
            return;
          }

          try {
            final lat = (value['latitude'] as num).toDouble();
            final lng = (value['longitude'] as num).toDouble();
            
            newMarkers.add(Marker(
              markerId: MarkerId(key.toString()),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(title: 'Pickup Point', snippet: 'ID: $key'),
            ));
          } catch (e) {
            print('--- Error parsing RTDB record $key: $e ---');
          }
        }
      });

      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
        
        // Auto-zoom to markers if we are stuck at default location
        if (_markers.isNotEmpty) {
          _zoomToFitMarkers();
        }
      }
    }, onError: (error) {
      print('--- Realtime Database Error: $error ---');
    });
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
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),

          // Top header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: const Color(0xFF071325),
              padding: EdgeInsets.only(top: topPad, bottom: 16, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.navigation, color: Color(0xFF00E676)),
                      SizedBox(width: 12),
                      Text(
                        'ECO TRACK',
                        style: TextStyle(color: Color(0xFF00E676), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 8, height: 8,
                        child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
                      ),
                      const SizedBox(width: 8),
                      const Text('ONLINE', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 16),
                      Material(
                        color: const Color(0x801F2A3D),
                        shape: const CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: const SizedBox(
                            width: 56, height: 56,
                            child: Icon(Icons.account_circle, color: Color(0xFF00E676), size: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 48,
              color: const Color(0xFF071325),
              alignment: Alignment.center,
              child: Container(
                width: 96, height: 4,
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
}
