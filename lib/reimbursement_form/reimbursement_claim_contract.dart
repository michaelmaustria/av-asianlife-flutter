
import 'package:av_asian_life/data_manager/availment.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/log_request.dart';
import 'package:av_asian_life/data_manager/log_response.dart';
import 'package:av_asian_life/data_manager/procedure.dart';
import 'package:av_asian_life/data_manager/provider.dart';
import 'package:av_asian_life/data_manager/user.dart';

import '../mvp_base.dart';

abstract class IReimburseModel extends IBaseModel{
  Future<List<Dependent>> getDependentsInfo(String cardNo);
}

abstract class IReimburseView extends IBaseView {
  void onSuccess(String message);
  void onError(String message);

}

abstract class IReimbursePresenter extends IBasePresenter {
  Future<User> getUserData();
  Future<List<Dependent>> initDependentsInfo(String cardNo);

  String validatePhoneNumber(String phone);

}