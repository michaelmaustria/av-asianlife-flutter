import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/provider.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/utility/url_launcher.dart';
import 'package:flutter/material.dart';

class SearchProviderResultPage extends StatelessWidget {

  final double height, width;
  final double lat, lng;
  final List<Provider> mProvider;
  final isNeedingProviderFromRequestLog;
  final IApplicationSession appSessionCallback;

  SearchProviderResultPage({this.height, this.width, this.mProvider, this.lat, this.lng, this.isNeedingProviderFromRequestLog, this.appSessionCallback});

  @override
  Widget build(BuildContext context) {

    print('isNeedingProviderFromRequestLog: $isNeedingProviderFromRequestLog');

    return Container(
      height: height * .9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
         children: <Widget>[
           Align(
               alignment: Alignment.topLeft,
               child: Padding(
                 padding: const EdgeInsets.only(bottom: 10.0, left: 5.0),
                 child: Text('${mProvider.length} Search Results found', style: TextStyle(fontWeight: FontWeight.w600),),
               )
           ),
           Expanded(
             child: ListView.builder(
                 itemCount: mProvider.length,
                 itemBuilder: (context, i) {
                   return GestureDetector(
                       onTap: () {
                         appSessionCallback.pauseAppSession();
                         if(isNeedingProviderFromRequestLog != null && isNeedingProviderFromRequestLog) {
                           Navigator.pop(context, mProvider[i]);
                         }
                       },
                       child: _getCard(mProvider[i], context)
                   );
                 }),
           ),
         ],
      ),
    );
  }

  String _formatDistance(String distance) => (double.parse(distance)).toStringAsFixed(2);

  void _openDialer(String contactNumber) {
    UrlLauncher.openPhone(contactNumber);
    appSessionCallback.pauseAppSession();
  }

  Widget _getCard(Provider provider, BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        side: new BorderSide(color: mPrimaryColor, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: Container(
          height: 200,
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Text(provider.hospitalName,
                            overflow: TextOverflow.ellipsis, maxLines: 2,
                            style: TextStyle(fontWeight: FontWeight.w600, ),)
                      ),
                      Text('${_formatDistance(provider.distance)} Km', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: width * .5,
                      child: InkWell(
                        onTap: () {
                          UrlLauncher.launchMaps(lat1: lat, lng1: lng, lat2: provider.latitude, lng2: provider.longitude, provider: provider);
                          appSessionCallback.pauseAppSession();
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Icon(Icons.pin_drop),
                            ),
                            Expanded(
                                child: Text(provider.address,
                                  overflow: TextOverflow.ellipsis, maxLines: 3,)
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        UrlLauncher.launchMaps(lat1: lat, lng1: lng, lat2: provider.latitude, lng2: provider.longitude, provider: provider);
                        appSessionCallback.pauseAppSession();
                      },
                      child: Row(
                        children: <Widget>[
                          Text('Get Directions', style: TextStyle(fontSize: 12.0)),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: width * .55,
                      child: InkWell(
                        onTap: () {
                          _openDialer(provider.contactNumber);
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Icon(Icons.phone),
                            ),
                            Expanded(
                              child: Text(provider.contactNumber != '' ? provider.contactNumber : 'N/A',
                                overflow: TextOverflow.ellipsis, maxLines: 3, style: TextStyle(fontSize: 12.0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _openDialer(provider.contactNumber);
                        },
                      child: Row(
                        children: <Widget>[
                          Text('Call Now', style: TextStyle(fontSize: 12.0),),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
