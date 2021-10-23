
import 'package:av_asian_life/data_manager/availment.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/log_request.dart';
import 'package:av_asian_life/data_manager/log_response.dart';
import 'package:av_asian_life/data_manager/procedure.dart';
import 'package:av_asian_life/data_manager/provider.dart';
import 'package:av_asian_life/data_manager/user.dart';

import '../mvp_base.dart';

abstract class IRequestLogModel extends IBaseModel{
  Future<LogResponse> postLogRequest(LogRequest request);
  Future<List<Availment>> getAvailmentTypes(String availType);
  Future<List<Provider>> getProviders(double lat, double lng, String gpsOn);
  Future<List<Dependent>> getDependentsInfo(String cardNo);
  Future<List<Procedure>> getProcedures(String cardNo, String providerID);
}

abstract class IRequestLogView extends IBaseView {
  void onSuccess(String message);
  void onError(String message);

}

abstract class IRequestLogPresenter extends IBasePresenter {
  Future<User> getUserData();
  Future<List<Availment>> initAvailmentType(String availType);
  Future<List<Provider>> initProviders();
  Future<List<Dependent>> initDependentsInfo(String cardNo);
  Future<List<Procedure>> initProcedures(String cardNo, String providerID);
  void sendLogRequest(LogRequest request);

  String validateComplaintText(String complaint);
  String validatePhoneNumber(String phone);

}