import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/city.dart';
import 'package:av_asian_life/data_manager/doctor.dart';
import 'package:av_asian_life/data_manager/province.dart';
import 'package:av_asian_life/data_manager/specialization.dart';
import 'package:av_asian_life/find_doctor/search_doctor_result.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/calculate_distance.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:menu_button/menu_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FindDoctorPage extends StatefulWidget {
  static String tag = 'find-doctor';
  final isNeedingDoctorFromRequestLog;
  final String provider;
  final IApplicationSession appSessionCallback;

  FindDoctorPage({this.isNeedingDoctorFromRequestLog, this.provider, this.appSessionCallback});

  @override
  _FindDoctorPageState createState() => _FindDoctorPageState();
}

class _FindDoctorPageState extends State<FindDoctorPage> {
  TextEditingController _controller = TextEditingController();

  static String _keyWord = '';
  static String _specialty = '';
  static String _hospitalid = '';
  static String _gpsOn = '0';
  static String _province = '';
  static String _city = '';
  static double _lat = 0;
  static double _lng = 0;

  bool _isNeedingDoctorFromRequestLog = false;
  bool isNearby = false;
  bool resultView = false;
  bool isVisible = false;
  bool isRefresh = false;

  bool _isClear = false;

  double searchResultPageHeight = 0;

  Future<List<Specialization>> _mSpecializations;
  Future<List<Doctor>> _mDoctors;
  Future<List<Province>> _mProvinces;
  Future<List<City>> _mCities;

  Position _position1, _position2;

  String _selectedSpecialization;
  String _selectedProvince;
  String _selectedCity;

  AlertDialog _loadingDialog;
  BuildContext _mContext;

  IApplicationSession _appSessionCallback;

