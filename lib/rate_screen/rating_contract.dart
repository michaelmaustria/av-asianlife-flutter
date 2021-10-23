
import 'package:av_asian_life/data_manager/faq.dart';
import 'package:av_asian_life/data_manager/rate_request.dart';
import 'package:av_asian_life/data_manager/rate_response.dart';
import 'package:av_asian_life/data_manager/user.dart';

import '../mvp_base.dart';

abstract class IRateModel extends IBaseModel{
  Future<RateResponse> postRate(RateRequest request);
}

abstract class IRateView extends IBaseView {
  void onSuccess(String message);
  void onError(String message);

}

abstract class IRatePresenter extends IBasePresenter {
  Future<User> getUserData();
  void postRating(RateRequest request);
}