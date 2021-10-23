
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/data_manager/user.dart';

import '../mvp_base.dart';

abstract class ILetterOfGuaranteeModel extends IBaseModel{
  Future<List<Requests>> getLogHistory(User user, String availType);
}

abstract class ILetterOfGuaranteeView extends IBaseView {
  void onSuccess(String message);
  void onError(String message);

}

abstract class ILetterOfGuaranteePresenter extends IBasePresenter {
  Future<User> getUserData();
  Future<List<Requests>> initLogHistory(User user, String availType);
}