  @override
  void initState() {
    super.initState();
    _appSessionCallback = widget.appSessionCallback;
    if(widget.isNeedingDoctorFromRequestLog != null)
      _isNeedingDoctorFromRequestLog = widget.isNeedingDoctorFromRequestLog;

    print('isNeedingDoctorFromRequestLog: $_isNeedingDoctorFromRequestLog');


    _getPermission().then((bool isPermitted){
      print('isPermitted: $isPermitted');
      if(!isPermitted)
        _showAlertDialog(_mContext);
      else
        _getLocation();
    });

    _mSpecializations = _fetchSpecialty();
    _mProvinces = _fetchProvince();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_isNeedingDoctorFromRequestLog && widget.provider != '')
        _initSearchDoctors();
    });
    if(_isNeedingDoctorFromRequestLog == false){
      Future.delayed(Duration.zero, () => newAlert());
    }
  }

  _initSearchDoctors(){
    setState(() {
      _mDoctors = _fetchDoctors();
    });
  }

  void _clearSearchQueries() {
    print('_clearSearchQueries');
    _keyWord = '';
    _specialty = '';
    _hospitalid = '';
    _province = '';
    //_gpsOn = '0';
    _city = '';
    _selectedSpecialization = null;
    _selectedProvince = null;
    _selectedCity = null;
    isNearby = false;
    _controller.clear();
  }

  Future<bool> _getPermission() async {
    PermissionStatus status = await PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse);
    print('status1: $status');

    if (status == PermissionStatus.granted) {
      _getLocation();
      return true;
    }else {
      Map<PermissionGroup, PermissionStatus> statuses = await PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse]);

      PermissionStatus status = statuses[PermissionGroup.locationWhenInUse];

      if(isNearby) {
        if (status != PermissionStatus.granted) {
          //open dialog prompting to redirect to settings...
          print('status: ${PermissionStatus.granted}');
          _showAlertDialog(_mContext);
        }
      }

      if(status == PermissionStatus.granted) {
        print('calling _getLocation');
        _getLocation();
        return true;
      } else return false;
    }
  }

  _getLocation() async {
    print('_getLocation');

    bool isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    print('_getLocation: $isLocationEnabled');
    if (isLocationEnabled) {
      _gpsOn = '1';

      _position1 = await Geolocator().getLastKnownPosition(
          desiredAccuracy: LocationAccuracy.high);
      _position2 = await Geolocator().getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _lat = (_position1?.latitude == _position2?.latitude) ? _position1?.latitude : _position2?.latitude;
      _lng = (_position1?.longitude == _position2?.longitude) ? _position1?.longitude : _position2?.longitude;


      print('Last Known = lat: ${_position1.latitude}, lng: ${_position1
          .longitude}, gps: $_gpsOn');
      print('Current = lat: ${_position2.latitude}, lng: ${_position2
          .longitude}, gps: $_gpsOn');
    }
    else
      _gpsOn = '0';


  }

  Future<List<Specialization>> _fetchSpecialty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetDoctorSpecialties';
    print(url);
    var res = await http.post(
        url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "hospitalID" : ""
      }
    );
    var json = jsonDecode(jsonDecode(res.body));
    List<Specialization> data = [];
    json.forEach((entity) {
      data.add(Specialization.fromJson(entity));
    });


    return data;
  }

  Future<List<Province>> _fetchProvince() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetProvinces';
    var res = await http.post(
        url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass
      }
    );
    var json = jsonDecode(jsonDecode(res.body));

    List<Province> data = [];
    json.forEach((entity) {
      data.add(Province.fromJson(entity));
    });

    isNearby = false;
    return data;
  }

  Future<List<City>> _fetchCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    isNearby = false;
    String url = '${_base_url}GetCities';
    var res = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "province" : _province
      }
    );
    var json = jsonDecode(jsonDecode(res.body));

    List<City> data = [];
    json.forEach((entity) {
      data.add(City.fromJson(entity));
    });
    isRefresh = true;

    return data;
  }

  Future<List<Doctor>> _fetchDoctors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    _showLoadingDialog();
    resultView = true;

    if (_isNeedingDoctorFromRequestLog) {
      if (widget.provider != null)
        _hospitalid = widget.provider;
    }

    print('_hospitalid: $_hospitalid');

    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetDoctors';
    print('URL: $url');

    List<Doctor> data = [];
    try{
      var res = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": _email
        },
        body: {
          "userid" : _api_user.toString(),
          "password" : _api_pass.toString(),
          "hospitalid" : _hospitalid.toString(),
          "specialty" : _specialty.toString(),
          "keyword" : _keyWord.toString(),
          "latitude" : _lat.toString(),
          "longitude" : _lng.toString(),
          "gpson" : _gpsOn.toString(),
          "province" : _province.toString(),
          "city" : _city.toString()
        }
      );
      var json = jsonDecode(jsonDecode(res.body));

      json.forEach((entity) {
        data.add(Doctor.fromJson(entity));
      });

      print('Doctor: ${data.length}');
    }catch (e) {
      print('HTTP ERROR');
      print(e);
    }



    setState(() {
      _isClear = false;
    });
    _closeAlert();
    if(_isNeedingDoctorFromRequestLog){
      Future.delayed(Duration.zero, () => newAlert());
    }
    return data;
  }

  SearchDoctorResultPage _getNearby(List<Doctor> doctor, double searchResultPageHeight, double width) {
    int len = 0;
    List<Doctor> nearest = [];
    for(Doctor item in doctor){
      double distance = CalculateDistance.calculateDistance(_lat, _lng, item.latitude, item.longitude);
      //print('Distance: $distance');
      if(distance <= 10.0){
        nearest.add(item);
        len++;
        //print('nearest item #$len added');
      }
      if(len == 20) {
        //print('max items reached');
        break;
      }
    }

    print(nearest.length);
    SearchDoctorResultPage result = SearchDoctorResultPage(
      mDoctor: nearest,
      height: searchResultPageHeight,
      width: width,
      lat: _lat,
      lng: _lng,
      isNeedingDoctorFromRequestLog: _isNeedingDoctorFromRequestLog,
      appSessionCallback: _appSessionCallback,
    );

    return result;
  }

  _initSearchNearbyDoctors() async {

    print('_initSearchNearbyDoctors');

    bool isPermitted = await _getPermission();

    if(isPermitted)
      _initSearchDoctors();
    else
      print('Location Permiison Not Granted');
  }

  void _showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text('Message'),
      content: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text('Open settings to activate your location services?'),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK", style: TextStyle(color: Colors.black87),),
          onPressed: () {
            setState(() {
              Navigator.of(context).pop('dialog');
              AppSettings.openLocationSettings();
              _getLocation();
            });
          },
        ),
        FlatButton(
          child: Text("Cancel", style: TextStyle(color: Colors.black54)),
          onPressed: () {
            setState(() {
              Navigator.of(context).pop('dialog');
            });
          },
        )
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showDialog() {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Message'),
      content: Text('Please choose doctor\'s specialization. Then press Nearby again.'),
      actions: <Widget>[
        FlatButton(
          child: Text("Confirm", style: TextStyle(color: Colors.black45),),
          onPressed: () {
            setState(() {
              Navigator.of(this.context).pop('dialog');
            });
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _clearSearchQueries();
  }

  @override
  Widget build(BuildContext context) {
    _mContext = context;
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Find Doctors'),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          flexibleSpace: Image(
            image:  AssetImage('assets/images/appBar_background.png'),
            fit: BoxFit.fill,),
        ),
        body: _getBody(),
      ),
    );
  }

  Widget _getBody() {
    return LayoutBuilder(builder: (context, constraint) {
      final height = constraint.maxHeight;
      final width = constraint.maxWidth;
      double advSearchButtonHeight = height * .15;
      double searchResultPageHeightInit = height * .75;
      double searchResultPageHeightOnExpand = searchResultPageHeightInit - advSearchButtonHeight;
      if(isVisible){
        searchResultPageHeight = searchResultPageHeightOnExpand;
      }else {
        searchResultPageHeight = searchResultPageHeightInit;
      }
      return SafeArea(
        top: false,
        bottom: true,
        child: Container(
          padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: width * .80,
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            style: TextStyle(fontSize: 15.0),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              border: OutlineInputBorder(),
                              hintText: "Search...",
                              labelText: "Search by: Doctor Name",
                            ),
                            onSubmitted: (searchKeyWord) {
                              _keyWord = '';
                              _keyWord = searchKeyWord;
                              if(_keyWord != '')
                                _initSearchDoctors();
                            },
                            onChanged: (searchKeyWord){
                              _keyWord = searchKeyWord;
                              //print(searchKeyWord);
                            },
                            onTap: () {
                              _appSessionCallback.pauseAppSession();
                              setState(() {
                                if(isVisible){
                                  searchResultPageHeight = searchResultPageHeightOnExpand;
                                }else {
                                  searchResultPageHeight = searchResultPageHeightInit;
                                }
                              });
                            },
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _appSessionCallback.pauseAppSession();
                            setState(() {
                              isNearby = true;
                              _controller.clear();
                            });

                            if(_specialty == null || _specialty == ''){
                              _showDialog();
                            }else {
                              _initSearchNearbyDoctors();
                            }
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.pin_drop,
                                size: 30.0,
                                color: Colors.black87,
                              ),
                              Text(
                                'Nearby',
                                style: TextStyle(fontSize: 12.0),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    SizedBox(
                      height: advSearchButtonHeight * .40,
                      child: RaisedButton(
                        elevation: 1.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: FutureBuilder<List<Specialization>>(
                          future: _mSpecializations,
                          builder: (BuildContext context, AsyncSnapshot<List<Specialization>> snapshot){
                            if(!snapshot.hasData)
                              return _dropDownDisabledHolder('Specialization');
                            else
                              return _getSpecialtyDropdown(snapshot.data);
                          },
                        ),
                        onPressed: () {
                          _appSessionCallback.pauseAppSession();
                        },
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            height: 50.0,
                            width: width * .45,
                            child: RaisedButton(
                              padding: EdgeInsets.all(12),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                Text('Advanced Search', style: TextStyle(fontSize: 13.5 ,color: Colors.black87),),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 28.0,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                              onPressed:  () {
                                setState(() {
                                  isVisible = !isVisible;
                                  if(isVisible){
                                    searchResultPageHeight = searchResultPageHeightOnExpand;
                                  }else {
                                    searchResultPageHeight = searchResultPageHeightInit;
                                  }
                                });
                                _appSessionCallback.pauseAppSession();
                              },
                            ),
                          ),

                          SizedBox(
                            height: 50.0,
                            width: width * .45,
                            child: RaisedButton(
                              padding: EdgeInsets.all(12),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text('Clear Search', style: TextStyle(fontSize: 13.5 ,color: Colors.black87),),
                                  Icon(
                                    Icons.clear,
                                    size: 20.0,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                              onPressed:  () {
                                setState(() {
                                  _clearSearchQueries();
                                  _isClear = true;
                                });
                                _appSessionCallback.pauseAppSession();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isVisible ? 1 : 0,
                      duration: Duration(milliseconds: 300),
                      child: Visibility(
                        visible: isVisible,
                        child: Container(
                          height: advSearchButtonHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              SizedBox(
                                height: advSearchButtonHeight * .40,
                                child: RaisedButton(
                                  elevation: 1.0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  child: FutureBuilder<List<Province>>(
                                    future: _mProvinces,
                                    builder: (BuildContext context, AsyncSnapshot<List<Province>> snapshot){
                                      if(!snapshot.hasData)
                                        return _dropDownDisabledHolder('Province');
                                      else
                                        return _getProvinceDropdown(snapshot.data);
                                    },
                                  ),
                                  onPressed: () { _appSessionCallback.pauseAppSession(); },
                                ),
                              ),
                              SizedBox(
                                height: advSearchButtonHeight * .40,
                                child: RaisedButton(
                                  elevation: 1.0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  child: FutureBuilder<List<City>>(
                                    future: _mCities,
                                    builder: (BuildContext context, AsyncSnapshot<List<City>> snapshot){
                                      if(!snapshot.hasData)
                                        return _dropDownDisabledHolder('City');
                                      else
                                        if(isRefresh == false)
                                        return _dropDownDisabledHolder('City');
                                        else
                                        return _getCityDropdown(snapshot.data);
                                    },
                                  ),
                                  onPressed: () { _appSessionCallback.pauseAppSession(); },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Visibility(
                        visible: resultView,
                        child: _getStreamBuilder(height, width),
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      color: Colors.white,
                      height: 20,
                      width: width,
                      child: Align(alignment: Alignment.center,child: copyRightText())
                  )
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _getProvinceDropdown(List<Province> provinces){
    List<String> dropDownItems = [''];
    dropDownItems.clear();
    provinces.forEach((cat) {
      dropDownItems.add(cat.province);
    });

    final Widget button = SizedBox(
         width: double.infinity,
         height: 40,
         child: Padding(
           padding: const EdgeInsets.only(right: 16),
           child: Stack(
             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
               Align(
                 alignment: Alignment.center,
                 child: Container(
                 child: Text(_province == '' ? 'Province' : _province, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)
              ),
             )
           ),
           Align(
             alignment: Alignment.centerRight,
             child: Container(
               child: Icon(
                 Icons.keyboard_arrow_down,
                 color: Colors.black,)
             )
           )
         ],
       ),
     ),
   );


    return MenuButton(
      popupHeight: 400,
      child: button,
      items: dropDownItems,
      topDivider: true,
      //crossTheEdge: true,
      scrollPhysics: AlwaysScrollableScrollPhysics(),
      dontShowTheSameItemSelected: false,
      // Use edge margin when you want the menu button don't touch in the edges
      edgeMargin: 12,
      itemBuilder: (value) => Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
        child: Align(
          alignment: Alignment.center,
            child: Container(
              child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)
              ),
            )
        ),
      ),
      toggledChild: Container(
        color: Colors.white,
        child: button,
      ),
      divider: Container(
        height: 1,
        color: Colors.white,
      ),
      onItemSelected: (newValue) {
        _appSessionCallback.pauseAppSession();
        setState(() {
           _selectedProvince = newValue;
          _province = _selectedProvince;
          _selectedCity = null;
          _city = 'City';
          isRefresh = false;
          _mCities = _fetchCity();
        });
        _appSessionCallback.pauseAppSession();
      },
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: const BorderRadius.all(
          Radius.circular(3.0),
        ),
        color: Colors.white),
      onMenuButtonToggle: (isToggle) {
        print(isToggle);
      },
     );
    // return SizedBox(
    //   width: double.infinity,
    //   child: DropdownButtonHideUnderline(
    //     child: DropdownButton(
    //       hint: SizedBox(
    //           width: double.infinity,
    //           child: Text('Province', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),)
    //       ),
    //       icon: Icon(Icons.keyboard_arrow_down),
    //       isExpanded: true,
    //       value: _selectedProvince,
    //       onChanged: (newValue) {
    //         setState(() {
    //           _selectedProvince = newValue;
    //           _province = _selectedProvince;
    //           _selectedCity = null;
    //           isRefresh = true;
    //           _mCities = _fetchCity();
    //         });
    //         _appSessionCallback.pauseAppSession();
    //       },
    //       items: dropDownItems.map((value) => DropdownMenuItem(
    //         child: SizedBox(
    //           width: double.infinity, // for example
    //           child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0, color: Colors.black54),),
    //         ),
    //         value: value,
    //       )).toList(),
    //     ),
    //   ),
    // );
  }

  Widget _getCityDropdown(List<City> cities){
    List<String> dropDownItems = [];
    cities?.forEach((cat) {
      dropDownItems.add(cat.city);
    });

    final Widget button = SizedBox(
         width: double.infinity,
         height: 40,
         child: Padding(
           padding: const EdgeInsets.only(right: 16),
           child: Stack(
             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
               Align(
                 alignment: Alignment.center,
                 child: Container(
                 child: Text(_city, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)
              ),
             )
           ),
           Align(
             alignment: Alignment.centerRight,
             child: Container(
               child: Icon(
                 Icons.keyboard_arrow_down,
                 color: Colors.black,)
             )
           )
         ],
       ),
     ),
   );


    return MenuButton(
      popupHeight: 350,
      child: button,
      items: dropDownItems,
      topDivider: true,
      //crossTheEdge: true,
      scrollPhysics: AlwaysScrollableScrollPhysics(),
      dontShowTheSameItemSelected: false,
      // Use edge margin when you want the menu button don't touch in the edges
      edgeMargin: 12,
      itemBuilder: (value) => Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
        child: Align(
          alignment: Alignment.center,
            child: Container(
              child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)
              ),
            )
        ),
      ),
      toggledChild: Container(
        color: Colors.white,
        child: button,
      ),
      divider: Container(
        height: 1,
        color: Colors.white,
      ),
      onItemSelected: (newValue) {
        _appSessionCallback.pauseAppSession();
        setState(() {
          _mDoctors = null;
          _selectedCity = newValue;
          _city = _selectedCity;
        });
        _initSearchDoctors();
        _appSessionCallback.pauseAppSession();
      },
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: const BorderRadius.all(
          Radius.circular(3.0),
        ),
        color: Colors.white),
      onMenuButtonToggle: (isToggle) {
        print(isToggle);
      },
     );

    // return SizedBox(
    //   width: double.infinity,
    //   child: DropdownButtonHideUnderline(
    //     child: DropdownButton(
    //       hint: SizedBox(
    //           width: double.infinity,
    //           child: Text('City', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),)
    //       ),
    //       icon: Icon(Icons.keyboard_arrow_down),
    //       isExpanded: true,
    //       value: _selectedCity,
    //       onChanged: (newValue) {
    //         setState(() {
    //           _mDoctors =  null;
    //           _selectedCity = newValue;
    //           _city = _selectedCity;

    //         });
    //         _initSearchDoctors();
    //         _appSessionCallback.pauseAppSession();
    //       },
    //       items: dropDownItems.map((value) => DropdownMenuItem(
    //         child: SizedBox(
    //           width: double.infinity, // for example
    //           child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0, color: Colors.black54),),
    //         ),
    //         value: value,
    //       )).toList(),
    //     ),
    //   ),
    // );

  }

  Widget _getSpecialtyDropdown(List<Specialization> specialty){
    List<String> dropDownItems = [];
    specialty.forEach((spc) {
      dropDownItems.add(toBeginningOfSentenceCase(spc.specialty.toLowerCase()));
    });

    final Widget button = SizedBox(
         width: double.infinity,
         height: 40,
         child: Padding(
           padding: const EdgeInsets.only(right: 16),
           child: Stack(
             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
               Align(
                 alignment: Alignment.center,
                 child: Container(
                 child: Text(_specialty == '' ? 'Specialization' : _specialty, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)
              ),
             )
           ),
           Align(
             alignment: Alignment.centerRight,
             child: Container(
               child: Icon(
                 Icons.keyboard_arrow_down,
                 color: Colors.black,)
             )
           )
         ],
       ),
     ),
   );


    return MenuButton(
      child: button,
      items: dropDownItems,
      topDivider: true,
      crossTheEdge: true,
      scrollPhysics: AlwaysScrollableScrollPhysics(),
      dontShowTheSameItemSelected: false,
      // Use edge margin when you want the menu button don't touch in the edges
      edgeMargin: 12,
      itemBuilder: (value) => Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
        child: Align(
          alignment: Alignment.center,
            child: Container(
              child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)
              ),
            )
        ),
      ),
      toggledChild: Container(
        color: Colors.white,
        child: button,
      ),
      divider: Container(
        height: 1,
        color: Colors.white,
      ),
      onItemSelected: (newValue) {
        _appSessionCallback.pauseAppSession();
        setState(() {
          _selectedSpecialization = newValue;
          _specialty = _selectedSpecialization;
          print('isNearby: $isNearby');
        });
        _appSessionCallback.pauseAppSession();
      },
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: const BorderRadius.all(
          Radius.circular(3.0),
        ),
        color: Colors.white),
      onMenuButtonToggle: (isToggle) {
        print(isToggle);
      },
     );

