import 'dart:core';
import 'dart:math' as math;

import 'package:location/location.dart';

class GoalLocation {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const GoalLocation(this.latitude, this.longitude, this.locationName);

  Stream<double> distanceFromUser(Stream<LocationData> sourceStream) async* {
    // Wait until a new chunk is available, then process it.
    await for (final currentLocation in sourceStream) {
      var currentUserLatitude = currentLocation.latitude;
      var currentUserLongitude = currentLocation.longitude;
      // checks nums are not null
      if (latitude == null ||
          longitude == null ||
          currentUserLongitude == null ||
          currentUserLatitude == null) {
        yield -1;
      }
      //calculate distance between 2 points with euclide formula
      var currentDistance = math.sqrt(
          math.pow((latitude! - currentUserLatitude!), 2) +
              math.pow((longitude! - currentUserLongitude!), 2));

      // Add lines to output stream.
      yield currentDistance;
    }
  }

  Stream<double> rdistanceFromUser(Stream<LocationData> sourceStream) async* {
    await for (final currentLocation in sourceStream) {
      var currentUserLatitude = currentLocation.latitude;
      var currentUserLongitude = currentLocation.longitude;

      var r = 6371e3; // earth diameter in metres
      var omega1 = currentUserLatitude! * math.pi / 180; // φ, λ in radians
      var omega2 = latitude! * math.pi / 180;
      var deltaLat = (latitude! - currentUserLatitude) * math.pi / 180;
      var deltaLong = (longitude! - currentUserLongitude!) * math.pi / 180;

      //calculate distance between 2 points with the formula found online
      var a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
          math.cos(omega1) *
              math.cos(omega2) *
              math.sin(deltaLong / 2) *
              math.sin(deltaLong / 2);
      var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

      var d = r * c; // in metres

      // Add lines to output stream.
      yield d;
    }
  }

  double getOffsetFromNorth(double currentLatitude, double currentLongitude,
      double targetLatitude, double targetLongitude) {
    var la_rad = currentLatitude * math.pi / 180;
    var lo_rad = currentLongitude * math.pi / 180;
    var de_la = targetLatitude * math.pi / 180;
    var de_lo = targetLongitude * math.pi / 180;

    var toDegrees = 180 *
        (math.atan(math.sin(de_lo - lo_rad) /
            math.pi /
            ((math.cos(la_rad) * math.tan(de_la)) -
                (math.sin(la_rad) * math.cos(de_lo - lo_rad)))));
    if (la_rad > de_la) {
      if ((lo_rad > de_lo || lo_rad < math.pi / 180 * (-180.0) + de_lo) &&
          toDegrees > 0.0 &&
          toDegrees <= 90.0) {
        toDegrees += 180.0;
      } else if (lo_rad <= de_lo &&
          lo_rad >= math.pi / 180 * (-180.0) + de_lo &&
          toDegrees > -90.0 &&
          toDegrees < 0.0) {
        toDegrees += 180.0;
      }
    }
    if (la_rad < de_la) {
      if ((lo_rad > de_lo || lo_rad < math.pi / 180 * (-180.0) + de_lo) &&
          toDegrees > 0.0 &&
          toDegrees < 90.0) {
        toDegrees += 180.0;
      }
      if (lo_rad <= de_lo &&
          lo_rad >= math.pi / 180 * (-180.0) + de_lo &&
          toDegrees > -90.0 &&
          toDegrees <= 0.0) {
        toDegrees += 180.0;
      }
    }
    return toDegrees;
  }

  Stream<double> bearingFromUser(Stream<LocationData> sourceStream) async* {
    await for (final currentLocation in sourceStream) {
      var currentUserLatitude = currentLocation.latitude;
      var currentUserLongitude = currentLocation.longitude;

      //const double doublepi = 6.2831853071795865;
      //const double rad2deg = 57.2957795130823209;
/*
      if (latitude == null ||
          longitude == null ||
          currentUserLongitude == null ||
          currentUserLatitude == null) {
        yield 361;
      } else {
        double theta = math.atan2(
            latitude! - currentUserLatitude, longitude! - currentUserLongitude);
        if (theta < 0.0) theta += doublepi;
        yield rad2deg * theta;
      }
*/

      var omega1 = currentUserLatitude! * math.pi / 180; // φ, λ in radians
      var omega2 = latitude! * math.pi / 180;
      //var deltaLat = (latitude! - currentUserLatitude) * math.pi / 180;
      var deltaLong = (longitude! - currentUserLongitude!) * math.pi / 180;

      var y = math.sin(deltaLong) * math.cos(omega2);
      var x = math.cos(omega1) * math.sin(omega2) -
          math.sin(omega1) * math.cos(omega2) * math.cos(deltaLong);
      var theta = math.atan2(y, x);
      var brng = (theta * 180 / math.pi + 360) % 360; // in degrees

      yield brng;
    }

    /// Calculates the distance between the supplied coordinates in meters.
    ///
    /// The distance between the coordinates is calculated using the Haversine
    /// formula (see https://en.wikipedia.org/wiki/Haversine_formula). The
    /// supplied coordinates [startLatitude], [startLongitude], [endLatitude] and
    /// [endLongitude] should be supplied in degrees.
    double distanceBetween(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
    ) {
      var earthRadius = 6378137.0;
      var dLat = (endLatitude - startLatitude) * math.pi / 180;
      ;
      var dLon = (endLongitude - startLongitude) * math.pi / 180;
      ;

      var a = math.pow(math.sin(dLat / 2), 2) +
          math.pow(math.sin(dLon / 2), 2) *
              math.cos((startLatitude) * math.pi / 180) *
              math.cos((endLatitude) * math.pi / 180);
      var c = 2 * math.asin(math.sqrt(a));

      return earthRadius * c;
    }

    /// Calculates the initial bearing between two points
    ///
    /// The initial bearing will most of the time be different than the end
    /// bearing, see https://www.movable-type.co.uk/scripts/latlong.html#bearing.
    /// The supplied coordinates [startLatitude], [startLongitude], [endLatitude]
    /// and [endLongitude] should be supplied in degrees.
    double bearingBetween(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
    ) {
      // convert in radians
      var startLongitudeRadians = (startLongitude) * math.pi / 180;
      var startLatitudeRadians = (startLatitude) * math.pi / 180;
      var endLongitudeRadians = (endLongitude) * math.pi / 180;
      var endLatitudeRadians = (endLatitude) * math.pi / 180;

      var y = math.sin(endLongitudeRadians - startLongitudeRadians) *
          math.cos(endLatitudeRadians);
      var x = math.cos(startLatitudeRadians) * math.sin(endLatitudeRadians) -
          math.sin(startLatitudeRadians) *
              math.cos(endLatitudeRadians) *
              math.cos(endLongitudeRadians - startLongitudeRadians);

      return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
    }
  }

/*

var r = 6371e3; // metres
var φ1 = lat1 * math.pi/180; // φ, λ in radians
var φ2 = lat2 * math.pi/180;
var Δφ deltaLat = (lat2-lat1) * math.pi/180;
var Δλ deltaLong = (lon2-lon1) * math.pi/180;

var a = math.sin(deltaLat/2) * math.sin(deltaLat/2) +
          math.cos(φ1) * math.cos(φ2) *
          math.sin(deltaLong/2) * math.sin(deltaLong/2);
var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));

var d = R * c; // in metres

*/
}
