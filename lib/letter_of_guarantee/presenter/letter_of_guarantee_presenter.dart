
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/letter_of_guarantee/model/letter_of_guarantee_model.dart';
import 'package:av_asian_life/mvp_base.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';

import '../letter_of_guarantee_contract.dart';

class LetterOfGuaranteePresenter implements ILetterOfGuaranteePresenter {

  ILetterOfGuaranteeModel _guaranteeModel = LetterOfGuaranteeModel();
  ILetterOfGuaranteeView _guaranteeView;

  @override
  void onAttach(IBaseView view) {
    print('onAttach: LetterOfGuaranteePresenter');
    _guaranteeView = view;
  }

  @override
  Future<User> getUserData() {
    MyPreferenceHandler _prefHandler = MyPreferenceHandler();
    return _prefHandler.getUserData();
  }

  @override
  Future<List<Requests>> initLogHistory(User user, String availType) {
    return _guaranteeModel.getLogHistory(user, availType);
  }


}