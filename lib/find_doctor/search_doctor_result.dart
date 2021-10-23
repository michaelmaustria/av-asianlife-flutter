import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/doctor.dart';
import 'package:av_asian_life/find_doctor/doctor_info.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/utility/url_launcher.dart';
import 'package:flutter/material.dart';

class SearchDoctorResultPage extends StatelessWidget {
  final double height, width;
  final double lat, lng;
  final List<Doctor> mDoctor;
  final isNeedingDoctorFromRequestLog;
  final IApplicationSession appSessionCallback;

  SearchDoctorResultPage({this.height, this.width, this.mDoctor, this.lat, this.lng, this.isNeedingDoctorFromRequestLog, this.appSessionCallback});

  @override
  Widget build(BuildContext context) {

    print('isNeedingDoctorFromRequestLog: $isNeedingDoctorFromRequestLog');

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
                child: Text('${mDoctor.length} Search Results found',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )),
          Expanded(
            child: ListView.builder(
                itemCount: mDoctor.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                      onTap: () {
                        appSessionCallback.pauseAppSession();
                        if(isNeedingDoctorFromRequestLog != null && isNeedingDoctorFromRequestLog) {
                          //print('Card tapped');
                          Navigator.pop(context, mDoctor[i]);
                        }
                      },
                      child: _getCard(mDoctor[i], context)
                  );
                }),
          ),
        ],
      ),
    );
  }

  String _formatDistance(String distance) =>
      (double.parse(distance)).toStringAsFixed(2);


  void _openDialer(String contactNumber) {
    UrlLauncher.openPhone(contactNumber);
    appSessionCallback.pauseAppSession();
  }

  Widget _getCard(Doctor doctor, BuildContext context) {
    //print(doctor.docId + doctor.address);
    return Hero(
      tag: doctor.docId + doctor.address,
      child: Card(
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
                        Container(
                          width: width * .60,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Dr. ${doctor.doctor}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              Text(
                                'Specialist on: ${doctor.specialty}',
                                style: TextStyle(fontSize: 10.0),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.topRight,
                            child:
                                Text('${_formatDistance(doctor.distance)} Km', style: TextStyle(fontSize: 11),)),
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
                            UrlLauncher.launchMaps(lat1: lat, lng1: lng, lat2: doctor.latitude, lng2: doctor.longitude, doctor: doctor);
                          },
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Icon(Icons.pin_drop),
                              ),
                              Expanded(
                                  child: Text(
                                doctor.address,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              )),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  UrlLauncher.launchMaps(lat1: lat, lng1: lng, lat2: doctor.latitude, lng2: doctor.longitude, doctor: doctor);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Get Directions',
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                    Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if(isNeedingDoctorFromRequestLog != null && isNeedingDoctorFromRequestLog) {
                                    _waitForDoctorInfo(context, doctor);
                                  }else{
                                    Navigator.of(context).push(
                                        PageRouteBuilder(
                                            opaque: false,
                                            barrierDismissible: true,
                                            pageBuilder: (BuildContext context, _, __) {
                                              return DoctorInfoPage(lat: lat, lng: lng, mDoctor: doctor,
                                                isNeedingDoctorFromRequestLog: isNeedingDoctorFromRequestLog,
                                                appSessionCallback: appSessionCallback,
                                              );
                                            })
                                    );
                                  }
                                  appSessionCallback.pauseAppSession();
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text('View all', style: TextStyle(fontSize: 12.0),),
                                    Icon(Icons.chevron_right),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: width * .55,
                          child: InkWell(
                            onTap: () {
                              _openDialer(doctor.contactNumber);
                              },
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: Icon(Icons.phone),
                                ),
                                Expanded(
                                  child: Text(
                                      doctor.contactNumber != ''
                                          ? doctor.contactNumber
                                          : 'N/A',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(fontSize: 12.0)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: InkWell(
                            onTap: () {
                              _openDialer(doctor.contactNumber);
                              },
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Call Now',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _waitForDoctorInfo(BuildContext context, Doctor doctor) async {
    Doctor result = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return DoctorInfoPage(lat: lat, lng: lng, mDoctor: doctor, isNeedingDoctorFromRequestLog: isNeedingDoctorFromRequestLog, appSessionCallback: appSessionCallback,);
        }));

    Navigator.pop(context, result);
  }
}
