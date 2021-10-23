
import 'package:av_asian_life/data_manager/faq.dart';
import 'package:av_asian_life/data_manager/user.dart';

import '../mvp_base.dart';

abstract class IFaqModel extends IBaseModel{
  Future<List<Faq>> getFaq();
}

abstract class IFaqView extends IBaseView {
  void onSuccess(String message);
  void onError(String message);

}

abstract class IFaqPresenter extends IBasePresenter {
  Future<User> getUserData();
  Future<List<Faq>> initFaq();
}