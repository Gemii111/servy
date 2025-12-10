import 'package:url_launcher/url_launcher.dart';
import '../../data/models/address_model.dart';

/// Service for handling navigation to locations
class NavigationService {
  static const NavigationService instance = NavigationService._();
  const NavigationService._();

  /// Open Google Maps with navigation to the specified coordinates
  ///
  /// [latitude] - Destination latitude
  /// [longitude] - Destination longitude
  /// [label] - Optional label for the destination (e.g., "Restaurant Name")
  Future<bool> openGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    // Create Google Maps URL
    final String encodedLabel = label != null ? Uri.encodeComponent(label) : '';
    final String googleMapsUrl =
        label != null
            ? 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$encodedLabel'
            : 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    final Uri mapsUri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(mapsUri)) {
        return await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Try to open as Google Maps app
        final String fallbackUrl =
            'https://maps.google.com/?q=$latitude,$longitude';
        final Uri fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          return await launchUrl(
            fallbackUri,
            mode: LaunchMode.externalApplication,
          );
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Open navigation app (Google Maps or default maps app)
  /// This will start turn-by-turn navigation
  Future<bool> startNavigation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    // Try Google Maps navigation first
    final String encodedLabel = label != null ? Uri.encodeComponent(label) : '';
    final String googleMapsNavUrl =
        label != null
            ? 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$encodedLabel&travelmode=driving'
            : 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    final Uri navUri = Uri.parse(googleMapsNavUrl);

    try {
      if (await canLaunchUrl(navUri)) {
        return await launchUrl(navUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Try standard Google Maps URL
        return await openGoogleMaps(
          latitude: latitude,
          longitude: longitude,
          label: label,
        );
      }
    } catch (e) {
      return false;
    }
  }

  /// Navigate to an address
  Future<bool> navigateToAddress(
    AddressModel address, {
    String? label,
    bool startNavigation = false,
  }) async {
    if (startNavigation) {
      return await this.startNavigation(
        latitude: address.latitude,
        longitude: address.longitude,
        label: label ?? address.label,
      );
    } else {
      return await openGoogleMaps(
        latitude: address.latitude,
        longitude: address.longitude,
        label: label ?? address.fullAddress,
      );
    }
  }

  /// Navigate to coordinates
  Future<bool> navigateToCoordinates({
    required double latitude,
    required double longitude,
    String? label,
    bool startNavigation = false,
  }) async {
    if (startNavigation) {
      return await this.startNavigation(
        latitude: latitude,
        longitude: longitude,
        label: label,
      );
    } else {
      return await openGoogleMaps(
        latitude: latitude,
        longitude: longitude,
        label: label,
      );
    }
  }
}
