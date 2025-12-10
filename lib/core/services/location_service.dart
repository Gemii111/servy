import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/logger.dart';

/// Service for handling location operations
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permissions
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get address from coordinates
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isEmpty) {
        // Fallback: return formatted coordinates
        return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      }

      Placemark place = placemarks[0];
      
      // Build address string
      String address = '';
      if (place.street != null && place.street!.isNotEmpty) {
        address += place.street!;
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += place.subLocality!;
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += place.locality!;
      }
      if (place.country != null && place.country!.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += place.country!;
      }

      // If address is still empty, use coordinates as fallback
      if (address.isEmpty) {
        return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      }
      
      return address;
    } catch (e) {
      Logger.e('LocationService', 'Failed to get address from coordinates: $e');
      // Fallback: return formatted coordinates instead of "Unknown Location"
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Get coordinates from address (geocoding)
  Future<LocationCoordinates?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isEmpty) {
        return null;
      }

      Location location = locations[0];
      return LocationCoordinates(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (e) {
      Logger.e('LocationService', 'Failed to get coordinates from address: $e');
      return null;
    }
  }
}

/// Location coordinates model
class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });
}

