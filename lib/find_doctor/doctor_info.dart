import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/doctor.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DoctorInfoPage extends StatefulWidget {
  final double lat, lng;
  final Doctor mDoctor;
  final bool isNeedingDoctorFromRequestLog;
  final IApplicationSession appSessionCallback;

  DoctorInfoPage({this.lat, this.lng, this.mDoctor, this.isNeedingDoctorFromRequestLog, this.appSessionCallback});


  @override
  _DoctorInfoPageState createState() => _DoctorInfoPageState();
}

class _DoctorInfoPageState extends State<DoctorInfoPage> {

  double height, width;
  Future<List<Doctor>> _mDoctorInfo;

  IApplicationSession _appSessionCallback;

  static String _keyWord = '';
  static String _specialty = '';
  static String _hospitalid = '';
  static String _gpsOn = '1';
  static String _province = '';
  static String _city = '';
  static double _lat = 0;
  static double _lng = 0;

  bool _isNeedingDoctorFromRequestLog = false;

  @override
  void initState() {
    super.initState();
    _appSessionCallback = widget.appSessionCallback;
    if(widget.isNeedingDoctorFromRequestLog != null)
      _isNeedingDoctorFromRequestLog = widget.isNeedingDoctorFromRequestLog;

    print('isNeedingDoctorFromRequestLog from Info: $_isNeedingDoctorFromRequestLog');

    setState(() {
      _keyWord = widget.mDoctor.doctor;
      _lat = widget.lat;
      _lng = widget.lng;
      _mDoctorInfo  =_fetchDoctors();
    });


  }

  Future<List<Doctor>> _fetchDoctors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetDoctors';
    print('URL: $url');
    var res = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "hospitalid" : _hospitalid,
        "specialty" : _specialty,
        "keyword" : _keyWord,
        "latitude" : _lat,
        "longitude" : _lng,
        "gpson" : _gpsOn,
        "province" : _province,
        "city" : _city
      }
    );
    var json = jsonDecode(jsonDecode(res.body));

    List<Doctor> data = [];
    print('test');
    json.forEach((entity) {
      print(entity);
      data.add(Doctor.fromJson(entity));
    });

    print(data[0].doctor);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    print(widget.mDoctor.docId + widget.mDoctor.address);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 150, horizontal: 15),
        child: Hero(
          tag: widget.mDoctor.docId + widget.mDoctor.address,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              side: new BorderSide(color: mPrimaryColor, width: 1.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Dr. ${widget.mDoctor.doctor}', overflow: TextOverflow.ellipsis, maxLines: 1,),
                                  Text('Specialist on: ${widget.mDoctor.specialty}', style: TextStyle(fontSize: 10.0),
                                    overflow: TextOverflow.ellipsis, maxLines: 1,),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.clear, color: mPrimaryColor,),
                                onPressed: () {
                                  _appSessionCallback.pauseAppSession();
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        )),
                    FutureBuilder<List<Doctor>>(
                      future: _mDoctorInfo,
                      builder: (BuildContext context, AsyncSnapshot<List<Doctor>> snapshot){
                        if(!snapshot.hasData)
                          return Expanded(child: Center(child: myLoadingIcon(height: height * .30, width: width * .25)));
                        else {
                          return Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, i) {
                                  return GestureDetector(
                                    onTap: () {
                                      _appSessionCallback.pauseAppSession();
                                      if(_isNeedingDoctorFromRequestLog != null && _isNeedingDoctorFromRequestLog) {
                                        print('Card tapped');
                                        Navigator.pop(context, snapshot.data[i]);
                                      }
                                    },
                                      child: _getDoctorInfo(snapshot.data[i], context));
                                }),
                          );
                        }
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(height: 15.0),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),),
    );
  }

  Widget _getDoctorInfo(Doctor doctor, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              color: mPrimaryColor,
              height: 1,
              width: width,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(doctor.hospitalName, style: TextStyle(fontSize: 10.0),
                    overflow: TextOverflow.ellipsis, maxLines: 2,),
                ),
                Align(alignment: Alignment.topRight, child: Text('${_formatDistance(doctor.distance)} Km', style: TextStyle(fontSize: 11))),
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
                    UrlLauncher.launchMaps(lat1: _lat, lng1: _lng, lat2: doctor.latitude, lng2: doctor.longitude, doctor: doctor);
                    _appSessionCallback.pauseAppSession();
                  },
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Icon(Icons.pin_drop),
                      ),
                      Expanded(
                          child: Text(doctor.address,
                            overflow: TextOverflow.ellipsis, maxLines: 3,)
                      ),
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
                          UrlLauncher.launchMaps(lat1: _lat, lng1: _lng, lat2: doctor.latitude, lng2: doctor.longitude, doctor: doctor);
                          _appSessionCallback.pauseAppSession();
                        },
                        child: Row(
                          children: <Widget>[
                            Text('Get Directions', style: TextStyle(fontSize: 12.0),),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                          child: Text(doctor.contactNumber != '' ? doctor.contactNumber : 'N/A',
                              overflow: TextOverflow.ellipsis, maxLines: 3, style: TextStyle(fontSize: 12.0)),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _openDialer(doctor.contactNumber);
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
          ),

        ],
      ),
    );
  }

  void  _openDialer(String contactNumber) {
    UrlLauncher.openPhone(contactNumber);
    _appSessionCallback.pauseAppSession();
  }

  String _formatDistance(String distance) => (double.parse(distance)).toStringAsFixed(2);
}