//     return SizedBox(
//       width: double.infinity,
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton(
//           hint: SizedBox(
//               width: double.infinity,
//               child: Text('Specialization', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),)
//           ),
//           icon: Icon(Icons.keyboard_arrow_down),
//           isExpanded: true,
//           value: _selectedSpecialization,
//           onChanged: (newValue) {
//             setState(() {
//               _selectedSpecialization = newValue;
//               _specialty = _selectedSpecialization;
//               print('isNearby: $isNearby');
// //              if(!isNearby){
// //                print('_initSearchDoctors: onDropdown');
// //                _initSearchDoctors();
// //              }
//             });
//             _appSessionCallback.pauseAppSession();
//           },
//           items: dropDownItems.map((value) => DropdownMenuItem(
//             child: SizedBox(
//               width: double.infinity, // for example
//               child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0, color: Colors.black54),),
//             ),
//             value: value,
//           )).toList(),
//         ),
//       ),
//     );

  }

  Widget _dropDownDisabledHolder(String text) {
    return SizedBox(
        width: double.infinity,
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),)
    );
  }

  void _showLoadingDialog() {
    // set up the AlertDialog
    _loadingDialog = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      contentPadding: EdgeInsets.all(0.0),
      content: myLoadingIcon(height: 125, width: 20),
    );

    // show the dialog
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _loadingDialog;
      },
    );

  }

  void _closeAlert() {
    Navigator.of(context).pop('dialog');//it will close last route in your navigator
  }

  Widget _getDoctorFutureBuilder(double height, double width) {
    return FutureBuilder<List<Doctor>>(
      future: _mDoctors,
      builder: (BuildContext context, AsyncSnapshot<List<Doctor>> snapshot){
        if(!snapshot.hasData) {
          return Container();
        }else {
          if(!isNearby)
            return SearchDoctorResultPage(
              mDoctor: snapshot.data,
              height: searchResultPageHeight,
              width: width,
              lat: _lat,
              lng: _lng,
              isNeedingDoctorFromRequestLog: _isNeedingDoctorFromRequestLog,
              appSessionCallback: _appSessionCallback,
            );
          else return _getNearby(snapshot.data, searchResultPageHeight, width);
        }
      },
    );
  }

  Stream<bool> _clearQueryData() async* {
    print('_clearQueryData: $_isClear');
    yield _isClear;
  }

  Widget _getStreamBuilder(double height, double width) {
    return StreamBuilder<bool>(
        stream: _clearQueryData(),
        builder: (context, snapshot) {
          print('StreamBuilder: ${snapshot?.data}');
          if(snapshot.hasData) {
            if(snapshot.data)
              return Container();
            else
              return _getDoctorFutureBuilder(height, width);
          } else {
            return Container();
          }

        }
    );
  }

  Widget _newAlert(BuildContext context,) {
    final _height = MediaQuery.of(context).size.height;
    context = this.context;
    return Container(
    padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: SafeArea(
        child: Stack(children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Column(children: <Widget>[
              SizedBox(height: 70),
              Container(
                child:Card(
                shape: new RoundedRectangleBorder(
                   borderRadius: new BorderRadius.circular(10.0),
                   side: BorderSide(color: Colors.black)
                ),
                color: Colors.yellow[600],
                child: Stack(
                  children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 15, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close),
                )),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(15, 25, 10, 0),
                  child: Text('REMINDERS:'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              children: <Widget>[
                Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.fromLTRB(15, 50, 10, 0),
                    child: Text(
                        '1) The Hospitals, Clinics, and Physicians accreditation may change from time to time.')
                ),
                Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                    child: Text(
                        '2) You can call the hospital or clinic or physician for verification and inquiries.')
                ),
                Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                    child:
                        Text('3) The list contains confidential information.'),
                ),
                Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                    child: Text(
                        '4) Any unauthorized copying or distribution of the list is strictly prohibited.')
                ),
                Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.fromLTRB(15, 10, 10, 20),
                    child: Text(
                        '5) If call doctor is not supported by device, you can copy the telephone number and paste it into your device\'s dialer.')
                )
              ],
            ),
          ),
        ])))
            ],)
          )
        ],),
      )
      );
  }

  void newAlert() {
    Navigator.of(context).push(
      PageRouteBuilder(
          pageBuilder: (context, _, __) => _newAlert(context), opaque: false),
    );
  }
}
