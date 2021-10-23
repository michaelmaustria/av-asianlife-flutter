import 'dart:math' show cos, sqrt, asin;

class CalculateDistance {

  static double calculateDistance(lat1, lng1, lat2, lng2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lng2 - lng1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

}