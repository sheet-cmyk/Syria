import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  static double distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return meters / 1000;
  }
}
