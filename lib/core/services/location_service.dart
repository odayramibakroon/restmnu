import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../errors/error_messages.dart';
import '../errors/exceptions.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
    };
  }

  factory LocationResult.fromMap(Map<String, dynamic> map) {
    return LocationResult(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      formattedAddress: map['formattedAddress'] as String? ?? '',
    );
  }
}

abstract class LocationService {
  Future<LocationResult> getCurrentLocation();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException(
          ErrorMessages.message(AppErrorKey.locationServiceDisabled),
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException(
            ErrorMessages.message(AppErrorKey.locationPermissionDenied),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException(
          ErrorMessages.message(AppErrorKey.locationPermissionDeniedForever),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      String formattedAddress =
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

      // Reverse geocode if platform supports it (web/windows may fail gracefully)
      if (!kIsWeb) {
        try {
          final placemarks = await Geocoding().placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final parts = <String>[
              if (place.street != null && place.street!.trim().isNotEmpty)
                place.street!.trim(),
              if (place.subLocality != null &&
                  place.subLocality!.trim().isNotEmpty)
                place.subLocality!.trim(),
              if (place.locality != null && place.locality!.trim().isNotEmpty)
                place.locality!.trim(),
              if (place.administrativeArea != null &&
                  place.administrativeArea!.trim().isNotEmpty)
                place.administrativeArea!.trim(),
            ];

            if (parts.isNotEmpty) {
              formattedAddress = parts.join('، ');
            }
          }
        } catch (_) {
          // Keep formatted fallback coordinates
        }
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        formattedAddress: formattedAddress,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException(
        ErrorMessages.withDetails(AppErrorKey.getCurrentLocation, e),
      );
    }
  }
}
