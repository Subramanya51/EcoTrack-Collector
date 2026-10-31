import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapsService {
  final String _apiKey = "AIzaSyBp24dhgoJyiaYcqkL54EnN8wZaWLTzygE";

  Future<Map<String, dynamic>?> getOptimizedRoute({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> waypoints,
  }) async {
    String waypointsString = "";
    if (waypoints.isNotEmpty) {
      waypointsString = 'optimize:true|' + 
          waypoints.map((w) => "${w.latitude},${w.longitude}").join('|');
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'waypoints=$waypointsString&'
        'key=$_apiKey';

    try {
      print('--- Requesting Directions API ---');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          print('--- Directions API Response: OK ---');
          return data;
        } else {
          print('--- Directions API Error: ${data['status']} ---');
          if (data['error_message'] != null) {
            print('--- Message: ${data['error_message']} ---');
          }
          return null;
        }
      } else {
        print('--- HTTP Error: ${response.statusCode} ---');
        return null;
      }
    } catch (e) {
      print('--- Error fetching route: $e ---');
      return null;
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
