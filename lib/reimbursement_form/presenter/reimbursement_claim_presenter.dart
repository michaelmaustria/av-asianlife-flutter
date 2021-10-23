
import 'package:av_asian_life/data_manager/availment.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/log_request.dart';
import 'package:av_asian_life/data_manager/log_response.dart';
import 'package:av_asian_life/data_manager/procedure.dart';
import 'package:av_asian_life/data_manager/provider.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/mvp_base.dart';
import 'package:av_asian_life/reimbursement_form/model/reimbursement_model.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:geolocator/geolocator.dart';

import '../reimbursement_claim_contract.dart';

class ReimbursePresenter implements IReimbursePresenter {

  IReimburseView _requestLogView;
  IReimburseModel _requestLogModel = ReimburseModel();

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

}