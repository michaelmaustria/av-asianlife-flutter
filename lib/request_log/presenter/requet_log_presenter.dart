
import 'package:av_asian_life/data_manager/availment.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/log_request.dart';
import 'package:av_asian_life/data_manager/log_response.dart';
import 'package:av_asian_life/data_manager/procedure.dart';
import 'package:av_asian_life/data_manager/provider.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/mvp_base.dart';
import 'package:av_asian_life/request_log/model/request_log_model.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:geolocator/geolocator.dart';

import '../request_log_contract.dart';

class RequestLogPresenter implements IRequestLogPresenter {

  IRequestLogView _requestLogView;
  IRequestLogModel _requestLogModel = RequestLogModel();

  Position _position1, _position2;
  String _gpsOn = '0';
  double _lat = 0;
  double _lng = 0;

  @override
  void onAttach(IBaseView view) {
    _requestLogView = view;
  }


  @override
  String validateComplaintText(String complaint) {
    return Common.validateInputLength(complaint);
  }


  @override
  String validatePhoneNumber(String phone) {
    return Common.phoneNumberValidator(phone);
  }

  @override
  void sendLogRequest(LogRequest request) async {
    LogResponse response = await _requestLogModel.postLogRequest(request);

    if(response.msgCode == '008')
      _requestLogView.onSuccess(response.msgDescription);
    else
      _requestLogView.onError(response.msgDescription);
  }

  @override
  Future<List<Provider>> initProviders() async {
    print('initAvailmentType');
    var isDone = await _getLocation();
    if(isDone)
      return _requestLogModel.getProviders(_lat, _lng, _gpsOn);
    else
      return null;
  }

  @override
  Future<List<Availment>> initAvailmentType(String availType) {
    print('initAvailmentType');
    return _requestLogModel.getAvailmentTypes(availType);
  }

  @override
  Future<User> getUserData() {
    MyPreferenceHandler _prefHandler = MyPreferenceHandler();
    return _prefHandler.getUserData();
  }

  Future<bool> _getLocation() async {
    print('_getLocation');
    bool isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    if(isLocationEnabled) _gpsOn = '1';
    else _gpsOn = '0';

    _position1 = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    _position2 = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _lat = _position1.latitude == _position2.latitude ? _position1.latitude : _position2.latitude;
    _lng = _position1.longitude == _position2.longitude ? _position1.longitude : _position2.longitude;

    print('Last Known = lat: ${_position1.latitude}, lng: ${_position1.longitude}, gps: $_gpsOn');
    print('Current = lat: ${_position2.latitude}, lng: ${_position2.longitude}, gps: $_gpsOn');

    if(_lng != null && _lng != null) return true;
    else return false;
  }

  @override
  Future<List<Dependent>> initDependentsInfo(String cardNo) {
    print('initDependentsInfo');
    return _requestLogModel.getDependentsInfo(cardNo);
  }

  @override
  Future<List<Procedure>> initProcedures(String cardNo, String providerID) {
    print('initProcedures');
    return _requestLogModel.getProcedures(cardNo, providerID);
  }




}