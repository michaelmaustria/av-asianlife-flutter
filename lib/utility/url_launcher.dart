
import 'package:av_asian_life/data_manager/doctor.dart';
import 'package:av_asian_life/data_manager/provider.dart';
import 'package:query_params/query_params.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {

  static openPhone(String number) async {

    final formattedNumber =
    number.replaceAllMapped(new RegExp(r'[\s-]'), (match) {
      return '';
    });

    print('number: $number');
    print('formattedNumber: $formattedNumber');

    String url = "tel:$formattedNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static launchMaps({double lat1, double lng1, double lat2, double lng2, Provider provider, Doctor doctor}) async {
    //String googleRoute = 'https://www.google.com/maps/dir/$lat1,$lng1/$lat2,$lng2';

    String googleRoute = 'https://maps.google.com/?saddr=$lat1,$lng1&';
    String appleRoute = 'http://maps.apple.com/?saddr=$lat1,$lng1&';

    String name = provider?.hospitalName == null ? doctor?.doctor : provider?.hospitalName;
    //String address = provider?.address == null ? doctor.address : provider.address;

    URLQueryParams googleParams = URLQueryParams();
    URLQueryParams appleParams = URLQueryParams();

    googleParams.append('daddr', '$lat2,$lng2($name)');
    appleParams.append('daddr', '$lat2,$lat2');
    
    String googleMapUrl = googleRoute + googleParams.toString();
    String appleMapUrl = appleRoute + appleParams.toString();

     if(await canLaunch(googleMapUrl))  {
      print('Google Map URL: $googleMapUrl');
      await launch(googleMapUrl);
    } else if (await canLaunch(appleMapUrl)) {
      print('Apple Map URL: $appleMapUrl');
      await launch(appleMapUrl);
    } else {
      throw 'Could not launch url';
    }
  }
}

