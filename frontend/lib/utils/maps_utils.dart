import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Shared Google Maps utilities used across map-related screens.
class MapsUtils {
  MapsUtils._(); // prevent instantiation

  /// Decodes a [Google Maps encoded polyline](https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
  /// string into a list of [LatLng] coordinates.
  ///
  /// Use the result as the `points` parameter of a [Polyline] to draw the
  /// actual road path returned by the Directions API.
  static List<LatLng> decodePolyline(String encoded) {
    final result = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int decodedValue = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        decodedValue |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat =
          ((decodedValue & 1) != 0) ? ~(decodedValue >> 1) : (decodedValue >> 1);
      lat += dlat;

      shift = 0;
      decodedValue = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        decodedValue |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng =
          ((decodedValue & 1) != 0) ? ~(decodedValue >> 1) : (decodedValue >> 1);
      lng += dlng;

      result.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return result;
  }
}
