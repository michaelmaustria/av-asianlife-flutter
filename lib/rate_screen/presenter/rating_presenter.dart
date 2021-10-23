
import 'package:av_asian_life/data_manager/rate_request.dart';
import 'package:av_asian_life/data_manager/rate_response.dart';
import 'package:av_asian_life/rate_screen/model/rating_model.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/mvp_base.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';

import '../rating_contract.dart';

class RatePresenter implements IRatePresenter {

  IRateModel _rateModel = RateModel();
  IRateView _rateView;

  @override
  void onAttach(IBaseView view) {
    print('onAttach: LetterOfGuaranteePresenter');
    _rateView = view;
  }

  @override
  Future<User> getUserData() {
    MyPreferenceHandler _prefHandler = MyPreferenceHandler();
    return _prefHandler.getUserData();
  }


  @override
  void postRating(RateRequest request) async {
    RateResponse response = await _rateModel.postRate(request);

    if(response.msgDescription == 'Request successfully posted')
      _rateView.onSuccess(response.msgDescription);
    else
      _rateView.onError(response.msgDescription);
  }

}